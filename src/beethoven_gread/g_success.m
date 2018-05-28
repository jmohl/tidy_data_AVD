% G_SUCCESS                  Manipulate Gram success levels
% 
%     [s] = g_success(level,success,rule);
%
%     Success levels can be accumulated through a trial-type
%     and are encoded as 16 bit integers. This function lets
%     you check whether certain success levels, or combinations
%     of success levels were reached in a trial
%
%     INPUTS
%     level   - desired success levels
%
%     OPTIONAL
%     success - a vector of decimal representation of success levels
%     rule    - a string with any of the below logical rules
%
%     AND 00 0    OR 00 0    NAND 00 1    NOR 00 1    XOR 00 0
%         01 0       01 1         01 1        01 0        01 1
%         10 0       10 1         10 1        10 0        10 1
%         11 1       11 1         11 0        11 0        11 0
%
%     OUTPUTS
%     s       - if only one input argument, a matrix of size(level)
%               is returned with the decimal representations of
%               Gram success levels
%               if a success vector and rule are also given as inputs,
%               a logical vector is returned with 1 indicating
%               satisfaction of the rule and 0 otherwise
%
%     EXAMPLE
%     g_success(0:16) % display decimal representations of individual 
%                     % success levels
%     success = [1 0 3 0 1 1]' % pretend success vector
%     g_success(1,success) % bit 1 high
%     g_success([1 2],success,'and') % bit 1 & bit 2 high
%     g_success([1 2],success,'or') % bit 1 or bit 2 high
%     g_success([1 3],success,'and') % bit 1 & bit 3 high

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 01.20.02 written 

function [s] = g_success(level,success,rule);

nlevels = length(level);

% 16 success levels starting at the least significant bit
str = repmat('0000000000000000',nlevels,1);
for i = 1:nlevels
   if level(i) ~= 0
      str(i,17 - level(i)) = '1';
   end
end
s = bin2dec(str);

if nargin >= 2
   if nlevels == 1   % Only one requested level
      s = check_bit(success,s);
   else              % Multiple levels
      % Initiate boolean vector
      s_temp = check_bit(success,s(1));
      switch lower(rule)
      case 'and'
         for i = 2:nlevels
            s_temp = and(s_temp,check_bit(success,s(i)));
         end
      case 'or'
         for i = 2:nlevels
            s_temp = or(s_temp,check_bit(success,s(i)));
         end
      case 'nor'
         for i = 2:nlevels
            s_temp = or(s_temp,check_bit(success,s(i)));
         end
         s_temp = 1 - s_temp;
      case 'nand'
         for i = 2:nlevels
            s_temp = and(s_temp,check_bit(success,s(i)));
         end
         s_temp = 1 - s_temp;
      case 'nand'
         error('Not yet implemented');
         % Problem with confusion of sequences.
      otherwise
         error('Bad combination rule for G_SUCCESS');
      end
      s = s_temp;
   end
   
end

return

%%%%%%%%%%%%%%%%%% LOCAL FUNCTIONS
function [x] = check_bit(vec,scal);

if scal == 0
   x = vec == 0;
else
   x = bitand(vec,scal)>0;
end