

%近距离段数据拟合，测远距离

clear;
close all;

%拟合的阶数
m = 2;
%DIS = [0.5; 1; 1.5; 2; 2.5];
% DIS = [1; 3; 5; 10; 15;20;25];
DIS = [1;3;5;8;10;15;20;25 ];
%黑体真实温度---点检温度
% y = xlsread('距离校正数据.xlsx', 'sheet1', 'C2:K2') + 273.5;
% X = xlsread('距离校正数据.xlsx', 'sheet1', 'C4:K4') + 273.5;
% 

%m_data = load('data.txt');

% y= m_data(1,1:3) + 273.5;
% X1=m_data(2:6,1:3)+ 273.5;
% X2=m_data(7:11,1:3)+ 273.5;
% X3=m_data(12:16,1:3)+ 273.5;
% X4=m_data(17:21,1:3)+ 273.5;
% X5=m_data(22:26,1:3)+ 273.5;
% X6=m_data(27:31,1:3)+ 273.5;
% X7=m_data(32:36,1:3)+ 273.5;
% X8=m_data(37:41,1:3)+ 273.5;
% X9=m_data(42:46,1:3)+ 273.5;
% X10=m_data(47:51,1:3)+ 273.5;

% y= m_data(1,1:5) ;
% X1=m_data(2:6,1:5);
% X2=m_data(7:11,1:5);
% X3=m_data(12:16,1:5);
% X4=m_data(17:21,1:5);
% X5=m_data(22:26,1:5);
% X6=m_data(27:31,1:5);
% X7=m_data(32:36,1:5);
% X8=m_data(37:41,1:5);
% X9=m_data(42:46,1:5);
% X10=m_data(47:51,1:5);
% X=(X1+X2+X3+X4+X5+X6+X7+X8+X9+X10)/10;

X = [19.8	50.1	100.6	150.7	201.2	300.1	451.3
19.4	49.5	99.4	149.2	199.6	297.5	446.8
19.6	49	98.8	148.3	197.9	295.4	442.4
18.8	48.1	96.8	146.1	195.2	291.5	437.5
18.4	47.5	96.1	144.7	193.4	289.2	432.2
18.9	47	94.2	142.6	190.3	283.9	423.8
19.1	45.6	89.3	138	184.9	277.8	421.3
19	45	90.7	137.4	184.7	273.1	411.1


];

y = [19.4	49.5	99.4	149.2	199.6	297.5	446.8
];
% y = [99.4 
% 139.7 
% 199.1 
% 250.5 
% 300.6 
% 341.3 
% 390.9 
% ]' + 273.5;
% X = [
%     
% 
% ]' + 273.5;


figure(1),
for i = 1:length(DIS)
    x = X(i, :);
    subplot(3, 3, i), plot(x, y, 'r', y, y, 'g');
    legend(strcat(num2str(DIS(i)), 'm读出数据'), '真实数据');
    p(i, :) = polyfit(x, y, m);
    z(i, :) = polyval(p(i, :), x);
    dif(i, :) = z(i, :) - y;
end

% figure(2);
% % plot(y-273.5, dif(1,:), 'r', y-273.5, dif(2,:), 'g', y-273.5, dif(3,:), 'b', y-273.5, dif(4,:), 'c',y-273.5, dif(5,:), 'y');
% plot(y, dif(1,:), 'r', y, dif(2,:), 'g', y, dif(3,:), 'b', y, dif(4,:), 'c');
% 
% legend('0.5m','1m','3m','5m');
% title([num2str(m) '阶拟合']);


p = [DIS, p];

%save polycof_Ger p
%load polycof_own_3 p

n = 1;
for i = 1:length(DIS)
    xx1(i, 1) = p(i, 1);
    yy1(i, 1) = p(i, 2);
    yy2(i, 1) = p(i, 3);
    yy3(i, 1) = p(i, 4);
end
c1 = polyfit(xx1, yy1, n);
c2 = polyfit(xx1, yy2, n);
c3 = polyfit(xx1, yy3, n); 
%test
% c1 = [-0.000019686 0.000053046];
% c2 = [0.00899 0.96322];
% c3 = [-0.16824 0.51336];

figure(3),

for i = 1:length(DIS)
    dis = DIS(i); 
    tmpx = X(i, :);
    if n == 1
        tmpz = (c1(1)*dis.^(n) + c1(2))*tmpx.^2  + (c2(1)*dis.^(n) + c2(2))*tmpx + c3(1)*dis.^(n) + c3(2);
    elseif n == 2
        tmpz = (c1(1)*dis.^(n) + c1(2)*dis + c1(3))*tmpx.^2 + (c2(1)*dis.^(n) + c2(2)*dis + c2(3))*tmpx + (c3(1)*dis.^(n) + c3(2)*dis + c3(3));
    end
    z = tmpz;
    dif = z - y;

    %subplot(3, 3, i); plot(y - 273.5, dif);
    subplot(3, 3, i); plot(y , dif);
    xlabel('观测黑体的温度/℃')
    ylabel('补偿后的误差/℃')
    title(strcat(num2str(dis), 'm处的补偿修正后的误差'));
end

%save polycof_Ger_last c1 c2 c3

result(1) = c1(1);
result(2) = c1(2);
result(3) = c2(1);
result(4) = c2(2);
result(5) = c3(1);
result(6) = c3(2);

file_01=fopen('距离校正参数.txt','w');
formatSpec='a0 = %.1f \na1 = %.1f \na2 = %.1f \na3 = %.1f \na4 = %.1f \na5 = %.1f \na6 = %.1f \na7 = %.1f \na8 = %.1f \n';
fprintf(file_01,formatSpec,result);
fprintf(formatSpec,result);
fclose(file_01);




%dlmwrite('距离校正参数.txt',result);
%最终的计算公式是
%用的是1个2次拟合和1个线性拟合的方法得到数据
%y:校正输出的温度值,绝对温度,
%x:机器读出的温度值,绝对温度,
%dis:需要输入的距离信息
%y = (a0*dis+a1)*x^2+(b0*dis+b1)*x+(c0*dis+c1);
%a0 = -9.0407e-005
%a1 = 0.00018468
%b0 = 0.077067
%b1 = 0.79863
%c0 = -14.889
%c1 = 42.89





