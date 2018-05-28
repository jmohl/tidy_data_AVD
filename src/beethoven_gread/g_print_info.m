% G_PRINT_INFO               Prints Gram preamble info to screen
% 
%     g_print_info(dat,index,verbose);
%
%     INPUTS
%     dat     - 'rawdata' Gram data structure
%     index   - index of trials to print
%  
%     OPTIONAL
%     verbose - controls amount of information printed
%               defaults to printing basic info only
%               2 : prints interval information
%               3 : prints target information
%

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.15.01 written

function g_print_info(dat,index,verbose);

if nargin < 2
   index = 1:length(dat);
end

if nargin < 3
   verbose = 1;
end

if exist('index','var')
   if isempty(index)
      index = 1:length(dat);
   end
end

index = index(:)';

fprintf('\n\n');
fprintf('=========================================================================\n');
fprintf(' Filename: %s, recorded from %s on %s \n',dat(1).fname,upper(dat(1).MONKNAME),...
   datestr(datenum(dat(1).YEAR,dat(1).MONTH,dat(1).DAY,dat(1).HOUR,dat(1).MIN,dat(1).SEC),21));
fprintf('=========================================================================\n');
for i = index
   fprintf(' Trial#: \t %g \n',dat(i).TRIAL);
   fprintf(' Typename: \t %s\n',dat(i).TYPENAME);
   fprintf(' Type: \t\t %g\n',dat(i).TYPE);
   fprintf(' Time: \t\t %g milliseconds\n',dat(i).TIME);
   fprintf(' Success: \t %s \n',dec2bin(dat(i).SUCCESS));
   fprintf(' Reward: \t %g \n',dat(i).REWARD);
   fprintf(' Water: \t %g \n',dat(i).WATER);
   fprintf(' Water VR: \t %g%% \n',dat(i).WATERVR);
   if verbose >= 2
      fprintf(' Intervals:  \n');
      fprintf('   ITI: \t %g \n',dat(i).ITI);
      fprintf('   Wait: \t %g \n',dat(i).WAIT);
      fprintf('   Fix: \t %g \n',dat(i).FIX);
      fprintf('   O+A: \t %g \n',dat(i).OPLUSA);
      fprintf('   Cue: \t %g \n',dat(i).CUE);
      fprintf('   Delay: \t %g \n',dat(i).DELAY);
      fprintf('   Latency:  %g \n',dat(i).LATENCY);
      fprintf('   Fix2: \t %g \n',dat(i).FIX2);
      fprintf('   Gap: \t %g \n',dat(i).GAP);
   end
   if verbose >= 3
      fprintf(' Target: \t x-pos \t y-pos \t color \t window size (deg)\n');
      for j = 1:min(size(dat(i).TAR,1),size(dat(i).WIN,1))
         fprintf('\t (%g) \t %+g \t %+g \t %g \t\t\t %g \n',j,dat(i).TAR(j,1),dat(i).TAR(j,2),...
            dat(i).TAR(j,3),dat(i).WIN(j));
      end
   end
   fprintf('-------------------------------------------------------------------------\n');
end
fprintf('\n\n');