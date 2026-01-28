r=[500,500,350,350,350]; % radii of the radars in km
n = length(r); % # of radars
res = 1; % resolution of the terrain in km^2
maxheights = [30 30 15 15 15]; % maximum height of the radars in km

%% Terrain generation
xsize = 2049;
ysize = 2049;
xgrid = 1:1:xsize;
ygrid = 1:1:ysize; 
iterations = 5;
mesh_size = 2049;
h0 = 4;
r0 = 2;
rr = 3;
seed = 1;

[x, y, h, hm, xm, ym] = generate_terrain(iterations, mesh_size, h0, r0, rr, seed);
max(max(hm))
min(min(hm))
%%
surf(xgrid, ygrid, max(hm, 0), 'EdgeColor','none'); hold on
axis equal
c = colorbar;
c.Label.String = 'Maaston korkeus (km)';
%% 
[px, py] = peaks(hm); % coordinates of the peaks in the terrain
p = [px py];
M = length(px); % amount of peaks

lb = ones(1,n);
ub = M * ones(1,n); % bounds for this binary problem
intcon = 1:n;

%% Set Genetic Algorithm options (requires Global Optimization Toolbox)
options = optimoptions('ga','Display','iter','UseParallel',true);

%% Run the genetic algorithm to minimize the negative covered volume.
[x_opt, fval] = ga(@(X) cost(n, [px(X), py(X)], hm, r, res, maxheights), n, [], [], [], [], lb, ub, [], intcon, options);

opt_coords = [px(x_opt), py(x_opt)];
maxVolume = volumeCovered(n, opt_coords, hm, r, res, maxheights);

fprintf('Maximum covered volume: %f km^3\n', maxVolume);
fprintf('Optimal radar positions (x, y):\n');
disp(opt_coords);

%%
cm = generate_terrain_colors(hm);
%%
surf(xgrid, ygrid, max(hm, 0), cm);    % Make figure (and flatten ocean).
set(gca, 'Position', [0 0 1 1]); % Fill the figure window.
set(gca,'XTick',[], 'YTick', [])
axis equal            % Set aspect ratio and turn off axis.
shading interp;                  % Interpolate color across faces.
material dull;                   % Mountains aren't shiny.
camlight left;                   % Add a light over to the left somewhere.
lighting gouraud;                % Use decent lighting.
for i = 1:n
    plotRadarScan(opt_coords(i,1), opt_coords(i,2), r(i), maxheights(i), 100, hm);
end
%% Debug
surf(xgrid, ygrid, max(hm, 0), 'EdgeColor','none'); hold on
axis equal
colorbar