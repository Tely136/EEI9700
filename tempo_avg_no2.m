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
input_file = 'aug.txt';
% input_file = 'dec.txt';
% input_file = 'all_dates.txt';

folders = read_batch(fullfile('input_files/',input_file));

full_avg_weekday = NaN(size(latgrid,1) ,size(latgrid,2), length(folders));
full_avg_weekend = NaN(size(latgrid,1) ,size(latgrid,2), length(folders));
for i = 1:length(folders)
    folder_name = folders(i);

    disp(strjoin(['Processing data in:', folder_name]))

    folder_contents = dir(fullfile(tempo_path, folder_name, '*.nc'));
    folder_avg_weekday = NaN(size(latgrid,1) ,size(latgrid,2) , length(folder_contents));
    folder_avg_weekend = NaN(size(latgrid,1) ,size(latgrid,2) , length(folder_contents));

    for j = 1:length(folder_contents)

        tempo_data = load_tempo_data(fullfile(tempo_path,folder_name, folder_contents(j).name));
        
        tempo_tropospheric_no2 = tempo_data.tropospheric;
        tempo_lat = tempo_data.lat;
        tempo_lon = tempo_data.lon;
        tempo_time = tempo_data.time;
        tempo_time.TimeZone = "UTC";
        tempo_qa = tempo_data.qa_value;

        tempo_tropospheric_no2(tempo_tropospheric_no2 <  0 | tempo_qa ~=0) = NaN;

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
        
        if weekday(tempo_time(i)) == 7 || weekday(tempo_time(i)) == 1
            folder_avg_weekend(:,:,j) = tempo_no2_interp;
        else 
            folder_avg_weekday(:,:,j) = tempo_no2_interp;
        end
    end

    full_avg_weekday(:,:,i) = mean(folder_avg_weekday, 3, 'omitnan');
    full_avg_weekend(:,:,i) = mean(folder_avg_weekend, 3, 'omitnan');
end

no2_avg_weekday = mean(full_avg_weekday, 3, 'omitnan');
no2_avg_weekend = mean(full_avg_weekend, 3, 'omitnan');

no2_avg = mean(cat(3, no2_avg_weekday, no2_avg_weekend), 3, 'omitnan');

%%
close all;

no2_min_weekday = min(no2_avg_weekday, [], 'all');
no2_max_weekday = max(no2_avg_weekday, [], 'all');

no2_min_weekend = min(no2_avg_weekend, [], 'all');
no2_max_weekend = max(no2_avg_weekend, [], 'all');

no2_min = min([no2_min_weekday no2_min_weekday], [], 'all');
no2_max = max([no2_max_weekday no2_max_weekday], [], 'all');

save_path = fullfile('./','results/', 'tempo_avg_no2/');

figure;
title = 'Average Tropospheric NO2 [molec/m^2] - Weekdays';
map_plot(latgrid,longrid,no2_avg_weekday,title,lat_bounds,lon_bounds, [no2_min no2_max])

saveas(gcf, fullfile(save_path, ['tempo_avg_no2_weekdays_', input_file, '.png']))
close(gcf);
 

figure;
title = 'Average Tropospheric NO2 [molec/m^2] - Weekend';
map_plot(latgrid,longrid,no2_avg_weekend,title,lat_bounds,lon_bounds, [no2_min no2_max])

saveas(gcf, fullfile(save_path, ['tempo_avg_no2_weekends_', input_file, '.png']))
close(gcf);


figure;
title = 'Average Tropospheric NO2 [molec/m^2] - All days';
map_plot(latgrid,longrid,no2_avg,title,lat_bounds,lon_bounds, [no2_min no2_max])

saveas(gcf, fullfile(save_path, ['tempo_avg_no2_all_', input_file, '.png']))
close(gcf);
