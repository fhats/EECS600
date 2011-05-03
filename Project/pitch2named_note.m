function [ named_note ] = pitch2named_note( pitch )
%pitch2named_note
%   Takes a pitch and returns a note name for the pitch.

    % constants used for this calculation
    a = 2 ^ (1/12);         % we're using an equal-tempered scale
    f0 = 440;               % typical base of 440 Hz
    
    % compute the number of half steps away from A4 the pitch is    
    n = ( log10(pitch) - log10(f0) ) / log10(a);
    n = round(n);

    n_lett = 'A';
    % Any music majors reading this: please don't kill me re: # vs. b
    switch mod(n,12)
        case 0
            n_lett = 'A';
        case 1
            n_lett = 'A#';
        case 2
            n_lett = 'B';
        case 3
            n_lett = 'C';
        case 4
            n_lett = 'C#';
        case 5
            n_lett = 'D';
        case 6
            n_lett = 'D#';
        case 7
            n_lett = 'E';
        case 8
            n_lett = 'F';
        case 9
            n_lett = 'F#';
        case 10
            n_lett = 'G';
        case 11
            n_lett = 'G#';
    end
    
    octave_distance = floor(n / 12);
    if mod(n,12) > 2
        octave_distance = octave_distance + 1;
    end
    octave = 4 + octave_distance;
    
    named_note = strcat(n_lett, int2str(octave));
    
end

