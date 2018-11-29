% Generate a matrix with saccade endpoints for each trial

%---------------
%Jeff Mohl
%3/28/17
%updated 2/20/18
%---------------

%Description: detect saccades (eye velocity > 50deg/s) and report all of
%the endpoints of those saccades. I think this script is a little excessive
%but not worth streamlining.

%UPDATE: altered so that the trace (rather than the velocity) is smoothed.
%This resulted in better performance and was more straightforward. Also
%altered the parameters for what was labeled as a saccade and how, listed
%below.

%parameters for saccade detection: (changed 2/20/18)
%start: velocity > 50 deg/s
%end: velocity < 25 deg/s, at least 50 ms before next saccade detected
%magnitude: at least 2 degrees
%adjustment: 50 ms is added to end time in order to get past slowdown time
%discarding: saccades occuring within 20 ms of end of trial (lack of data)

%note that eye position is sampled at 500hz, and everything is done in 'eye time' for this script, so index = time/2

function [locations,sac_interval] = find_sacs(HEyeTrace,VEyeTrace, h_only)
%report the location of all detected saccades (x,y,t) with velocity from
%100-900 deg/sec
HEyeTrace = smooth(HEyeTrace,15); %smoothing to remove jitter. Might result in difficulty with exact measurement of saccade timing
VEyeTrace = smooth(VEyeTrace,15);
eye_vel = zeros(length(HEyeTrace),1);
if h_only
    for i = 1:(length(HEyeTrace)-1)
        eye_vel(i) = abs((HEyeTrace(i+1)-HEyeTrace(i)))/.002; %.002 puts in deg/sec (2 ms bin length, due to 500hz sampling)
    end
else
    for i = 1:(length(HEyeTrace)-1)
        eye_vel(i) = sqrt((HEyeTrace(i+1)-HEyeTrace(i))^2+(VEyeTrace(i+1)-VEyeTrace(i))^2)/.002;
    end
end

high_times = find(eye_vel>50); %eye velocity > 50 deg/s
shifted = vertcat(high_times(2:end),0);
transition_times = high_times(find(abs(shifted-high_times) > 25)); %detect time points where the saccade slows down for at least 100 ms
sac_end_times=[];
sac_start_times=[];
for t = 1:length(transition_times);
    transition = transition_times(t);
    slow_times = find(eye_vel<25); %find times where saccade is below 25 deg/s
    if ~isempty(slow_times(find(slow_times < transition,1,'last')))
        sac_start = slow_times(find(slow_times < transition,1,'last'));
    else
        sac_start = 1;
    end
    if ~isempty(slow_times(find(slow_times > transition,1)))    %first slow time after transition
        
        sac_end = slow_times(find(slow_times > transition,1))+25;%+25 makes endpoint more accurate (instead of being on the curve, is on the flat)
        if sac_end < length(HEyeTrace) %dont use endpoints that go past the end of the trial
            if h_only
                magnitude = abs(HEyeTrace(sac_start)-HEyeTrace(sac_end));
            else
                magnitude = sqrt((HEyeTrace(sac_start)-HEyeTrace(sac_end))^2+(VEyeTrace(sac_start)-VEyeTrace(sac_end))^2);
            end
            if magnitude > 2 & max(abs(VEyeTrace(sac_start:sac_end))) < 35  %saccade must have a magnitude of at least 2 degrees, otherwise skipped, also skipping blinks (result in very high V amplitude when using eye tracker)
                sac_start_times(end+1) = sac_start;
                sac_end_times(end+1) = sac_end;
            end
        else
            sac_start_times(end+1) = sac_start;
            sac_end_times(end+1) = length(HEyeTrace); %if no slow times after transition, happens at end of trials
        end
    
    end
end

if ~isempty(sac_end_times)
    Hsac_endpoints = HEyeTrace(sac_end_times);
    Vsac_endpoints = VEyeTrace(sac_end_times);
else
    Hsac_endpoints = [];
    Vsac_endpoints = [];
end
% check_sac_plotter; %code for looking at the raw eye traces and comparing
% that with what comes out of the code
locations=[Hsac_endpoints,Vsac_endpoints];
sac_interval = [sac_start_times'*2,sac_end_times'*2]; %sampling rate is 500 hz, so multiplying by 2 to put in trial time
end

