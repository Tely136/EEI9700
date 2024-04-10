function [min_data, max_data] = find_min_max(input_data, input_lat, input_lon, lat_bounds, lon_bounds)

min_lat = lat_bounds(1);
max_lat = lat_bounds(2);

min_lon = lon_bounds(1);
max_lon = lon_bounds(2);


latIndices = input_lat >= min_lat & input_lat <= max_lat;
lonIndices = input_lon >= min_lon & input_lon <= max_lon;

indices = latIndices & lonIndices;

zero_rows = all(indices == 0, 2);
zero_cols = all(indices == 0, 1);


cropped_data = input_data(~zero_rows, :);
cropped_data = cropped_data(:,~zero_cols);


min_data = min(cropped_data, [], 'all');
max_data = max(cropped_data, [], 'all');

end