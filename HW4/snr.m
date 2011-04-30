function f = snr(s,n)
% compute the signal to noise ratio for signal s and noise n
    f = 10*(log10(mean(s.^2)) - log10(mean(n.^2)));
    