clc; clearvars; close all;

[file, path] = uigetfile(fullfile('./' ,'results/', 'tempo_pandora_comparison/'));
load(fullfile(path, file))



