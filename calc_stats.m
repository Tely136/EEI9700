clc; clearvars; close all;
set(0,'DefaultFigureWindowStyle','docked')

[tropomi_path,tempo_path,pandora_path,ground_path] = get_paths();

load(fullfile(tempo_path, 'tempo_data.mat'))
load(fullfile(pandora_path, 'pandora_data.mat'))

conversion_factor = 6.02214 * 10^19; % conversion from mol/cm^2 to molec/m^2

% Create comparison table

varnames = {'Site', 'Datetime', 'TEMPO_NO2', 'Pandora_NO2', 'NO2_Uncertainty', 'Albedo', 'Cloud_Fraction', 'Ground_Pixel_Quality',...
        'Snow_Ice_Flag', 'Surface_Pressure', 'Terrain_Height', 'Tropopause_Pressure', 'Relative_Azimuth', 'Solar_Azimuth',...
        'Solar_Zenith', 'Viewing_Azimuth', 'Viewing_Zenith'};

vartypes = {'string', 'datetime', 'double', 'double', 'double', 'double', 'double',...
            'double', 'double', 'double', 'double', 'double', 'double',...
            'double', 'double', 'double', 'double'};

comparison_table = table('Size', [0 length(varnames)],'VariableNames', varnames, 'VariableTypes', vartypes);

time_threshold = minutes(10);

for i = 1:size(tempo_data, 1)
    site = tempo_data.Site(i);
    tempo_time = tempo_data.Datetime(i);
    tempo_no2 = tempo_data.NO2(i);
    tempo_qa = tempo_data.qa(i);

    if tempo_qa == 0 || tempo_qa == 1
        % get corresponding pandora data by time
        
        time_filt = abs(tempo_time - pandora_data.Datetime) <= time_threshold;
        qa_filt = pandora_data.qa == 0 | pandora_data.qa == 1 | pandora_data.qa == 10 | pandora_data.qa == 11;
        % qa_filt = pandora_data.qa == 0 | pandora_data.qa == 10; % HQ pandora data

        pandora_subset = pandora_data((pandora_data.Site == site & time_filt & qa_filt),:);
        pandora_no2_mean = mean(pandora_subset.NO2)*conversion_factor;
        
        if ~isnan(pandora_no2_mean)
            temp_table = table(site, tempo_time, tempo_no2, pandora_no2_mean, tempo_data.NO2_Uncertainty(i), tempo_data.Albedo(i), tempo_data.Cloud_Fraction(i),...
                         tempo_data.Ground_Pixel_Quality(i), tempo_data.Snow_Ice_Flag(i), tempo_data.Surface_Pressure(i), tempo_data.Terrain_Height(i),...
                         tempo_data.Tropopause_Pressure(i), tempo_data.Relative_Azimuth(i),  tempo_data.Solar_Azimuth(i), tempo_data.Solar_Zenith(i), ...
                         tempo_data.Viewing_Azimuth(i), tempo_data.Viewing_Zenith(i), 'VariableNames',varnames);

            comparison_table = [comparison_table; temp_table];
        end
    end
end

ccny_comparison_table = comparison_table(comparison_table.Site == 'CCNY',:);
nybg_comparison_table = comparison_table(comparison_table.Site == 'NYBG',:);
queens_comparison_table = comparison_table(comparison_table.Site == 'QueensCollege',:);

% Ordinary Least Squares
% August and December

[total_ls_model, total_ls_slope, total_ls_intercept] = return_lm_stats(comparison_table);
[ccny_ls_model, ccny_ls_slope, ccny_ls_intercept] = return_lm_stats(ccny_comparison_table);
[queens_ls_model, queens_ls_slope, queens_ls_intercept] = return_lm_stats(queens_comparison_table);
[nybg_ls_model, nybg_ls_slope, nybg_ls_intercept] = return_lm_stats(nybg_comparison_table);


slope = [ccny_ls_slope; queens_ls_slope; nybg_ls_slope; total_ls_slope];
n_obs = [size(ccny_comparison_table, 1); size(queens_comparison_table, 1); size(nybg_comparison_table, 1); size(comparison_table,1)];

% August Only
august_table = comparison_table(comparison_table.Datetime>=datetime(2023,8,1,0,0,0) & comparison_table.Datetime<=datetime(2023,9,1,0,0,0),:);
[total_ls_model_aug, total_ls_slope_aug, total_ls_intercept_aug] = return_lm_stats(august_table);

