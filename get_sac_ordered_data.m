function [ sac_ordered_tidy_data ] = get_sac_ordered_data( tidy_data, correct_threshold )
sac_order_cell = cell(length(tidy_data.trial),1);
% extract HEyeTrace corresponding to the 1st sac end point after go_time:
for ii = 1:length(tidy_data.trial)
    % get saccade sac_x coordinate for each trial
    if isempty(tidy_data.sac_endpoints{ii,1}) == 1 % some trials have empty sac_endpoints
        HEyeTrace = NaN;
    else
        for jj = 1: size(tidy_data.sac_endpoints{ii,1},1)
            if tidy_data.sac_endpoints{ii,1}(jj,3) >= tidy_data.go_time(ii)
                HEyeTrace = tidy_data.sac_endpoints{ii,1}(jj,1);
                break
            end
        end
    end
    
    if isnan(tidy_data.go_time(ii)) == 1 % invalid trials
        sac_order_cell{ii} = 'NaN';
        %count_invalid = count_invalid+1;
    else
        if length(tidy_data.trial_type{ii}) == 1 % unimodal-stimulus trials
            sac_order_cell{ii} = tidy_data.trial_type{ii};
        else % A+V trials
%             sac_end_HEyeTrace = ...
%                 tidy_data.eyedata{ii, 1}((motor_end_vect(ii)/2),1);% 50ms after sac initiation,/2--convert to index eyeddata
            Adiff = abs(HEyeTrace - tidy_data.A_tar(ii));
            Vdiff = abs(HEyeTrace - tidy_data.V_tar(ii));
            if min(Adiff, Vdiff) > correct_threshold % within 10 degree is considered correct
                sac_order_cell{ii} = 'NaN';
            else
                if Adiff > Vdiff
                    sac_order_cell{ii} = 'VA';
                elseif Adiff == Vdiff
                    sac_order_cell{ii} = 'same'; % if A_loc=V_loc
                else
                    sac_order_cell{ii} = 'AV';
                end
            end
        end
    end
end
% sanity check for number of trials in each condition(A, AV, NaN, V, VA)
tmp = sac_order_cell;
[uniquetmp, ~, J]=unique(tmp);
num_trial_in_each_condition = histc(J, 1:numel(uniquetmp));

% add sac order as a column in tidy_data:
T = table(sac_order_cell);
T.Properties.VariableNames = {'sac_order'};
sac_ordered_tidy_data = [tidy_data T];

% splitting:
%VA_index = find(strcmp(sac_ordered_tidy_data.sac_order, 'VA'));
%AV_index = find(strcmp(sac_ordered_tidy_data.sac_order, 'AV'));
%Vfirst_tidy_data = sac_ordered_tidy_data(sac_ordered_tidy_data.sac_order == 'VA',:);
end

