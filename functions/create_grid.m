function [lats, lons] = create_grid(lat_bounds, lon_bounds, L_lat, L_lon)
    
    Req = 6371 * 10^3;
    
    latstart = lat_bounds(1);
    latend = lat_bounds(2);
    
    lonstart = lon_bounds(1);
    lonend = lon_bounds(2);
    
    n_lats = floor((latend-latstart)*pi*Req/(180*L_lat));
    n_lons = floor((lonend-lonstart)*pi*Req/(180*L_lon));
    
    lats = zeros(n_lats, n_lons);
    lons = zeros(n_lats, n_lons);
    
    
    lat1 = latstart;
    
    lon1 = lonstart;
   
    lats(1,1:end) = lat1;
    lons(1:end,1) = lon1;
    
    for i=1:n_lats
        lat2 = L_lat*(180/(pi*Req))*(i-1) + lat1;
    
        lats(i,1:end) = lat2;
    
        for j = 1:n_lons
    
            lon2 = (180/pi)*(L_lon/(Req*cosd(lat2)))*(j-1) + lon1;
    
            lons(i,j) = lon2;
    
        end
    end


