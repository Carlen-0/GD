% ZC20B项目将5个焦温点的曲线，打包生成7条  
% 增加两个焦温点  【0℃、65℃】
clear;clc;
close all;

read_open = 1;
transform_open = 1;
test_open = 0;

names2 = [10 20 30 40 50];
reserve = uint8(zeros(1,90));

path = 'D:\预研\精度优化\曲线数据包\ZC20B';
filelist = dir([path '\*_Low.raw']); % 高温对应High，低温对应Low

for file = 1:length(filelist)
    curve_name = strcat(path, '\', filelist(file).name);
%     disp(filelist(file).name);
%     close all;
    %% 读原始曲线数据包
    if read_open == 1
        fid = fopen(curve_name, 'r');
        fseek(fid,0,'eof');
        ftell(fid);
        fseek(fid,0,'bof');

        usHeadLength = fread(fid, 1, 'int32');         %文件头长度(4bytes)
        cModuleMtMark = fread(fid, 60, 'char');        %模组测温标识符(60bytes)
        ucGearMark = fread(fid, 1, 'uint8');           %高温/常温数据包标记位(1bytes)
        ucFocusNumber = fread(fid, 1, 'uint8');        %焦温点数 N(1bytes)
        sTMin = fread(fid, 1, 'int16');                %最小测量温度 Tmin(2bytes)
        sTMax = fread(fid, 1, 'int16');                %最大测量温度 Tmax(2bytes)
        
        ucGain = fread(fid, 1, 'uint8');               %GAIN(1bytes) 6
        ucInt = fread(fid, 1, 'uint8');               %INT(1bytes) 7
        ucRes = fread(fid, 1, 'uint8');                %RES(1bytes) 8
        
        % disp([ucGain, ucInt, ucRes]);
        ucCurveNumber = fread(fid, 1, 'uint8');        %曲线条数S（1bytes)
        ucDistanceCompensateMode = fread(fid, 1, 'uint8');%距离补偿模式M（1bytes)
        ucDistanceNumber = fread(fid, 1, 'uint8');     %距离点D个数（1bytes)
        usWidth = fread(fid, 1, 'uint16');             %图像宽(2bytes)
        usHeight = fread(fid, 1, 'uint16');            %图像高(2bytes)
        
        usCurveTemperatureNumber = fread(fid, 1, 'uint16');%曲线温度点个数(2bytes)
        usFocusArrayLength = fread(fid, 1, 'uint16');  %曲线焦温点个数(2bytes)
        usCurveDataLength = fread(fid, 1, 'uint32');   %曲线数据长度(4bytes)
        usKMatLength = fread(fid, 1, 'uint32');        %k矩阵长度(4bytes)
        
        fCompensateA1 = fread(fid, 1, 'float');
        fCompensateA2 = fread(fid, 1, 'float');
        fCompensateB1 = fread(fid, 1, 'float');
        fCompensateB2 = fread(fid, 1, 'float');
        fCompensateC1 = fread(fid, 1, 'float');
        fCompensateC2 = fread(fid, 1, 'float');
        sDistanceArray = fread(fid, 5, 'uint16');  %标定距离点（10bytes)

        cDate = fread(fid, 10, 'char');             %日期（10bytes）
        cTime = fread(fid, 10, 'char');             %时间（10bytes）
        cModuleCode = fread(fid, 24, 'uint8');      %模组编号（24bytes）
        cLiaoHao = fread(fid, 12, 'uint8');         %采集料号 29
        
        cSheBeiBianHao = fread(fid, 1, 'uint8');        %设备编号 30 
        cZhiJuHao = fread(fid, 1, 'uint8');        %治具号 31
        cKaChaoHao = fread(fid, 1, 'uint8');        %模组卡位号32
        cDingBiaoHeiTiNumber = fread(fid, 1, 'uint8');        %定标黑体个数33       
        cDingJiaoType = fread(fid,1,'uint8');       % 定焦类型
        cFieldType = fread(fid,1,'uint8');          % 镜头类型
        fCorrectError = fread(fid, 24, 'uint8');    %校验误差（10*4bytes）34
        usMTPointX = fread(fid, 1, 'uint16');       %标定点坐标x（2bytes）
        usMTPointY = fread(fid, 1, 'uint16');       %标定点坐标y（2bytes）

        sensor_para = fread(fid, 30, 'uint8');      %探测器参数（30bytes）
        usFocusArray = fread(fid, usFocusArrayLength/2, 'uint16');     %焦温矩阵 （10bytes）
        % disp(usFocusArray'/100);
        % continue

        for i = 1:usFocusArrayLength/2
            curve_data_distance1(i, :) = fread(fid, usCurveTemperatureNumber, 'uint16');      %曲线
            curve_data_distance2(i, :) = fread(fid, usCurveTemperatureNumber, 'uint16'); 
            figure(1),hold on, plot(curve_data_distance1(i, :));
            figure(2),hold on, plot(curve_data_distance2(i, :));
        end
        
        for i = 1:usFocusArrayLength/2
            K_array(i, :) = fread(fid, usWidth*usHeight, 'uint16');         %K
        end
        fclose(fid);
    end
     %% 写曲线数据包
      if transform_open == 1
        if ~exist([path '/low'],'dir')
            mkdir([path '/low']);
        end
        fid = fopen([path '/low/' filelist(file).name], 'w');
        % 更改项
        ucFocusNumber = ucFocusNumber + 2;
        ucCurveNumber = ucFocusNumber*ucDistanceNumber;
        usFocusArrayLength = ucFocusNumber*2;
        usCurveDataLength = usCurveTemperatureNumber*2*usFocusArrayLength;
        usKMatLength = usWidth*usHeight*2*ucFocusNumber;
        usFocusArray = [0, usFocusArray(1), usFocusArray(2), usFocusArray(3), ...
            usFocusArray(4), usFocusArray(5), 6500];

        cFieldType = 0;
        
        fwrite(fid, usHeadLength, 'int32');         %文件头长度(4bytes)
        fwrite(fid, cModuleMtMark, 'char');         %模组测温标识符(60bytes)
        %fwrite(fid, zeros(1, (60-length(cModuleMtMark))), 'char');
        fwrite(fid, ucGearMark, 'uint8');           %高温/常温数据包标记位(1bytes)
        fwrite(fid, ucFocusNumber, 'uint8');        %焦温点数 N(1bytes)
        fwrite(fid, sTMin, 'int16');                %最小测量温度 Tmin(2bytes)
        fwrite(fid, sTMax, 'int16');                %最大测量温度 Tmax(2bytes)
        fwrite(fid, ucGain, 'uint8');               %GAIN(1bytes)
        fwrite(fid, ucInt, 'uint8');                %INT(1bytes)
        fwrite(fid, ucRes, 'uint8');                %RES(1bytes) 
        fwrite(fid, ucCurveNumber, 'uint8');        %曲线条数S（1bytes)
        fwrite(fid, ucDistanceCompensateMode, 'uint8');%距离补偿模式M（1bytes)
        fwrite(fid, ucDistanceNumber, 'uint8');     %距离点D个数（1bytes)
        fwrite(fid, usWidth, 'uint16');             %图像宽(2bytes)
        fwrite(fid, usHeight, 'uint16');            %图像高(2bytes)
        fwrite(fid, usCurveTemperatureNumber, 'uint16');%曲线温度点个数(2bytes)
        fwrite(fid, usFocusArrayLength, 'uint16');  %曲线温度点个数(2bytes)
        fwrite(fid, usCurveDataLength, 'uint32');   %曲线数据长度(4bytes)
        fwrite(fid, usKMatLength, 'uint32');        %k矩阵长度(4bytes)
        fwrite(fid, fCompensateA1, 'float');
        fwrite(fid, fCompensateA2, 'float');
        fwrite(fid, fCompensateB1, 'float');
        fwrite(fid, fCompensateB2, 'float');
        fwrite(fid, fCompensateC1, 'float');
        fwrite(fid, fCompensateC2, 'float');
        fwrite(fid, sDistanceArray, 'uint16');  %标定距离点（10bytes) 25
        fwrite(fid, cDate, 'char');            %日期（10bytes）
        %fwrite(fid, zeros(1, (10-length(cDate))), 'char');
        fwrite(fid, cTime, 'char');            %时间（10bytes）
       % fwrite(fid, zeros(1, (10-length(cTime))), 'char');
        fwrite(fid, cModuleCode, 'uint8');      %模组编号（24bytes）
       % fwrite(fid, zeros(1, (24-length(cModuleCode))), 'char');
         fwrite(fid, cLiaoHao, 'uint8');         %采集料号 29
        
        fwrite(fid, cSheBeiBianHao, 'uint8');        %设备编号 30 
        fwrite(fid, cZhiJuHao, 'uint8');        %治具号 31
        fwrite(fid, cKaChaoHao, 'uint8');        %模组卡位号32
        fwrite(fid, cDingBiaoHeiTiNumber, 'uint8');        %定标黑体个数33
        fwrite(fid, cDingJiaoType,'uint8');
        fwrite(fid, cFieldType,'uint8');
        fwrite(fid, fCorrectError, 'uint8');    %校验误差（10*4bytes）34
        fwrite(fid, usMTPointX, 'uint16');       %标定点坐标x（2bytes）
        fwrite(fid, usMTPointY, 'uint16');       %标定点坐标y（2bytes）

        fwrite(fid, sensor_para, 'uint8');      %探测器参数（30bytes）
        fwrite(fid, usFocusArray, 'uint16');    %焦温矩阵 （10bytes）
        for i = 1:usFocusArrayLength/2
            if i == 1
                curve_final_distance1(i, :) = curve_data_distance1(1, :) + ...
                    (usFocusArray(1)-usFocusArray(2))/(usFocusArray(2)-usFocusArray(3))*(curve_data_distance1(1,:) - curve_data_distance1(2,:));      %曲线
                curve_final_distance2(i, :) = curve_data_distance2(1, :) + ...
                    (usFocusArray(1)-usFocusArray(2))/(usFocusArray(2)-usFocusArray(3))*(curve_data_distance2(1,:) - curve_data_distance2(2,:));  
            elseif (i > 1 && i < 7)
                curve_final_distance1(i, :) = curve_data_distance1(i-1, :);
                curve_final_distance2(i, :) = curve_data_distance2(i-1, :);
            elseif i == 7
                curve_final_distance1(i, :) = curve_data_distance1(5, :) + ...
                    (usFocusArray(7)-usFocusArray(6))/(usFocusArray(6)-usFocusArray(5))*(curve_data_distance1(5,:) - curve_data_distance1(4,:));      %曲线
                curve_final_distance2(i, :) = curve_data_distance2(5, :) + ...
                    (usFocusArray(7)-usFocusArray(6))/(usFocusArray(6)-usFocusArray(5))*(curve_data_distance2(5,:) - curve_data_distance2(4,:));       
            end
            figure(3),hold on, plot(curve_final_distance1(i, :));
            figure(4),hold on, plot(curve_final_distance2(i, :));
        end
        
        for i = 100:200
            curve_final_distance2(1,i) = curve_final_distance2(1,i)+(i-100)*0.84;
            curve_final_distance2(2,i) = curve_final_distance2(2,i)+(i-100)*0.81;
            curve_final_distance2(3,i) = curve_final_distance2(3,i)+(i-100)*0.80;
        end
        for i = 201:300
            curve_final_distance2(1,i) = curve_final_distance2(1,i)+84;
            curve_final_distance2(2,i) = curve_final_distance2(2,i)+81;
            curve_final_distance2(3,i) = curve_final_distance2(3,i)+80;
        end
        for i = 301:500
            curve_final_distance2(1,i) = curve_final_distance2(1,i)+84+(i-300)*0.09;
            curve_final_distance2(2,i) = curve_final_distance2(2,i)+81+(i-300)*0.085;
            curve_final_distance2(3,i) = curve_final_distance2(3,i)+80+(i-300)*0.07;
        end
        for i = 501:800
            curve_final_distance2(1,i) = curve_final_distance2(1,i)+102+(i-500)*0.08;
            curve_final_distance2(2,i) = curve_final_distance2(2,i)+98+(i-500)*0.06;
            curve_final_distance2(3,i) = curve_final_distance2(3,i)+94+(i-500)*0.05;
        end
        for i = 801:1300
            curve_final_distance2(1,i) = curve_final_distance2(1,i)+126;
            curve_final_distance2(2,i) = curve_final_distance2(2,i)+116;
            curve_final_distance2(3,i) = curve_final_distance2(3,i)+109;
        end
        for i = 1301:usCurveTemperatureNumber
            curve_final_distance2(1,i) = curve_final_distance2(1,i)+126+(i-1300)*0.492;
            curve_final_distance2(2,i) = curve_final_distance2(2,i)+116+(i-1300)*0.462;
            curve_final_distance2(3,i) = curve_final_distance2(3,i)+109+(i-1300)*0.432;
        end
                
        for i = 1:usFocusArrayLength/2
            figure(5),hold on, plot(curve_final_distance1(i, :));
            figure(6),hold on, plot(curve_final_distance2(i, :));
            fwrite(fid, curve_final_distance1(i,:), 'uint16');
            fwrite(fid, curve_final_distance2(i,:), 'uint16');
        end

        for i = 1:ucFocusNumber
            if i == 1
                fwrite(fid, K_array(i, :), 'uint16');
            elseif i >1 && i < 7
                fwrite(fid, K_array(i-1, :), 'uint16');
            elseif i == 7
                fwrite(fid, K_array(i-2, :), 'uint16');
            end    
        end
        fclose(fid);
      end
   %% 读新生成的曲线数据包
   if test_open == 1
        close all;
        fid = fopen([[path '/transform'] '/' filelist(file).name], 'r');

        usHeadLength = fread(fid, 1, 'int32');         %文件头长度(4bytes)
        cModuleMtMark = fread(fid, 60, 'char');        %模组测温标识符(60bytes)
        ucGearMark = fread(fid, 1, 'uint8');           %高温/常温数据包标记位(1bytes)
        ucFocusNumber = fread(fid, 1, 'uint8');        %焦温点数 N(1bytes)
        sTMin = fread(fid, 1, 'int16');                %最小测量温度 Tmin(2bytes)
        sTMax = fread(fid, 1, 'int16');                %最大测量温度 Tmax(2bytes)
        ucGain = fread(fid, 1, 'uint8');               %GAIN(1bytes)
        ucInt = fread(fid, 1, 'uint8');                %INT(1bytes)
        ucRes = fread(fid, 1, 'uint8');                %RES(1bytes) 
        ucCurveNumber = fread(fid, 1, 'uint8');        %曲线条数S（1bytes)
        ucDistanceCompensateMode = fread(fid, 1, 'uint8');%距离补偿模式M（1bytes)
        ucDistanceNumber = fread(fid, 1, 'uint8');     %距离点D个数（1bytes)
        usWidth = fread(fid, 1, 'uint16');             %图像宽(2bytes)
        usHeight = fread(fid, 1, 'uint16');            %图像高(2bytes)
        usCurveTemperatureNumber = fread(fid, 1, 'uint16');%曲线温度点个数(2bytes)
        usFocusArrayLength = fread(fid, 1, 'uint16');  %曲线焦温点个数(2bytes)
        usCurveDataLength = fread(fid, 1, 'uint32');   %曲线数据长度(4bytes)
        usKMatLength = fread(fid, 1, 'uint32');        %k矩阵长度(4bytes)
        fCompensateA1 = fread(fid, 1, 'float');
        fCompensateA2 = fread(fid, 1, 'float');
        fCompensateB1 = fread(fid, 1, 'float');
        fCompensateB2 = fread(fid, 1, 'float');
        fCompensateC1 = fread(fid, 1, 'float');
        fCompensateC2 = fread(fid, 1, 'float');
        sDistanceArray = fread(fid, 5, 'uint16');  %标定距离点（10bytes)

        cDate = fread(fid, 10, 'char');             %日期（10bytes）
        cTime = fread(fid, 10, 'char');             %时间（10bytes）
        cModuleCode = fread(fid, 24, 'uint8');      %模组编号（24bytes）
        cLiaoHao = fread(fid, 12, 'uint8');         %采集料号 29
        
        cSheBeiBianHao = fread(fid, 1, 'uint8');        %设备编号 30 
        cZhiJuHao = fread(fid, 1, 'uint8');        %治具号 31
        cKaChaoHao = fread(fid, 1, 'uint8');        %模组卡位号32
        cDingBiaoHeiTiNumber = fread(fid, 1, 'uint8');        %定标黑体个数33
        cDingJiaoType = fread(fid,1,'uint8'); % 定焦类型
        cFieldType = fread(fid,1,'uint8'); % 镜头类型
        fCorrectError = fread(fid, 24, 'uint8');    
        usMTPointX = fread(fid, 1, 'uint16');       %标定点坐标x（2bytes）
        usMTPointY = fread(fid, 1, 'uint16');       %标定点坐标y（2bytes）

        sensor_para = fread(fid, 30, 'uint8');      %探测器参数（30bytes）
        usFocusArray = fread(fid, ucFocusNumber, 'uint16');     %焦温矩阵 （10bytes）
        disp(usFocusArray');
        for i = 1:usFocusArrayLength/2
            curve_data_distance1(i, :) = fread(fid, usCurveTemperatureNumber, 'uint16');      %曲线
            curve_data_distance2(i, :) = fread(fid, usCurveTemperatureNumber, 'uint16'); 
            figure(1),hold on, plot(curve_data_distance1(i, :));
            figure(2),hold on, plot(curve_data_distance2(i, :));
        end

        for i = 1:usFocusArrayLength/2
            K_array(i, :) = fread(fid, usWidth*usHeight, 'uint16');         %K
        end

        fclose(fid);
   end
end



