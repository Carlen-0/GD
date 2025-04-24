% 将4个焦温点的曲线，打包生成6条 ZC08E
% 增加两个焦温点  【10℃、60℃】
% 读取一个打包的.raw 数据包
%%
clear;clc;close all;
read_open = 1;
transform_open = 1;
test_open = 0;

% path00 = '\\D:\ZG\project\ZS15A\自研黑体验证\数据包\*.raw';
% [file, path] = uigetfile(path00);
fullpath = mfilename('fullpath');
[path,name] = fileparts(fullpath);
curve_name = 'ita_standard_high.raw';

for JJ = 1:1
    if read_open == 1
        fid = fopen(curve_name, 'r');
        fseek(fid,0,'eof');
        ftell(fid);
        fseek(fid,0,'bof');
        usHeadLength = fread(fid, 1, 'int32');         %216 文件头长度(4bytes) 0
        cModuleMtMark = fread(fid, 60, 'char');        %1 模组测温标识符(60bytes) 1
        ucGearMark = fread(fid, 1, 'uint8');           %2 高温/常温数据包标记位(1bytes) 2
        ucFocusNumber = fread(fid, 1, 'uint8');        %焦温点数 N(1bytes) 3
        sTMin = fread(fid, 1, 'int16');                %最小测量温度 Tmin(2bytes) 4
        sTMax = fread(fid, 1, 'int16');                %最大测量温度 Tmax(2bytes) 5
        ucGain = fread(fid, 1, 'uint8');               %GAIN(1bytes) 6
        ucInt = fread(fid, 1, 'uint8');                %INT(1bytes) 7
        ucRes = fread(fid, 1, 'uint8');                %RES(1bytes) 8
        disp([ucGain, ucInt, ucRes]);
        ucCurveNumber = fread(fid, 1, 'uint8');        %曲线条数S（1bytes) 9
        ucDistanceCompensateMode = fread(fid, 1, 'uint8');%距离补偿模式M（1bytes) 10
        ucDistanceNumber = fread(fid, 1, 'uint8');     %距离点D个数（1bytes) 11
        usWidth = fread(fid, 1, 'uint16');             %图像宽(2bytes)12
        usHeight = fread(fid, 1, 'uint16');            %图像高(2bytes)13
        usCurveTemperatureNumber = fread(fid, 1, 'uint16');%曲线温度点个数(2bytes) 14
        usFocusArrayLength = fread(fid, 1, 'uint16');  %曲线焦温点长度(2bytes)15
        usCurveDataLength = fread(fid, 1, 'uint32');   %曲线数据长度(4bytes)16
        usKMatLength = fread(fid, 1, 'uint32');        %k矩阵长度(4bytes)17
        fCompensateA1 = fread(fid, 1, 'float');  %19
        fCompensateA2 = fread(fid, 1, 'float');
        fCompensateB1 = fread(fid, 1, 'float');
        fCompensateB2 = fread(fid, 1, 'float');
        fCompensateC1 = fread(fid, 1, 'float');
        fCompensateC2 = fread(fid, 1, 'float'); %24
        sDistanceArray = fread(fid, 5, 'uint16');  %标定距离点（10bytes) 25
        cDate = fread(fid, 10, 'char');             %日期（10bytes）26
        cTime = fread(fid, 10, 'char');             %时间（10bytes）27
        cModuleCode = fread(fid, 24, 'uint8');      %模组编号（24bytes）28
        cLiaoHao = fread(fid, 12, 'uint8');         %采集料号 29
        cSheBeiBianHao = fread(fid, 1, 'uint8');    %设备编号 30
        cZhiJuHao = fread(fid, 1, 'uint8');         %治具号 31
        cKaChaoHao = fread(fid, 1, 'uint8');        %模组卡位号 32
        cDingBiaoHeiTiNumber = fread(fid, 1, 'uint8');        %定标黑体个数33
        fFocusType =  fread(fid, 1, 'uint8'); 
        fFieldType = fread(fid, 1, 'uint8'); 
        fMtTpye = fread(fid, 1, 'uint8'); 
        fCorrectDistance = fread(fid, 1, 'float');
        fCorrectError = fread(fid, 19, 'uint8');    %校验误差（10*4bytes）34
        usMTPointX = fread(fid, 1, 'uint16');       %标定点坐标x（2bytes）35
        usMTPointY = fread(fid, 1, 'uint16');       %216 标定点坐标y（2bytes）36
        if usWidth == 120
            sensor_para = fread(fid, 30, 'uint8');%探测器参数（30bytes）  30
        else
            sensor_para = fread(fid, [70,10], 'uint16');
        end

        usFocusArray = fread(fid, usFocusArrayLength/2, 'uint16');   %焦温矩阵(数组)
        disp(usFocusArray');
%         figure(1);hold on;title(file);
        for i = 1:usFocusArrayLength/2
            curve_data_distance05(i,:) = fread(fid, usCurveTemperatureNumber, 'uint16');%曲线 0.5m
            curve_data_distance12(i,:) = fread(fid, usCurveTemperatureNumber, 'uint16');
        end
        
        for i = 1:usFocusArrayLength/2
            K_array22(i,:) = fread(fid, usWidth*usHeight, 'uint16');%K
        end
		
        fclose(fid);
    end
    
    %% 写曲线数据包
    if transform_open == 1
        if ~exist([path '\new'],'dir')
            mkdir([path '\new']);
        end
        fid = fopen([path '\new\ita_high_temp_high.raw'], 'w');
        
        usCurveTemperatureNumber = 25000;
        ucFocusNumber = 6;
        ucCurveNumber = ucFocusNumber*ucDistanceNumber;
        usFocusArrayLength = ucFocusNumber*2;
        usCurveDataLength = usCurveTemperatureNumber*2*usFocusArrayLength;
        usKMatLength = usWidth*usHeight*2*ucFocusNumber;
        
        [a,b,c] = xlsread('D:\项目\ZC08E\原理样机_高温镜头\曲线数据\7_Higher.xlsx');
        m_data = cellfun(@str2num,b(2:5,2:end));
        m_data = sortrows(m_data,1);
        usFocusArray = (m_data(1:4,1))'*100;    % 焦温数组
        
        usFocusArray = [1000, usFocusArray(1), usFocusArray(2), usFocusArray(3), usFocusArray(4), 6000];    % 焦温数组
        
        %5℃环温对应曲线
        Data_5(:,1)=[19.3013 48.1185 96.4470 193.3441 290.1154 386.6651 627.1877 771.0607 962.5339 1440.0773];    %High
%         Data_5(:,1)=[20 50 100 200 300 400 650 800 1000 1500];    %High
        Data_5(:,2)=(m_data(1,end-9:end))'; 
        Data_5(:,2) = Data_5(:,2) - Data_5(1,2) + 1000;
        nCurve(2,:) = Curve_Higher(Data_5);
        
        %15℃环温对应曲线
        Data_15(:,1)=[19.7557 48.4729 96.7061 193.5190 290.2552 386.7866 627.2891 771.1565 962.6253 1440.1636];
%         Data_15(:,1)=[20 50 100 200 300 400 650 800 1000 1500];
        Data_15(:,2)=(m_data(2,end-9:end))';
        Data_15(:,2) = Data_15(:,2) - Data_15(1,2) + 1000;
        nCurve(3,:) = Curve_Higher(Data_15);
        
        %23℃环温对应曲线
        Data_23(:,1)=[20.2557 48.8636 96.9921 193.7124 290.4096 386.9209 627.4011 771.2624 962.7264 1440.2591];
%         Data_23(:,1)=[20 50 100 200 300 400 650 800 1000 1500];
        Data_23(:,2)=(m_data(3,end-9:end))';
        Data_23(:,2) = Data_23(:,2) - Data_23(1,2) + 1000;
        nCurve(4,:) = Curve_Higher(Data_23);
        
        %35℃环温对应曲线
        Data_35(:,1)=[20.8014 49.2908 97.3053 193.9243 290.5789 387.0682 627.5239 771.3786 962.8372 1440.3638];
%         Data_35(:,1)=[20 50 100 200 300 400 650 800 1000 1500];
        Data_35(:,2)=(m_data(4,end-9:end))';
        Data_35(:,2) = Data_35(:,2) - Data_35(1,2) + 1000;
        nCurve(5,:) = Curve_Higher(Data_35);
        
        
        %扩容10℃焦温曲线，避免3℃环温开机焦温过低，温度不准
        nCurve(1,:) = nCurve(2,:) + (usFocusArray(1)-usFocusArray(2))/(usFocusArray(2)-usFocusArray(3))*(nCurve(2,:) - nCurve(3,:));      %曲线
        nCurve(6,:) = nCurve(5,:) - (usFocusArray(5)-usFocusArray(6))/(usFocusArray(4)-usFocusArray(5))*(nCurve(4,:) - nCurve(5,:));
        
        figure(1),
        for i = 1:ucFocusNumber
            plot(nCurve(i,:));
            hold on,
        end
        
        fwrite(fid,  usHeadLength, 'int32');        %216 文件头长度(4bytes) 0
        fwrite(fid, cModuleMtMark, 'char');         %1 模组测温标识符(60bytes) 1
        fwrite(fid, ucGearMark, 'uint8');           %2 高温/常温数据包标记位(1bytes) 2
        fwrite(fid, ucFocusNumber, 'uint8');        %焦温点数 N(1bytes) 3
        sTMin = 0;
        sTMax = 2500;
        fwrite(fid, sTMin, 'int16');                %最小测量温度 Tmin(2bytes) 4
        fwrite(fid, sTMax, 'int16');                %GAIN(1bytes) 6
        fwrite(fid, ucGain, 'uint8');               %最大测量温度 Tmax(2bytes) 5
        fwrite(fid, ucInt, 'uint8');                %INT(1bytes) 7
        fwrite(fid, ucRes, 'uint8');                %RES(1bytes) 8
        disp([ucGain, ucInt, ucRes]);
        fwrite(fid, ucCurveNumber, 'uint8');        %曲线条数S（1bytes) 9
        fwrite(fid, ucDistanceCompensateMode, 'uint8');%距离补偿模式M（1bytes) 10
        fwrite(fid, ucDistanceNumber, 'uint8');     %距离点D个数（1bytes) 11
        usWidth_new = 640;
        usHeight_new = 512;
        fwrite(fid, usWidth_new, 'uint16');             %图像宽(2bytes) 12
        fwrite(fid, usHeight_new, 'uint16');            %图像高(2bytes) 13
        fwrite(fid, usCurveTemperatureNumber, 'uint16');%曲线温度点个数(2bytes) 14
        fwrite(fid, usFocusArrayLength, 'uint16');  %曲线焦温点个数(2bytes)15
        fwrite(fid, usCurveDataLength, 'uint32');   %曲线数据长度(4bytes)16
        fwrite(fid, usKMatLength, 'uint32');        %k矩阵长度(4bytes)17
        fwrite(fid, fCompensateA1, 'float');  %19
        fwrite(fid, fCompensateA2, 'float');
        fwrite(fid, fCompensateB1, 'float');
        fwrite(fid, fCompensateB2, 'float');
        fwrite(fid, fCompensateC1, 'float');
        fwrite(fid, fCompensateC2, 'float'); %24
        sDistanceArray = [15;30;0;0;0];
        fwrite(fid, sDistanceArray, 'uint16');  %标定距离点（10bytes) 25
        fwrite(fid, cDate, 'char');             %日期（10bytes）26
        fwrite(fid, cTime, 'char');             %时间（10bytes）27
        fwrite(fid, cModuleCode, 'uint8');      %模组编号（24bytes）28
        fwrite(fid, cLiaoHao, 'uint8');         %采集料号 29
        fwrite(fid, cSheBeiBianHao, 'uint8');   %设备编号 30
        fwrite(fid, cZhiJuHao, 'uint8');        %治具号 31
        fwrite(fid, cKaChaoHao, 'uint8');       %模组卡位号32
        fwrite(fid, cDingBiaoHeiTiNumber, 'uint8');        %定标黑体个数33
        fFocusType = 1;
        fwrite(fid, fFocusType, 'uint8');    %校验误差（10*4bytes）34
        fFieldType = 11;
        fwrite(fid, fFieldType, 'uint8');    %校验误差（10*4bytes）34
        fMtTpye = 3;
        fwrite(fid, fMtTpye, 'uint8');    %校验误差（10*4bytes）34
        fwrite(fid, fCorrectDistance, 'float');    %校验误差（10*4bytes）34
        fwrite(fid, fCorrectError, 'uint8');    %校验误差（10*4bytes）34
        fwrite(fid, usMTPointX, 'uint16');       %标定点坐标x（2bytes）35
        fwrite(fid, usMTPointY, 'uint16');       %标定点坐标y（2bytes）36
        
        if usWidth == 120
            fwrite(fid, sensor_para, 'uint8');      %探测器参数（30bytes）
        else
            fwrite(fid, sensor_para, 'uint16');      %探测器参数（30bytes）
        end
        
        fwrite(fid, usFocusArray, 'uint16');     %焦温矩阵(数组)（10bytes）
        
        for i = 1:usFocusArrayLength/2
            fwrite(fid, nCurve(i,:), 'uint16');      %曲线 0.5m
            fwrite(fid, nCurve(i,:), 'uint16');
            figure(1),hold on, plot(nCurve(i,:));
        end
        
        fclose(fid);
    end
    
end

