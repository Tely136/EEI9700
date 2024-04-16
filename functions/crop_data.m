function [output_data, output_lat, output_lon] = crop_data(input_data, input_lat, input_lon, lat_bounds, lon_bounds)

    min_lat = lat_bounds(1);
    max_lat = lat_bounds(2);
    
    min_lon = lon_bounds(1);
    max_lon = lon_bounds(2);
    
    
    latIndices = input_lat >= min_lat & input_lat <= max_lat;
    lonIndices = input_lon >= min_lon & input_lon <= max_lon;
    
    indices = latIndices & lonIndices;
    
    zero_rows = all(indices == 0, 2);
    zero_cols = all(indices == 0, 1);
    
    
    output_lat = input_lat(~zero_rows, :);
    output_lat = output_lat(:,~zero_cols);
    
    output_lon = input_lon(~zero_rows, :);
    output_lon = output_lon(:,~zero_cols);
    
    output_data = input_data(~zero_rows, :);
    output_data = output_data(:,~zero_cols);

    % if isempty(output_data)
    %     output_data = zeros(size(input_data));
    %     output_lat = zeros(size(input_data));
    %     output_lon = zeros(size(input_data));
    % end


end