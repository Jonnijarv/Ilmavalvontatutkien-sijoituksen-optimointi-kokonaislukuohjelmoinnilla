function Vmax = theoreticalMaxVolume(radii, heights)
    Vmax = 0;
    for i = 1:length(radii)
        r=radii(i);
        terrainFlat = zeros(3*r,3*r);
        radarpos = [1.5*r,1.5*r];
        Vmax = Vmax + volumeCovered(1, radarpos, terrainFlat, radii, 1, heights(i));
    end
end