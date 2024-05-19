clc; clearvars; close all;

tempo = load("results\tempo_avg_no2\tempo_avg_no2.mat");
tropomi = load("results\tropomi_avg_no2\tropomi_avg_no2.mat");

tempo_dates = tempo.dates;
tropomi_dates = tropomi.dates;

tempo_no2 = tempo.full_avg;
tropomi_no2 = tropomi.full_avg;

lat = tempo.latgrid;
lon = tempo.longrid;

lat_bounds = [min(lat,[],'all') max(lat,[],'all')];
lon_bounds = [min(lon,[],"all") max(lon,[],"all")];

load('usastates.mat')

%% August

aug1 = datetime(2023,8,1,0,0,0);
aug31 = datetime(2023,8,31,23,59,59);

tempo_no2_aug = tempo_no2(:,:,tempo_dates>=aug1&tempo_dates<=aug31);
tropomi_no2_aug = tropomi_no2(:,:,tropomi_dates>=aug1&tropomi_dates<=aug31);

tempo_no2_aug_avg = mean(tempo_no2_aug,3,"omitmissing");
tropomi_no2_aug_avg = mean(tropomi_no2_aug,3,"omitmissing");

min_no2_aug = min(cat(3,tropomi_no2_aug_avg,tempo_no2_aug_avg),[],'all');
max_no2_aug = max(cat(3,tropomi_no2_aug_avg,tempo_no2_aug_avg),[],'all');

clim_aug = [min_no2_aug max_no2_aug];

figure;
t_aug = tiledlayout(1,2);
nexttile
map_plot(lat, lon, tempo_no2_aug_avg, 'TEMPO', lat_bounds, lon_bounds, clim_aug)
nexttile
map_plot(lat, lon, tropomi_no2_aug_avg, 'Tropomi', lat_bounds, lon_bounds, clim_aug)

title(t_aug,'August')
%% December

dec1 = datetime(2023,12,1,0,0,0);
dec31 = datetime(2023,12,31,23,59,59);

tempo_no2_dec = tempo_no2(:,:,tempo_dates>=dec1&tempo_dates<=dec31);
tropomi_no2_dec = tropomi_no2(:,:,tropomi_dates>=dec1&tropomi_dates<=dec31);

tempo_no2_dec_avg = mean(tempo_no2_dec,3,"omitmissing");
tropomi_no2_dec_avg = mean(tropomi_no2_dec,3,"omitmissing");

min_no2_dec = min(cat(3,tropomi_no2_dec,tempo_no2_dec),[],'all');
max_no2_dec = max(cat(3,tropomi_no2_dec,tempo_no2_dec),[],'all');

clim_dec = [min_no2_dec max_no2_dec];

figure;
t_dec = tiledlayout(1,2);
nexttile
map_plot(lat, lon, tempo_no2_dec_avg, 'TEMPO', lat_bounds, lon_bounds, clim_dec)
nexttile
map_plot(lat, lon, tropomi_no2_dec_avg, 'Tropomi', lat_bounds, lon_bounds, clim_dec)

title(t_dec,'December')
