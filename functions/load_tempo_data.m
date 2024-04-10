function output = load_tempo_data(file)

    tropospheric_no2 = ncread(file, 'product/vertical_column_troposphere');
    stratospheric_no2 = ncread(file, 'product/vertical_column_stratosphere');
    total_no2 = ncread(file, 'product/vertical_column_total');
    qa_value = ncread(file, 'product/main_data_quality_flag');


    lat = ncread(file, 'geolocation/latitude');
    lon = ncread(file, 'geolocation/longitude');
    time = ncread(file, 'geolocation/time'); time = datetime(time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06');

    output = struct;
    output.tropospheric = tropospheric_no2;
    output.stratospheric = stratospheric_no2;
    output.total = total_no2;
    output.qa_value = qa_value;
    output.lat = lat;
    output.lon = lon;
    output.time = time;

end
