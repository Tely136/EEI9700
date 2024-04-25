clc; clearvars; close all;


[file, path] = uigetfile(fullfile('./', 'processed_data/'));
load(fullfile(path, file))

%% Ordinary Least Squares

ccny_ls_model = fitlm(ccny_table.pandora_no2, ccny_table.tempo_no2, 'VarNames', {'CCNY Pandora', 'TEMPO NO2'}); % CCNY Pandora
queens_ls_model = fitlm(queens_table.pandora_no2, queens_table.tempo_no2, 'VarNames', {'Queens Pandora', 'TEMPO NO2'}); % Queens Pandora
bronx_ls_model = fitlm(bronx_table.pandora_no2, bronx_table.tempo_no2, 'VarNames', {'Bronx Pandora', 'TEMPO NO2'}); % Bronx Pandora

pandora_total = cat(1, ccny_table.pandora_no2, queens_table.pandora_no2, bronx_table.pandora_no2);
tempo_total = cat(1, ccny_table.tempo_no2, queens_table.tempo_no2, bronx_table.tempo_no2);

total_ls_model = fitlm(pandora_total, tempo_total, 'VarNames', {'All Pandoras', 'TEMPO NO2'}); % All Pandoras


ccny_ls_intercept = ccny_ls_model.Coefficients.Estimate(1);
ccny_ls_slope = ccny_ls_model.Coefficients.Estimate(2);

queens_ls_intercept = queens_ls_model.Coefficients.Estimate(1);
queens_ls_slope = queens_ls_model.Coefficients.Estimate(2);

bronx_ls_intercept = bronx_ls_model.Coefficients.Estimate(1);
bronx_ls_slope = bronx_ls_model.Coefficients.Estimate(2);

total_ls_intercept = total_ls_model.Coefficients.Estimate(1);
total_ls_slope = total_ls_model.Coefficients.Estimate(2);

slope = [ccny_ls_slope; queens_ls_slope; bronx_ls_slope; total_ls_slope];
n_obs = [length(ccny_table.pandora_no2); length(queens_table.pandora_no2); length(bronx_table.pandora_no2); length(tempo_total)];


%% Mean Difference

ccny_md = mean(ccny_table.tempo_no2 - ccny_table.pandora_no2);
queens_md = mean(queens_table.tempo_no2 - queens_table.pandora_no2);
bronx_md = mean(bronx_table.tempo_no2 - bronx_table.pandora_no2);
total_md = mean(tempo_total - pandora_total);

MD = [ccny_md; queens_md ;bronx_md; total_md];


%% Mean Relative Difference

ccny_mrd = mean((ccny_table.tempo_no2 - ccny_table.pandora_no2)./ccny_table.pandora_no2);
queens_mrd = mean((queens_table.tempo_no2 - queens_table.pandora_no2)./queens_table.pandora_no2);
bronx_mrd = mean((bronx_table.tempo_no2 - bronx_table.pandora_no2)./bronx_table.pandora_no2);
total_mrd = mean((tempo_total - pandora_total)./pandora_total);

MRD = [ccny_mrd; queens_mrd ;bronx_mrd; total_mrd];

%% Filter Weekdays and Weekends

rf = rowfilter(ccny_table);
ccny_weekdays = ccny_table(rf.weekday >= 2 & rf.weekday <= 6,:);
ccny_weekends = ccny_table(rf.weekday == 1 | rf.weekday == 7,:);

rf = rowfilter(queens_table);
queens_weekdays = queens_table(rf.weekday >= 2 & rf.weekday <= 6,:);
queens_weekends = queens_table(rf.weekday == 1 | rf.weekday == 7,:);

rf = rowfilter(bronx_table);
bronx_weekdays = bronx_table(rf.weekday >= 2 & rf.weekday <= 6,:);
bronx_weekends = bronx_table(rf.weekday == 1 | rf.weekday == 7,:);


%%
close all; clc;

statistics = table(MD, MRD, slope, n_obs);

marker_sz = 20;

bound1 = max([ccny_table.pandora_no2; queens_table.pandora_no2; bronx_table.pandora_no2], [], 'all');
bound2 = max([ccny_table.tempo_no2; bronx_table.tempo_no2; queens_table.tempo_no2], [], 'all');
bound = max([bound1, bound2]);

x_test = [0 bound];
ccny_line = @(x) x*ccny_ls_slope + ccny_ls_intercept ;
queens_line = @(x) x*queens_ls_slope + queens_ls_intercept ;
bronx_line = @(x) x*bronx_ls_slope + bronx_ls_intercept ;
total_line = @(x) x*total_ls_slope + total_ls_intercept ;

figure; % All data with linear regressions for each site
hold on;

scatter(ccny_weekdays.pandora_no2, ccny_weekdays.tempo_no2, marker_sz, 'b', 'filled')
scatter(ccny_weekends.pandora_no2, ccny_weekends.tempo_no2, marker_sz, 'b')

scatter(queens_weekdays.pandora_no2, queens_weekdays.tempo_no2, marker_sz, 'r', 'filled')
scatter(queens_weekends.pandora_no2, queens_weekends.tempo_no2, marker_sz, 'r')

scatter(bronx_weekdays.pandora_no2, bronx_weekdays.tempo_no2, marker_sz, 'g', 'filled')
scatter(bronx_weekends.pandora_no2, bronx_weekends.tempo_no2, marker_sz, 'g')

plot(x_test, ccny_line(x_test), "Color", 'b')
plot(x_test, queens_line(x_test), "Color", 'r')
plot(x_test, bronx_line(x_test), "Color", 'g')

xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')

xlim([0 bound1])
ylim([0 bound2])

hold off


figure; % All data
hold on;

scatter(ccny_weekdays.pandora_no2, ccny_weekdays.tempo_no2, marker_sz, 'b', 'filled')
scatter(ccny_weekends.pandora_no2, ccny_weekends.tempo_no2, marker_sz, 'b')

scatter(queens_weekdays.pandora_no2, queens_weekdays.tempo_no2, marker_sz, 'b', 'filled')
scatter(queens_weekends.pandora_no2, queens_weekends.tempo_no2, marker_sz, 'b')

scatter(bronx_weekdays.pandora_no2, bronx_weekdays.tempo_no2, marker_sz, 'b', 'filled')
scatter(bronx_weekends.pandora_no2, bronx_weekends.tempo_no2, marker_sz, 'b')

plot(x_test, total_line(x_test))

xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')

xlim([0 bound1])
ylim([0 bound2])

hold off