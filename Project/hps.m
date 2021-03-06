function [ pitches ] = hps( w, Fs , stepthru, show_changes )
%hps 
%   Attempts to perform pitch detection based on the harmonic product
%   spectrum algorithm. After the HPS is computed, pitch(es) extracted from
%   the peaks of the spectrum and then "smoothed" in time to reduce
%   misdetection noise. The parameter stepthru should be set to 1 to enable
%   a walkthrough of the HPS as it steps through each window of signal to
%   examine. show_changes, when set to 1, will only output a note when it is different from
%   the note preceding it.
    
    % define the number of harmonics we want to consider
    harmonics = 5;
    
    segment_size = 512;
    smoothing_factor = 30; % a note should exist this many samples in either direction to 'smooth' the signal
    pre_pitches = {};
    
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
        
        max_val = max(prod);
        pks = prod > (max_val * 0.25);
        detected_pitches = [];
        for p=1:length(pks),
            if pks(p) > 0
                detected_pitch = frequency_range(p);
                detected_pitches = [detected_pitches nearest_note(detected_pitch)];
            end
        end
        unique_pitches = unique(detected_pitches);
        pre_pitches = [pre_pitches; unique_pitches];
        
        if stepthru == 1
            figure(1)
            plot(prod);
            unique_pitches
            pause
        end
    end

    pitches = {};
    % post-processing
    for i=1:size(pre_pitches,1),
        r_min = max(1,i-smoothing_factor);
        r_max = min(size(pre_pitches,1), i+smoothing_factor);
        ok_pitches = [];
        for p=1:length(pre_pitches{i}),
            pitch = pre_pitches{i}(p);
            
            pre = 1;
            post = 1;
            %check earlier
            for r=r_min:i,
                if isempty(find( pre_pitches{r} == pitch )), pre = 0; end
            end
            %check later
            for r=i:r_max,
                if isempty(find( pre_pitches{r} == pitch )), post = 0; end
            end
            
            if pre == 1 || post == 1
                ok_pitches = [ok_pitches pitch];
            end
            
        end
        pitches = [pitches; ok_pitches];
        
    end

    % transform pitches into named notes
    nn = {};
    for p=1:size(pitches,1),
        nnp = [];
        for r=1:length(pitches{p}),
            nnp = [nnp pitch2named_note(pitches{p}(r))];
        end
        nn = [nn; nnp];
    end
    pitches = nn;
    
    if show_changes == 1
        u_pitches = {};
        last_pitch_set = [];
        
        for p=1:size(pitches, 1),
            if ~isempty(setxor(last_pitch_set, pitches{p}))
                u_pitches = [u_pitches; pitches(p)];
                last_pitch_set = pitches{p};
            end
        end
        
        pitches = u_pitches;
    end
end

