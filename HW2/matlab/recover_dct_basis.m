function [ dct_basis ] = recover_dct_basis(  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    dct_basis = [];
    for i=1:8,
        for j=1:8,
            % Illuminate a single pixel at a time to find the basis fcns
            q = zeros(8);
            q(i,j) = 1;
            % Compute the DCT and reshape the result to fit into the result
            % matrix
            d = dct2(q);
            dct_basis = horzcat(dct_basis, reshape(d, 64, 1));
        end
    end
    % Take the inverse
    dct_basis = dct_basis ^ -1;
    plotBFs(dct_basis);
end

