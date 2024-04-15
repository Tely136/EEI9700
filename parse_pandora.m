clc; clearvars; close all;

if exist('C:\Users\Thomas Ely\OneDrive - The City College of New York', 'dir')
    pandora_path = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\EEI9700 Data\Pandora Data\';

elseif exist('C:\Users\Thomas\OneDrive - The City College of New York', 'dir')
    pandora_path = 'C:\Users\Thomas\OneDrive - The City College of New York\EEI9700 Data\Pandora Data\';
end

[filename, full_path] = uigetfile([pandora_path,'*.txt']);

dates = NaT;
no2_trop = zeros;
qa_values = zeros;


start_counter = 0;
fid = fopen([full_path, filename], "rt");
if fid == -1
    error('Failed to open file: %s', filename);
end

while ~feof(fid)
    line = fgetl(fid);
    if ischar(line)
        if strcmp(line, '---------------------------------------------------------------------------------------')
            start_counter = start_counter + 1;
            continue

        elseif start_counter < 2
            continue

        else
            split_line = strsplit(line);

            date = datetime(double(string(split_line(2))) * 24 * 60 * 60, 'ConvertFrom', 'epochtime', 'Epoch', '2000-01-01');
            no2 = double(string(split_line(62)));
            qa = double(string(split_line(53)));

            dates(end+1) = date;
            no2_trop(end+1) = no2;
            qa_values(end+1) = qa;

        end
    end
end

fclose(fid);

site = strsplit(full_path, '\'); site = string(site(end-1));

pandora_data = struct;

pandora_data.date = dates;
pandora_data.no2_trop = no2_trop;
pandora_data.qa = qa_values;

new_filename = strrep(filename, 'txt', 'mat');

save([full_path, new_filename], 'pandora_data')