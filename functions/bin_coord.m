function [min_i,min_j] = bin_coord(lat_target,lon_target, lat_grid, lon_grid)

    A = ones(size(lat_grid));
    
    [~, m] = min(abs(lat_grid-lat_target), [], 'all', 'linear');
    lat1 = lat_grid(m);
    lat2 = lat_grid(m-1);
    
    
    ind = lat_grid >= lat1  & lat_grid <= lat2;
    
    min_d = inf;
    min_i = 0;
    min_j = 0;
    for i = 1:size(ind,1)
        for j = 1:size(ind,2)
            lat = lat_grid(i,j);
            lon = lon_grid(i,j);
    
            d = haversine_distance(lat_target, lon_target, lat, lon);
            if d < min_d
                min_d = d;
                min_i = i;
                min_j = j-1;
            end           
        end
    end
    
    A(min_i, min_j) = 0;
end

