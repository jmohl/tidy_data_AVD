%% Saccade accuracy filter
%
% -------------------
% Jeff Mohl
% 4/10/19
% -------------------
%
% Description: remove the "valid" label from trials where the A and V
% labeled saccades are very far away from the actual target locations, as
% these indicate lapses and make model fitting difficult. Currently finding
% different error distributions for auditory and visual saccades and filtering
% out trials with >3x the standard deviation of the errors.
% 
% note: only unimodal conditions (trial types A and V) and the dual saccade
% AV trials are filtered here, because single saccade AV trials are more
% difficult to reliably label the "desired" target (monkey could either
% saccade to A, V, or somewhere in the middle, and all of these are not
% necessarily things I want to consider lapses).

% output:
% filter_vec - trials which contain INACCURATE saccades. label these trials
% as invalid in tidy data.

function filter_vec = accuracy_filter(data)
%it's pretty annoying to work with arrays of cells (which is how the
%saccade endpoints are stored in tidy data, so first I make new fields in
%the date structure for the x coordinate of the relevant saccades.

%single saccade trials
sing_sacs(data.n_sacs == 1,:) = data(data.n_sacs == 1,:).valid_endpoints;
sing_sacs = cell2mat(sing_sacs);
data.sing_x(data.n_sacs == 1) = sing_sacs(:,1); %x coord of single sac

%2 saccade trials, split by A and V locations
AV_sacs(data.n_sacs > 1,:) = [data(data.n_sacs > 1 ,:).A_endpoints, data(data.n_sacs > 1 ,:).V_endpoints] ;
AV_sacs = cell2mat(AV_sacs);
data.A_x(data.n_sacs >1) = AV_sacs(:,1);
data.V_x(data.n_sacs >1) = AV_sacs(:,3);

A_error = zeros(height(data),1);
V_error = zeros(height(data),1);
%single A trials
A_error(strcmp(data.trial_type,'A')) = data(strcmp(data.trial_type,'A'),:).A_tar - data(strcmp(data.trial_type,'A'),:).sing_x;
%dual sac A trials
A_error(data.n_sacs > 1) = data(data.n_sacs > 1,:).A_tar - data(data.n_sacs > 1,:).A_x;
%single V trials
V_error(strcmp(data.trial_type,'V')) = data(strcmp(data.trial_type,'V'),:).V_tar - data(strcmp(data.trial_type,'V'),:).sing_x;
%dual sac V trials
V_error(data.n_sacs > 1) = data(data.n_sacs > 1,:).V_tar - data(data.n_sacs > 1,:).V_x;

% for these calculations, only going to include trials that were already
% considered valid using the get_valid_trials code
A_error(~data.valid_tr) = 0;
V_error(~data.valid_tr) = 0;

% A_error = abs(A_error);
% V_error = abs(V_error); 

mean_A_error = mean(A_error(A_error ~= 0)); %exclude zeros, which are placeholders
mean_V_error = mean(V_error(V_error ~= 0));

std_A_error = std(A_error(A_error ~= 0));
std_V_error = std(V_error(V_error ~= 0));

%find all trials exceeding 3 std from mean error
error_bounds_A =[ mean_A_error + 3*std_A_error, mean_A_error - 3*std_A_error];
filter_vec_A = A_error > error_bounds_A(1) | A_error < error_bounds_A(2);

error_bounds_V =[ mean_V_error + 3*std_V_error, mean_V_error - 3*std_V_error];
filter_vec_V = V_error > error_bounds_V(1) | V_error < error_bounds_V(2);

filter_vec = filter_vec_A | filter_vec_V;

%plotting for verification
% figure
% histogram(V_error(V_error ~=0),'BinWidth',1)
% hold on
% histogram(V_error(V_error ~=0 & filter_vec_V),'BinWidth',1)

end



