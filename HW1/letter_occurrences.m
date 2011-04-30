% letter_occurrences.m
% Finds the locations of a given letter in an image of text.
% Fred Hatfull (fxh32)
% 2011-14-2

function [ occurrences ] = letter_occurrences( letter, img, threshold )
    
    % use the normalized 2-D cross correlation to determine how well
    % regions of the image match the given template
    % this will give clusters of high values (close to 1) at the bottom
    % right of each matching segment
    c = normxcorr2(letter, img);
    
    % filter for correlation values above the given threshold
    locations = c(:,:) >= threshold;
    
    occurrences = [];
    
    %return the results as a vector
    for y=1:size(locations, 1),
        for x=1:size(locations, 2),
            if locations(y,x),
                occurrences = vertcat(occurrences, [x y]);
            end
        end
    end
    
end