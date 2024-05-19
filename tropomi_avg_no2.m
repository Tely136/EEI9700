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


% input_file = 'aug_full.txt';
% input_file = 'dec_full.txt';
input_file = 'all_dates.txt';

folders = read_batch(fullfile('input_files/',input_file));

dates = NaT(1, length(folders));
full_avg = NaN(size(latgrid,1) ,size(latgrid,2), length(folders));
for i = 1:length(folders)
    folder_name = folders(i);

    disp(strjoin(['Processing data in:', folder_name]))

    folder_contents = dir(fullfile(tropomi_path, folder_name, '*.nc'));
    dates(i) = datetime(str2double(folder_name), 'ConvertFrom', 'yyyymmdd');

    day_avg = NaN(size(latgrid,1) ,size(latgrid,2) , length(folder_contents));

    for j = 1:length(folder_contents)
        file = folder_contents(j).name;

        TROPOMI_data = load_tropomi_data(fullfile(tropomi_path, folder_name, file));

        tropomi_tropospheric_no2 = TROPOMI_data.tropospheric;
        tropomi_lat = TROPOMI_data.lat;
        tropomi_lon = TROPOMI_data.lon;
        tropomi_time = TROPOMI_data.time;
        tropomi_time.TimeZone = 'UTC';
        tropomi_qa = TROPOMI_data.qa_value;

        % Filter TROPOMI data for low QA and negative values
        qa_filter_tropomi = 0.5;
        tropomi_tropospheric_no2(tropomi_qa < qa_filter_tropomi) = NaN;
        tropomi_tropospheric_no2(tropomi_tropospheric_no2 < 0) = NaN;
        
        % Crop images to lat-lon bounds
        [tropomi_tropospheric_no2_crop, tropomi_lat_crop, tropomi_lon_crop] = crop_data(tropomi_tropospheric_no2, tropomi_lat, tropomi_lon, lat_bounds, lon_bounds);        

        % Interpolate data
        trop_lat_vec = reshape(tropomi_lat_crop, [], 1);
        trop_lon_vec = reshape(tropomi_lon_crop, [], 1);
        trop_no2_vec = reshape(tropomi_tropospheric_no2_crop, [], 1);
                      
        % Create interpolant objects for TROPOMI
        tropomi_interpolant = scatteredInterpolant(trop_lat_vec, trop_lon_vec, trop_no2_vec, 'nearest');
        
        % Interpolate TEMPO and TROPOMI data new new lat-lon grid
        trop_no2_interp_vec = tropomi_interpolant(latq_new, lonq_new);
        trop_no2_interp = reshape(trop_no2_interp_vec, size(latgrid));
        
        day_avg(:,:,j) = trop_no2_interp;
    end

    full_avg(:,:,i) = mean(day_avg, 3, 'omitnan');
end

disp('Saving results')
save_path = fullfile('./','results/', 'tropomi_avg_no2/');
save(fullfile(save_path,'tropomi_avg_no2.mat'), 'full_avg', 'latgrid', 'longrid', 'dates')

disp('Done')

% no2_min_weekday = min(no2_avg_weekday, [], 'all');
% no2_max_weekday = max(no2_avg_weekday, [], 'all');
% 
% no2_min_weekend = min(no2_avg_weekend, [], 'all');
% no2_max_weekend = max(no2_avg_weekend, [], 'all');
% 
% no2_min = min([no2_min_weekday no2_min_weekday], [], 'all');
% no2_max = max([no2_max_weekday no2_max_weekday], [], 'all');
% 
% save_path = fullfile('./','results/', 'tropomi_avg_no2/');
% 
% figure;
% title = 'TROPOMI Average Tropospheric NO2 [molec/m^2] - Weekdays';
% map_plot(latgrid,longrid,no2_avg_weekday,title,lat_bounds,lon_bounds, [no2_min no2_max])
% 
% saveas(gcf, fullfile(save_path, ['tropomi_avg_no2_weekdays_', input_file, '.png']))
% saveas(gcf, fullfile(save_path, ['tropomi_avg_no2_weekdays_', input_file, '.fig']))
% close(gcf);
% 
% 
% figure;
% title = 'TROPOMI Average Tropospheric NO2 [molec/m^2] - Weekend';
% map_plot(latgrid,longrid,no2_avg_weekend,title,lat_bounds,lon_bounds, [no2_min no2_max])
% 
% saveas(gcf, fullfile(save_path, ['tropomi_avg_no2_weekends_', input_file, '.png']))
% saveas(gcf, fullfile(save_path, ['tropomi_avg_no2_weekends_', input_file, '.fig']))
% close(gcf);
% 
% 
% figure;
% title = 'TROPOMI Average Tropospheric NO2 [molec/m^2] - All days';
% map_plot(latgrid,longrid,no2_avg,title,lat_bounds,lon_bounds, [no2_min no2_max])
% 
% saveas(gcf, fullfile(save_path, ['tropomi_avg_no2_all_', input_file, '.png']))
% saveas(gcf, fullfile(save_path, ['tropomi_avg_no2_all_', input_file, '.fig']))
% close(gcf);
% 
