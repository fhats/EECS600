function [ nearest_freq ] = nearest_note( fn )
%nearest_note
%   returns the nearest note in a 12-tone equal-tempered scale that is
%   configured to A4 = 440Hz. Useful for pitches that are close to a pitch
%   but not right on.
    
    % constants used for this calculation
    a = 2 ^ (1/12);         % we're using an equal-tempered scale
    f0 = 440;               % typical base of 440 Hz
    
    n = ( log10(fn) - log10(f0) ) / log10(a);
    
    steps = round(n);
    
    % return the frequency of the note that it is close to
    nearest_freq = f0 * ((a)^steps);
    
end

