%% get relevant parameters for different paradigm versions
%
% -------------------
% Jeff Mohl
% 5/18/18
% -------------------
%
% Description: currently have two paradigms with slight differences in the
% beet data files. This function creates a structure to contain that
% information for the relevant paradigm type
%
%inputs:
% avd_ver - either 1 or 2, version of avd paradigm for this date
%outputs:
% params - structure containing relevant parameter data for given version
function params = get_paradigm_params(avd_ver)

if avd_ver == 1 %JM TODO
    params.version = 1;
    params.stim_onset = 5;
    params.go_cue = 6;
    params.sing_rew = 8; %different reward stats for single mod and dual mod trials
    params.dual_rew = 13;
    params.Atar_row = [3,2]; % for the "close" target condition A tar is row 2 instead of row 3. see notes on experimental setup doc
    params.Vtar_row = [2,3];
    params.overlap_ID = 2;
    params.simul_ID = 7:8;
    params.close_ID = 9:12; % 4 conditions, 2 rewarded and 2 not rewarded
   
elseif avd_ver == 2
    params.version = 2;
    params.stim_onset = 5;
    params.go_cue = 6;
    params.sing_rew = 9;
    params.dual_rew = 14;
    params.Atar_row = 3; 
    params.Vtar_row = 2;
    params.overlap_ID = 2;
    params.simul_ID = [7 8]; %two simul tasks, one is just the L-R flipped version of the other
elseif  strcmp(avd_ver,'HU') %same params as avd2
    params.version = 2;
    params.stim_onset = 5;
    params.go_cue = 6;
    params.sing_rew = 9;
    params.dual_rew = 14;
    params.Atar_row = 3; 
    params.Vtar_row = 2;
    params.overlap_ID = 2;
    params.simul_ID = [7 8]; %two simul tasks, one is just the L-R flipped version of the other
else
    error('no specified parameters for given avd version')
end

end