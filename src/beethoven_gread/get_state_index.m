% GET_STATE_INDEX            Extract index of samples within requested states
% 
%     [ind] = get_state_index(statedata,states,dt);
%
%     INPUTS
%     statedata - matrix as formatted by G_READ_EYEDATA:
%                 
%                 start     end     state(1)
%                 start     end     state(2)
%                 start     end     state(3)
%                   .        .        .
%                   .        .        .
%                   .        .        .
%                 start     end     state(n)
%
%     states    - vector of desired states
%     dt        - sampling time of the state info (usually 2 ms)
%
%     OUTPUTS
%     ind       - index of samples that correspond to requested 
%                 state
%
%     EXAMPLE
%     This function would normally be used to get the index for
%     eyedata that was collected in a particular state. For 
%     example, if you have a raw data structure 'dat':
%
%     % this gets the index for eyedata in states 3 through 11
%     >> ind = get_state_index(dat(1).statedata,[3:11],dat(1).EYERES);
%     >> plot(dat(1).eyedata(ind,:);

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.00.01 written
%     brian 02.12.02 got rid of slow loop for multiple states

function [ind] = get_state_index(statedata,states,dt);

if size(statedata,2) ~= 3
   error('Incorrectly formatted STATEDATA');
end

% Convert from milliseconds to samples
statedata(:,1:2) = statedata(:,1:2)/dt; 

if length(states) == 1
   %-- Only 1 state was requested
   temp = find(statedata(:,3) == states);
   if ~isempty(temp)
      ind = (statedata(temp,1):statedata(temp,2))'; 
   else
      ind = [];
   end
else
   %-- Multiple requested states
   % Note that we force the first state exist
   min_s = find(statedata(:,3) == min(states));
   if isempty(min_s)
      ind = [];
      return
   end
   max_s = find(statedata(:,3) <= max(states));
   if isempty(max_s)
      ind = (statedata(min_s(1),1):statedata(min_s(1),2))';
   else
      ind = (statedata(min_s(1),1):statedata(max_s(end),2))';
   end
end

% HACK! in case anyone requests a search starting at state 0
if ~isempty(ind)
   if ind(1) == 0
      ind(1) = [];
   end
end

return