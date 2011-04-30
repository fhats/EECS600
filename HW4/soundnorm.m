function y = soundnorm(x)
    % normalize a .wav sound to range [-1, 1] so it doesn't clip when played.
    y = (x - mean(x))/(max(x) - min(x));
    