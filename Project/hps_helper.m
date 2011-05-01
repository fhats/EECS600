function [ pitch ] = cheating( x, Fs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    fx=log(abs(fft(x,2048)));
    len=length(fx);
    fx1=fx(1:2:len); %harmonic compression
    fx2=fx(1:3:len);
    fx3=fx(1:4:len);
    fx4=fx(1:5:len);
    len4=length(fx4);
    Px=2*(fx(1:len4)+fx1(1:len4)+fx2(1:len4)+fx3(1:len4)+fx4(1:len4));
    F=0:Fs/(len):Fs;
    [m,I]=max(exp(Px(1:len4)));
    plot(exp(Px(1:len4)));
    pitch=F(I);
    
    e_s = exp(Px(1:len4));
    pitch = [];
    pks = e_s > (0.5 * 10^7)
    for i=1:length(pks),
        if pks(i) > 0
            pitch = [pitch F(i)];
        end
    end
    
end

