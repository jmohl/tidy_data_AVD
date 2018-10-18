%% determines number of valid saccades for each trial
%
% -------------------
% Jeff Mohl
% 10/08/18
% -------------------
%
% Description: determines the number of saccades occuring within the valid
% response interval (determined as between go_time and end_time + buffer
% which accounts for failed trials). 

function sac_vector = get_n_sacs(tidy_data,sac_buffer)

sac_vector = zeros(height(tidy_data),1);

for tr = 1:length(sac_vector)
    if ~isnan(tidy_data.go_time(tr)) & ~isempty(tidy_data.sac_endpoints{tr})
        this_sac_ints = tidy_data.sac_intervals{tr};
        sac_vector(tr) = sum(this_sac_ints(:,2) > tidy_data.go_time(tr) & this_sac_ints(:,2) < tidy_data.end_time(tr)+sac_buffer);
    end
end
end