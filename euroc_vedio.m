% 读取数据
err = readNPY('C:\Users\22954\Desktop\euroc结果\0601_trans_error\vins_0_trans\error_array.npy');
t = readNPY('C:\Users\22954\Desktop\euroc结果\0601_trans_error\vins_0_trans\timestamps.npy');

% 提取时间戳数据（第一列）
timestamps = t(:) - t(1);

% 提取其余列数据作为y坐标
y_values = err;

% 获取数据的行数和列数
[numRows, numCols] = size(y_values);

% 创建图形窗口
figure;
hold on;
xlabel('时间 (s)');
ylabel('值');
title('数据动画');
grid on;

% 初始化线条
h = plot(timestamps(1), y_values(1, :), 'o-');

% 设置初始轴范围
initial_window = 2;  % 初始显示的时间窗口长度
max_window = 100;     % 最大显示的时间窗口长度
xlim([timestamps(1), timestamps(1) + initial_window]);
ylim([min(y_values(:)), max(y_values(:))]);

% 设置动画帧数
frame_rate = 1/24;

% 保存动画为GIF
filename = 'data_animation.gif';
for i = 1:numRows
    % 更新线条数据
    set(h, 'XData', timestamps(1:i));
    for j = 1:numCols
        set(h(j), 'YData', y_values(1:i, j));
    end
    
    % 动态调整x轴范围
    if timestamps(i) > (timestamps(1) + initial_window)
        current_window = min(initial_window + frame_rate * (i - 1), max_window);
        xlim([0, timestamps(i)]);
    end
    
    drawnow;
    pause(frame_rate);  % 控制播放速度
    
    % 获取当前帧并保存为GIF
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);
    if i == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append');
    end
end
