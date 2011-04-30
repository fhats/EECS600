% highlight_letter.m
% Uses letter_occurrences() to find the areas of an image where there is
% most likely to be a match for a certain letter and draw a bounding box
% around the region to highlight the location of the detected letter.
% Fred Hatfull (fxh32)
% 2011-14-2


function [ final_img ] = highlight_letter( img, letter, threshold )

    % first grayscale our images (to simplify the cross-correlation -
    % there's no need to be doing 3-D cross correlation!)
    g_img = rgb2gray(img);
    g_letter = rgb2gray(letter);
    
    % get the detected locations of the letters
    locations = letter_occurrences(g_letter, g_img, threshold);
    
    % build a new image from the input
    final_img = img;
    
    % draw the bounding boxes on the newly constructed image
    for i=1:size(locations,1),
        x = locations(i,1);
        y = locations(i,2);
        for k=y-size(letter,1):y+1,
            for j=x-size(letter,2):x+1,
                if j == x-size(letter,2) || j == x+1 || k == y-size(letter,1) || k == y+1, 
                    final_img(k,j,1) = 255;
                    final_img(k,j,2) = 0;
                    final_img(k,j,3) = 0;
                end
            end
        end
    end
end

