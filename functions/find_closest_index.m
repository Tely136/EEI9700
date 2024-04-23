function [row, col] = find_closest_index(matrix, targetNumber)
    % Compute the absolute difference between the target number and each element
    differences = abs(matrix - targetNumber);
    
    % Find the linear index of the minimum difference
    [~, linearIndex] = min(differences(:));
    
    % Convert the linear index to row and column indices
    [row, col] = ind2sub(size(matrix), linearIndex);
end
