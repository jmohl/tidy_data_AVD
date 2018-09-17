%% Label trial types in plain language
%
% -------------------
% Jeff Mohl
% 5/23/18
% -------------------
%
% Description: converts from ambiguous TASKID to clear label
%
%inputs:
% trim_data - trimmed data table
% params - parameters for given paradigm
%outputs:
% trial_types - column of trial types (A,V,AV)

function trial_type = get_trial_types(trim_data, paradigm_params)

switch paradigm_params.version
    case 1
        is_AV = ismember(trim_data.TASKID, [paradigm_params.simul_ID, paradigm_params.close_ID]);
        is_A = trim_data.TASKID == 2 & trim_data.AMODALITY == 6 & trim_data.BMODALITY == 1; %aud only, no vis
        is_V = trim_data.TASKID == 2 & trim_data.AMODALITY == 5 & trim_data.BMODALITY == 6; %vis only, no aud
        
        trial_type = cell(height(trim_data),1);
        trial_type(is_AV) = {'AV'};
        trial_type(is_A) = {'A'};
        trial_type(is_V) = {'V'};
        
    case 2
        is_AV = ismember(trim_data.TASKID, paradigm_params.simul_ID); %simul (mismatched) AV
        is_A = trim_data.TASKID == 2 & trim_data.AMODALITY == 6 & trim_data.BMODALITY == 1; %aud only, no vis
        is_V = trim_data.TASKID == 2 & trim_data.AMODALITY == 5 & trim_data.BMODALITY == 6; %vis only, no aud

        trial_type = cell(height(trim_data),1);
        trial_type(is_AV) = {'AV'};
        trial_type(is_A) = {'A'};
        trial_type(is_V) = {'V'};
end

end