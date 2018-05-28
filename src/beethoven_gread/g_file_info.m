% G_FILE_INFO                Some info about a Gramalkn datafile
% 
%     [trials,errors,num_trials] = g_file_info(fname);
%
%     Calling without inputs prints the trial number of trials
%     with positive ERROR values to the command window.
%
%     INPUTS
%     fname       - filename as a string (include extension)
%
%     OUTPUTS
%     trials      - vector of trials numbers
%     errors      - vector of ERROR value from preamble
%     num_trials  - total number of trials in data file (not in data structure)

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 02.10.02 written

function [trials,errors,num_trials] = g_file_info(fname);

%----- Globals, definitions, & constants
INT = 'int16';
BLOCKSIZE = 1024;    % bytes

%----- Open data file assuming little-endian
[fid,message] = fopen(fname,'rb','ieee-le');
if fid < 0
   fprintf('\n%s ... File probably not found.\n',message);
   return;
end

% Run through the data file once to grab the blocksizes
num_trials = 1;
while 1
   if num_trials == 1
      % Move to position where dataype version is stored.
      % Reading once is OK, since Gram requires restart when
      % changing between datatype versions.
      fidpos = ftell(fid);
      fseek(fid,164*2,'bof');
      datatype_version = fread(fid,1,INT);
      fseek(fid,fidpos,'bof');
   else
      % Move pointer to end of trial
      ind = BLOCKSIZE*sum(blocks(1:(num_trials-1)));
      fseek(fid,ind,'bof');
   end
   % Read in enough of preamble to get blocksize and trial number
   temp = fread(fid,56,INT);
   if isempty(temp)
      break % EOF
   else
      blocks(num_trials) = temp(11);
      errors(num_trials) = temp(14);
      trials(num_trials) = temp(56);
      num_trials = num_trials + 1;
   end
end
num_trials = num_trials - 1;
fclose(fid);

if nargout == 0
   fprintf('\n');
   fprintf('   Filename: %s \n',fname);
   fprintf('   %g trials starting with trial #%g and ending with trial #%g\n',...
      num_trials,trials(1),trials(end));
   if length(find(errors)) > 0
      fprintf('   %g trials with ERROR high. The trial #''s are:\n',length(find(errors)));
      disp(trials(find(errors)));
   else
      fprintf('   No trials with ERROR high\n\n');
   end
end

return
