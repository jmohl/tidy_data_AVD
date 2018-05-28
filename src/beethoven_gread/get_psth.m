% GET_PSTH                   Estimate spike rate
% 
%     [r,t,r_sem] = get_psth(spk,binsize,window,flag,varargin);
%
%     INPUTS
%     spk      - spike times, should be packed as cell array
%                each cell containing spikes for a single trial.
%                currently expects spike times to be in milliseconds
%     binsize  - size of bins in milliseconds
%     window   - vector [start_time end_time] specifying in milliseconds
%                spike times to include
%  
%     OPTIONAL
%     flag     - 'kde' : kernel density estimate (SLOW!)
%                        BINSIZE is then used as first pass kernel width
%                'isi' : inverse interspike-interval (like AVS)
%                        BINSIZE is ignored
%                defaults to standard histogram without FLAG
%     varargin - for 'kde', specifies how adaptive the estimator is,
%                0 is standard non-adaptive density estimation,
%                (0,1] gives variable smoothing (see AKDE)
%
%     OUTPUTS
%     r        - mean spike rate in units of spikes/sec
%     t        - corresponding time vector in milliseconds
%     r_sem    - standard error of the mean spike rate

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.00.01 written
%     brian 02.15.02 added ISI estimator

function [r,t,r_sem] = get_psth(spk,binsize,window,flag,varargin);

dt = 1; % Spike time resolution in milliseconds

if nargin < 4
   flag = '';
end

if strcmp(flag,'kde')
   t = (window(1):window(2))';
   nbins = length(t);
elseif strcmp(flag,'isi')
   t = (window(1):window(2))';
   nbins = length(t);
else
   % Sets up bin edges to use HISTC
   nbins = ceil((window(2)-window(1))/binsize) + 1;
   t = (window(1) + (0:(nbins-1))*(binsize*dt))';
end
r = zeros(nbins,length(spk));
reps = zeros(nbins,length(spk));

%----- Loop over all repeats and get rate
for j = 1:length(spk)
   spkind = spk{j};
   spkind = spkind(spkind>t(1) & spkind<t(end));
   if ~isempty(spkind)
      if strcmp(flag,'kde')
         if nargin > 4
            reps(:,j) = akde(t,spkind,binsize,varargin{1})*1000;
         else
            reps(:,j) = akde(t,spkind,binsize)*1000;
         end
      elseif strcmp(flag,'isi')
         isi = diff(spkind);
         % Shift to array that starts at index 1
         temp = spkind - t(1) + 1;
         for n = 1:length(isi)
            ind = round(temp(n):temp(n+1));
            reps(ind,j) = 1/(isi(n)/1000);
         end
      else
         temp = histc(spkind,t)/(binsize*(dt/1000));
         % Time vector is shifted from centers from edges, let's us use HIST instead
         %temp = hist(spkind,t + binsize/2)/(binsize*(dt/1000));
         reps(:,j) = temp(:);
      end
   end
end

r = mean(reps,2);
if nargout == 3
   r_sem = std(reps,0,2)/sqrt(length(spk));
end

return
