function [ pitches ] = hps( w, Fs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    % define the number of harmonics we want to consider
    harmonics = 5;
    
    segment_size = 512;
    
    pitches = [];
    
    for i=1:segment_size/2:length(w) - segment_size,
        
        segment = w(i:i+segment_size) .* hamming(segment_size+1);
        segment = [segment; zeros(segment_size * 15, 1)];
        
        power_spectrum = log(abs(fft(segment)));
        
        summed_ds = zeros(length(segment), 1);
        % perform downsampling
        for n=1:harmonics,
            d_s = downsample(segment,n);
            summed_ds(1:length(d_s)) = summed_ds(1:length(d_s)) + d_s;
        end
        
        summed_ds = summed_ds * 2;
        product = exp(summed_ds);
        
        [max_val, index] = max(product);
        
        F = 0:Fs/(length(segment)):Fs;
        
        pitches = [pitches, F(index)];
        
    end

end

