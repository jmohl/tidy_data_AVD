%% Load metadata file
%
% -------------------
% Jeff Mohl
% 5/25/18
% -------------------
%
% Description: loads csv metadata
%
%inputs:
% avd_ver - either 1 or 2, version of avd paradigm for this date
%outputs:
% metadata table

function metadata = load_metadata(avd_ver)

if avd_ver == 1
    metadata = readtable('recording_metadata_AVduals_v1.csv');
elseif avd_ver == 2
    metadata = readtable('recording_metadata_AVD2.csv');
    metadata_yoko = readtable('Yoko_recording_metadata_AVD2.csv');
    metadata = metadata(:,1:10);
    metadata_yoko = metadata_yoko(:,1:10);
    metadata = [metadata;metadata_yoko];
elseif strcmp(avd_ver, 'HU')
    metadata = readtable('human_metadata.xlsx'); %for some reason I have no clue about the csv version does not import correctly
end

end