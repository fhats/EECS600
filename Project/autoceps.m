function [ ac ] = autoceps( x )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    fftxabs = abs(fft(x));
    ac = real(ifft(log(fftxabs.^2)));

end

