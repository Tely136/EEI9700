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

slope = [ccny_ls_slope; queens_ls_slope; bronx_ls_slope; total_ls_slope];
n_obs = [length(ccny_table.pandora_no2); length(queens_table.pandora_no2); length(bronx_table.pandora_no2); length(tempo_total)];


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

%%

statistics = table(MD, MRD, slope, n_obs);