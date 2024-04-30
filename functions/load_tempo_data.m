function output = load_tempo_data(file)

    % Product
    tropospheric_no2 = ncread(file, 'product/vertical_column_troposphere');
    tropospheric_no2_uncertainty = ncread(file, 'product/vertical_column_troposphere_uncertainty');
    % stratospheric_no2 = ncread(file, 'product/vertical_column_stratosphere');
    % total_no2 = ncread(file, 'product/vertical_column_total');
    qa_value = ncread(file, 'product/main_data_quality_flag');

    % Support data
    albedo = ncread(file, 'support_data/albedo');
    cloud_fraction = ncread(file, 'support_data/eff_cloud_fraction');
    ground_pixel_quality = ncread(file, 'support_data/ground_pixel_quality_flag');
    snow_ice_fraction = ncread(file, 'support_data/snow_ice_fraction');
    surface_pressure = ncread(file, 'support_data/surface_pressure');
    terrain_height = ncread(file, 'support_data/terrain_height');
    tropopause_pressure = ncread(file, 'support_data/tropopause_pressure');


    % Geolocation parameters
    lat = ncread(file, 'geolocation/latitude');
    lon = ncread(file, 'geolocation/longitude');
    rel_azimuth = ncread(file, 'geolocation/relative_azimuth_angle');
    solar_azimuth = ncread(file, 'geolocation/solar_azimuth_angle');
    solar_zenith = ncread(file, 'geolocation/solar_zenith_angle');
    viewing_zenith = ncread(file, 'geolocation/viewing_azimuth_angle');
    viewing_azimuth = ncread(file, 'geolocation/viewing_zenith_angle');
    time = ncread(file, 'geolocation/time'); time = datetime(time, 'ConvertFrom', 'epochtime', 'Epoch', '1980-01-06');

    output = struct;
    output.tropospheric = tropospheric_no2;
    output.tropospheric_uncertainty = tropospheric_no2_uncertainty;
    % output.stratospheric = stratospheric_no2;
    % output.total = total_no2;
    output.qa_value = qa_value;

    output.albedo = albedo;
    output.cloud_fraction = cloud_fraction;
    output.ground_pixel_quality = ground_pixel_quality;
    output.snow_ice_fraction = snow_ice_fraction;
    output.surface_pressure = surface_pressure;
    output.terrain_height = terrain_height;
    output.tropopause_pressure = tropopause_pressure;

    output.lat = lat;
    output.lon = lon;
    output.rel_a = rel_azimuth;
    output.saa = solar_azimuth;
    output.sza = solar_zenith;
    output.vaa = viewing_azimuth;
    output.vza = viewing_zenith;
    output.time = time;

end
