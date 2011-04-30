function [ times ] = first_note_intensity( snd, fs, offset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [S,F,T] = spectrogram(snd, 512, [], [], fs);
    
    figure(1);
    spectrogram(snd, 512, [], [], fs, 'yaxis')
    occurrences = [];
    template = S(:,offset);
    
    c = conv(template, template);
    [t_, index] = max(c);
    
    for i=1:size(S,2),
        c = conv(template, S(:,i));
        mag = c(index);
        occurrences = horzcat(occurrences, mag);
    end
    
    figure(2);
    plot(abs(occurrences))
    
    threshold = abs(max(c)) * 0.641;
    [peaks, locations] = findpeaks(abs(occurrences), 'minpeakheight', threshold);
    times = [];
    for i=1:length(locations),
        times = horzcat(times, (length(snd)/fs) * (locations(i)/length(S)));
    end
    
end

