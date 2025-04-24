function [nCurve] = Curve_Higher(Data)
    Tmax = 25000;
    Tmin = 1;
    
    Order = 2;
    AD_array = Data(:,2);
    T_array = Data(:,1) * 10;
    T_array = round(T_array);
    
    len = length(Data);
    if(rem(len,2) > 0)
        a = (len-1)/2;
    else
        a = len/2;
    end
    
    if(rem(len,2) > 0)
        for i=1:a(1)
            p= polyfit(T_array(2*i-1:2*i+1,1), AD_array(2*i-1:2*i+1,1),Order); %????
            b(1:3,i) = p;
        end
    else
        for i=1:a-1
            p= polyfit(T_array(2*i-1:2*i+1,1), AD_array(2*i-1:2*i+1,1),Order); %????
            b(1:3,i) = p;
        end
        p = polyfit(T_array(2*a(1)-2:2*a(1),1), AD_array(2*a(1)-2:2*a(1),1),Order);
        b(1:3,a(1)) = p;
    end
    
    v=Tmin : T_array(3);
    yi(v) = polyval(b(1:3,1),v); %??????????
    
    for i=2:a(1)-1
        v=T_array(2*i-1) : T_array(2*i+1);
        yi(v) = polyval(b(1:3,i),v); %??????????
    end
    
    v=T_array(2*a-1) : Tmax;
    yi(v) = polyval(b(1:3,a),v); %??????????    
    
    v=Tmin : Tmax;
    nCurve = round(yi);
    figure(1);
        
    plot(T_array,AD_array,'o',v,nCurve,'-r'); hold on    
end
