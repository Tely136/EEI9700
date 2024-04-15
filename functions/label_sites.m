function label_sites(cities_lat, cities_lon, cities_names)
    for k = 1:length(cities_lat)
        textm(cities_lat(k), cities_lon(k), cities_names(k), 'Color', 'w', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
end
