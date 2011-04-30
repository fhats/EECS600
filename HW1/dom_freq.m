function [ max_freqs ] = dom_freq( snd, fs, snd_start, snd_end )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [S, F, T] = spectrogram(snd(snd_start:snd_end),[],[],[],fs);
    samples = size(S, 2);
    max_freqs = [];
    for i=1:samples,
        [fmax, index] = max(S(:,i));
        max_freqs = horzcat(max_freqs, F(index));
    end

end

