function f = cost(n, coords, hm, r, res, maxheights)
   penalty = 0;
   volume = volumeCovered(n, coords, hm, r, res, maxheights);
   [rows, cols] = size(hm);
    
    for i = 1:n
        x = coords(i,1);
        y = coords(i,2);

        dx = min(x - 1, cols - x);
        dy = min(y - 1, rows - y);

        dist_to_edge = min(dx, dy); % shortest distance to any edge

        if dist_to_edge < r(i)
            penalty = penalty + (r(i) - dist_to_edge)^2;
        end

        for j = i+1:n
            dmin = r(i)+r(j); % minimum allowed distance between radars
            dist = norm(coords(i,:) - coords(j,:));
            if dist < dmin
                penalty = penalty + (dmin - dist)^2;  % Quadratic penalty
            end
        end
    end

% Combine volume with penalty
    f = -volume + 1e4 * penalty;  % Weight penalty; adjust multiplier as needed
end
