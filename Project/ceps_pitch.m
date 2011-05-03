function [ detected_pitches ] = ceps_pitch( w, Fs )
%cep_pitch
%   Breaks a signal into chunks and uses the cepstrum to attempt to
%   determine the dominant pitch in each segment.
    
    ceps_len = 200;
    % define a quefrency range we want to examine
    c_min = 13;
    c_max = ceps_len * .8;
    detected_pitches = [];
    
    for i=1:10:length(w)-ceps_len,
        ceps = autoceps(w(i:i+ceps_len));
        [f fi] = max(ceps(c_min:c_max));
        fi = fi + c_min;
        detected_pitches = [detected_pitches nearest_note(Fs / fi)];
    end

end

