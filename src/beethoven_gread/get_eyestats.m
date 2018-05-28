% GET_EYESTATS               Basic statistics of eye movements
% 
%     [eyestats,v] = get_eyestats(dat,states,vthresh,vminmax,athresh,dthresh,fparams);
%
%     This function is essentially a wrapper for GET_EYEMETRICS. The search
%     for saccades is forced to begin at the first requested state, and it
%     ranges over time up to the largest requested state that exists in the 
%     data. Therefore, the SACCADE_TIMES field is relative the time of the
%     onset of the first requested state (stored in START_T).
%
%     Note that this is currently limited to returning data for one saccade
%     within the requested states. Handling multiple saccades could be
%     implemented if anyone desires. In the meantime, it is easy to call
%     this function repeatedly with different states.
%
%     INPUTS [ALL TIMES IN MILLISECONDS!!!]
%     dat      - data structure with eyedata
%     states   - vector of states within which to search for saccades, different
%                state vectors can be passed in for each trial, simply pass in
%                a cell array with a vector for each trial
%     vthresh  - initial velocity threshold (> ~10 degrees/sec)
%     vminmax  - minimum peak velocity (>= vthresh)
%     athresh  - minimum amplitude (> target window)
%     dthresh  - minimum duration (>= ~5 milliseconds)
%
%     OPTIONAL
%     fparams  - 2 element vector containing Savitzy-Golay filter parameters
%  
%     OUTPUTS
%     eyestats - structure array with eye statistics, each element is a structure
%                with the fields:
%
%                peak_velocity - scalar, deg/sec
%                saccade_times - [start end], msec
%                amplitude     - scalar, deg
%                endpoint      - [xpos ypos], deg
%                start_t       - scalar indicating start time of search, msec
%                states        - [vector] indicating states searched
%     v        - corresponding velocity trace (polar amplitdude deg/sec)

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 01.15.02 written
%     brian 02.19.02 implemented check for minimal number of eyesamples
%     brian 04.06.02 added optional velocity output

function [eyestats,v] = get_eyestats(dat,states,vthresh,vminmax,athresh,dthresh,fparams);

%----- Globals, definitions, & constants
DEF = 'eyestats';

% We allow for the case where STATES can be different for each trial,
% if this is the case, there must be a cell for each trial.
nstatevecs = size(states,1);
if (nstatevecs > 1) & (nstatevecs ~= length(dat))
   error('Number of rows in DAT and STATES must match.');
end

dt = dat(1).EYERES;
trials = length(dat);
if exist('fparams','var')
   % Precompute the differentiating filter
   [B,D] = sgolay(fparams(1),fparams(2));
   df = D(:,2);
   
   % Minimum amount of data where we can search for a saccade
   min_data_samples = max(fparams(2),dthresh/dt);
else
   df = [];
   min_data_samples = max(3,dthresh/dt);
end

for i = 1:trials
   if nstatevecs > 1
      ind = get_state_index(dat(i).statedata,states{i},dt);
   else
      ind = get_state_index(dat(i).statedata,states,dt);
   end
   
   % If subject actually makes it to the requested states
   if length(ind) > min_data_samples
      if isempty(df)
         [temp,v_temp] = get_eyemetrics(dat(i).eyedata(ind,:),dt,vthresh,vminmax,athresh,dthresh);
      else
         [temp,v_temp] = get_eyemetrics(dat(i).eyedata(ind,:),dt,vthresh,vminmax,athresh,dthresh,df);
      end
      temp.start_t = min(ind)*dt;
      if nstatevecs > 1
         temp.states = states{i};
      else
         temp.states = states;
      end
      temp.def = DEF;
      eyestats(i) = temp;
      
      if nargout == 2
         v{i} = v_temp;
      end
   else
      % Populate struct array for trials when the eyes never made it
      % to the requested states
      eyestats(i).peak_velocity = NaN;
      eyestats(i).saccade_times = [NaN NaN];
      eyestats(i).amplitude = NaN;
      eyestats(i).endpoint = [NaN NaN];
      eyestats(i).start_t = NaN;
      eyestats(i).states = states;
      eyestats(i).def = DEF;
      
      if nargout == 2
         v{i} = [];
      end
   end
end

return
