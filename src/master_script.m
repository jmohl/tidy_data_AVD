%% master script for converting all beethoven data to tidy data format
%
% -------------------
% Jeff Mohl
% Updated:9/6/18
% -------------------
%
% Description: this script will load the data from multiple days
% (extracted from metadata csvs) and convert them to the tidy data format.

%TODO:
%-alerts based on really small file size (something wrong)
%-alert for big files that are not listed in metadata

% hardcoded parameters
local_directory = 'C:\Users\jtm47\Documents\Projects\tidy_data_AVD\';
%all_ver = {1,2,'HU'}; %1,2, or 'HU' for avd1, avd2, and human paradigm versions respectively
all_ver = {2}; %only running on version 2 to update
limited_subjects = 1;subjects = {'Yoko'};  %option to run only specific subjects

%adding paths
cd(local_directory)
addpath('src','results','data','src\beethoven_gread')

for ver = 1:length(all_ver)
    avd_ver = all_ver{ver};
    %load metadata containing file IDs
    metadata = load_metadata(avd_ver);
    if limited_subjects
        metadata = metadata(contains(metadata.beet_name,subjects),:);
    end
    %get parameters related to this paradigm version
    paradigm_params = get_paradigm_params(avd_ver);
    
    %loop over all file names,
    for i=1:height(metadata)
        file_ID = metadata.beet_name{i};
        if strcmp(avd_ver,'HU')
            tidy_data = create_tidy(file_ID,paradigm_params);
            %save file in results
            save(sprintf('%s\\%s_tidy','results',file_ID),'tidy_data');
        elseif metadata.good_rec(i) >= 0.5 %only days with good recordings(see docs, labeled by good_rec > 0.5)
            %generate tidy data for this file
            tidy_data = create_tidy(file_ID,paradigm_params);
            % add field for quality of recording, from metadata
            tidy_data.is_multiunit(:,1) = metadata.good_rec(i) == .5; %multiunits are labeled as .5 in the good_rec field
            %save file in results
            save(sprintf('%s\\%s_tidy','results',file_ID),'tidy_data');
        end
    end
end