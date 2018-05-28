% G_READ_EYEDATA             Read in packed eyedata
% 
%     [eyedata,statedata] = g_read_eyedata(fid,nsamples,neyes,eyegain,dt,datatype_version);
%
%     Unpacks eye and state data. Assumes that the file has been
%     opened using the little-endian machine-format.
%
%     If reading datatype version 3 format is as follows:
%          16 bits vertical eye position
%          16 bits horizontal eye position
%          16 bits state & histo (8 bits each)
%     If reading datatype version 2 format is as follows:
%          24 bits eye position (packed)
%          8 bits state
%          16 bits histo
%
%     INPUTS
%     fid              - valid pointer for data file, eye and state data 
%                        is read straight through and fid must be parked 
%                        at the beginning of the requested data
%     nsamples         - # of desired samples
%     neyes            - # of analog channels
%     eyegain          - x and y-position divided by this
%     dt               - sampling time of eyedata in milliseconds
%     datatype_version - added to preamble in Gram v.3.0.77 
%  
%     OUTPUTS
%     eyedata          - first column is x-pos, second is y-pos
%     statedata        - matrix of state information
%                        each row is information for a state arranged as:
%                        [start end state], in units of milliseconds

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.00.01 written based on source code for Gram v.3.0.69
%     brian 01.09.01 also handles new datatype version from Gram v.3.0.77
%     brian 02.09.02 bitshifts converted to explicit divides (sadly, it's faster)
%     brian 02.15.02 simplified statedata encoding
%     brian 08.05.02 fixed bug for statedata encoding that crashed with one state
%     brian 02.23.03 Added catch for datatype_version 4 (no longer exists)
%     brian 07.14.04 Properly handles multiple analog channels.
%                    Currently ONLY works for 16 bit data.

function [eyedata,statedata] = g_read_eyedata(fid, nsamples, neyes, eyegainx1, eyegainy1, eyegainx2, eyegainy2, eyegainx3, eyegainy3, eyegainx4, eyegainy4, dt, datatype_version);

%----- Globals, definitions, & constants
INT = 'uint16';
MASK_f000 = 61440; % 1111000000000000
MASK_0f00 = 3840;  % 0000111100000000
MASK_00f0 = 240;   % 0000000011110000
MASK_000f = 15;    % 0000000000001111
MASK_00ff = 255;   % 0000000011111111
MASK_0fff = 4095;  % 0000111111111111
MASK_ff00 = 65280; % 1111111100000000

%----- Read in the eye data
disassembledBits = fread(fid,nsamples*(2*neyes+1),INT);
xpos = zeros(nsamples*neyes,1);
ypos = zeros(nsamples*neyes,1);
eyedata = zeros(nsamples,2*neyes);

if (datatype_version == 0) | (datatype_version == 2) | (datatype_version == 4)% 0 for old data pre 3.0.77
   % Bit resolution of eyedata
   MAXVAL = 2^12;
   % Point at which to fold the eye data over to negative values
   FOLDVAL = MAXVAL/2;
   
   %----- Unpack it with some bit diddling
   fabc = disassembledBits(1:3:end);
   ghde = disassembledBits(2:3:end);
   if length(fabc) ~= length(ghde)
      error('Bad eyedata alignment in G_READ_EYEDATA.');
   end
   
   %-- Break FA BC GH DE into ABC DEF GH
   % x-position (NOTE that horizontal is written 1st here!)
   xpos = bitand(fabc,MASK_0fff);
   % y-position
   nibbleF = bitand(fabc,MASK_f000);
   byteDE = bitand(ghde,MASK_00ff);
   ypos = byteDE*16; %ypos = bitshift(byteDE,4); 
   ypos = bitor(ypos,nibbleF/4096); %ypos = bitor(ypos,bitshift(nibbleF,-12)); 
   
   % State info
   if nargout == 2
      s = bitand(ghde,MASK_ff00)/256; %s = bitshift(bitand(ghde,MASK_ff00),-8); 
      % HACK !!!!!!! changes required to conform to trial-types.
      % Pre 3.0.77 data (datatype_version == 0) also seems shifted
      % by one sample? However, this may not be a problem since
      % the eyedata seems to have an extra point at the beginning?
      if datatype_version == 0
         s(1) = 1;
         s = s - 1;
      else
         s = s - 1;
      end
   end
elseif datatype_version == 3
   % Bit resolution of eyedata
   MAXVAL = 2^16;
   % Point at which to fold the eye data over to negative values
   FOLDVAL = MAXVAL/2;
 
	nintspersample = neyes*2+1;
	s = disassembledBits(nintspersample:nintspersample:end);
	disassembledBits(nintspersample:nintspersample:end) = [];
	
	ypos = disassembledBits(1:2:end);
	xpos = disassembledBits(2:2:end);

%    ypos = disassembledBits(1:3:end);
%    xpos = disassembledBits(2:3:end);

%    % State info
%    if nargout == 2
%       %s = bitshift(bitand(disassembledBits(3:3:end),MASK_00ff),8);
%       % HACK !!!!!!! check that state is packed into least significant bits
%       s = disassembledBits(3:3:end);
%    end
else
   error('Unknown DATATYPE_VERSION.');
end

% Prepare output formatting for statedata
if nargout == 2
   [temp,d] = myunique(s);
   statedata = zeros(length(temp),3);
   statedata(:,3) = temp;
   if length(temp) == 1 % in case there is only one state
      ind = d;
   else
      ind = [d ; nsamples];
   end

   statedata(:,2) = ind;
   statedata(2:end,1) = ind(1:end-1);
   statedata(:,1:2) = statedata(:,1:2)*dt; % Convert to milliseconds
end

% As far as I can tell, the eyepos values are written unsigned, so
% the negative values get wrapped around to the upper end of the
% largest value for a 12 or 16 bit unsigned integer
xpos(xpos>FOLDVAL) = xpos(xpos>FOLDVAL) - MAXVAL;
ypos(ypos>FOLDVAL) = ypos(ypos>FOLDVAL) - MAXVAL;
% eyedata(:,1:2:(neyes*2)) = reshape(xpos,nsamples,neyes)/eyegain;
% eyedata(:,2:2:(neyes*2)) = reshape(ypos,nsamples,neyes)/eyegain;

%eddie changed with gainx and gainy and also for all eyes

gainx = [eyegainx1, eyegainx2, eyegainx3, eyegainx4];
gainy = [eyegainy1, eyegainy2, eyegainy3, eyegainy4];

for i = 1:neyes
	eyedata(:,2*(i-1)+1) = xpos(i:neyes:end)/gainx(i);
	eyedata(:,2*(i-1)+2) = ypos(i:neyes:end)/gainy(i);
end
%%%%%%%%%%%%%%%%%%%%%%%% Fix for AVS HACK
% A reduction of ADC resolution was implemented in Gram v.3.0.77 (?)
% to conform to a bug in AVS (only for DATATYPE_VERSION = 2)
% this involves dropping LSB and right-shifting by one (ie, divide by 2)
% leaving 11 bits of eyedata resolution
if (datatype_version == 2) | (datatype_version == 4)
   eyedata = eyedata/2;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOCAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See MATLAB UNIQUE for explanation
function [b,d] = myunique(a)

d = find(diff(a));
if isempty(d) % HACK in case there is only one state
   [b,d] = unique(a);
else
   b = a([d ; d(end)+1]);
end