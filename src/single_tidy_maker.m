%% script for running on only a single day
%
% -------------------
% Jeff Mohl
% 7/17/18
% -------------------
%
% Description: this script is used if wanting to generate tidy data for a
% single specific day (hard coded in file_ID below)

local_directory = 'C:\Users\jtm47\Documents\Projects\tidy_data_AVD\';
avd_ver = 2;

%adding paths
cd(local_directory) %I don't know if this is the right way to do this.
addpath('src','results','data')

%% Hard coded values for desired file
file_dir = 'C:\Users\jtm47\Documents\beethoven_data_copy_avd2';
%file_dir = 'data';
file_name = 'Yoko_AVD2_2018_11_14'; 
file_ID =sprintf('%s\\%s',file_dir,file_name);
save_path = 'C:\Users\jtm47\Documents\Data\';

%% make tidy_data

%get parameters related to this paradigm version
paradigm_params = get_paradigm_params(avd_ver);

tidy_data = create_tidy(file_ID,paradigm_params);

save(sprintf('%s\\%s_tidy',save_path,file_name),'tidy_data');
