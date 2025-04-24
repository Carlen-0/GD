% ZU14A项目零下环温曲线，采集-10/0环温曲线（焦温0~10），焦温-20、-10、20曲线延伸，焦温-40、-30共用-20曲线
%% 
clear;clc;close all;
read_open = 1;
transform_open = 1;
test_open = 0;

fullpath = mfilename('fullpath');
[path name] = fileparts(fullpath);
% curve_name = 'ita_param_Custom1.raw';
curve_name = 'ita_param_Custom4.raw';

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
        ucInt = fread(fid, 1, 'uint8');               %INT(1bytes) 7
        ucRes = fread(fid, 1, 'uint8');                %RES(1bytes) 8
%         disp([ucGain, ucInt, ucRes]);
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
        cSheBeiBianHao = fread(fid, 1, 'uint8');        %设备编号 30
        cZhiJuHao = fread(fid, 1, 'uint8');        %治具号 31
        cKaChaoHao = fread(fid, 1, 'uint8');        %模组卡位号32
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

        usFocusArray = fread(fid, usFocusArrayLength/2, 'int16');   %焦温矩阵(数组) 
        disp(usFocusArray');      
%         figure(1);hold on;title(file);          
        for i = 1:usFocusArrayLength/2
            curve_data_distance05(i, :) = fread(fid, usCurveTemperatureNumber, 'uint16');%曲线 0.5m
            curve_data_distance12(i, :) = fread(fid, usCurveTemperatureNumber, 'uint16');
        end
        
%         for i = 1:usFocusArrayLength/2
%             K_array22(i, :) = fread(fid, usWidth*usHeight, 'uint16');%K
%         end   
        fclose(fid);
    end
%        %画曲线
%     figure(2);
%     for i = 1:usFocusArrayLength/2
%         plot (1:6300,curve_data_distance05(i,:));hold on ;
%     end
    %% 写曲线数据包
    if transform_open == 1
        if ~exist('Custom4')
            mkdir('Custom4');
        end
        fid = fopen([[path '/Custom4'] '/' curve_name], 'w');  
        
        ucFocusNumber = 7;
        ucCurveNumber = ucFocusNumber*ucDistanceNumber;
        usFocusArrayLength = ucFocusNumber*2;
        usCurveTemperatureNumber = 6300;
        usCurveDataLength = usCurveTemperatureNumber*2*usFocusArrayLength;
        usKMatLength = usWidth*usHeight*2*ucFocusNumber;
        
        [a b c ] = xlsread('Y16记录表_定制范围4.xls');      
        m_data = a(1:2,2:9);        
%         m_data = cellfun(@str2num,m_data);
        usFocusArray = (m_data(1:2,1))' * 100;    % 焦温数组
        %20240402 新探测器扩容焦温增加8℃
         usFocusArray = [-4000, -3000, -2000, -1000+800, usFocusArray(1)+800, usFocusArray(2)+800, 2000+800];    % 焦温数组
                
        %-10℃环温对应曲线     
        Data_10(1:7,1)=[70	90	150	200	300	400 600];    %High  
        Data_10(1:7,2)=(m_data(1,2:8))';
        Data_10(:,2) =  Data_10(:,2) - Data_10(2,2) + 1000;
        nCurve(5,:) = Curve_High(Data_10);
%       plot( nCurve(2,:))
         %0℃环温对应曲线     
        Data_0(1:7,1)=[70	90	150	200	300	400 600];    %High  
        Data_0(1:7,2)=(m_data(2,2:8))';   
        Data_0(:,2) =  Data_0(:,2) - Data_0(2,2) + 1000;
        nCurve(6,:) = Curve_High(Data_0);
        
%         %23℃环温对应曲线
%         Data_23(1:11,1)=[70	90	110	150	200	250	300	350	400 440 600];
%         Data_23(1:11,2)=(m_data(3,2:12))';
%         Data_23(:,2) =  Data_23(:,2) - Data_23(2,2) + 1000;
%         nCurve(4,:) = Curve_High(Data_23);
%         
%         %33℃环温对应曲线
%         Data_33(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];
%         Data_33(1:11,2)=(m_data(4,2:12))'; 
%         Data_33(:,2) =  Data_33(:,2) - Data_33(2,2) + 1000;
%         nCurve(5,:) = Curve_High(Data_33);
% 
%           %43℃环温对应曲线
%         Data_43(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];
%         Data_43(1:11,2)=(m_data(5,2:12))'; 
%         Data_43(:,2) =  Data_43(:,2) - Data_43(2,2) + 1000;
%         nCurve(6,:) = Curve_High(Data_43);
        
        nCurve(4, :) = nCurve(5, :) + (usFocusArray(4)-usFocusArray(5))/(usFocusArray(5)-usFocusArray(6))*(nCurve(5,:) - nCurve(6,:));      %曲线
        nCurve(3, :) = nCurve(5, :) + (usFocusArray(3)-usFocusArray(5))/(usFocusArray(5)-usFocusArray(6))*(nCurve(5,:) - nCurve(6,:));
        
        nCurve(7, :) = nCurve(6, :) + (usFocusArray(7)-usFocusArray(6))/(usFocusArray(6)-usFocusArray(5))*(nCurve(6,:) - nCurve(5,:));
        
        nCurve(2, :) = nCurve(3, :);
        nCurve(1, :) = nCurve(2, :);
%         
        figure(1)
        for i = 1:ucFocusNumber 
            plot(nCurve(i,:))
            hold on 
        end
        fwrite(fid,  usHeadLength, 'int32');         %216 文件头长度(4bytes) 0
        fwrite(fid, cModuleMtMark, 'char');        %1 模组测温标识符(60bytes) 1
        fwrite(fid, ucGearMark, 'uint8');           %2 高温/常温数据包标记位(1bytes) 2
        fwrite(fid, ucFocusNumber, 'uint8');        %焦温点数 N(1bytes) 3
        sTMin = -50;
        sTMax = 580;
        fwrite(fid, sTMin, 'int16');                %最小测量温度 Tmin(2bytes) 4
        fwrite(fid, sTMax, 'int16');               %最大测量温度 Tmax(2bytes) 5
        fwrite(fid, ucGain, 'uint8');               %GAIN(1bytes) 6 
        fwrite(fid, ucInt, 'uint8');                %INT(1bytes) 7
        fwrite(fid, ucRes, 'uint8');                %RES(1bytes) 8
%         disp([ucGain, ucInt, ucRes]);
        fwrite(fid, ucCurveNumber, 'uint8');        %曲线条数S（1bytes) 9
        fwrite(fid, ucDistanceCompensateMode, 'uint8');%距离补偿模式M（1bytes) 10
        fwrite(fid, ucDistanceNumber, 'uint8');     %距离点D个数（1bytes) 11
        usWidth_new = 384;
        usHeight_new = 288;
        fwrite(fid, usWidth_new, 'uint16');             %图像宽(2bytes) 12
        fwrite(fid, usHeight_new, 'uint16');            %图像高(2bytes)13
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
        fwrite(fid, cSheBeiBianHao, 'uint8');        %设备编号 30
        fwrite(fid, cZhiJuHao, 'uint8');        %治具号 31
        fwrite(fid, cKaChaoHao, 'uint8');        %模组卡位号32
        fwrite(fid, cDingBiaoHeiTiNumber, 'uint8');        %定标黑体个数33
        fFocusType =  0; 
        fwrite(fid, fFocusType, 'uint8');    %校验误差（10*4bytes）34
        fFieldType =  0; 
        fwrite(fid, fFieldType, 'uint8');    %校验误差（10*4bytes）34
        fMtTpye = 6; 
        fwrite(fid, fMtTpye, 'uint8');    %校验误差（10*4bytes）34
        fwrite(fid, fCorrectDistance, 'float');    %校验误差（10*4bytes）34
        fwrite(fid, fCorrectError, 'uint8');    %校验误差（10*4bytes）34
        fwrite(fid, usMTPointX, 'uint16');       %标定点坐标x（2bytes）35
        fwrite(fid, usMTPointY, 'uint16');       %标定点坐标y（2bytes）36
        
        sensor_para(2,1:10) = 90;   %INT_Set
        sensor_para(3,1:10) = 5;    %Gain
        sensor_para(4,1:10) = 14;   %RA_SEL
        sensor_para(5,1:10) = 64;   %HSSD
        sensor_para(6,1:10) = 12;   %GFID
        sensor_para(7,1:10) = 7;    %RC
        sensor_para(8,1:10) = 2;    %RD
        sensor_para(9,1:10) = 2;    %REF_RD
        sensor_para(10,1:10) = 4;   %SKIM_NUC_STEP_ADJ
        sensor_para(11,1:10) = 3;   %SKIM_GFID_REF_STEP_ADJ
        sensor_para(12,1:10) = 255; %VBUS
        sensor_para(13,1:10) = 0;   %GSK_OP2
        sensor_para(14,1:10) = 22;  %Nmiddle
        sensor_para(15,1:10) = 18;  %Csize
        sensor_para(16,1:10) = 5000;%NUC_LOW_fine
        sensor_para(17,1:10) = 6000;%NUC_High_fine
        sensor_para(18,1:10) = 4500;%NUC_LOW_coarse
        sensor_para(19,1:10) = 6500;%NUC_High_coarse
        sensor_para(20,1:10) = 4000;%HSSD_LOW
        sensor_para(21,1:10) = 7000;%HSSD_HIGH
        sensor_para(22,1:10) = 2000;%RA_SEL_LOW
        sensor_para(23,1:10) = 10000;%RA_SEL_HIGH
        sensor_para(24:70,1:10) = 0;%RA_SEL_HIGH
               
        if usWidth == 120        
            fwrite(fid, sensor_para, 'uint8');      %探测器参数（30bytes）
        else
            fwrite(fid, sensor_para, 'uint16');      %探测器参数（30bytes）
        end
        fwrite(fid, usFocusArray, 'int16');     %焦温矩阵(数组) （10bytes）
               
           
        for i = 1:usFocusArrayLength/2
            fwrite(fid, nCurve(i, :), 'uint16');      %曲线 0.5m
            fwrite(fid, nCurve(i, :), 'uint16');
            figure(1),hold on, plot(nCurve(i, :));
        end
        
        fclose(fid);
    end    
    
end


function [nCurve] = Curve_High(Data)
    ADmin = 1;
    ADmax =6300;
    Order = 3;
    AD_array = Data(:,2);
    T_array = Data(:,1) * 10;
    p = polyfit(T_array,AD_array, Order); %3次拟合
    nCurve = polyval(p,ADmin:ADmax);
%     plot(nCurve);
%     hold on,plot(T_array,AD_array,'o');
end