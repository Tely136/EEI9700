function map_plot(lat, lon, param, title_str, lat_bounds, lon_bounds, color_lim, sites)
    arguments
        lat 
        lon 
        param 
        title_str 
        lat_bounds 
        lon_bounds 
        color_lim  = []
        sites = struct([])
    end

    states = readgeotable("usastatelo.shp");

    usamap(lat_bounds, lon_bounds);
    surfacem(lat, lon, param)
    geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);

    if ~isempty(sites)
        sites_lat = sites.lat;
        sites_lon = sites.lon;
        sites_names = sites.names;
        scatterm(sites_lat, sites_lon, 50, 'Marker', '*', ...
             'MarkerEdgeColor', 'w', ...
             'MarkerFaceAlpha', 0, ... % Transparency of marker face
             'MarkerEdgeAlpha', 1);    % Transparency of marker edge
        label_sites(sites_lat, sites_lon, sites_names)
    end

    colorbar
    if ~isempty(color_lim)
        ax = gca;
        ax.CLim = color_lim;
    end
    title(title_str)

end

