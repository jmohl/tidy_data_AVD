%% script for running on only a single day
%
% -------------------
% Jeff Mohl
% 7/17/18
% -------------------
%
% Description: this script is used if wanting to generate tidy data for a
% single specific day (hard coded in file_ID below)

%% Hard coded values for desired file
file_dir = 'C:\Users\jtm47\Documents\beethoven_data_copy_avd2';
file_name = 'human_test_2018_07_19';
file_ID =sprintf('%s\\%s',file_path,file_name);
save_path = 'C:\Users\jtm47\Documents\Data\human_AVD2';

%% make tidy_data
% hardcoded parameters
local_directory = 'C:\Users\jtm47\Documents\Projects\tidy_data_AVD\';
avd_ver = 2;

%adding paths
cd(local_directory) %I don't know if this is the right way to do this.
addpath('src','results','data')

%get parameters related to this paradigm version
paradigm_params = get_paradigm_params(avd_ver);

this_tidy = create_tidy(file_ID,paradigm_params);

save(sprintf('%s\\%s_tidy',save_path,file_name),'this_tidy');
