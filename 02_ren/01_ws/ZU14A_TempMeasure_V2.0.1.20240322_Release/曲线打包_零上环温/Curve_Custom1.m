function [nCurve] = Curve_Custom1(Data)
    ADmin = 1;
    ADmax =6300;
    Order = 3;
    AD_array = Data(:,2);
    T_array = Data(:,1) * 10;
    p = polyfit(T_array,AD_array, Order); %3´ÎÄâºÏ
    nCurve = polyval(p,ADmin:ADmax);
%     plot(nCurve);
%     hold on,plot(T_array,AD_array,'o');
end