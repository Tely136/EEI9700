function [min_i,min_j] = bin_coord(lat_target,lon_target, lat_grid, lon_grid)
    
    min_d = inf;
    min_i = nan;
    min_j = nan;
    for i = 1:size(lat_grid,1)
        for j =1:size(lon_grid,2)
            
            lat = lat_grid(i,j);
            lon = lon_grid(i,j);
    
            d = haversine_distance(lat_target, lon_target, lat, lon);
            if d < min_d
                min_d = d;
                min_i = i;
                min_j = j;
            end
    
        end
    end
end

