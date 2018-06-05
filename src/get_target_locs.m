%% extract A and V target locations
%
% -------------------
% Jeff Mohl
% 5/23/18
% -------------------
%
% Description: converts from ambiguous TAR array to A and V target
% locations
%
%inputs:
% trim_data - trimmed data table
% params - parameters for given paradigm
%outputs:
% A_tar, V_tar - columns of A and V tars for each trial

function [A_tar,V_tar] = get_target_locs(trim_data, paradigm_params)

if paradigm_params.version == 1;
    error('get_trial_types not set up for avd1')
end

%currently only set up for paradigm version 2
if paradigm_params.version == 2
    %for TAR array, row 1 is always fix, row 2 is visual, row 3 is auditory
    %(in paradigm version 2 only)
    A_tar = [];
    V_tar = [];
    for i=1:height(trim_data) %couldn't figure out how to do this not in a loop
        A_tar(i,1) = trim_data.TAR{i}(paradigm_params.Atar_row,1);
        V_tar(i,1) = trim_data.TAR{i}(paradigm_params.Vtar_row,1);
    end
    %set to NaN for unimodal trials
    is_A = ismember(trim_data.trial_type, 'A');
    is_V = ismember(trim_data.trial_type, 'V');
    V_tar(is_A) = NaN;
    A_tar(is_V) = NaN;
end

end