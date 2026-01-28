function plotRadarScan(x0, y0, rmax, rz, num_rays, hm)
    z0 = hm(y0,x0);
   
    for theta = linspace(0, 2*pi, num_rays)
        x_end = x0 + rmax * cos(theta);
        y_end = y0 + rmax * sin(theta);
        z_end = z0 + rz;
        line([y0, y_end], [x0, x_end], [z0, z_end], 'Color', [1 0.1 0.05 0.5]); % Light green rays 
        line([y_end, y_end], [x_end, x_end], [z0, z_end], 'Color', [1 0.1 0.05 0.5])
    end
    
    % Draw radar coverage circle
  
end