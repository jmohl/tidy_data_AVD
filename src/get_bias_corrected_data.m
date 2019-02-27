%% correcting for eye tracker induced bias
%
% -------------------
% Jeff Mohl
% 2/27/19
% -------------------
%
% Description: eye tracker is calibrated manually during recording, but
% this process is not perfect. This function effectively adjusts the gain
% and offset so that saccades are as well aligned with real space as
% possible while maintaining a linear relationship (taking visually guided
% saccades as approximately unbiased). It acts only on the x (horizontal)
% component of the data


function [data] = get_bias_corrected_data(data)

V_data = data(strcmp(data.trial_type,'V') & data.valid_tr,:);
%remove any trials that don't have valid saccades, for some reason.
V_data = V_data(~cellfun(@isempty,V_data.valid_endpoints),:);
%also remove V data from 30 degree trials because those are known to be
%less accurate, so will not use for calibration
V_data = V_data(abs(V_data.V_tar) ~= 30,:); 
saccades_vector = vertcat(V_data.valid_endpoints{:,1});
saccades_vector = saccades_vector(:,1);

%find linear coefficients for visual saccades
coeffs = polyfit(V_data.V_tar(:,1),saccades_vector,1);

for i = 1:height(data)
    if ~isempty(data.sac_endpoints{i})
    this_endpoints = data.sac_endpoints{i};
    this_endpoints(:,1) = this_endpoints(:,1)/coeffs(1) - coeffs(2); %only adjusting first column, x component
    data.sac_endpoints{i}= this_endpoints;
    end
end

end