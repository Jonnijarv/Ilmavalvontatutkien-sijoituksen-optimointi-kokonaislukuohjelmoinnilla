function V = volumeCovered(nRadars, radarpos, terrain, radii, resolution, maxheights)
    [nrows, ncols] = size(terrain);
    terrain = terrain/1000;
    
    % Preallocate visible volume map (in km)
    visibleHeight = zeros(nrows, ncols);  % height in km

    for i = 1:nRadars
        x0 = round(radarpos(i,1));
        y0 = round(radarpos(i,2));
        rmax = radii(i);           % in km
        rz   = maxheights(i);      % in km
        z0   = terrain(y0, x0);  % radar terrain base in km

        % Clamp radar position
        x0 = min(max(x0, 1), ncols);
        y0 = min(max(y0, 1), nrows);

        % Compute beam slope
        upperSlope = rz / rmax;  % tan(theta)

        % Build boundary points at ~rmax
        endpoints = [];
        for dx = -rmax:rmax
            dy = floor(sqrt(rmax^2 - dx^2));
            endpoints(end+1,:) = [x0+dx, y0+dy];   %#ok<AGROW>
            endpoints(end+1,:) = [x0+dx, y0-dy];   %#ok<AGROW>
        end
        % Clamp to grid and remove duplicates
        endpoints(:,1) = min(max(endpoints(:,1),1), ncols);
        endpoints(:,2) = min(max(endpoints(:,2),1), nrows);
        endpoints = unique(endpoints, 'rows');

        % Ray-cast to each boundary point
        for k = 1:size(endpoints,1)
            xE = endpoints(k,1);
            yE = endpoints(k,2);
            d = hypot(xE - x0, yE - y0);
            nSteps = ceil(d);
            xLine = round(linspace(x0, xE, nSteps));
            yLine = round(linspace(y0, yE, nSteps));

            maxTerrainAngle = -Inf;
            for s = 2:nSteps
                xi = xLine(s);
                yi = yLine(s);
                if xi < 1 || yi < 1 || xi > ncols || yi > nrows, continue; end

                % Dist in km
                dist = hypot(xi - x0, yi - y0);
                if dist > rmax, break; end

                terrainHeight = terrain(yi, xi);  % in km
                terrainAngle = (terrainHeight - z0)/dist;

                % Beam top height at this distance
                beamTopHeight = z0 + dist * upperSlope;

                % If beam is above terrain (any part visible)
                if beamTopHeight > terrainHeight
                    % Obstruction check: how high is the terrain so far?
                    if terrainAngle > maxTerrainAngle
                        % Only count height above terrain that is not blocked
                        visible = beamTopHeight - terrainHeight;  % km
                        visibleHeight(yi, xi) = max(visibleHeight(yi, xi), visible);
                        maxTerrainAngle = terrainAngle;  % update horizon
                    else
                        visible = beamTopHeight - dist*maxTerrainAngle-z0;
                        visibleHeight(yi, xi) = max(visibleHeight(yi, xi), visible);
                    end
                else
                    break;  % beam blocked at this ray
                end
            end
        end
    end

    % Total volume in km³
    V = sum(visibleHeight(:)) * resolution^2;
end