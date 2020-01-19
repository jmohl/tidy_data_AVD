%% Function for getting the saccade order
%
% ---------------------------
% Jeff Mohl
% 1/19/20
% ---------------------------
%
% Description: This function takes in a tidy_data structure assigns a new
% field reflecting the saccade order for each trial. Saccade order can be
% either AV, indicating A target first, or VA, indicating V target first.
% Function will also label single saccade trials with A or V, for unimodal
% trials, or 'same' when there is only one saccade on a combined trial
%
% Inputs:
% tidy_data - a tidy_data structure containing individual trials for each
% row, must contain the valid_endpoints field.
%
% Outputs:
% updated_tidy - tidy_data structuer with saccade order, first_sac_int
% added

%Note: this code is pretty slow, on the order of 1-2 seconds, but because I
%run the outlying script once per cell and then never touch it again I'm
%not going to spend time optimizing. 

function updated_tidy = get_sac_ordered_data(tidy_data)
updated_tidy = tidy_data;
updated_tidy.sac_order(:) = {'none'};
updated_tidy.first_sac_time(:) = nan;

for tr = 1:height(tidy_data)
    if updated_tidy(tr,:).valid_tr %only compute these new fields for valid trials
        %find the first saccade interval after to go cue
        all_sacs = updated_tidy(tr,:).sac_intervals{:,1}(:,1);
        updated_tidy.first_sac_time(tr) = min(all_sacs(all_sacs > updated_tidy(tr,:).go_time-100));%100ms buffer added here
        % if single saccade, label sac order depending on trial type
        if updated_tidy(tr,:).n_sacs <= 1
            if strcmp(updated_tidy.trial_type(tr),'AV')
                updated_tidy.sac_order(tr) = {'same'};
            else
                updated_tidy.sac_order(tr) = updated_tidy.trial_type(tr);
            end
        else %if more than one saccade, determine order
            %if first valid saccade = A_enpoints, then AV, otherwise VA
            if updated_tidy(tr,:).valid_endpoints{:}(1,1) == updated_tidy(tr,:).A_endpoints{:}(1,1)
                updated_tidy(tr,:).sac_order = {'AV'};
            else
                updated_tidy(tr,:).sac_order = {'VA'};
            end
        end 
    end
end

end