% INITIATE_GLOBALS           Initiate some useful parameters
%
% Several functions make a call to this script to initiate pseudo-global
% variables (eg., G_READ_DATA & G_READ_PREAMBLE). These aren't truly global
% since they are only visible within the function, but they sort of serve
% the same purpose. If you want to use these variables in a function,
% simply make a call to INITIATE_GLOBALS inside your function.

%---- These are all binary switches.
% dumps some debugging information into the command window
DEBUG_FLAG = 0;
% set to 0 if you want to keep trials flagged as errors (dropped eyesamples)
ERROR_FLAG = 0;
% set to 0 if you don't want to exclude junk spikedata (failure to garbage collect)
SPIKE_FLAG = 1;
% set to 1 if you want to read in bitmap filenames (unless you use these,
% keep this off because reading these filenames is slow
VSG_FLAG = 1;

%----- 
% Number of private preamble elements. These are read in sequentially starting
% at preamble position 384. Last 256 bytes of preamble are reserved for user defines.
USR_PREAMB_ELEMENTS = 13;
