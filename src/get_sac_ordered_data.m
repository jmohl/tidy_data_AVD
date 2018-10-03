%% Function for getting the saccade order
%
% ---------------------------
% Wenxi Xiao
% 10/03/18
% ---------------------------
%
% Description: This function takes in a tidy_data structure assigns a new
% field reflecting the saccade order for each trial. Saccade order can be
% either AV, indicating A target first, or VA, indicating V target first.
% Function will also label single saccade trials with A or V, for unimodal
% trials, or 'same' when the trial has A and V targets in the same
% location.
%
% Inputs:
% tidy_data - a tidy_data structure containing individual trials for each
% row, must contain the sac_endpoints field.
% correct_threshold - a threshold (in degrees) for considering a saccade as
% validly directed towards one of the targets. A good value for this is in
% the 10 degree range (equivalent to a 20 degree window)
%

function [ sac_ordered_tidy_data ] = get_sac_ordered_data( tidy_data, correct_threshold )
sac_order_cell = cell(length(tidy_data.trial),1);
% extract HEyeEndpoint corresponding to the 1st sac end point after go_time:
for tr = 1:length(tidy_data.trial)
    % get saccade sac_x coordinate for each trial
    if isempty(tidy_data.sac_endpoints{tr,1}) == 1 % some trials have empty sac_endpoints
        HEyeEndpoint = NaN;
    else
        for jj = 1: size(tidy_data.sac_endpoints{tr,1},1)
            if tidy_data.sac_endpoints{tr,1}(jj,3) >= tidy_data.go_time(tr)
                HEyeEndpoint = tidy_data.sac_endpoints{tr,1}(jj,1);
                break
            end
        end
    end
    
    if isnan(tidy_data.go_time(tr)) == 1 % invalid trials
        sac_order_cell{tr} = 'NaN';
        %count_invalid = count_invalid+1;
    else
        if length(tidy_data.trial_type{tr}) == 1 % unimodal-stimulus trials
            sac_order_cell{tr} = tidy_data.trial_type{tr};
        else % A+V trials
%             sac_end_HEyeTrace = ...
%                 tidy_data.eyedata{ii, 1}((motor_end_vect(ii)/2),1);% 50ms after sac initiation,/2--convert to index eyeddata
            Adiff = abs(HEyeEndpoint - tidy_data.A_tar(tr));
            Vdiff = abs(HEyeEndpoint - tidy_data.V_tar(tr));
            if min(Adiff, Vdiff) > correct_threshold % within 10 degree is considered correct
                sac_order_cell{tr} = 'NaN';
            else
                if Adiff > Vdiff
                    sac_order_cell{tr} = 'VA';
                elseif Adiff == Vdiff
                    sac_order_cell{tr} = 'same'; % if A_loc=V_loc
                else
                    sac_order_cell{tr} = 'AV';
                end
            end
        end
    end
end
% sanity check for number of trials in each condition(A, AV, NaN, V, VA)
% tmp = sac_order_cell;
% [uniquetmp, ~, J]=unique(tmp);
% num_trial_in_each_condition = histc(J, 1:numel(uniquetmp));

% add sac order as a column in tidy_data:
T = table(sac_order_cell);
T.Properties.VariableNames = {'sac_order'};
sac_ordered_tidy_data = [tidy_data T];

% splitting:
%VA_index = find(strcmp(sac_ordered_tidy_data.sac_order, 'VA'));
%AV_index = find(strcmp(sac_ordered_tidy_data.sac_order, 'AV'));
%Vfirst_tidy_data = sac_ordered_tidy_data(sac_ordered_tidy_data.sac_order == 'VA',:);
end

