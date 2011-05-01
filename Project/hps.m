function [ pitches ] = hps( w, Fs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    % define the number of harmonics we want to consider
    harmonics = 5;
    
    segment_size = 512;
    
    pitches = [];
    
    for i=1:segment_size/16:length(w) - segment_size,
        
        segment = w(i:i+segment_size) .* hamming(segment_size+1);
        %segment = [segment; zeros(segment_size * 15, 1)];
        
        power_spec = log( abs( fft(segment, 4096) ) );
        
        d_s_sum = zeros(length(power_spec), 1);
        for n=1:harmonics,
            d_s = downsample(power_spec, n);
            d_s_sum(1:length(d_s)) = d_s_sum(1:length(d_s)) + d_s;
            d_s_sum = d_s_sum(1:length(d_s));
        end
        
        prod = exp(2 * d_s_sum);
        
        frequency_range = 0:Fs/(length(power_spec)):Fs;
        
        [max_val index] = max(prod);
        
        detected_pitch = frequency_range(index);
        
        pitches = [pitches, nearest_note(detected_pitch)];
        
    end

end

