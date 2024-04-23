function [tropomi_path,tempo_path,pandora_path,ground_path] = get_paths()
    if exist('C:\Users\Thomas Ely\OneDrive - The City College of New York', 'dir')
        prefix = 'C:\Users\Thomas Ely\OneDrive - The City College of New York\EEI9700 Data\';
    
    elseif exist('C:\Users\Thomas\OneDrive - The City College of New York', 'dir')
        prefix = 'C:\Users\Thomas\OneDrive - The City College of New York\EEI9700 Data\';
    
    elseif exist('C:\Users\tely1\OneDrive - The City College of New York', 'dir')
        prefix = 'C:\Users\tely1\OneDrive - The City College of New York\EEI9700 Data\';
    
    else
        error("Path to data doesn't exist")
    
    end
    
    tropomi_path = [prefix, 'TROPOMI Data\'];
    tempo_path = [prefix, 'TEMPO Data\'];
    pandora_path = [prefix, 'Pandora Data\'];
    ground_path = [prefix, 'Ground Sampler Data\'];
end

