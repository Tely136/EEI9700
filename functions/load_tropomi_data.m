function output = load_tropomi_data(file)

    conversion_factor = 6.02214 * 10^19;

    tropospheric_no2 = ncread(file, 'PRODUCT/nitrogendioxide_tropospheric_column');
    stratospheric_no2 = ncread(file, '/PRODUCT/SUPPORT_DATA/DETAILED_RESULTS/nitrogendioxide_stratospheric_column');
    total_no2 = ncread(file, '/PRODUCT/SUPPORT_DATA/DETAILED_RESULTS/nitrogendioxide_total_column');
    qa_value = ncread(file, 'PRODUCT/qa_value');

    lat = ncread(file, 'PRODUCT/latitude');
    lon = ncread(file, 'PRODUCT/longitude');
    time = ncread(file, 'PRODUCT/time_utc'); time = datetime(time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z', 'TimeZone', 'UTC');
   
    output = struct;
    output.tropospheric = tropospheric_no2 * conversion_factor;
    output.stratospheric = stratospheric_no2 * conversion_factor;
    output.total = total_no2 * conversion_factor;
    output.qa_value = qa_value;
    output.lat = lat;
    output.lon = lon;
    output.time = time;

end