function [output, i] = reshape_remove_nan(A,ind)
    arguments
        A
        ind = []
    end

    if isempty(ind)
        i = isnan(A);
        A(i) = [];
        
        output = reshape(A, [], 1);

    else
        A(ind) = [];
        output = reshape(A, [], 1);
        i = ind;

    end

end

