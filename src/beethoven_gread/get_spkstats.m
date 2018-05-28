% GET_SPKSTATS               Get basic spike statistics
% 
%     [spkstats,spk] = get_spkstats(dat,state,offset,window,exclusion_window);
%
%     INPUTS
%     dat              - raw data structure
%     state            - scalar specifying the state that the OFFSET parameter is
%                        relative to; note that spikes are not limited to this state,
%                        that is, if the WINDOW extends beyond the state, spks are
%                        still included (unless we never got to this state)
%     offset           - scalar (in milliseconds) specifying anchor of counting 
%                        window relative to start of STATE (specifies the zero)
%     window           - vector with two numbers specifying (in milliseconds) the
%                        amount of time to start counting before and after OFFSET
%
%     OPTIONAL
%     exclusion_window - vector with two numbers specifying (in milliseconds) a
%                        window to ignore spikes before and after OFFSET; good for
%                        excluding artifacts
%
%     OUTPUTS
%     out              - struct array defined as 'spkstats' containing fields:
% 
%                        count  - number of spikes found in window
%                        abs_t  - absolute time in trial about which window is anchored
%                        window - relative to abs_t
%                        state  - state given as input
%
%     EXAMPLE
%     % to count spikes that occur from -10 milliseconds before 
%     % to 250 milliseconds after the onset of state 5:
%
%     >> spkstats = get_spkstats(dat,5,0,[-10 250]);
%
%     % to shift the same window to 50 milliseconds after the onset of 
%     % state 5:
%
%     >> spkstats = get_spkstats(dat,5,50,[-10 250]);

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 01.01.02 written
%     brian 02.12.02 changed third input name from TIME to OFFSET
%     brian 08.08.02 added optional input for excluding spikes

function [spkstats,spk] = get_spkstats(dat,state,offset,window,exclusion_window);

%----- Globals, definitions, & constants
DEF = 'spkstats';

% Pull spikes out as cell array
spk = extract(dat,'spkdata');

if max(size(offset)) == 1
   offset = repmat(offset,length(dat),1);
elseif max(size(offset)) ~= length(dat)
   error('Length of OFFSET vector must match length of DAT [GET_SPKSTATS].');
end

for i = 1:length(dat)
   % Convert to units of milliseconds, this is a HACK since the
   % spike times are multiplied by 10 in Gram so AVS can read
   temp = spk{i}/1000;
   
   ind = get_state_index(dat(i).statedata,state,dat(i).EYERES);
   if ~isempty(ind)
      %-- If we made it to the desired state
      % Convert to absolute trial time
      abs_t = ind(1)*dat(i).EYERES + offset(i);
      start_t = abs_t + window(1);
      end_t = abs_t + window(2);
            
      if ~isempty(temp)
         %-- If we have spikes, align them to the desired event time
         if nargin == 5
            exclude_start_t = abs_t + exclusion_window(1);
            exclude_end_t = abs_t + exclusion_window(2);
            spk{i} = temp((temp>start_t) & (temp<end_t) & ((temp<exclude_start_t) | (temp>exclude_end_t))) - abs_t;
         else
            % Subtracting ABS_T shifts back to relative time
            spk{i} = temp((temp>start_t) & (temp<end_t)) - abs_t;
         end
         spkstats(i).count = length(spk{i});
         spkstats(i).abs_t = abs_t;
         spkstats(i).window = window;
         spkstats(i).state = state;
         spkstats(i).def = DEF;
      else
         spk{i} = [];
         spkstats(i).count = 0;
         spkstats(i).abs_t = abs_t;
         spkstats(i).window = window;
         spkstats(i).state = state;
         spkstats(i).def = DEF;
      end
   else
      spk{i} = [];
      spkstats(i).count = NaN;
      spkstats(i).abs_t = NaN;
      spkstats(i).window = window;
      spkstats(i).state = state;
      spkstats(i).def = DEF;
   end
end

return