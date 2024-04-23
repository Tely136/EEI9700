clc;
clearvars;


load(fullfile('./', 'processed_data/', 'data_tables.mat'))



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


figure(1)
plot(ccny_ls_model)
xlim([0 10^17])
ylim([0 10^17])

figure(2)
plot(queens_ls_model)
xlim([0 10^17])
ylim([0 10^17])

figure(3)
plot(bronx_ls_model)
xlim([0 10^17])
ylim([0 10^17])

figure(4)
plot(total_ls_model)
xlim([0 10^17])
ylim([0 10^17])


%% Mean Difference

%% Mean Relative Difference