function [ dom_freqs ] = dom_freqs( snd, fs, snd_start, snd_end )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    i = snd_start;
    sample_size = fs * 0.4; % use .4 second samples if possible
    dom_freqs = [];
    while i < snd_end,
        c_start = i;
        c_end = c_start + sample_size;
        if c_end > snd_end,
            c_end = snd_end;
        end
        
        dom_freqs = horzcat(dom_freqs, dom_freq(snd, fs, c_start, c_end));
        
        i = c_end;
    end

end

