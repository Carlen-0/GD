% 将5个焦温点的曲线，打包生成7条
% 增加两个焦温点  【0℃、65℃】2024 04 02 新探测器修改增加两个焦温点  【0℃、75℃】
% 读取一个打包的.raw 数据包
%% 
clear;clc;close all;
read_open = 1;
transform_open = 1;
test_open = 0;

fullpath = mfilename('fullpath');
[path name] = fileparts(fullpath);
% curve_name = 'ita_param_Low.raw';

lens_folder = '\CurveData'; %根据镜头数命名的文件夹
path_lens=fullfile(path,lens_folder); %镜头数路径
files = dir(fullfile(path_lens)); %文件夹
folder_nums = size(files,1);% 文件夹里文件数
folder_names = { };
for i=3:folder_nums     %获取所有文件夹名，文件中子文件夹的名称是从第3位开始的，这里需要注意
    folder_names{i-2} = files(i,1).name;
end
%---------批量处理------------%
equipment_number = length(folder_names);  %设备数，批量处理的个数
for k=1: equipment_number 
path_excel_data = fullfile(path_lens,folder_names(k)); %Excel数据存放的路径
% path_curve_data= fullfile(path_lens,folder_names(k),'\High'); %曲线包存放的路径
path_curve_data= fullfile(path_lens,folder_names(k)); %曲线包存放的路径
curve_name = 'ita_param_Custom1.raw';

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

        usFocusArray = fread(fid, usFocusArrayLength/2, 'uint16');   %焦温矩阵(数组) 
%         disp(usFocusArray');      
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
            if ~exist(path_curve_data{1});
               mkdir(path_curve_data{1});
            end
         fid = fopen([[path_curve_data{1}] '\' curve_name], 'w');
        
        ucFocusNumber = 7;
        ucCurveNumber = ucFocusNumber*ucDistanceNumber;
        usFocusArrayLength = ucFocusNumber*2;
        usCurveTemperatureNumber = 6300;
        usCurveDataLength = usCurveTemperatureNumber*2*usFocusArrayLength;
        usKMatLength = usWidth*usHeight*2*ucFocusNumber;
        
%         [a b c ] = xlsread('Y16记录表_定制范围1.xls');      
        data_excel_name =  'Y16记录表_100~550.xlsx';
        [a b c ] = xlsread([[path_excel_data{1}] '\' data_excel_name]); 
        m_data = a(1:5,2:13);        
%         m_data = cellfun(@str2num,m_data);
        usFocusArray = (m_data(1:5,1))' * 100;    % 焦温数组
        
 %         20240402 新探测器焦温扩容数据修改
%          usFocusArray = [500, usFocusArray(1), usFocusArray(2), usFocusArray(3),usFocusArray(4) ...
%             usFocusArray(5), 6500];    % 焦温数组
        
        usFocusArray = [500+800, usFocusArray(1), usFocusArray(2), usFocusArray(3),usFocusArray(4) ...
            usFocusArray(5), 6500+800];    % 焦温数组
        
        %3℃环温对应曲线     
        Data_3(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];    %High  
        Data_3(1:11,2)=(m_data(1,2:12))';
        Data_3(:,2) =  Data_3(:,2) - Data_3(2,2) + 1000;
        nCurve(2,:) = Curve_Custom1(Data_3);
%       plot( nCurve(2,:))
         %13℃环温对应曲线     
        Data_13(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];    %High  
        Data_13(1:11,2)=(m_data(2,2:12))';   
        Data_13(:,2) =  Data_13(:,2) - Data_13(2,2) + 1000;
        nCurve(3,:) = Curve_Custom1(Data_13);
        
        %23℃环温对应曲线
        Data_23(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];
        Data_23(1:11,2)=(m_data(3,2:12))';
        Data_23(:,2) =  Data_23(:,2) - Data_23(2,2) + 1000;
        nCurve(4,:) = Curve_Custom1(Data_23);
        
        %33℃环温对应曲线
        Data_33(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];
        Data_33(1:11,2)=(m_data(4,2:12))'; 
        Data_33(:,2) =  Data_33(:,2) - Data_33(2,2) + 1000;
        nCurve(5,:) = Curve_Custom1(Data_33);

          %43℃环温对应曲线
        Data_43(1:11,1)=[70	90	110	150	200	250	300	350	400 435 600];
        Data_43(1:11,2)=(m_data(5,2:12))'; 
        Data_43(:,2) =  Data_43(:,2) - Data_43(2,2) + 1000;
        nCurve(6,:) = Curve_Custom1(Data_43);
        
        nCurve(1, :) = nCurve(2, :) + (usFocusArray(1)-usFocusArray(2))/(usFocusArray(2)-usFocusArray(3))*(nCurve(2,:) - nCurve(3,:));      %曲线
        nCurve(7, :) = nCurve(6, :) + (usFocusArray(7)-usFocusArray(6))/(usFocusArray(6)-usFocusArray(5))*(nCurve(6,:) - nCurve(5,:));

% %针对个别设备，扩展高温曲线时，增加响应率非线性衰减参数kxyl，以3个环温两两间450℃y16差值的比值为系数
%         kxyl = (nCurve(6,5000)-nCurve(5,5000))/(nCurve(5,5000)-nCurve(4,5000))
%         nCurve(7, :) = nCurve(6, :) + kxyl * (usFocusArray(7)-usFocusArray(6))/(usFocusArray(6)-usFocusArray(5))*(nCurve(6,:) - nCurve(5,:));
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
        fMtTpye = 3; 
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
        fwrite(fid, usFocusArray, 'uint16');     %焦温矩阵(数组) （10bytes）
               
           
        for i = 1:usFocusArrayLength/2
            fwrite(fid, nCurve(i, :), 'uint16');      %曲线 0.5m
            fwrite(fid, nCurve(i, :), 'uint16');
            figure(1),hold on, plot(nCurve(i, :));
        end
        disp(path_curve_data);
        disp(usFocusArray);   
        
        fclose(fid);
    end    
    
end
end

