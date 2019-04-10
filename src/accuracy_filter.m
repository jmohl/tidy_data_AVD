%% Saccade accuracy filter
%
% -------------------
% Jeff Mohl
% 4/10/19
% -------------------
%
% Description: remove the "valid" label from trials where the A and V
% labeled saccades are very far away from the actual target locations, as
% these indicate lapses and make model fitting difficult. Currently using
% variable displacement 


function filtered_data = accuracy_filter(data)

av_diff = zeros(height(data),2);

%TODO this is super slow
for i=1:length(av_diff)
    if strcmp(data(i,:).trial_type,'AV') && data(i,:).n_sacs > 1 && data(i,:).valid_tr
        av_diff(i,1) = data(i,:).A_endpoints{:}(1) - data(i,:).A_tar;
        av_diff(i,2) = data(i,:).V_endpoints{:}(1) - data(i,:).V_tar;
    end
end
%filter out saccades that are really inaccurate, 
%get stats on errors
error_vec = abs(av_diff(av_diff(:,1) ~= 0,:));
mean_error = mean(error_vec,1);
std_error = std(error_vec,1);

%find all trials exceeding 3 std from mean error
error_bounds = abs(mean_error) + 3*std_error;
filter_vec = abs(av_diff) > error_bounds;
filter_vec = max(filter_vec,[],2);
%change valid label to 0, indicating trial is invalid
filtered_data = data;
filtered_data.valid_tr(filter_vec) = 0;
end