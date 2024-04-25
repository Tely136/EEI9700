clc; close all; clearvars;
addpath("functions\")
addpath("shapes\")
set(0,'DefaultFigureWindowStyle','docked')

[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();
load(fullfile(pandora_path, "pandora_data.mat"));
load(fullfile(tempo_path, "tempo_data.mat"));

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

missing_data = isnan(tempo_data.NO2);
tempo_data(missing_data,:) = [];

save(fullfile(tempo_path, 'tempo_data.mat'), "tempo_data");


%% 


function tempo_table = extract_data(tempo_table, tempo_file, sitename, site_lat, site_lon)

    tempo_tropospheric_no2 = tempo_file.tropospheric;
    tempo_lat = tempo_file.lat;
    tempo_lon = tempo_file.lon;
    tempo_time = tempo_file.time;
    tempo_qa = tempo_file.qa_value;
        
    [site_row, site_col] = bin_coord(site_lat, site_lon, tempo_lat, tempo_lon);

    tempo_no2_site = tempo_tropospheric_no2(site_row, site_col);
    tempo_time_site = tempo_time(site_col);
    tempo_qa_site = tempo_qa(site_row, site_col);

    temp_table = table(sitename, tempo_time_site, tempo_no2_site, tempo_qa_site, 'VariableNames', {'Site', 'Datetime', 'NO2', 'qa'});

    tempo_table = [tempo_table; temp_table];
       
end



