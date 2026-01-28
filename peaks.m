function [i,j] = peaks(h)

    % Get all 8 neighbor matrices
    c  = h(2:end-1, 2:end-1);   % center (original h)
    tl = h(1:end-2, 1:end-2);   % top-left
    t = h(2:end-1, 1:end-2);   % top
    tr = h(3:end, 1:end-2);     % top-right
    l = h(1:end-2, 2:end-1);   % left
    r = h(3:end, 2:end-1);     % right
    bl = h(1:end-2, 3:end);   % bottom-left
    b = h(2:end-1, 3:end);   % bottom
    br = h(3:end, 3:end);     % bottom-right

    % Logical condition: center ≥ all 8 neighbors
    isPeak = c >= tl & c >= t & c >= tr & ...
             c >= l & c >= r & ...
             c >= bl & c >= b & c >= br & c > 0;

    % Extract indices and values
    peaks = find(isPeak);
    [j,i] = ind2sub(size(isPeak), peaks);
    %i = ii + minr;
    %j = jj + minr;