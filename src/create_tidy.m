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
tidy_data=struct2table(g_read_data(file_name));%load data file and make table

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
trim_data = tidy_data(:,included_fields);

% remove garbage from file ID, if applicable

trim_data.file_ID(:,1) = {file_ID}; %add file ID 

%convert numbers into more clear trial types
trim_data.trial_type = get_trial_types(trim_data,paradigm_params);

%convert TAR into A tar and V tar for each trial
[trim_data.A_tar,trim_data.V_tar] = get_target_locs(trim_data,paradigm_params);

%convert from state codes to times of informative trial components (stim_onset, go_cue, end)
[trim_data.stim_time,trim_data.go_time,trim_data.end_time] = get_state_times(trim_data,paradigm_params);

%detect saccades and add that data to table
sac_endpoints = cell(height(trim_data),1);
sac_intervals = cell(height(trim_data),1);
for i = 1:height(trim_data)
    [sac_endpoints{i},sac_intervals{i}] = find_sacs(trim_data.eyedata{i}(:,1),trim_data.eyedata{i}(:,2),0); 
    %3rd value is an option to use only horizontal saccade velocity for purposes of determining whether a saccade occured
end
trim_data.sac_endpoints = sac_endpoints;
trim_data.sac_intervals = sac_intervals;

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
    'sac_endpoints',...
    'sac_intervals'...
};
tidy_data = trim_data(:,tidy_fields);

%making fields have same conventions
tidy_data.Properties.VariableNames{'TRIAL_NUMBER'} = 'trial';
tidy_data.Properties.VariableNames{'REWARD'} = 'reward';

% add field for saccade order
tidy_data = get_sac_ordered_data(tidy_data,paradigm_params.correct_window); %correct window is set in paradigm params

% add valid trial labels
tidy_data.valid_tr = get_valid_trials(tidy_data,paradigm_params.min_state, paradigm_params.min_dur);

% get valid endpoints
tidy_data.valid_endpoints =cell(height(tidy_data),1);
tidy_data(tidy_data.valid_tr,:).valid_endpoints = get_response_endpoints(tidy_data(tidy_data.valid_tr,:), 1, paradigm_params.sac_buffer);

%plot vis guided histograms for trouble shooting and validation
% for visual trials, splitting by positive and negative targets
% V_data = tidy_data(strcmp(tidy_data.trial_type,'V')& tidy_data.valid_tr,:);
% plot_sac_box(V_data)
% title('V uncorrected')

 % adjust calibration, aligning all saccades on visual targets
tidy_data = get_bias_corrected_data(tidy_data);

% plots for visualization of bias correction effects
% V_data = tidy_data(strcmp(tidy_data.trial_type,'V')& tidy_data.valid_tr,:);
% plot_sac_box(V_data)
% title('V corrected')

% rerun get valid endpoints on bias corrected data, also get labeled A and
% V saccades.
tidy_data.A_endpoints =cell(height(tidy_data),1);
tidy_data.V_endpoints =cell(height(tidy_data),1);
[tidy_data(tidy_data.valid_tr,:).valid_endpoints,...
    tidy_data(tidy_data.valid_tr,:).A_endpoints,...
    tidy_data(tidy_data.valid_tr,:).V_endpoints]...
    = get_response_endpoints(tidy_data(tidy_data.valid_tr,:), 1, paradigm_params.sac_buffer);

% Make trials invalid if A and V endpoints are not within acceptable
% accuracy windows
%tidy_data = acuracy_filter(tidy_data);

% add field for number of valid saccades in each trial
tidy_data.n_sacs = cellfun(@(x) size(x,1),tidy_data.valid_endpoints);

end






