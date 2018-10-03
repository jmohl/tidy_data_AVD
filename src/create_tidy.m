%% Make tidy structure for a given date
%
% -------------------
% Jeff Mohl
% 5/18/18
% -------------------
%
% Description: when given a file name, will return a tidy data structure
% for that beethoven file.

%inputs:
% file_ID - name of the file to be loaded
% avd_ver - (1 or 2) version of paradigm to load
%
%outputs:
% tidy_data - tidy data structure including following fields:
%   field: description


function tidy_data = create_tidy(file_ID,paradigm_params)

file_name = sprintf('%s.dat.cell1',file_ID);
data=struct2table(g_read_data(file_name));%load data file and make table

% include only useful fields from raw data
included_fields ={...
    'TRIAL_NUMBER',...    
    'TASKID',...
    'REWARD',...
    'AMODALITY',...
    'BMODALITY',...
    'TAR',...
    'eyedata',...
    'statedata',...
    'spkdata',...
    'SUBJECTNAME',...
};
trim_data = data(:,included_fields);
trim_data.file_ID(:,1) = {file_ID}; %add file ID 

%convert numbers into more clear trial types
trim_data.trial_type = get_trial_types(trim_data,paradigm_params);

%convert TAR into A tar and V tar for each trial
[trim_data.A_tar,trim_data.V_tar] = get_target_locs(trim_data,paradigm_params);

%convert from state codes to times of informative trial components (stim_onset, go_cue, end)
[trim_data.stim_time,trim_data.go_time,trim_data.end_time] = get_state_times(trim_data,paradigm_params);

%detect saccades and add that data to table
sac_endpoints = cell(height(trim_data),1);
for i = 1:height(trim_data)
    sac_endpoints{i} = find_sacs(trim_data.eyedata{i}(:,1),trim_data.eyedata{i}(:,2),0); 
    %3rd value is an option to use only horizontal saccade velocity for purposes of determining whether a saccade occured
end
trim_data.sac_endpoints = sac_endpoints;

%convert spike times to ms (spikeres is 10 micro seconds,spkdata is in microseconds)
for i = 1:height(trim_data)
trim_data.spkdata{i} = trim_data.spkdata{i}/1000;
end

% include only desired fields and set order (for ease of reading)
tidy_fields = {...
    'file_ID',...
    'TRIAL_NUMBER',...    
    'trial_type',...
    'A_tar',...
    'V_tar',...
    'REWARD',...
    'stim_time',...
    'go_time',...
    'end_time',...
    'statedata',...
    'spkdata',...
    'eyedata',...
    'sac_endpoints'...
};
tidy_data = trim_data(:,tidy_fields);

%making fields have same conventions
tidy_data.Properties.VariableNames{'TRIAL_NUMBER'} = 'trial';
tidy_data.Properties.VariableNames{'REWARD'} = 'reward';

% add field for saccade order
tidy_data = get_sac_ordered_data(tidy_data,paradigm_params.correct_window); %correct window is set in paradigm params

end