% December only
december_table = comparison_table(comparison_table.Datetime>=datetime(2023,12,1,0,0,0) & comparison_table.Datetime<=datetime(2024,1,1,0,0,0),:);
[total_ls_model_dec, total_ls_slope_dec, total_ls_intercept_dec] = return_lm_stats(december_table);

% Weekdays Only
weekday_table = comparison_table(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:);

% Weekends Only
weekend_table = comparison_table(~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:);

% Filters for QA
cld_threshold = 0.5;
cld_filter = comparison_table.Cloud_Fraction<=cld_threshold;

qa_table = comparison_table(cld_filter,:);
[total_ls_model_qa, total_ls_slope_qa, total_ls_intercept_qa] = return_lm_stats(qa_table);
[ccny_ls_model_qa, ccny_ls_slope_qa, ccny_ls_intercept_qa] = return_lm_stats(qa_table(qa_table.Site=='CCNY',:));
[queens_ls_model_qa, queens_ls_slope_qa, queens_ls_intercept_qa] = return_lm_stats(qa_table(qa_table.Site=='QueensCollege',:));
[nybg_ls_model_qa, nybg_ls_slope_qa, nybg_ls_intercept_qa] = return_lm_stats(qa_table(qa_table.Site=='NYBG',:));

% Mean Difference
ccny_md = mean(ccny_comparison_table.TEMPO_NO2 - ccny_comparison_table.Pandora_NO2);
queens_md = mean(queens_comparison_table.TEMPO_NO2 - queens_comparison_table.Pandora_NO2);
nybg_md = mean(nybg_comparison_table.TEMPO_NO2 - nybg_comparison_table.Pandora_NO2);
total_md = mean(comparison_table.TEMPO_NO2 - comparison_table.Pandora_NO2);

MD = [ccny_md; queens_md ;nybg_md; total_md];


% Mean Relative Difference
ccny_mrd = mean(ccny_comparison_table.TEMPO_NO2 - ccny_comparison_table.Pandora_NO2./ccny_comparison_table.Pandora_NO2);
queens_mrd = mean(queens_comparison_table.TEMPO_NO2 - queens_comparison_table.Pandora_NO2./queens_comparison_table.Pandora_NO2);
nybg_mrd = mean(nybg_comparison_table.TEMPO_NO2 - nybg_comparison_table.Pandora_NO2./nybg_comparison_table.Pandora_NO2);
total_mrd = mean(comparison_table.TEMPO_NO2 - comparison_table.Pandora_NO2./comparison_table.Pandora_NO2);

MRD = [ccny_mrd; queens_mrd ;nybg_mrd; total_mrd];

% Figure parameters
statistics = table(MD, MRD, slope, n_obs);

marker_sz = 20;

bound1 = max(comparison_table.Pandora_NO2, [], 'all');
bound2 = max(comparison_table.TEMPO_NO2, [], 'all');
bound = max([bound1, bound2]);

bound1_qa = max(qa_table.Pandora_NO2, [], 'all');
bound2_qa = max(qa_table.TEMPO_NO2, [], 'all');
bound_qa = max([bound1_qa, bound2_qa]);

x_test = [0 bound];
ccny_line = @(x) x*ccny_ls_slope + ccny_ls_intercept;
queens_line = @(x) x*queens_ls_slope + queens_ls_intercept;
bronx_line = @(x) x*nybg_ls_slope + nybg_ls_intercept;
total_line = @(x) x*total_ls_slope + total_ls_intercept;

x_test_qa = [0 bound_qa];
ccny_line_qa = @(x) x*ccny_ls_slope_qa + ccny_ls_intercept_qa;
queens_line_qa = @(x) x*queens_ls_slope_qa + queens_ls_intercept_qa;
bronx_line_qa = @(x) x*nybg_ls_slope_qa + nybg_ls_intercept_qa;

total_line_aug = @(x) x*total_ls_slope_aug + total_ls_intercept_aug;
total_line_dec = @(x) x*total_ls_slope_dec + total_ls_intercept_dec;

%% All data with linear regressions for each site

