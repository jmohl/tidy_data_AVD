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


function filter_vec = accuracy_filter(data)

sing_sacs(data.n_sacs == 1,:) = data(data.n_sacs == 1,:).valid_endpoints;
sing_sacs = cell2mat(sing_sacs);
%just simplify the data structure to arrays instead of cells. cells are so
%annoying anyways. This way you can directly subtract from the target for
%each group, which really makes things easier.
data.sing_x(data.n_sacs == 1) = sing_sacs(:,1); %x coord of single sac

%2 saccade trials, split by A and V locations
AV_sacs(data.n_sacs > 1,:) = [data(data.n_sacs > 1 ,:).A_endpoints, data(data.n_sacs > 1 ,:).V_endpoints] ;
AV_sacs = cell2mat(AV_sacs);
data.A_x(data.n_sacs >1) = AV_sacs(:,1);
data.V_x(data.n_sacs >1) = AV_sacs(:,3);

%get target to compare to
data(strcmp(data.trial_type,'A'),:).comptar = data(strcmp(data.trial_type,'A'),:).A_tar;
data(strcmp(data.trial_type,'V'),:).comptar = data(strcmp(data.trial_type,'V'),:).V_tar;

%TODO this is super slow, also need to adjust to apply to all trial types
% for i=1:length(sac_dif)
%     if strcmp(data(i,:).trial_type,'AV') && data(i,:).n_sacs > 1 && data(i,:).valid_tr
%         sac_dif(i,1) = data(i,:).A_endpoints{:}(1) - data(i,:).A_tar;
%         sac_dif(i,2) = data(i,:).V_endpoints{:}(1) - data(i,:).V_tar;
%     end
% end
%filter out saccades that are really inaccurate, 
%get stats on errors
error_vec = abs(sac_dif(sac_dif(:,1) ~= 0,:));
mean_error = mean(error_vec,1);
std_error = std(error_vec,1);

%find all trials exceeding 3 std from mean error
error_bounds = abs(mean_error) + 3*std_error;
filter_vec = abs(sac_dif) > error_bounds;
filter_vec = max(filter_vec,[],2);

end