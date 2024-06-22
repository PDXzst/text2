#include <ros/ros.h>
#include <nav_msgs/Path.h>
#include <geometry_msgs/Twist.h>
#include <tf2/LinearMath/Quaternion.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

ros::Publisher velocity_pub;

void pathCallback(const nav_msgs::Path::ConstPtr& path_msg) {
    if (path_msg->poses.size() < 2) {
        //ROS_WARN("Not enough poses in path to calculate velocity.");
        return;
    }

    const auto& pose1 = path_msg->poses[path_msg->poses.size() - 2];
    const auto& pose2 = path_msg->poses.back();

    double dt = (pose2.header.stamp - pose1.header.stamp).toSec();

    if (dt <= 0) {
        //ROS_WARN("Non-positive time difference between poses.");
        return;
    }

    // 计算线速度
    double dx = pose2.pose.position.x - pose1.pose.position.x;
    double dy = pose2.pose.position.y - pose1.pose.position.y;
    double dz = pose2.pose.position.z - pose1.pose.position.z;

    double vx = dx / dt;
    double vy = dy / dt;
    double vz = dz / dt;

    // 计算角速度
    tf2::Quaternion q1, q2, dq;
    tf2::fromMsg(pose1.pose.orientation, q1);
    tf2::fromMsg(pose2.pose.orientation, q2);
    dq = q2 * q1.inverse();

    double angle = dq.getAngle();
    tf2::Vector3 axis = dq.getAxis();
    double wx = axis.x() * angle / dt;
    double wy = axis.y() * angle / dt;
    double wz = axis.z() * angle / dt;

    geometry_msgs::Twist twist;
    twist.linear.x = vx;
    twist.linear.y = vy;
    twist.linear.z = vz;
    twist.angular.x = wx;
    twist.angular.y = wy;
    twist.angular.z = wz;

    velocity_pub.publish(twist);
}

int main(int argc, char** argv) {
    ros::init(argc, argv, "path_to_velocity");
    ros::NodeHandle nh;
    std::string path_topic;
    std::string twist_topic;
    ros::param::get("~path_topic", path_topic);
    ros::param::get("~twist_topic", twist_topic);

    ros::Subscriber path_sub = nh.subscribe(path_topic, 10, pathCallback);
    velocity_pub = nh.advertise<geometry_msgs::Twist>(twist_topic, 10);

    ros::spin();
    return 0;
}