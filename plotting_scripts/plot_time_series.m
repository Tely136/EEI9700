
[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();


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

% TODO (MAYBE): smooth data over 10 minute window
% ccny_pandora_no2_plt = movmean(ccny_pandora_no2_plt, 10);



%%
close all

mk_size = 30;
linethickness = 1.2;

figure;
hold on
yyaxis left
scatter(ccny_pandora_dates_plt, ccny_pandora_no2_plt, mk_size, "blue", "filled")
scatter(tempo_pandora_ccny_date_arr, pandora_ccny_no2_arr, mk_size, "red", "filled")
ylabel('Tropospheric NO2 Column [molec/m^2]')


yyaxis right
plot(ground_date, ground_no2, 'LineWidth',linethickness)
ylabel('Ground NO2 [ppb]')

xlim([t_start t_end])

hold off