%近距离段数据拟合，测远距离

clear;
close all;

%拟合的阶数
m = 2;
% DIS = [0.5;  2;  3;  5;  8;  10];
% DIS = [0.5;1;1.5];
% DIS = [0.2;  0.5;  1.5;  2.5];
% DIS = [2;  3;  5;  8];
DIS = [1;  3;  5];
% DIS = [5;  8;  10];

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

% high orgin
% X = [102.9 152.5 202.3 252.8 304.7 359 408.8 
% 101.4 150.1 198.4 247.6 298.6 351.2 400.1  
% 99.9 147.7 195 244.1 293.3 345.4 393.9];
% 
% y = [101.4 150.1 198.4 247.6 298.6 351.2 400.1];

% low orgin
% X = [20.8 35.8 51.1 61.5 101.1 151.2
% 21 35.5 50.6 60.5 99.6 148.7
% 21.2 35.5 50.3 59.8 98.1 146.3];
% 
% y = [21 35.5 50.6 60.5 99.6 148.7];

% low average
% X = [20.08	35.86	51.48	61.42	102.16	153.56
% 20.4	35.54	50.56	60.18	100.04	150.8
% 21.06	35.22	49.8	59.52	98.7	148.62];
% y = [20.4	35.54	50.56	60.18	100.04	150.8];

% high average
X = [102.56	153.22	204.16	305.4	407.38	460.34
99.86	149.6	199.34	298.58	398.22	449.62
97.42	146.9	195.84	293.32	391.14	441.62];
y = [99.86	149.6	199.34	298.58	398.22	449.62];
% X=[101.45        153.55        255.9        357.25        579
% 100.1        150.65        250.95        350.05        553.5
% 99.1        149.5        248.4        347        547];
% y = [100.1        150.65        250.95        350.05        553.5];
figure(1),
for i = 1:length(DIS)
    x = X(i, :);
    subplot(2, 3, i), plot(x, y, '-or', y, y, '-og');
    legend(strcat(num2str(DIS(i)), 'm读出数据'), '真实数据');
    p(i, :) = polyfit(x, y, m); %不同温度的拟合系数
    z(i, :) = polyval(p(i, :), x);
    dif(i, :) = z(i, :) - y;
end

figure(2);
% plot(y-273.5, dif(1,:), 'r', y-273.5, dif(2,:), 'g', y-273.5, dif(3,:), 'b', y-273.5, dif(4,:), 'c',y-273.5, dif(5,:), 'y');
plot(y, dif(1,:), 'r', y, dif(2,:), 'g', y, dif(3,:), 'b');
% plot(y, dif(1,:), 'r', y, dif(2,:), 'g', y, dif(3,:), 'b',y, dif(4,:));
% plot(y, dif(1,:), 'r', y, dif(2,:), 'g', y, dif(3,:), 'b',y, dif(4,:), 'y',y, dif(5,:), 'k',y, dif(6,:), 'm');

legend('0.5m','1m','1.5m');
% legend('0.2m','0.5m','1.5m','2.5m');
% legend('2m','3m','5m','8m');
% legend('0.5m','1m','1.5m','2m','2.5m');
% legend('0.5m','2m','3m','5m','8m','10m');
title([num2str(m) '阶拟合']);


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

figure(3),

% X = [20	53.8	106.3	159.6
% 19.7	50.6	98.8	149.3
% 21.3	48.7	92.9	139.3];

for i = 1:length(DIS)
    dis = DIS(i); 
    tmpx = X(i, :);
    if n == 1
        tmpz = (c1(1)*dis.^(n) + c1(2))*tmpx.^2  + (c2(1)*dis.^(n) + c2(2))*tmpx + c3(1)*dis.^(n) + c3(2);
    elseif n == 2
        tmpz = (c1(1)*dis.^(n) + c1(2)*dis + c1(3))*tmpx.^2 + (c2(1)*dis.^(n) + c2(2)*dis + c2(3))*tmpx + (c3(1)*dis.^(n) + c3(2)*dis + c3(3));
    end
    crrection(i,:) = tmpz;
    dif = crrection(i,:) - y;

    %subplot(3, 3, i); plot(y - 273.5, dif);
    subplot(3, 2, i); plot(y , dif, '-o');
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

% result(1) = c1(1);
% result(2) = c1(2);
% result(3) = c1(3);
% result(4) = c2(1);
% result(5) = c2(2);
% result(6) = c2(3);
% result(7) = c3(1);
% result(8) = c3(2);
% result(9) = c3(3);

file_01=fopen('距离校正参数.txt','w');
% formatSpec='coefA1 = %.17f;\ncoefA2 = %.17f;\ncoefB1 = %.17f;\ncoefB2 = %.17f;\ncoefC1 = %.17f;\ncoefC2 = %.17f;\n';
% formatSpec='a0 = %.17f \na1 = %.17f \na2 = %.17f \na3 = %.17f \na4 = %.17f \na5 = %.17f \n';
% formatSpec='a0 = %.17f \na1 = %.17f \na2 = %.17f \na3 = %.17f \na4 = %.17f \na5 = %.17f \na6 = %.17f \na7 = %.17f \na8 = %.17f \n';
formatSpec='%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n';
% formatSpec='coefA1 = %.17f;\ncoefA2 = %.17f;\ncoefB1 = %.17f;\ncoefB2 = %.17f;\ncoefC1 = %.17f;\ncoefC2 = %.17f;\n';
% formatSpec='%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n%.17f \n';
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





