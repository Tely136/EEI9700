close all
clearvars
clc

[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();

load(fullfile(tempo_path, 'tempo_data.mat'))
load(fullfile(pandora_path, 'pandora_data.mat'))

conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2


%%
close all

marker_size = 75;
linewidth = 2.5;

start_time = datetime(2023,8,9,13,0,0);
end_time = datetime(2023,8,9,22,0,0);


temp_tempo = tempo_data(tempo_data.Solar_Zenith < 70 & tempo_data.qa==0, :);
temp_pandora = pandora_data((pandora_data.qa == 0 |pandora_data.qa == 1 |pandora_data.qa == 10 |pandora_data.qa == 11), :);


% ccny
ccny_tempo = temp_tempo(temp_tempo.Site=='CCNY',:);
ccny_pandora = temp_pandora(temp_pandora.Site=='CCNY',:);

figure;
hold on

plot(ccny_pandora.Datetime, ccny_pandora.NO2.*conversion_factor, 'LineWidth', linewidth)
scatter(ccny_tempo.Datetime, ccny_tempo.NO2, marker_size, 'black', 'filled')
title('NO2 Vertical Column Density [molec/cm^2]')
xlim([start_time, end_time])
legend('Pandora NO2 VCD', 'TEMPO NO2 VCD')
fontsize(20, "points");

hold off
