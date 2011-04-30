% bach_first_note_occurrences.m
% A script to read a file and use first_note_occurrences on it
% Fred Hatfull (fxh32)
% 2011-14-2
[snd, fs] = wavread(uigetfile('*','Select a WAV file to analyze','.'));
first_note_occurrences(snd, fs, 2)