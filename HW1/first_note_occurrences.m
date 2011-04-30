% first_note_occurrences.m
% Finds the locations of a given note in a recording.
% Fred Hatfull (fxh32)
% 2011-14-2

function [ times ] = first_note_occurrences( snd, fs, offset )
%first_note_occurrences returns the locations a template is found at
%   this function creates a template from a specified time-slice of a
%   spectrogram and convovlves each time slice of the spectrogram against
%   that template to try to detect when a sound similar to the template is
%   played

    %first take the spectrogram of the sound waveform
    %try for 512 slices, but work with whatever spectrogram() can give us
    %back
    [S,F,T] = spectrogram(snd, 512, [], [], fs);
    
    occurrences = [];
    
    %the frequency template of the note
    template = S(:,offset);
    
    %find the index into the convolution matrix for the frequency of the
    %fundamental for the note we care about
    template_c = conv(template, template);
    [t_, index] = max(template_c);
    
    % convolve the template with each slice of the spectrogram
    for i=1:size(S,2),
        c = conv(template, S(:,i));
        mag = c(index);
        occurrences = horzcat(occurrences, mag);
    end
    
    %find the areas where the desired frequency is the most intense after
    %convolving
    %use thresholding to exclude small peaks that occur due to harmonics of
    %other notes including notes with fundamentals octaves apart from the
    %template note
    threshold = abs(max(template_c)) * 0.6;
    [peaks, locations] = findpeaks(abs(occurrences), 'minpeakheight', threshold);
    times = [];
    for i=1:length(locations),
        times = horzcat(times, (length(snd)/fs) * (locations(i)/length(S)));
    end
    
end

