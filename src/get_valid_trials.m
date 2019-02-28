%% Behavioral filtration -get validly attempted trials
%
% -------------------
% Jeff Mohl
% 2/27/19
% -------------------
%
% Description: not all trials can be included in the analysis. However
% visual capture is a part of this paradigm so I don't want to filter out
% simply based on reward because I want to include many trials that were
% not "correct" but were attempted in good faith. This function specifies
% what counts as a "valid" trial for the purposes of other analyses.
%
% Valid trials meet the following criteria
% 1. go cue was reached
% 2. at least one saccade was made between the go cue and the end of trial
% 3. if AV trial, at least one target window was reached. This is the
% minimum acceptable behavior because failing to reach ANY target window
% will not allow the trial to progress it's full duration. 


function valid_trial = get_valid_trials(data,min_state, min_dur) 

initiated = ~isnan(data.go_time);

is_AV = strcmp(data.trial_type,'AV');

endpoints=zeros(height(data),2);
on_target = zeros(height(data),1);
for i = 1:height(data)
    if ~isnan(data.go_time(i))
        first_sac = find(data(i,:).sac_intervals{:}(:,1) >= data(i,:).go_time - 100,1); %very occasionally the monkey will anticipate the go cue and initiate a saccade early, -100 here compensates for that
        if ~isempty(first_sac)
         endpoints(i,:) = data(i,:).sac_endpoints{:}(first_sac,:);
         on_target(i) = max(data(i,:).statedata{:}(:,3) == min_state);
        end
    end
end

valid_dur = abs(data.end_time - data.go_time) > min_dur;

has_sac = endpoints(:,1) ~= 0;

AV_on_target = is_AV & on_target;

valid_single = ~is_AV & initiated & has_sac;
valid_AV = AV_on_target & initiated & has_sac & valid_dur;
valid_trial = valid_single | valid_AV;

end
