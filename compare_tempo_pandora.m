clc; close all; clearvars;
addpath("functions\")
addpath("shapes\")
set(0,'DefaultFigureWindowStyle','docked')

table_varnames = {'Site', 'Datetime', 'NO2', 'NO2_Uncertainty', 'Albedo', 'Cloud_Fraction', 'Ground_Pixel_Quality',...
        'Snow_Ice_Flag', 'Surface_Pressure', 'Terrain_Height', 'Tropopause_Pressure', 'Relative_Azimuth', 'Solar_Azimuth',...
        'Solar_Zenith', 'Viewing_Azimuth', 'Viewing_Zenith', 'qa'};

table_vartypes = {'string', 'datetime', 'double', 'double', 'double', 'double', 'double',...
        'double', 'double', 'double', 'double', 'double', 'double',...
        'double', 'double', 'double', 'double'};

[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();
load(fullfile(pandora_path, "pandora_data.mat"));

if exist(fullfile(tempo_path, "tempo_data.mat"), "file")
    load(fullfile(tempo_path, "tempo_data.mat"));
else
    tempo_data = table('Size', [0 length(table_varnames)], 'VariableTypes', table_vartypes, 'VariableNames', table_varnames);
end

conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2

ccny_pandora_lat = 40.8153;
ccny_pandora_lon = -73.9505;
ccny_pandora_alt = 34; % m


queens_pandora_lat = 40.7361;
queens_pandora_lon = -73.8215;
queens_pandora_alt = 25; % m


bronx_pandora_lat = 40.8679;
bronx_pandora_lon = -73.8781;
bronx_pandora_alt = 31; % m

sites = struct;
sites.names = ["CCNY" "QueensCollege" "NYBG"];
sites.lat = [ccny_pandora_lat queens_pandora_lat bronx_pandora_lat];
sites.lon = [ccny_pandora_lon queens_pandora_lon bronx_pandora_lon];



input_file = 'all_dates.txt';
% input_file = 'input_dates.txt';

folders = read_batch(fullfile('input_files/',input_file));

for i = 1:length(folders)
    folder_name = folders(i);

    disp(strjoin(['Processing data in:', folder_name]))

    folder_contents = dir(fullfile(tempo_path, folder_name, '*.nc'));
    for j = 1:length(folder_contents)


        tempo_file = load_tempo_data(fullfile(tempo_path,folder_name, folder_contents(j).name));
       
        for k = 1:length(sites.names)
            tempo_data = extract_data(tempo_data, tempo_file, sites.names(k), sites.lat(k), sites.lon(k));
        end        
    end
end

tempo_data = unique(tempo_data);

missing_data = isnan(tempo_data.NO2) | tempo_data.NO2 < 0;
tempo_data(missing_data,:) = [];

save(fullfile(tempo_path, 'tempo_data.mat'), "tempo_data");


%% 


function tempo_table = extract_data(tempo_table, tempo_file, sitename, site_lat, site_lon)

    varnames = {'Site', 'Datetime', 'NO2', 'NO2_Uncertainty', 'Albedo', 'Cloud_Fraction', 'Ground_Pixel_Quality',...
        'Snow_Ice_Flag', 'Surface_Pressure', 'Terrain_Height', 'Tropopause_Pressure', 'Relative_Azimuth', 'Solar_Azimuth',...
        'Solar_Zenith', 'Viewing_Azimuth', 'Viewing_Zenith', 'qa'};


    % tempo_tropospheric_no2 = tempo_file.tropospheric;
    % tempo_tropospheric_no2_uncertainty = tempo_file.tropospheric_uncertainty;
    % tempo_qa = tempo_file.qa_value;
    % 
    % albedo = tempo_file.albedo;
    % cloud_frac = tempo_file.cloud_fraction;
    % ground_pixel_quality = tempo_file.ground_pixel_quality;
    % snow_ice_fraction = tempo_file.snow_ice_fraction;
    % surface_pressure = tempo_file.surface_pressure;
    % terrain_height = tempo_file.terrain_height;
    % tropoopause_pressure = tempo_file.tropopause_pressure;
    % 
    % 
    % 
    % 
    tempo_lat = tempo_file.lat;
    tempo_lon = tempo_file.lon;
    % rel_a = tempo_file.rel_a;
    % saa = tempo_file.saa;
    % sza = tempo_file.sza;
    % vaa = tempo_file.vaa;
    % vza = tempo_file.vza;
    % tempo_time = tempo_file.time;

    
        
    [site_row, site_col] = bin_coord(site_lat, site_lon, tempo_lat, tempo_lon);

    tempo_no2_site = tempo_file.tropospheric(site_row, site_col);
    tempo_no2_uncertainty_site = tempo_file.tropospheric_uncertainty(site_row, site_col);
    tempo_qa_site = tempo_file.qa_value(site_row, site_col);

    albedo_site = tempo_file.albedo(site_row, site_col);
    cloud_frac_site = tempo_file.cloud_fraction(site_row, site_col);
    ground_pixel_quality_site = tempo_file.ground_pixel_quality(site_row, site_col);
    snow_ice_frac_site = tempo_file.snow_ice_fraction(site_row, site_col);
    surface_pressure_site = tempo_file.surface_pressure(site_row, site_col);
    terrain_height_site = tempo_file.terrain_height(site_row, site_col);
    tropopause_pressure_site = tempo_file.tropopause_pressure(site_row, site_col);

    rel_a_site = tempo_file.rel_a(site_row, site_col);
    saa_site = tempo_file.saa(site_row, site_col);
    sza_site = tempo_file.sza(site_row, site_col);
    vaa_site = tempo_file.vaa(site_row, site_col);
    vza_site = tempo_file.vza(site_row, site_col);
    tempo_time_site = tempo_file.time(site_col);



    temp_table = table(sitename, tempo_time_site, tempo_no2_site, tempo_no2_uncertainty_site, albedo_site, ...
                       cloud_frac_site, ground_pixel_quality_site, snow_ice_frac_site, surface_pressure_site, terrain_height_site,...
                       tropopause_pressure_site, rel_a_site, saa_site, sza_site, vaa_site, vza_site, tempo_qa_site, 'VariableNames', varnames);

    tempo_table = [tempo_table; temp_table];
       
end
