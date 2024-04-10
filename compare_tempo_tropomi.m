clc; close all; clearvars;
set(0,'DefaultFigureWindowStyle','docked')


if exist('C:\Users\Thomas Ely\OneDrive - The City College of New York', 'dir')
    tropomi_path = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\TROPOMI Data\';
    tempo_path = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\TEMPO Data\';

elseif exist('C:\Users\Thomas\OneDrive - The City College of New York', 'dir')
    tropomi_path = 'C:\Users\Thomas\OneDrive - The City College of New York\TROPOMI Data\';
    tempo_path = 'C:\Users\Thomas\OneDrive - The City College of New York\TEMPO Data\';
end

disp('Loading satellite data...')

% TROPOMI Data 
[tropomi_file, tropomi_file_path] = uigetfile([tropomi_path, '\*.nc']);
TROPOMI_data = load_tropomi_data([tropomi_file_path, tropomi_file]);

tropomi_tropospheric_no2 = TROPOMI_data.tropospheric;
tropomi_stratospheric_no2 = TROPOMI_data.stratospheric;
tropomi_total_no2 = TROPOMI_data.total;
tropomi_lat = TROPOMI_data.lat;
tropomi_lon = TROPOMI_data.lon;
tropomi_time = TROPOMI_data.time;
tropomi_qa = TROPOMI_data.qa_value;


% Get the time TROPOMI passes over NYC
NYC_lat = 40.5;
NYC_lon = -74;

[~, tropomi_lat_i] = findClosestIndex(tropomi_lat, NYC_lat); 
tropomi_time_nyc = datetime(string(tropomi_time(tropomi_lat_i)), 'Format','dd-MMM-uuuu HH:mm:ss');

% TEMPO Data 
tempo_file_path = uigetdir(tempo_path);
tempo_files = dir([tempo_file_path, '\*.nc']);
tempo_dates = string({tempo_files.name});
time_diffs = minutes(size(tempo_dates));
for i=1:length(tempo_dates)
    temp = strsplit(tempo_dates(i), '_');
    tempo_dates(i) = datetime(temp(5), 'InputFormat', 'yyyyMMdd''T''HHmmss''Z');

    time_diffs(i) = abs(tempo_dates(i) - tropomi_time_nyc);
end
[~, minindex] = min(time_diffs);
tempo_file = tempo_files(minindex);

