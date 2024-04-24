
load(fullfile('./', 'processed_data/', 'data_tables.mat'))
[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();

conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2


% Pandora Data
ccny_pandora_data = load([pandora_path, 'CCNY\', 'Pandora135s1_ManhattanNY-CCNY_L2_rnvh3p1-8']);
ccny_pandora_no2 = ccny_pandora_data.pandora_data.no2_trop * conversion_factor;
ccny_pandora_dates = ccny_pandora_data.pandora_data.date;
ccny_pandora_dates.TimeZone = 'UTC';
ccny_pandora_qa = ccny_pandora_data.pandora_data.qa;


A = readtable([ground_path, 'is52_no2.xls']);
ground_no2 = A.NO2;
ground_date = A.Date + hours(A.Time .*24); ground_date.TimeZone = "UTC";

% A = readtable([ground_path, '20230601_0821_1minave_NO2_CCNY_Shed.txt']);
% ground_no2 = A.NO2Conc_ppb_;
% ground_date = A.Date_Time_UTC_; ground_date.TimeZone = "UTC";

t_start = datetime(2023,08,1, 'TimeZone', 'UTC');
t_end = datetime(2023,08,31, 'TimeZone', 'UTC');


index = (ccny_pandora_qa == 0 | ccny_pandora_qa == 1 | ccny_pandora_qa == 10 | ccny_pandora_qa == 11) & ccny_pandora_no2 >=0;
ccny_pandora_no2_plt = ccny_pandora_no2(index);
ccny_pandora_dates_plt = ccny_pandora_dates(index); 



%%
close all

mk_size = 30;
linethickness = 1.2;

figure;
hold on
yyaxis left
scatter(ccny_pandora_dates_plt, ccny_pandora_no2_plt, mk_size, "blue", "filled")
scatter(ccny_table.time, ccny_table.tempo_no2, mk_size, "red", "filled")
ylabel('Tropospheric NO2 Column [molec/m^2]')


yyaxis right
plot(ground_date, ground_no2, 'LineWidth',linethickness)
ylabel('Ground NO2 [ppb]')

xlim([t_start t_end])

hold off