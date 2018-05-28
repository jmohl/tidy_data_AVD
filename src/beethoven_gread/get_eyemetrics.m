% GET_EYEMETRICS             Basic metrics of eye movements
% 
%     [stats,v] = get_eyemetrics(eyedata,dt,vthresh,vminmax,athresh,dthresh,fparams);
%
%     Eye movements are taken as all events which exceed the initial 
%     velocity threshold (VTHRESH). From these, saccades are selected as 
%     events which exceed a minimum duration (DTHRESH), possess a peak 
%     velocity of at least VMINMAX, and an amplitude > ATHRESH. The start 
%     and end times of the saccade are taken as:
%                     LAT x peak velocity,
%     where LAT is a constant and the times are selected from either side
%     of the maximum.
%
%     INPUTS [ALL TIMES IN MILLISECONDS!!!]
%     eyedata - [xpos ypos] matrix
%     dt      - eye position sampling time (ususally 2 milliseconds)
%     vthresh - initial velocity threshold (> ~30 degrees/sec)
%     vminmax - minimum peak velocity (>= vthresh)
%     athresh - minimum amplitude (> target window)
%     dthresh - minimum duration (>= ~5 milliseconds)
%
%     OPTIONAL
%     fparams - 2 element vector containing Savitzy-Golay filter parameters,
%               [3 7] to [3 11] are reasonable, 2nd element must be odd;
%               if greater than 2 element vector, assumed to be a FIR filter.
%               calling without FPARAMS defaults to using a difference to
%               estimate the velocity.
%  
%     OUTPUTS
%     stats   - structure with fields:
%
%               peak_velocity - scalar, deg/sec
%               saccade_times - [start end], msec
%               amplitude     - scalar, deg
%               endpoint      - [xpos ypos], deg
%
%     v       - velocity trace (polar radius of movement)

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 01.15.02 written
%     brian 02.10.02 fixed minimum amplitude criterion
%     brian 03.30.02 corrected temporal shift for SG filter

function [stats,v] = get_eyemetrics(eyedata,dt,vthresh,vminmax,athresh,dthresh,fparams);

%----- Constants & globals
LAT = 0.15;        % Fraction of peak velocity to use as start & end times
MAX_SACCADES = 1;  % Sets the number of saccades that will be detected HACK!!

if dt ~= 2
   warning('Are you sure that the DT shouldn''t be 2?');
end

xpos = eyedata(:,1);
ypos = eyedata(:,2);
samples = length(xpos);

if exist('fparams','var')
   % Use Savitzky-Golay differentiating filter
   if length(fparams) == 2
      % Compute the filter parameters
      [B,D] = sgolay(fparams(1),fparams(2));
      filtlen = fparams(2);
      hw = (filtlen+1)/2;
      df = D(:,2);
   else
      % Assume whatever was passed in is a proper FIR filter
      filtlen = length(fparams);
      hw = (filtlen+1)/2;
      df = fparams(:);
   end
   
   % Velocity amplitude
   v = sqrt(conv(df,xpos).^2 + conv(df,ypos).^2)/(dt/1000);
   v = v(hw:end-(hw-1));
   
   %Acceleration ?
   %a = sqrt(2*conv(D(:,3),xpos).^2 + 2*conv(D(:,3),ypos).^2)/(dt/1000);
   %a = a(hw:end-(hw-1));
else
   % Use simple difference to estimate derivative
   hw = 1;
   v = zeros(samples,1);
   v(1:(samples-1)) = sqrt((diff(xpos).^2) + (diff(ypos).^2))/(dt/1000);
end

% Kill the endpoints, means we have to ignore any saccades that
% happen in the first or last hw samples
try
   v(1:(hw-1)) = 0;
   v((end-(hw-1)):end) = 0;
catch
   v = v*0;
end

%----- Find all potential movements using VTHRESH criterion
% Index of velocities above threshold
ind = find(v>vthresh);
if isempty(ind)
   stats.peak_velocity = NaN;
   stats.saccade_times = [NaN NaN];
   stats.amplitude = NaN;
   stats.endpoint = [NaN NaN];
   return
end
% Pad the end so that a difference greater than one will mark
% the end of the last saccade
ind = [ind ; ind(end)+2];
% Any values greater than one mark the bounderies between saccades,
% where a saccade is taken as all CONTINUOUS indices of velocities 
temp = diff(ind);
% This marks the stop indices for each saccade
stop_ind = find(temp>1);
stop_ind = [0 ; stop_ind];

%----- Check each potential saccade against the remaining criteria
count = 1;
dthresh = ceil(dthresh/dt); % convert this to samples
for i = 1:(length(stop_ind)-1)
   % Extract index of potential saccade
   sind = ind((stop_ind(i)+1):stop_ind(i+1));
   
   % Meet duration criterion?
   if length(sind) > dthresh
      % Extract velocity profile of movement
      temp = v(sind);      
      j = min(find(temp == max(temp)));
    
      % Minimum peak velocity
      if temp(j) >= vminmax
         peak_velocity(count) = temp(j);
         
         % Find the start (left of peak) and end (right of peak) times
         k = min(find((temp(1:j)<=temp(j)) & (temp(1:j)>LAT*temp(j))));
         saccade_times(count,1) = sind(k)*dt;
         k = (j-1) + max(find((temp(j:end)<=temp(j)) & (temp(j:end)>LAT*temp(j))));
         saccade_times(count,2) = sind(k)*dt;
         
         % Extend the index to get endpoint & amplitude
         sind = [sind(1):min(sind(end)+15,samples)];
         temp = v(sind); 
         xtemp = xpos(sind);
         ytemp = ypos(sind);
         k = (j-1) + max(find((temp(j:end)<=temp(j)) & (temp(j:end)>.05*temp(j))));
         % Amplitude is relative to the beginning of the saccade
         amplitude(count) = sqrt((xtemp(1)-xtemp(k))^2 + (ytemp(1)-ytemp(k))^2);
         % but endpoint is relative to the origin
         endpoint(count,:) = [xtemp(k) , ytemp(k)];
         
         if amplitude < athresh
            peak_velocity(count) = [];
            saccade_times(count,:) = [];
            amplitude(count) = [];
            endpoint(count,:) = [];
         else
            count = count + 1;
            if count > MAX_SACCADES
               break;
            end
         end
      end
   end
end
count = count - 1;

% Set up the output structure
if count >= 1
   stats.peak_velocity = peak_velocity';
   stats.saccade_times = saccade_times;
   stats.amplitude = amplitude';
   stats.endpoint = endpoint;
else
   stats.peak_velocity = NaN;
   stats.saccade_times = [NaN NaN];
   stats.amplitude = NaN;
   stats.endpoint = [NaN NaN];
end

if nargout == 0
   figure
   t = (1:length(eyedata))*dt;
   plot(t,eyedata); hold on;
   if count >= 1
      for i = 1:count
         plot([stats.saccade_times(i,1) stats.saccade_times(i,1)],...
            [-2 2],'r');
         plot([stats.saccade_times(i,2) stats.saccade_times(i,2)],...
            [-2 2],'k');
      end
   end
end

return
