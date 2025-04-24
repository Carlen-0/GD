function [nCurve] = Curve_Low(Data)
    ADmin = 1;
    ADmax =2300;
    Order = 2;
    AD_array = Data(:,2) ;
    T_array = Data(:,1) * 10;
    p = polyfit(T_array,AD_array, Order); %2´ÎÄâºÏ
    nCurve = polyval(p,ADmin:ADmax);
%     plot(nCurve);
%     hold on,plot(T_array,AD_array,'o');
end