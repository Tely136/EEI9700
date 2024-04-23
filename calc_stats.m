clc;


i = isnan(tempo_ccny_no2_arr);
tempo_ccny_no2_arr(i) = [];
tempo_ccny_qa_arr(i) = [];
pandora_ccny_no2_arr(i) = [];

i = isnan(tempo_queens_no2_arr);
tempo_queens_no2_arr(i) = [];
tempo_queens_qa_arr(i) = [];
pandora_queens_no2_arr(i) = [];

i = isnan(tempo_bronx_no2_arr);
tempo_bronx_no2_arr(i) = [];
tempo_bronx_qa_arr(i) = [];
pandora_bronx_no2_arr(i) = [];

tempo_ccny_no2_vec = reshape(tempo_ccny_no2_arr, [], 1); 
tempo_ccny_qa_vec = reshape(tempo_ccny_qa_arr, [], 1); 
pandora_ccny_no2_vec = reshape(pandora_ccny_no2_arr, [], 1); 

tempo_queens_no2_vec = reshape(tempo_queens_no2_arr, [], 1); 
tempo_queens_qa_vec = reshape(tempo_queens_qa_arr, [], 1); 
pandora_queens_no2_vec = reshape(pandora_queens_no2_arr, [], 1);

tempo_bronx_no2_vec = reshape(tempo_bronx_no2_arr, [], 1); 
tempo_bronx_qa_vec = reshape(tempo_bronx_qa_arr, [], 1); 
pandora_bronx_no2_vec = reshape(pandora_bronx_no2_arr, [], 1);


tempo_no2_vec = cat(1, tempo_ccny_no2_vec, tempo_queens_no2_vec, tempo_bronx_no2_vec);
tempo_qa_vec = cat(1, tempo_ccny_qa_vec, tempo_queens_qa_vec, tempo_bronx_qa_vec);
pandora_no2_vec = cat(1, pandora_ccny_no2_vec, pandora_queens_no2_vec, pandora_bronx_no2_vec);



%% Ordinary Least Squares

ccny_ls_model = fitlm(pandora_ccny_no2_vec, tempo_ccny_no2_vec, 'VarNames', {'CCNY Pandora', 'TEMPO NO2'}); % CCNY Pandora
queens_ls_model = fitlm(pandora_queens_no2_vec, tempo_queens_no2_vec, 'VarNames', {'Queens Pandora', 'TEMPO NO2'}); % Queens Pandora
bronx_ls_model = fitlm(pandora_bronx_no2_vec, tempo_bronx_no2_vec, 'VarNames', {'Bronx Pandora', 'TEMPO NO2'}); % Bronx Pandora

total_ls_model = fitlm(pandora_no2_vec, tempo_no2_vec, 'VarNames', {'All Pandoras', 'TEMPO NO2'}); % All Pandoras


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