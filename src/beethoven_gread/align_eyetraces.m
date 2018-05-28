% ALIGN_EYETRACES            Aligns eyedata to particular time
% 
%     [out] = align_eyetraces(dat,state,time,window);
%
%     INPUTS 
%     dat    - rawdata structure
%     state  - scalar specifying the state that the TIME parameter is
%              relative to; note that eyedata are not limited to this state,
%              that is, if the WINDOW extends beyond the state, eyedata are
%              still included (unless we never got to this state)
%     time   - scalar (in milliseconds) specifying anchor of counting 
%              window relative to start of STATE
%     window - vector with two numbers specifying (in milliseconds) the
%              amount of time to start counting before and after TIME
%  
%     OUTPUTS
%     out    - cell array with same size as dat; each cell contains:
%              
%              out{i}(:,1)   - time vector in milliseconds
%              out{i}(:,2:3) - corresponding x- and y-pos
%
%     EXAMPLES
%     To get spikes and eyetraces aligned, make sequential calls with same parameters
%     >> [spkstats,spk] = get_spkstats(dat,3,0,[-100 500]);
%     >> eyetraces = align_eyetraces(dat,3,0,[-100 500]);
%     
%     Plotting is straightforward using a FOR loop
%     >> raster(spk); 
%     >> for i = 1:length(eyetraces); plot(eyetraces{i}(:,1),eyetraces{i}(:,2:3)); end
%
%     There is also a syntax to align to an absolute time (eg., reaction time)
%     >> eyetraces = align_eyetraces(dat,0,reaction_time,[-100 500]);
%     % OR
%     >> eyetraces = align_eyetraces(dat,[],reaction_time,[-100 500]);

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 03.12.02 written

function [out] = align_eyetraces(dat,state,time,window);

if max(size(time)) == 1
   time = repmat(time,length(dat),1);
elseif max(size(time)) ~= length(dat)
   error('Length of TIME vector must match length of DAT [GET_SPKSTATS].');
end

% Get the sampling time and the start time of requested state
dt = dat(1).EYERES;
if ~isempty(state)
   statedata = extract(dat,'statedata',state,1);
end

% Align each trial
for i = 1:length(dat)
   if isempty(state)
      abs_t = time(i);
   else
      abs_t = statedata(i) + time(i);
   end
   if ~isnan(abs_t)
      start_t = abs_t + window(1);
      end_t = abs_t + window(2);
      
      % Find the eyesamples that fall into our start and end times
      temp = 1:length(dat(i).eyedata);
      ind = find((temp > start_t/dt) & (temp < end_t/dt));
      
      if ~isempty(ind)
         % Pack aligned and trimmed data for each trial into cell array
         out{i}(:,2:3) = dat(i).eyedata(ind,:);
         out{i}(:,1) = dt*(1:length(ind))' + window(1);
      else
         out{i}(:,2:3) = [NaN NaN];
         out{i}(:,1) = [NaN];
      end
   else
      out{i}(:,2:3) = [NaN NaN];
      out{i}(:,1) = [NaN];
   end
end

return