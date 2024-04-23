close all
clc

tempo_ccny_no2_vec = reshape(tempo_ccny_no2_arr, [], 1); tempo_ccny_no2_vec(isnan(tempo_ccny_no2_vec)) = [];
tempo_ccny_qa_vec = reshape(tempo_ccny_qa_arr, [], 1); tempo_ccny_qa_vec(isnan(tempo_ccny_qa_vec)) = [];
pandora_ccny_no2_vec = reshape(pandora_ccny_no2_arr, [], 1); pandora_ccny_no2_vec(isnan(pandora_ccny_no2_vec)) = [];

tempo_queens_no2_vec = reshape(tempo_queens_no2_arr, [], 1); tempo_queens_no2_vec(isnan(tempo_queens_no2_vec)) = [];
tempo_queens_qa_vec = reshape(tempo_queens_qa_arr, [], 1); tempo_queens_qa_vec(isnan(tempo_queens_qa_vec)) = [];
pandora_queens_no2_vec = reshape(pandora_queens_no2_arr, [], 1); pandora_queens_no2_vec(isnan(pandora_queens_no2_vec)) = [];

tempo_bronx_no2_vec = reshape(tempo_bronx_no2_arr, [], 1); tempo_bronx_no2_vec(isnan(tempo_bronx_no2_vec)) = [];
tempo_bronx_qa_vec = reshape(tempo_bronx_qa_arr, [], 1); tempo_bronx_qa_vec(isnan(tempo_bronx_qa_vec)) = [];
pandora_bronx_no2_vec = reshape(pandora_bronx_no2_arr, [], 1); pandora_bronx_no2_vec(isnan(pandora_bronx_no2_vec)) = [];

y1 = [0, max(tempo_ccny_no2_vec)];
x1 = [0, max(tempo_ccny_no2_vec)];

i = isnan(tempo_ccny_no2_vec);
tempo_ccny_no2_arr(i) = [];
pandora_ccny_no2_arr(i) = [];

X = [ones(length(pandora_ccny_no2_vec),1) pandora_ccny_no2_vec];

format long
b = X\tempo_ccny_no2_vec;
y_fit = X * b;

R = 1 - sum((tempo_ccny_no2_vec - y_fit).^2)/sum((tempo_ccny_no2_vec - mean(tempo_ccny_no2_vec)).^2);

fit = ['y = ', num2str(b(1)), ' + ', num2str(b(2)), 'x', newline, 'R = ', num2str(R)];


%%

% Scatter plot of all data
figure;
hold on
scatter(pandora_ccny_no2_vec, tempo_ccny_no2_vec)
plot(pandora_ccny_no2_vec, y_fit)
plot(x1, y1)
xlabel('Pandora Tropospheriv NO2 Column []')
ylabel('TEMPO Tropospheric NO2 Column[]')
xlim([0 5*10^16])
ylim([0 5*10^16])
text(1*10^16, 4*10^16, fit)

hold off


% Scatter plot of all data
figure;
hold on
scatter(pandora_ccny_no2_vec, tempo_ccny_no2_vec)
scatter(pandora_queens_no2_vec, tempo_queens_no2_vec)
scatter(pandora_bronx_no2_vec, tempo_bronx_no2_vec)

% plot(pandora_ccny_no2_vec, y_fit)
% plot(x1, y1)
xlabel('Pandora Tropospheriv NO2 Column []')
ylabel('TEMPO Tropospheric NO2 Column[]')
xlim([0 5*10^16])
ylim([0 5*10^16])

hold off