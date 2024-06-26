clc; close all; clearvars;
addpath("functions\")
addpath("shapes\")

if exist('C:\Users\Thomas Ely\OneDrive - The City College of New York', 'dir')
    tropomi_path = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\EEI9700 Data\TROPOMI Data\';
    tempo_path = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\EEI9700 Data\TEMPO Data\';
    pandora_path = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\EEI9700 Data\Pandora Data\';

elseif exist('C:\Users\Thomas\OneDrive - The City College of New York', 'dir')
    tropomi_path = 'C:\Users\Thomas\OneDrive - The City College of New York\EEI9700 Data\TROPOMI Data\';
    tempo_path = 'C:\Users\Thomas\OneDrive - The City College of New York\EEI9700 Data\TEMPO Data\';
    pandora_path = 'C:\Users\Thomas\OneDrive - The City College of New York\EEI9700 Data\Pandora Data\';
end

NYC_lat = 40.75;
NYC_lon = -73.99;
conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2

disp('Loading data...')

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
sites.lat = [40.8153 40.7361 40.8679];
sites.lon = [-73.9505 -73.8215 -73.8781];

states = readgeotable("usastatelo.shp");

dates = read_batch('input_dates.txt');

for i = 1:length(dates)
    date = dates(i);
    files = dir(fullfile(tropomi_path,date,'*.nc'));

    save_path = fullfile('./results', 'tempo_tropomi_comparison', date);
    if ~exist(save_path, 'dir')
        mkdir(save_path)
    end

    
    for j = 1:length(files)
        file = files(j).name;

        disp(['Processing ', file])

        % TROPOMI Data 
        try
            TROPOMI_data = load_tropomi_data(fullfile(tropomi_path, date, file));
        catch
            warning('No TROPOMI data for this day. Skipping iteration')
            continue
        end
        
        tropomi_tropospheric_no2 = TROPOMI_data.tropospheric;
        tropomi_stratospheric_no2 = TROPOMI_data.stratospheric;
        tropomi_total_no2 = TROPOMI_data.total;
        tropomi_lat = TROPOMI_data.lat;
        tropomi_lon = TROPOMI_data.lon;
        tropomi_time = TROPOMI_data.time;
        tropomi_time.TimeZone = 'UTC';
        tropomi_qa = TROPOMI_data.qa_value;
        
        % Get the time TROPOMI passes over NYC
        [~, tropomi_lat_i] = find_closest_index(tropomi_lat, NYC_lat); 
        tropomi_time_nyc = tropomi_time(tropomi_lat_i);
        


        % TEMPO Data 
        tempo_files = dir(fullfile(tempo_path, date, '\*.nc'));
        if isempty(tempo_files)
            warning('No TEMPO data for this day. Skipping iteration')
            continue
        end
        tempo_dates = string({tempo_files.name});
        time_diffs = minutes(size(tempo_dates));
        
        for k = 1:length(tempo_dates)
            temp = strsplit(tempo_dates(k), '_');
            tempo_dates(k) = datetime(temp(5), 'InputFormat', 'yyyyMMdd''T''HHmmss''Z');
        
            time_diffs(k) = tropomi_time_nyc - tempo_dates(k);
        end
        [~, minindex] = min(time_diffs(time_diffs>=0));
        tempo_file = tempo_files(minindex);

        if minindex ~= 1
            % load previous file as well
        end

        if minindex ~= length(tempo_dates)
            % load next file as well
        end
        
        tempo_data = load_tempo_data(fullfile(tempo_path,date, tempo_file.name));
        
        tempo_tropospheric_no2 = tempo_data.tropospheric;
        tempo_stratospheric_no2 = tempo_data.stratospheric;
        tempo_total_no2 = tempo_data.total;
        tempo_lat = tempo_data.lat;
        tempo_lon = tempo_data.lon;
        tempo_time = tempo_data.time;
        tempo_time.TimeZone = "UTC";
        tempo_qa = tempo_data.qa_value;
        
        % Get the time TEMPO passes over NYC
        [~, tempo_lon_i] = find_closest_index(tempo_lon, NYC_lon); 
        tempo_time_nyc = tempo_time(tempo_lon_i);


        % Filter TROPOMI and TEMPO data for low QA and negative values
        qa_filter_tropomi = 0.5;
        tropomi_tropospheric_no2(tropomi_qa < qa_filter_tropomi) = NaN;
        tropomi_tropospheric_no2(tropomi_tropospheric_no2 < 0) = NaN;
        
        tempo_tropospheric_no2(tempo_qa ~= 0) = NaN;
        tempo_tropospheric_no2(tempo_tropospheric_no2 < 0) = NaN;
        
        % Latitude and longitude bounds for satellite images
        lat_bounds = [40 43];
        lon_bounds = [-76 -71];
        
        % Crop images to lat-lon bounds
        [tropomi_tropospheric_no2_crop, tropomi_lat_crop, tropomi_lon_crop] = crop_data(tropomi_tropospheric_no2, tropomi_lat, tropomi_lon, lat_bounds, lon_bounds);
        [tempo_tropospheric_no2_crop, tempo_lat_crop, tempo_lon_crop] = crop_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, lat_bounds, lon_bounds);
        if isempty(tropomi_tropospheric_no2_crop)
            warning('No TROPOMI data in bounds. Skipping iteration')
            continue

        elseif isempty(tempo_tropospheric_no2_crop)
            warning('No TEMPO data in bounds. Skipping iteration')
            continue
        end

        % Find min and max NO2 values in cropped image
        [min_tropomi_no2, max_tropomi_no2] = find_min_max(tropomi_tropospheric_no2, tropomi_lat, tropomi_lon, lat_bounds, lon_bounds);
        [min_tempo_no2, max_tempo_no2] = find_min_max(tempo_tropospheric_no2, tempo_lat, tempo_lon, lat_bounds, lon_bounds);
        
        min_no2_plot = min([min_tempo_no2 min_tropomi_no2], [], 'all');
        max_no2_plot = max([max_tempo_no2 max_tropomi_no2], [], 'all');
        
        % Interpolate data
        trop_lat_vec = reshape(tropomi_lat_crop, [], 1);
        trop_lon_vec = reshape(tropomi_lon_crop, [], 1);
        trop_no2_vec = reshape(tropomi_tropospheric_no2_crop, [], 1);
        
        tempo_lat_vec = reshape(tempo_lat_crop, [], 1);
        tempo_lon_vec = reshape(tempo_lon_crop, [], 1);
        tempo_no2_vec = reshape(tempo_tropospheric_no2_crop, [], 1);
        
        % Create new lat-lon grid to interpolate satellite data to
        [latgrid, longrid] = create_grid(lat_bounds, lon_bounds, 1000, 1000);
        latq_new = reshape(latgrid, [], 1);
        lonq_new = reshape(longrid, [], 1);
        
        % Create interpolant objects for TEMPO and TROPOMI
        tropomi_interpolant = scatteredInterpolant(trop_lat_vec, trop_lon_vec, trop_no2_vec, 'nearest');
        tempo_interpolant = scatteredInterpolant(tempo_lat_vec, tempo_lon_vec, tempo_no2_vec, 'nearest');
        
        % Interpolate TEMPO and TROPOMI data new new lat-lon grid
        trop_no2_interp_vec = tropomi_interpolant(latq_new, lonq_new);
        tempo_no2_interp_vec = tempo_interpolant(latq_new, lonq_new);
        
        trop_no2_interp = reshape(trop_no2_interp_vec, size(latgrid));
        tempo_no2_interp = reshape(tempo_no2_interp_vec, size(latgrid));
        
        % Interpolate NO2 measured by TEMPO and TROPOMI to Pandora sites coordinates
        trop_no2_ccny = tropomi_interpolant(ccny_pandora_lat, ccny_pandora_lon);
        trop_no2_queens = tropomi_interpolant(queens_pandora_lat, queens_pandora_lon);
        trop_no2_bronx = tropomi_interpolant(bronx_pandora_lat, bronx_pandora_lon);
        
        tempo_no2_ccny = tempo_interpolant(ccny_pandora_lat, ccny_pandora_lon);
        tempo_no2_queens = tempo_interpolant(queens_pandora_lat, queens_pandora_lon);
        tempo_no2_bronx = tempo_interpolant(bronx_pandora_lat, bronx_pandora_lon);
        
        % Subtraction between TEMPO and TROPOMI data
        tempo_tropomi_diff = tempo_no2_interp - trop_no2_interp;
       
        % Create and save figure
        figure;
        subplot(1,2,1)
        
        trop_time_nyc_str = string(tropomi_time_nyc);
        tempo_time_nyc_str = string(tempo_time_nyc);
        
        title_str = ['TROPOMI Tropospheric NO2 [molec/cm^2]', trop_time_nyc_str];
        map_plot(tropomi_lat, tropomi_lon, tropomi_tropospheric_no2, title_str, lat_bounds, lon_bounds, [min_no2_plot, max_no2_plot]);
        
        subplot(1,2,2)
        
        title_str = ['TEMPO Tropospheric NO2 [molec/cm^2]', tempo_time_nyc_str];
        map_plot(tempo_lat, tempo_lon, tempo_tropospheric_no2, title_str, lat_bounds, lon_bounds, [min_no2_plot, max_no2_plot]);
        
        save_filename = string(datetime(tropomi_time_nyc, "Format",'uuuuMMdd''T''HHmmss'));
        saveas(gcf, fullfile(save_path, strjoin([save_filename, '.png'], '')))
        saveas(gcf, fullfile(save_path, strjoin([save_filename, '.fig'], '')))

        close all;
    end
end


%%

function [time_lat, time_lon] = find_passover_time(sat_time, sat_lat, sat_lon, target_lat, target_lon)

    [~, lat_i] = find_closest_index(sat_lat, target_lat); 
    time_lat = datetime(string(sat_time(lat_i)), 'Format','dd-MMM-uuuu HH:mm:ss');

    [lon_i, ~] = find_closest_index(sat_lon, target_lon); 
    time_lon = string(sat_time(lon_i));

end

function [row, col] = find_closest_time(dates, target_date)

    time_diffs = abs(dates - target_date);

    [~, linear_index] = min(time_diffs);
    
    [row, col] = ind2sub(size(dates), linear_index);

end


