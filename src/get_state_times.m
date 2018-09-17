%% get times for relevant states
%
% -------------------
% Jeff Mohl
% 5/22/18
% -------------------
%
% Description: converting from state code/time pairs to independant fields
% with meaningful names
%
%inputs:
% trim_data - trimmed data table
% params - parameters for given paradigm
%outputs:
% stim_onset,go_cue,end_time - rows of time values (in ms) for
% corresponding timepoints on each trial

function [stim_time,go_time,end_time] = get_state_times(trim_data,paradigm_params)

switch paradigm_params.version  
    case {1,2} % same code works for both versions of the task here, as the states are changed in paradigm_params
       stim_time = [];
       go_time = [];
       end_time =[];
       for i=1:height(trim_data)
           this_stim = find(trim_data.statedata{i}(:,3)==paradigm_params.stim_onset,1); %only take first time state appears, can occur more than once on rare instances with dropped signal
           if ~isempty(this_stim)
               stim_time(i,1) = trim_data.statedata{i}(this_stim,1);
           else
               stim_time(i,1) = NaN;
           end

           this_go = find(trim_data.statedata{i}(:,3)==paradigm_params.go_cue,1);
           if ~isempty(this_go)
               go_time(i,1) = trim_data.statedata{i}(this_go,1);
           else
               go_time(i,1) = NaN;
           end

           %somewhat awkward logic for end state, which can eiter be two
           %different reward states (depending on trial type) or failure states
           if strcmp(trim_data.trial_type(i),'AV')
               end_states = [paradigm_params.dual_rew, paradigm_params.dual_rew+2]; %failure state is always rew state + 2
           else
               end_states = [paradigm_params.sing_rew, paradigm_params.sing_rew+2]; %failure state is always rew state + 2
           end
           this_end = find(ismember(trim_data.statedata{i}(:,3),end_states),1);
           if ~isempty(this_end)
               end_time(i,1) = trim_data.statedata{i}(this_end,1);
           else
               end_time(i,1) = NaN;
           end
       end    
end

end