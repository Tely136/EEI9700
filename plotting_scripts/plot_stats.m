clc; clearvars; close all;

load(fullfile('results/tempo_pandora_comparison', 'comparison.mat'))
load(fullfile('results/tempo_pandora_comparison', 'comparison_qa.mat'))
load(fullfile('results/tempo_pandora_comparison', 'statistics.mat'))

ccny_color = [0 0.4470 0.7410];
queens_color = [0.8500 0.3250 0.0980];
nybg_color = [0.9290 0.6940 0.1250];

linewidth = 1;
%% All stats without filtering
% clc; close all;

figure;
hold on

plot([0 max(comparison_table.Pandora_NO2)], [0 statistics_table.Linear_Fit_Slope('CCNY',:).*max(comparison_table.Pandora_NO2)], 'Color', ccny_color, 'LineWidth', linewidth)
plot([0 max(comparison_table.Pandora_NO2)], [0 statistics_table.Linear_Fit_Slope('QueensCollege',:).*max(comparison_table.Pandora_NO2)], 'Color', queens_color, 'LineWidth', linewidth)
plot([0 max(comparison_table.Pandora_NO2)], [0 statistics_table.Linear_Fit_Slope('NYBG',:).*max(comparison_table.Pandora_NO2)], 'Color', nybg_color, 'LineWidth', linewidth)
plot([0 max(comparison_table.Pandora_NO2)],[0 max(comparison_table.Pandora_NO2)], 'LineStyle','--', 'Color', 'black', 'LineWidth', linewidth)

scatter(comparison_table(comparison_table.Site=='CCNY',:).Pandora_NO2, comparison_table(comparison_table.Site=='CCNY',:).TEMPO_NO2, 'MarkerEdgeColor', ccny_color, 'LineWidth', linewidth)
scatter(comparison_table(comparison_table.Site=='QueensCollege',:).Pandora_NO2, comparison_table(comparison_table.Site=='QueensCollege',:).TEMPO_NO2, 'MarkerEdgeColor', queens_color, 'LineWidth', linewidth)
scatter(comparison_table(comparison_table.Site=='NYBG',:).Pandora_NO2, comparison_table(comparison_table.Site=='NYBG',:).TEMPO_NO2, 'MarkerEdgeColor', nybg_color, 'LineWidth', linewidth)
xlabel('Pandora Tropospheric NO2 Column []')
ylabel('TEMPO Troposhoeric NO2 Column []')
title('TEMPO Pandora Comparison - Unscreened')

legend('CCNY', 'Queens', 'NYBG', '')
hold off

%% All stats but filtering clouds and high SZA
% clc; close all;

figure;
hold on
plot([0 max(comparison_table_qa.Pandora_NO2)], [0 statistics_table.Linear_Fit_Slope('CCNY_QA',:).*max(comparison_table_qa.Pandora_NO2)], 'Color', ccny_color, 'LineWidth', linewidth)
plot([0 max(comparison_table_qa.Pandora_NO2)], [0 statistics_table.Linear_Fit_Slope('QueensCollege_QA',:).*max(comparison_table_qa.Pandora_NO2)], 'Color', queens_color, 'LineWidth', linewidth)
plot([0 max(comparison_table_qa.Pandora_NO2)], [0 statistics_table.Linear_Fit_Slope('NYBG_QA',:).*max(comparison_table_qa.Pandora_NO2)], 'Color', nybg_color, 'LineWidth', linewidth)
plot([0 max(comparison_table_qa.Pandora_NO2)],[0 max(comparison_table_qa.Pandora_NO2)], 'LineStyle','--', 'Color', 'black', 'LineWidth', linewidth)

scatter(comparison_table_qa(comparison_table_qa.Site=='CCNY',:).Pandora_NO2, comparison_table_qa(comparison_table_qa.Site=='CCNY',:).TEMPO_NO2, 'MarkerEdgeColor', ccny_color, 'LineWidth', linewidth)
scatter(comparison_table_qa(comparison_table_qa.Site=='QueensCollege',:).Pandora_NO2, comparison_table_qa(comparison_table_qa.Site=='QueensCollege',:).TEMPO_NO2, 'MarkerEdgeColor', queens_color, 'LineWidth', linewidth)
scatter(comparison_table_qa(comparison_table_qa.Site=='NYBG',:).Pandora_NO2, comparison_table_qa(comparison_table_qa.Site=='NYBG',:).TEMPO_NO2, 'MarkerEdgeColor', nybg_color, 'LineWidth', linewidth)
xlabel('Pandora Tropospheric NO2 Column []')
ylabel('TEMPO Troposhoeric NO2 Column []')
title('TEMPO Pandora Comparison - Screened')

legend('CCNY', 'Queens', 'NYBG', '')
hold off


%% Screened data - Weekdays


%% Screened data - Weekends
%% Screened data - August
%% Screened data - December