tempo_data = load_tempo_data([tempo_file_path, '\', tempo_file.name]);

tempo_tropospheric_no2 = tempo_data.tropospheric;
tempo_stratospheric_no2 = tempo_data.stratospheric;
tempo_total_no2 = tempo_data.total;
tempo_lat = tempo_data.lat;
tempo_lon = tempo_data.lon;
tempo_time = tempo_data.time;
tempo_qa = tempo_data.qa_value;

states = readgeotable("usastatelo.shp");

disp('Done.')
%%
clc

qa_filter_tropomi = 0.5;

lat_bounds = [40 43];
lon_bounds = [-76 -71];

tropomi_tropospheric_no2(tropomi_qa < qa_filter_tropomi) = NaN;
tropomi_tropospheric_no2(tropomi_tropospheric_no2 < 0) = NaN;

tempo_tropospheric_no2(tempo_qa ~= 0) = NaN;
tempo_tropospheric_no2(tempo_tropospheric_no2 < 0) = NaN;

[tropomi_tropospheric_no2_crop, tropomi_lat_crop, tropomi_lon_crop] = crop_data(tropomi_tropospheric_no2, tropomi_lat, tropomi_lon, lat_bounds, lon_bounds);
[tempo_tropospheric_no2_crop, tempo_lat_crop, tempo_lon_crop] = crop_data(tempo_tropospheric_no2, tempo_lat, tempo_lon, lat_bounds, lon_bounds);


% Interpolate data
trop_lat_vec = reshape(tropomi_lat_crop, [], 1);
trop_lon_vec = reshape(tropomi_lon_crop, [], 1);
trop_no2_vec = reshape(tropomi_tropospheric_no2_crop, [], 1);

tempo_lat_vec = reshape(tempo_lat_crop, [], 1);
tempo_lon_vec = reshape(tempo_lon_crop, [], 1);
tempo_no2_vec = reshape(tempo_tropospheric_no2_crop, [], 1);

x1 = min(trop_lat_vec);
x2 = max(trop_lat_vec);
y1 = min(trop_lon_vec);
y2 = max(trop_lon_vec);
a = (y2-y1)/(x2-x1);

f = @(lat) a .*(lat - x1) + y1;

[latgrid, longrid] = create_grid(lat_bounds, lon_bounds, 1000, 1000);
latq_new = reshape(latgrid, [], 1);
lonq_new = reshape(longrid, [], 1);

tropomi_interpolant = scatteredInterpolant(trop_lat_vec, trop_lon_vec, trop_no2_vec, 'nearest');
tempo_interpolant = scatteredInterpolant(tempo_lat_vec, tempo_lon_vec, tempo_no2_vec, 'nearest');

trop_no2_interp_vec = tropomi_interpolant(latq_new, lonq_new);
tempo_no2_interp_vec = tempo_interpolant(latq_new, lonq_new);


trop_no2_interp = reshape(trop_no2_interp_vec, size(latgrid));
tempo_no2_interp = reshape(tempo_no2_interp_vec, size(latgrid));

[min_tropomi_no2, max_tropomi_no2] = find_min_max(tropomi_tropospheric_no2, tropomi_lat, tropomi_lon, lat_bounds, lon_bounds);
[min_tempo_no2, max_tempo_no2] = find_min_max(tempo_tropospheric_no2, tempo_lat, tempo_lon, lat_bounds, lon_bounds);

min_no2_plot = min([min_tempo_no2 min_tropomi_no2], [], 'all');
max_no2_plot = max([max_tempo_no2 max_tropomi_no2], [], 'all');

[tempo_lon_i, ~] = findClosestIndex(tempo_lon, NYC_lat); 
tempo_time_nyc = string(tempo_time(tempo_lon_i));

trop_no2_interp(trop_no2_interp < 0) = NaN;
tempo_no2_interp(tempo_no2_interp < 0) = NaN;

tempo_tropomi_diff = tempo_no2_interp - trop_no2_interp;


% Correlation


%%
close all;
clc

figure;
subplot(1,2,1)

trop_time_nyc_str = string(tropomi_time_nyc);
tempo_time_nyc_str = string(tempo_time_nyc);

usamap(lat_bounds, lon_bounds)
surfacem(tropomi_lat, tropomi_lon, tropomi_tropospheric_no2)
geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);
colorbar
ax = gca;
ax.CLim = [min_no2_plot max_no2_plot];
title(['TROPOMI Tropospheric NO2 [molec/cm^2]', trop_time_nyc_str])


subplot(1,2,2)

usamap(lat_bounds, lon_bounds)
surfacem(tempo_lat, tempo_lon, tempo_tropospheric_no2)
geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);
colorbar
ax = gca;
ax.CLim = [min_no2_plot max_no2_plot];
title(['TEMPO Tropospheric NO2 [molec/cm^2]', tempo_time_nyc_str])


figure;
usamap(lat_bounds, lon_bounds)
surfacem(latgrid, longrid, trop_no2_interp)
geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);
colorbar
ax = gca;
ax.CLim = [min_no2_plot max_no2_plot];
title(['TROPOMI Tropospheric NO2 [molec/cm^2]', trop_time_nyc_str])

figure;
usamap(lat_bounds, lon_bounds)
surfacem(latgrid, longrid, tempo_no2_interp)
geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);
colorbar
ax = gca;
ax.CLim = [min_no2_plot max_no2_plot];
title(['TEMPO Tropospheric NO2 [molec/cm^2]', tempo_time_nyc_str])


% figure;
% histogram(tempo_tropomi_diff)
% 
% figure;
% usamap(lat_bounds, lon_bounds)
% surfacem(latgrid, longrid, tempo_tropomi_diff)
% geoshow(states,"DisplayType","polygon", 'FaceAlpha', 0);
% colorbar
% ax = gca;
% ax.CLim = [-1*10^(16) 2*10^(16)];
% title(['TEMPO - TROPOMI [molec/cm^2]'])

% figure;
% scatter(trop_no2_interp_vec, tempo_no2_interp_vec)

%%

function [row, col] = findClosestIndex(matrix, targetNumber)
    % Compute the absolute difference between the target number and each element
    differences = abs(matrix - targetNumber);
    
    % Find the linear index of the minimum difference
    [~, linearIndex] = min(differences(:));
    
    % Convert the linear index to row and column indices
    [row, col] = ind2sub(size(matrix), linearIndex);
end
