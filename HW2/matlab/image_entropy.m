function [ entropy ] = image_entropy( image, bins )
%image_entropy takes an image and a number of bins and estimates the
%entropy of the image
%   Detailed explanation goes here

    entropy = 0;
    
    [n, x] = imhist(image, bins);
    
    total_samples = size(image, 1) * size(image, 2);
    
    for i=1:length(n),
        bucket_size = n(i);
        if bucket_size > 0,
            probability = (bucket_size / total_samples);
            entropy = entropy + (probability * log2(probability));
        end
    end
    
    entropy = -entropy;
end