% Before QA
figure; 
hold on;
scatter(comparison_table(comparison_table.Site=='CCNY'&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).Pandora_NO2,...
        comparison_table(comparison_table.Site=='CCNY'&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'b', 'filled');
scatter(comparison_table(comparison_table.Site=='CCNY'&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).Pandora_NO2,...
        comparison_table(comparison_table.Site=='CCNY'&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'b');
plot(x_test, ccny_line(x_test), "Color", 'b')

scatter(comparison_table(comparison_table.Site=='QueensCollege'&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).Pandora_NO2,...
        comparison_table(comparison_table.Site=='QueensCollege'&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'g', 'filled');
scatter(comparison_table(comparison_table.Site=='QueensCollege'&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).Pandora_NO2,...
        comparison_table(comparison_table.Site=='QueensCollege'&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'g');
plot(x_test, queens_line(x_test), "Color", 'r')

scatter(comparison_table(comparison_table.Site=='NYBG'&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).Pandora_NO2,...
        comparison_table(comparison_table.Site=='NYBG'&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'r', 'filled');
scatter(comparison_table(comparison_table.Site=='NYBG'&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).Pandora_NO2,...
        comparison_table(comparison_table.Site=='NYBG'&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'r');
plot(x_test, bronx_line(x_test), "Color", 'g')

title('All data before filtering')
xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')
legend('CCNY', '', ['y = ', num2str(ccny_ls_slope), 'x'], 'Queens College', '', ['y = ', num2str(queens_ls_slope), 'x'], 'New York Botanical Gardens', '', ['y = ', num2str(nybg_ls_slope), 'x'])
xlim([0 bound1])
ylim([0 bound2])
hold off

% After QA
figure; 
hold on;
scatter(qa_table(qa_table.Site=='CCNY'&weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6,:).Pandora_NO2,...
        qa_table(qa_table.Site=='CCNY'&weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'b', 'filled');
scatter(qa_table(qa_table.Site=='CCNY'&~(weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6),:).Pandora_NO2,...
        qa_table(qa_table.Site=='CCNY'&~(weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'b');
plot(x_test_qa, ccny_line_qa(x_test_qa), "Color", 'b')

scatter(qa_table(qa_table.Site=='QueensCollege'&weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6,:).Pandora_NO2,...
        qa_table(qa_table.Site=='QueensCollege'&weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'g', 'filled');
scatter(qa_table(qa_table.Site=='QueensCollege'&~(weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6),:).Pandora_NO2,...
        qa_table(qa_table.Site=='QueensCollege'&~(weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'g');
plot(x_test_qa, queens_line_qa(x_test_qa), "Color", 'r')

scatter(qa_table(qa_table.Site=='NYBG'&weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6,:).Pandora_NO2,...
        qa_table(qa_table.Site=='NYBG'&weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'r', 'filled');
scatter(qa_table(qa_table.Site=='NYBG'&~(weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6),:).Pandora_NO2,...
        qa_table(qa_table.Site=='NYBG'&~(weekday(qa_table.Datetime)>=2&weekday(qa_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'r');
plot(x_test_qa, bronx_line_qa(x_test_qa), "Color", 'g')

title('All data after filtering')
xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')
legend('CCNY', '', ['y = ', num2str(ccny_ls_slope_qa), 'x'], 'Queens College', '', ['y = ', num2str(queens_ls_slope_qa), 'x'], 'New York Botanical Gardens', '', ['y = ', num2str(nybg_ls_slope_qa), 'x'])
% xlim([0 bound1])
% ylim([0 bound2])
hold off

%% Effect of parameters on correlation
close all;
% TODO: add input to function to display appropriate units
% TODO: fix title display

figure; 
parameter_plot(comparison_table, 'TEMPO_NO2')

figure; 
parameter_plot(comparison_table, 'Pandora_NO2')

figure; 
parameter_plot(comparison_table, 'NO2_Uncertainty')

figure; 
parameter_plot(comparison_table, 'Albedo', [0 0.2])

figure; 
parameter_plot(comparison_table, 'Cloud_Fraction')

figure; 
parameter_plot(comparison_table, 'Ground_Pixel_Quality')

figure; 
parameter_plot(comparison_table, 'Snow_Ice_Flag')

figure; 
parameter_plot(comparison_table, 'Surface_Pressure')

figure; 
parameter_plot(comparison_table, 'Terrain_Height')

figure; 
parameter_plot(comparison_table, 'Tropopause_Pressure')

figure; 
parameter_plot(comparison_table, 'Relative_Azimuth')

figure; 
parameter_plot(comparison_table, 'Solar_Azimuth')

figure; 
parameter_plot(comparison_table, 'Solar_Zenith')

figure; 
parameter_plot(comparison_table, 'Viewing_Azimuth')

figure; 
parameter_plot(comparison_table, 'Viewing_Zenith')


%% All sites in August

close all;

figure; 
hold on;

scatter(comparison_table(comparison_table.Datetime>=datetime(2023,8,1,0,0,0)&comparison_table.Datetime<=datetime(2023,9,1,0,0,0)&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).Pandora_NO2,...
        comparison_table(comparison_table.Datetime>=datetime(2023,8,1,0,0,0)&comparison_table.Datetime<=datetime(2023,9,1,0,0,0)&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'b', 'filled');
scatter(comparison_table(comparison_table.Datetime>=datetime(2023,8,1,0,0,0)&comparison_table.Datetime<=datetime(2023,9,1,0,0,0)&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).Pandora_NO2,...
        comparison_table(comparison_table.Datetime>=datetime(2023,8,1,0,0,0)&comparison_table.Datetime<=datetime(2023,9,1,0,0,0)&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'b');

plot(x_test, total_line_aug(x_test))

xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')

xlim([0 bound1])
ylim([0 bound2])

hold off

%% All sites in December
close all

figure; 
hold on;

scatter(comparison_table(comparison_table.Datetime>=datetime(2023,12,1,0,0,0)&comparison_table.Datetime<=datetime(2024,12,1,0,0,0)&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).Pandora_NO2,...
        comparison_table(comparison_table.Datetime>=datetime(2023,12,1,0,0,0)&comparison_table.Datetime<=datetime(2024,12,1,0,0,0)&weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6,:).TEMPO_NO2, marker_sz, 'b', 'filled');
scatter(comparison_table(comparison_table.Datetime>=datetime(2023,12,1,0,0,0)&comparison_table.Datetime<=datetime(2024,12,1,0,0,0)&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).Pandora_NO2,...
        comparison_table(comparison_table.Datetime>=datetime(2023,12,1,0,0,0)&comparison_table.Datetime<=datetime(2024,12,1,0,0,0)&~(weekday(comparison_table.Datetime)>=2&weekday(comparison_table.Datetime)<=6),:).TEMPO_NO2, marker_sz, 'b');

plot(x_test, total_line_aug(x_test))

xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')

xlim([0 bound1])
ylim([0 bound2])

hold off

%% Low Cloud Fraction
close all;

figure; 
hold on;

scatter(comparison_table(comparison_table.Cloud_Fraction<=cld_threshold,:).Pandora_NO2,...
        comparison_table(comparison_table.Cloud_Fraction<=cld_threshold,:).TEMPO_NO2, marker_sz, 'b', 'filled');

plot(x_test, total_ls_slope_qa.*(x_test))

xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')

xlim([0 bound1])
ylim([0 bound2])

hold off
%%

function [lm, slope, intercept] = return_lm_stats(input_table)
    lm = fitlm(input_table.Pandora_NO2, input_table.TEMPO_NO2);

    intercept = lm.Coefficients.Estimate(1);
    slope = lm.Coefficients.Estimate(2);
end

function parameter_plot(table, parameter, clim)
    arguments
        table
        parameter
        clim = []
    end

    week_filt = weekday(table.Datetime)>=2&weekday(table.Datetime)<=6;
    weekend_filt = ~(weekday(table.Datetime)>=2&weekday(table.Datetime)<=6);

    hold on;
    scatter(table(week_filt,:), "Pandora_NO2","TEMPO_NO2", 'Filled', 'ColorVariable', parameter)
    scatter(table(weekend_filt,:), "Pandora_NO2","TEMPO_NO2", 'ColorVariable', parameter)
    plot([0 max(table.Pandora_NO2)], [0 max(table.Pandora_NO2)])
    colorbar
    title([parameter])
    xlim([0 max([max(table.Pandora_NO2) max(table.TEMPO_NO2)], [], 'all')])
    ylim([0 max([max(table.Pandora_NO2) max(table.TEMPO_NO2)], [], 'all')])
    xlabel('Tropospheric NO2 Column Density Measured by Pandora [molec/m^2]')
    ylabel('Tropospheric NO2 Column Density Measured by TEMPO [molec/m^2]')
    legend('Weekday', 'Weekend')
    if ~isempty(clim)
        ax = gca;
        ax.CLim = clim;
    end
    hold off

end