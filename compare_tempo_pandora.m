clc; close all; clearvars;
addpath("functions\")
addpath("shapes\")
set(0,'DefaultFigureWindowStyle','docked')

[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();

conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2

% Pandora Data
ccny_pandora_data = load([pandora_path, 'CCNY\', 'Pandora135s1_ManhattanNY-CCNY_L2_rnvh3p1-8']);
ccny_pandora_no2 = ccny_pandora_data.pandora_data.no2_trop * conversion_factor;
ccny_pandora_dates = ccny_pandora_data.pandora_data.date;
ccny_pandora_dates.TimeZone = 'UTC';
ccny_pandora_qa = ccny_pandora_data.pandora_data.qa;
ccny_pandora_lat = 40.8153;
ccny_pandora_lon = -73.9505;

queens_pandora_data = load([pandora_path, 'Queens\', 'Pandora55s1_QueensNY_L2_rnvh3p1-8']);
queens_pandora_no2 = queens_pandora_data.pandora_data.no2_trop * conversion_factor;
queens_pandora_dates = queens_pandora_data.pandora_data.date;
queens_pandora_dates.TimeZone = 'UTC';
queens_pandora_qa = queens_pandora_data.pandora_data.qa;
queens_pandora_lat = 40.7361;
queens_pandora_lon = -73.8215;

bronx_pandora_data = load([pandora_path, 'Bronx180\', 'Pandora180s1_BronxNY_L2_rnvh3p1-8']);
bronx_pandora_no2 = bronx_pandora_data.pandora_data.no2_trop * conversion_factor;
bronx_pandora_dates = bronx_pandora_data.pandora_data.date;
bronx_pandora_dates.TimeZone = 'UTC';
bronx_pandora_qa = bronx_pandora_data.pandora_data.qa;
bronx_pandora_lat = 40.8679;
bronx_pandora_lon = -73.8781;

sites = struct;
sites.names = ["CCNY" "Queens" "Bronx"];
sites.lat = [ccny_pandora_lat queens_pandora_lat bronx_pandora_lat];
sites.lon = [ccny_pandora_lon queens_pandora_lon bronx_pandora_lon];


y = 512;
tempo_ccny_no2_arr = nan(y,y);
tempo_ccny_qa_arr = nan(y,y);
pandora_ccny_no2_arr = nan(y,y);
tempo_pandora_ccny_date_arr = NaT(y,y); tempo_pandora_ccny_date_arr.TimeZone = 'UTC';

tempo_queens_no2_arr = nan(y,y);
tempo_queens_qa_arr = nan(y,y);
pandora_queens_no2_arr = nan(y,y);
tempo_pandora_queens_date_arr = NaT(y,y); tempo_pandora_queens_date_arr.TimeZone = 'UTC';

tempo_bronx_no2_arr = nan(y,y);
tempo_bronx_qa_arr = nan(y,y);
pandora_bronx_no2_arr = nan(y,y);
tempo_pandora_bronx_date_arr = NaT(y,y); tempo_pandora_bronx_date_arr.TimeZone = 'UTC';


% Tempo data
% input_file = 'input_dates.txt';
% input_file = 'aug.txt';
% input_file = 'dec.txt';
input_file = 'all_dates.txt';

folders = read_batch(fullfile('input_files/',input_file));

for i = 1:length(folders)
    folder_name = folders(i);

    disp(strjoin(['Processing data in:', folder_name]))

    folder_contents = dir(fullfile(tempo_path, folder_name, '*.nc'));
    for j = 1:length(folder_contents)

        % TODO: check if there is actual satellite data at the pandora site

        tempo_data = load_tempo_data(fullfile(tempo_path,folder_name, folder_contents(j).name));
        
        tempo_tropospheric_no2 = tempo_data.tropospheric;
        tempo_lat = tempo_data.lat;
        tempo_lon = tempo_data.lon;
        tempo_time = tempo_data.time;
        tempo_time.TimeZone = "UTC";
        tempo_qa = tempo_data.qa_value;

    
        [tempo_no2_ccny, tempo_qa_ccny, tempo_time_ccny, ccny_pandora_avg_no2, skip] = extract_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, tempo_time, tempo_qa, ccny_pandora_no2, ccny_pandora_lat, ccny_pandora_lon, ccny_pandora_dates, ccny_pandora_qa);
        if skip == true
            continue
        else
            tempo_ccny_no2_arr(i,j) = tempo_no2_ccny;
            tempo_ccny_qa_arr(i,j) = tempo_qa_ccny;
            tempo_pandora_ccny_date_arr(i,j) = tempo_time_ccny;
            pandora_ccny_no2_arr(i, j) = ccny_pandora_avg_no2;
    
        end

        [tempo_no2_queens, tempo_qa_queens, tempo_time_queens, queens_pandora_avg_no2, skip] = extract_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, tempo_time, tempo_qa, queens_pandora_no2, queens_pandora_lat, queens_pandora_lon, queens_pandora_dates, queens_pandora_qa);
        if skip == true
            continue
        else
            tempo_queens_no2_arr(i,j) = tempo_no2_queens;
            tempo_queens_qa_arr(i,j) = tempo_qa_queens;
            tempo_pandora_queens_date_arr(i,j) = tempo_time_queens;
            pandora_queens_no2_arr(i, j) = queens_pandora_avg_no2;
    
        end

        [tempo_no2_bronx, tempo_qa_bronx, tempo_time_bronx, bronx_pandora_avg_no2, skip] = extract_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, tempo_time, tempo_qa, bronx_pandora_no2, bronx_pandora_lat, bronx_pandora_lon, bronx_pandora_dates, bronx_pandora_qa);
        if skip == true
            continue
        else
            tempo_bronx_no2_arr(i,j) = tempo_no2_bronx;
            tempo_bronx_qa_arr(i,j) = tempo_qa_bronx;
            tempo_pandora_bronx_date_arr(i,j) = tempo_time_bronx;
            pandora_bronx_no2_arr(i, j) = bronx_pandora_avg_no2;
    
        end
    end
end

[tempo_ccny_no2_vec, i] = reshape_remove_nan(tempo_ccny_no2_arr);
[tempo_ccny_qa_vec, ~] = reshape_remove_nan(tempo_ccny_qa_arr, i);
[tempo_pandora_ccny_date_vec, ~] = reshape_remove_nan(tempo_pandora_ccny_date_arr, i);
[pandora_ccny_no2_vec, ~] = reshape_remove_nan(pandora_ccny_no2_arr, i);

[tempo_queens_no2_vec, i] = reshape_remove_nan(tempo_queens_no2_arr);
[tempo_queens_qa_vec, ~] = reshape_remove_nan(tempo_queens_qa_arr, i);
[tempo_pandora_queens_date_vec, ~] = reshape_remove_nan(tempo_pandora_queens_date_arr, i);
[pandora_queens_no2_vec, ~] = reshape_remove_nan(pandora_queens_no2_arr, i);

[tempo_bronx_no2_vec, i] = reshape_remove_nan(tempo_bronx_no2_arr);
[tempo_bronx_qa_vec, ~] = reshape_remove_nan(tempo_bronx_qa_arr, i);
[tempo_pandora_bronx_date_vec, ~] = reshape_remove_nan(tempo_pandora_bronx_date_arr, i);
[pandora_bronx_no2_vec, ~] = reshape_remove_nan(pandora_bronx_no2_arr, i);

var_names = {'time', 'tempo_no2', 'pandora_no2', 'qa'};
ccny_table = table(tempo_pandora_ccny_date_vec, tempo_ccny_no2_vec, pandora_ccny_no2_vec, tempo_ccny_qa_vec, 'VariableNames', var_names);
queens_table = table(tempo_pandora_queens_date_vec, tempo_queens_no2_vec,  pandora_queens_no2_vec, tempo_queens_qa_vec, 'VariableNames', var_names);
bronx_table = table(tempo_pandora_bronx_date_vec, tempo_bronx_no2_vec, pandora_bronx_no2_vec, tempo_bronx_qa_vec, 'VariableNames', var_names);

save(fullfile('./', 'processed_data/', 'data_tables.mat') ,"ccny_table", "queens_table", "bronx_table")

%% 


function [tempo_no2_site, tempo_qa_site, tempo_time_site, avg, skip] = extract_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, tempo_time, tempo_qa, pandora_no2, pandora_lat, pandora_lon, pandora_dates, pandora_qa)
    skip = false;

    [site_row, site_col] = bin_coord(pandora_lat, pandora_lon, tempo_lat, tempo_lon);


    % TODO: create flag for weekend days
    tempo_no2_site = tempo_tropospheric_no2(site_row, site_col);
    tempo_time_site = tempo_time(site_col);
    tempo_qa_site = tempo_qa(site_row, site_col);
    
    time_threshold = minutes(10); % TODO: check if this includes before and after
    ind = abs(minutes(pandora_dates - tempo_time_site)) <= minutes(time_threshold);
    
    pandora_no2_tempo = pandora_no2(ind);
    pandora_time_tempo = pandora_dates(ind);
    pandora_qa_tempo = pandora_qa(ind);
    
    
    avg = 0;
    u = 0;
    for k = 1:length(pandora_no2_tempo)
        if pandora_qa_tempo(k) == 0 || pandora_qa_tempo(k) == 1 || pandora_qa_tempo(k) == 10 || pandora_qa_tempo(k) == 11
    
            avg = avg + pandora_no2_tempo(k);
            u = u + 1;
        end
    end
    
    if isnan(tempo_no2_site) || tempo_no2_site < 0
        skip = true; % skip if TEMPO pixel is nonexistent or negative
    end
    
    if u == 0
        skip = true; % skip if all Pandora data in window was low QA
    end

    avg = avg./u;
end



