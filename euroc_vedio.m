% ��ȡ����
err = readNPY('C:\Users\22954\Desktop\euroc���\0601_trans_error\vins_0_trans\error_array.npy');
t = readNPY('C:\Users\22954\Desktop\euroc���\0601_trans_error\vins_0_trans\timestamps.npy');

% ��ȡʱ������ݣ���һ�У�
timestamps = t(:) - t(1);

% ��ȡ������������Ϊy����
y_values = err;

% ��ȡ���ݵ�����������
[numRows, numCols] = size(y_values);

% ����ͼ�δ���
figure;
hold on;
xlabel('ʱ�� (s)');
ylabel('ֵ');
title('���ݶ���');
grid on;

% ��ʼ������
h = plot(timestamps(1), y_values(1, :), 'o-');

% ���ó�ʼ�᷶Χ
initial_window = 2;  % ��ʼ��ʾ��ʱ�䴰�ڳ���
max_window = 100;     % �����ʾ��ʱ�䴰�ڳ���
xlim([timestamps(1), timestamps(1) + initial_window]);
ylim([min(y_values(:)), max(y_values(:))]);

% ���ö���֡��
frame_rate = 1/24;

% ���涯��ΪGIF
filename = 'data_animation.gif';
for i = 1:numRows
    % ������������
    set(h, 'XData', timestamps(1:i));
    for j = 1:numCols
        set(h(j), 'YData', y_values(1:i, j));
    end
    
    % ��̬����x�᷶Χ
    if timestamps(i) > (timestamps(1) + initial_window)
        current_window = min(initial_window + frame_rate * (i - 1), max_window);
        xlim([0, timestamps(i)]);
    end
    
    drawnow;
    pause(frame_rate);  % ���Ʋ����ٶ�
    
    % ��ȡ��ǰ֡������ΪGIF
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);
    if i == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append');
    end
end
