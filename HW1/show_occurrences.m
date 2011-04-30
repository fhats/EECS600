img = imread(uigetfile());
% a nice S to use for a template
letter = img(40:50, 281:287, :);
% found using guess-and-check
% produced no false positives and no false negatives
threshold = 0.79;

% show the results!
imshow(highlight_letter(img, letter, threshold));