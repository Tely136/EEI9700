function map_plot(lat, lon, param, title_str, lat_bounds, lon_bounds, color_lim, sites)

    states = readgeotable("usastatelo.shp");

    sites_lat = sites.lat;
    sites_lon = sites.lon;
    sites_names = sites.names;


    usamap(lat_bounds, lon_bounds);
    surfacem(lat, lon, param)
    geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);

    scatterm(sites_lat, sites_lon, 50, 'Marker', '*', ...
         'MarkerEdgeColor', 'w', ...
         'MarkerFaceAlpha', 0, ... % Transparency of marker face
         'MarkerEdgeAlpha', 1);    % Transparency of marker edge
    label_sites(sites_lat, sites_lon, sites_names)


    colorbar
    ax = gca;
    ax.CLim = color_lim;
    title(title_str)

end

