% Calculate and show the average tropospheric NO2 measured by TEMPO over a certain time period

clc; close all; clearvars;
addpath("functions\")
addpath("shapes\")
set(0,'DefaultFigureWindowStyle','docked')

[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();

conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2
lat_bounds = [40 43];
lon_bounds = [-76 -71];

[latgrid, longrid] = create_grid(lat_bounds, lon_bounds, 1000, 1000);
latq_new = reshape(latgrid, [], 1);
lonq_new = reshape(longrid, [], 1);


% input_file = 'input_dates.txt';
% input_file = 'aug.txt';
% input_file = 'dec.txt';
input_file = 'all_dates.txt';

folders = read_batch(fullfile('input_files/',input_file));

dates = NaT(1, length(folders));
full_avg = NaN(size(latgrid,1) ,size(latgrid,2), length(folders));
for i = 1:length(folders)
    folder_name = folders(i);

    disp(strjoin(['Processing data in:', folder_name]))

    folder_contents = dir(fullfile(tempo_path, folder_name, '*.nc'));

    dates(i) = datetime(str2double(folder_name), 'ConvertFrom', 'yyyymmdd');

    day_avg = NaN(size(latgrid,1) ,size(latgrid,2) , length(folder_contents));

    for j = 1:length(folder_contents)

        tempo_data = load_tempo_data(fullfile(tempo_path,folder_name, folder_contents(j).name));
        
        tempo_tropospheric_no2 = tempo_data.tropospheric;
        tempo_lat = tempo_data.lat;
        tempo_lon = tempo_data.lon;
        tempo_time = tempo_data.time;
        tempo_time.TimeZone = "UTC";
        tempo_qa = tempo_data.qa_value;
        tempo_sza = tempo_data.sza;
        tempo_cld_frac = tempo_data.cloud_fraction;

        tempo_tropospheric_no2(tempo_tropospheric_no2 <  0 | tempo_qa ~=0 | tempo_cld_frac < 0.15 | tempo_sza > 70) = NaN;

        % Crop images to lat-lon bounds
        [tempo_tropospheric_no2_crop, tempo_lat_crop, tempo_lon_crop] = crop_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, lat_bounds, lon_bounds);

        % Interpolate data
        tempo_lat_vec = reshape(tempo_lat_crop, [], 1);
        tempo_lon_vec = reshape(tempo_lon_crop, [], 1);
        tempo_no2_vec = reshape(tempo_tropospheric_no2_crop, [], 1);

        % Create interpolant objects for TEMPO
        tempo_interpolant = scatteredInterpolant(tempo_lat_vec, tempo_lon_vec, tempo_no2_vec, 'nearest');

        % Interpolate TEMPO data new new lat-lon grid  
        tempo_no2_interp_vec = tempo_interpolant(latq_new, lonq_new);
        tempo_no2_interp = reshape(tempo_no2_interp_vec, size(latgrid));
        
        day_avg(:,:,j) = tempo_no2_interp;
    end

    full_avg(:,:,i) = mean(day_avg, 3, 'omitnan');
end

disp('Saving results')
save_path = fullfile('./','results/', 'tempo_avg_no2/');
save(fullfile(save_path,'tempo_avg_no2.mat'), 'full_avg', 'latgrid', 'longrid', 'dates')

disp('Done')

% figure;
% title = 'Average Tropospheric NO2 [molec/m^2] - Weekdays';
% map_plot(latgrid,longrid,no2_avg_weekday,title,lat_bounds,lon_bounds, [no2_min no2_max])
% 
% saveas(gcf, fullfile(save_path, ['tempo_avg_no2_weekdays_', input_file, '.png']))
% close(gcf);
% 
% 
% figure;
% title = 'Average Tropospheric NO2 [molec/m^2] - Weekend';
% map_plot(latgrid,longrid,no2_avg_weekend,title,lat_bounds,lon_bounds, [no2_min no2_max])
% 
% saveas(gcf, fullfile(save_path, ['tempo_avg_no2_weekends_', input_file, '.png']))
% close(gcf);
% 
% 
% figure;
% title = 'Average Tropospheric NO2 [molec/m^2] - All days';
% map_plot(latgrid,longrid,no2_avg,title,lat_bounds,lon_bounds, [no2_min no2_max])
% 
% saveas(gcf, fullfile(save_path, ['tempo_avg_no2_all_', input_file, '.png']))
% close(gcf);
