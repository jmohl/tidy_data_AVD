% G_READ_PREAMBLE2           Read in Gramalkn 3.0 data preamble
% 
%     [p] = g_read_preamble2(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);
%
%     The names (sans underscoring) are the same as in preamb.h, the only
%     difference is in the TAR and WIN information, which is stored as a
%     matrix (row specifies target #, [xpos ypos color]) rather than
%     as separate variables.
%
%     INPUTS
%     fid                 - pointer to data file, preamble read straight through
%                           so fid must point to the beginning of the preamble
%     VSG_FLAG            - 1 to read bitmap filenames, 0 otherwise
%     USR_PREAMB_ELEMENTS - # of 16 bit integers from last 256 bytes of preamble
%  
%     OUTPUTS
%     p                   - structure with fields matching preamb.h

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.00.01 written based on source code for Gram v.3.0.69
%     brian 01.09.01 updated for preamble to Gram v.3.0.77
%     brian 02.07.02 updated to read bitmap filenames
%     brian 02.13.02 handles reserved (user specified) preamble elements
%     brian 02.14.02 reduced the number of calls to FREAD
%     brian 06.09.02 reads in added target and interval variables
%                    note that g v. 3.0.83 has a bug in the preamble which
%                    causes some variables be overwritten, see note on line 216
%		eddie 01.01.04 added new preamble variables and updated g_read_data to call this file if preamble version is 3 or 4

function [p] = g_read_preamble2(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);

%----- Globals, definitions, & constants
KEEP_UNUSED_FIELDS = 0;  % Toggles exclusions of selected fields below
PREAMBLENGTH = 1024;     % # of bytes allocated to entire preamble
RESERVED_BYTES = 256;    % # of bytes reserved at end of preamble for user variables
NWIN = 11;
INT = 'int16';           % 16 bits signed
UINT = 'uint16';         % 16 bits unsigned
CHAR = 'char';           % 8 bits

%----- Read in preamble
if KEEP_UNUSED_FIELDS
   p.HEADER1 = fread(fid,1,INT);               % dataBuffer[0] preamble header1 | magic number = 21850
   p.HEADER2 = fread(fid,1,INT);               % dataBuffer[1] preamble header2 | magic number = 23210
   p.BLOCKS = fread(fid,1,UINT);               % dataBuffer[2] num of 1024 byte block - parity check
   p.NUMADC = fread(fid,1,UINT);               % dataBuffer[3] num of adc data - parity check
   p.NUMSPIKE = fread(fid,1,UINT);             % dataBuffer[4] num of spike data- parity check

   p.CAP = fread(fid,1,INT);                   % dataBuffer[5] type of dataBuffer | 0 - standard trialtype, 1 - if text file
else
   fseek(fid,6*2,0);
end

temp              = fread(fid,14,UINT);        %%%%%
p.EYERES          = temp(1);                   % dataBuffer[6] eye resolution, currently at 2ms
p.SPIKERES        = temp(2);                   % dataBuffer[7] spike resolution, currently at 1us
p.LEDGAIN         = temp(3);                   % dataBuffer[8] degree in between two LEDs
p.EYEGAIN         = temp(4);                   % dataBuffer[9] degrees that corresponding to 7.5V

p.BLOCKS1         = temp(5);                   % dataBuffer[10] num of 1024 byte block
p.NUMADC1         = temp(6);                   % dataBuffer[11] num of adc data
p.NUMSPIKE1       = temp(7);                   % dataBuffer[12] num of spike data
p.ERROR           = temp(8);                   % dataBuffer[13] spike recording error

if KEEP_UNUSED_FIELDS
   p.SPIKETIME    = temp(9:end);               % dataBuffer[14-19] spike end time after
end

% Things that do not need update all the time
p.MONKNAME = tostr(fread(fid,10,CHAR));        % dataBuffer[20-24] Monkey name

temp              = fread(fid,7,INT);
p.YEAR            = temp(1);                   % dataBuffer[25] year
p.MONTH           = temp(2);                   % dataBuffer[26] month
p.DAY             = temp(3);                   % dataBuffer[27] day
p.HOUR            = temp(4);                   % dataBuffer[28] hour
p.MIN             = temp(5);                   % dataBuffer[29] min
p.SEC             = temp(6);                   % dataBuffer[30] sec
p.EYES            = temp(7);                   % dataBuffer[31] number of eyes

if KEEP_UNUSED_FIELDS
   p.PLTCODE = fread(fid,1,INT);               % dataBuffer[32] analysis start code
   p.PLTTIME = fread(fid,1,INT);               % dataBuffer[33] histo duration
   p.LASTTARX = fread(fid,1,INT);              % dataBuffer[34] last checked targetx
   p.LASTTARY = fread(fid,5,INT);              % dataBuffer[35-39] last checked targety
   
   p.TRIALID1 = char(fread(fid,10,CHAR));      % dataBuffer[40-44] trialid1
   p.TRIALID2 = char(fread(fid,10,CHAR));      % dataBuffer[45-49] trialid2
else
   fseek(fid,8*2 + 20,0);
end

% Things that do need update all the time
p.TYPENAME = tostr(fread(fid,10,CHAR));        % dataBuffer[50-54] trial type ascii string

temp              = fread(fid,11,UINT);        %%%%%
p.TRIAL           = temp(1);                   % dataBuffer[55] trial# (number of trials run so far)
p.TYPE            = temp(2);                   % dataBuffer[56] trial type number, in sequential order
p.PERCENT         = temp(3);                   % dataBuffer[57] percentage of the type specified in qui
p.SUCCESS         = temp(4);                   % dataBuffer[58] trial success or not

if KEEP_UNUSED_FIELDS
   p.START        = temp(5);                   % dataBuffer[59] recording data start time // retained from gram22 for compatibility
   p.END          = temp(6);                   % dataBuffer[60] recording data end // retained from gram22 for compatibility
end

p.TIME            = temp(7);                   % dataBuffer[61] total time of the trial (ms?)
p.REWARD          = temp(8);                   % dataBuffer[62] number of reward given
p.WATER           = temp(9);                   % dataBuffer[63] number of water given
if KEEP_UNUSED_FIELDS
   p.PLTSTART     = temp(10:11);               % dataBuffer[64-65] graphs plot start state
end

% Targets
p.TAR = zeros(16,3);
p.TAR(1:5,:) = fread(fid,[3 5],INT)';          % dataBuffer[66-80] tar1-tar5

temp              = fread(fid,34,UINT);        %%%%%

% Windows
p.WIN = zeros(NWIN,1);
p.WIN(1:5)        = temp(1:5);                 % dataBuffer[81-85] win1-win5

% Time intervals
p.ITI             = temp(6);                   % dataBuffer[86] 
p.WAIT            = temp(7);                   % dataBuffer[87] 
p.FIX             = temp(8);                   % dataBuffer[88] 
p.OPLUSA          = temp(9);                   % dataBuffer[89] 
p.A               = temp(10);                  % dataBuffer[90] 
p.B               = temp(11);                  % dataBuffer[91] 
p.CUE             = temp(12);                  % dataBuffer[92] 
p.FIX2            = temp(13);                  % dataBuffer[93] 
p.DELAY           = temp(14);                  % dataBuffer[94] 
p.LATENCY         = temp(15);                  % dataBuffer[95] 
p.GAP             = temp(16);                  % dataBuffer[96] 
if KEEP_UNUSED_FIELDS
   p.BRFA         = temp(17);                  % dataBuffer[97] 
   p.STIM1        = temp(18);                  % dataBuffer[98] 
   p.STIM2        = temp(19);                  % dataBuffer[99] 
end

% preserved for future
if KEEP_UNUSED_FIELDS
   p.DISPLAY      = temp(20);                  % dataBuffer[100] retained from gram22 for compatibility
   p.PIPINTO      = temp(21);                  % dataBuffer[101] retained from gram22 for compatibility
   p.PIPINCO      = temp(22);                  % dataBuffer[102] retained from gram22 for compatibility
   p.PIPAMPO      = temp(23);                  % dataBuffer[103] retained from gram22 for compatibility
   p.PIPAMPINCO   = temp(24);                  % dataBuffer[104] retained from gram22 for compatibility
   p.PIPINTA      = temp(25);                  % dataBuffer[105] retained from gram22 for compatibility
   p.PIPINCA      = temp(26);                  % dataBuffer[106] retained from gram22 for compatibility
   p.PIPAMPINCA   = temp(27);                  % dataBuffer[107] retained from gram22 for compatibility
end

% new added by JZ
p.WATERVR         = temp(28);                  % dataBuffer[108] water defined in gui
if KEEP_UNUSED_FIELDS
   p.BEEP         = temp(29);                  % dataBuffer[109] retained from gram22 for compatibility
   p.PUFF         = temp(30:31);               % dataBuffer[110-111] retained from gram22 for compatibility
   p.STROBE       = temp(32);                  % dataBuffer[112] retained from gram22 for compatibility
   p.STIMU1       = temp(33);                  % dataBuffer[113] retained from gram22 for compatibility
   p.STIMU2       = temp(34);                  % dataBuffer[114] retained from gram22 for compatibility
end
% end of gram22 preamb %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% begin of gramalkn 3.0 preamb %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.TAR(6:16,:) = fread(fid,[3 11],INT)';        % dataBuffer[115-147] tar6-tar16

% added windows for gramalkn 3.0
p.WIN(6:11) = fread(fid,6,INT);                % dataBuffer[148-153] win6-win11
   
% added intervals for gramalkn 3.0
temp              = fread(fid,11,UINT);         %%%%%
p.C               = temp(1);                   % dataBuffer[154] target C
p.D               = temp(2);                   % dataBuffer[155] target D
p.E               = temp(3);                   % dataBuffer[156] target E
p.F               = temp(4);                   % dataBuffer[157] target F
p.G               = temp(5);                   % dataBuffer[158] target G
p.H               = temp(6);                   % dataBuffer[159] target H
p.I               = temp(7);                   % dataBuffer[160] target I
p.J               = temp(8);                   % dataBuffer[161] target J

p.MAXLAG          = temp(9);                   % dataBuffer[162] 
p.NASH            = temp(10);                  % dataBuffer[163] 

p.DATATYPE_VERSION = temp(11);                 % dataBuffer[164] 2 = packed, 3 = unpacked
p.PREAMBLE_VERSION = 0;                        % this value is initialized here, but extracted below

if p.DATATYPE_VERSION == 4
   % See note below for explanation
   DUMB_HACK_TO_FIX_DUMBER_BUG = 1;
else
   DUMB_HACK_TO_FIX_DUMBER_BUG = 0;
end
if p.DATATYPE_VERSION > 1
   %if 0 % Fix for Hanuman SeqMove trials prior to 020702
   %   % Equation Object variables
   %   p.MAXMOVES = fread(fid,1,INT);           % dataBuffer[165]
   %   p.MOVE = fread(fid,1,INT);               % dataBuffer[166]
   %   p.BRANCHPOINT = fread(fid,1,INT);        % dataBuffer[167]
   %   p.P1 = fread(fid,1,INT);                 % dataBuffer[168]
   %   p.P2 = fread(fid,1,INT);                 % dataBuffer[169]
   %   p.P3 = fread(fid,1,INT);                 % dataBuffer[170]
   %   p.P4 = fread(fid,1,INT);                 % dataBuffer[171]
   %   p.P5 = fread(fid,1,INT);                 % dataBuffer[172]
   %   p.P6 = fread(fid,1,INT);                 % dataBuffer[173]
   %end
   
   if VSG_FLAG % These are strings for bitmap filenames
      p.BITMAP1 = tostr(fread(fid,10,CHAR));   % dataBuffer[165-169]
      p.BITMAP2 = tostr(fread(fid,10,CHAR));   % dataBuffer[170-174]
      p.BITMAP3 = tostr(fread(fid,10,CHAR));   % dataBuffer[175-179]
      p.BITMAP4 = tostr(fread(fid,10,CHAR));   % dataBuffer[180-184]
      p.BITMAP5 = tostr(fread(fid,10,CHAR));   % dataBuffer[185-189]
      p.BITMAP6 = tostr(fread(fid,10,CHAR));   % dataBuffer[190-194]
      p.BITMAP7 = tostr(fread(fid,10,CHAR));   % dataBuffer[195-199]
      p.BITMAP8 = tostr(fread(fid,10,CHAR));   % dataBuffer[200-204]
      p.BITMAP9 = tostr(fread(fid,10,CHAR));   % dataBuffer[205-209]
      p.BITMAP10 = tostr(fread(fid,10,CHAR));  % dataBuffer[210-214]
      p.BITMAP11 = tostr(fread(fid,10,CHAR));  % dataBuffer[215-219]
      p.BITMAP12 = tostr(fread(fid,10,CHAR));  % dataBuffer[220-224]
      p.BITMAP13 = tostr(fread(fid,10,CHAR));  % dataBuffer[225-229]
      p.BITMAP14 = tostr(fread(fid,10,CHAR));  % dataBuffer[230-234]
      p.BITMAP15 = tostr(fread(fid,10,CHAR));  % dataBuffer[235-239]
      p.BITMAP16 = tostr(fread(fid,10,CHAR));  % dataBuffer[240-244]
      % NOTE : there is a bug in Gramalkn v3.0.83, see preamb.h, the last bitmap
      % filename is overwritten by WIN12-16, and intervals K-P are written to an
      % earlier part of the preamble. This is why we seek 76x2 bytes ahead instead
      % of 80 bytes ahead below when VSG_FLAG = 0. In the case we want to read 
      % some bitmap names, and we want the intervals, I back the FID up 4x2
      % bytes. THIS IS A HACK AND SHOULD BE CORRECTED WITH A NEW DATATYPE VERSION.
      % This only works if preamb.h has been corrected to map intervals K-P to
      % databuffer[246-251] (should be corrected to be [250-256])
      if ~DUMB_HACK_TO_FIX_DUMBER_BUG
         fseek(fid,-4*2,'cof'); % HACK
     end
   else
      % As of 3.0.92b the above note has been addressed, but there is no
      % consistent way to tell which version of the preamble you are using,
      % so note the HACKS
      % HACK: Please note that the use of DATATYPE_VERSION above to set the
      % DUMB_HACK_TO_FIX_DUMBER_BUG flag is a proxy for what should properly 
      % be a preamble element indicating PREAMBLE_VERSION. 
      % Unfortunately, for the version of Gram I'm running (3.0.92b) this
      % has not yet been implemented, and DATATYPE_VERSION is still = 4,
      % when in fact I use the packed datatype (= 2) !!!!!!!!!!!!!!!!!!
      % Note, that once I upgrade and the DATATYPE_VERSION is again properly
      % assigned, there MUST be a PREAMBLE_VERSION implemented, or else I 
      % won't be able to set the DUMB_HACK_TO_FIX_DUMBER_BUG flag.
      if DUMB_HACK_TO_FIX_DUMBER_BUG
         fseek(fid,80*2,'cof');
      else
         fseek(fid,76*2,'cof'); % HACK
      end
   end
   
   fidpos = ftell(fid);
   % added by eddie, this has something to do with the dumb hack. It only works if I move forward 
   fseek(fid,4*2,'cof'); % 
   
   temp              = fread(fid,11,INT);     %%%%%
   p.WIN(12:16)      = temp(1:5);              % dataBuffer[241-245] win12-win16
   p.K               = temp(6);                % dataBuffer[246] target K
   p.L               = temp(7);                % dataBuffer[247] target L
   p.M               = temp(8);                % dataBuffer[248] target M
   p.N               = temp(9);                % dataBuffer[249] target N
   p.O               = temp(10);               % dataBuffer[250] target O
   p.P               = temp(11);               % dataBuffer[251] target P
   
   temp              = fread(fid, 1, INT);     % dataBuffer[256]
   
   p.PREAMBLE_VERSION = temp(1);  
   
   temp             = fread(fid, 8, INT);
   
   p.gainX1         = temp(1);                  % dataBuffer[257]
   p.gainX2         = temp(2);                  % dataBuffer[258]
   p.gainX3         = temp(3);                  % dataBuffer[259]
   p.gainX4         = temp(4);                  % dataBuffer[260]
   p.gainY1         = temp(5);                  % dataBuffer[261]
   p.gainY2         = temp(6);                  % dataBuffer[262]
   p.gainY3         = temp(7);                  % dataBuffer[263]
   p.gainY4         = temp(8);                  % dataBuffer[264]
   
   temp     		  = fread(fid, 4, INT);
   
	p.DEVICE_1      = temp(1);            % dataBuffer[265]
   p.DEVICE_2      = temp(2);            % dataBuffer[266]
   p.DEVICE_3      = temp(3);            % dataBuffer[267]
   p.DEVICE_4      = temp(4);            % dataBuffer[268]
   
   temp         = fread(fid, 26, INT);
   
   p.CNTR_00 = temp(1);            % dataBuffer[269]
   p.CNTR_01 = temp(2);            % dataBuffer[270]
   p.CNTR_02 = temp(3);            % dataBuffer[271]
   p.CNTR_03 = temp(4);            % dataBuffer[272]
   p.CNTR_04 = temp(5);            % dataBuffer[273]
   p.CNTR_05 = temp(6);            % dataBuffer[274]
   p.CNTR_06 = temp(7);            % dataBuffer[275]
   p.CNTR_07 = temp(8);            % dataBuffer[276]
   p.CNTR_08 = temp(9);            % dataBuffer[277]
   p.CNTR_09 = temp(10);           % dataBuffer[278]
   p.CNTR_10 = temp(11);           % dataBuffer[279]
   p.CNTR_11 = temp(12);           % dataBuffer[280]
   p.CNTR_12 = temp(13);           % dataBuffer[281]
   p.CNTR_13 = temp(14);           % dataBuffer[282]
   p.CNTR_14 = temp(15);           % dataBuffer[283]
   p.CNTR_15 = temp(16);           % dataBuffer[284]
   p.CNTR_16 = temp(17);           % dataBuffer[285]
   
   p.COUNTERTYPE	= temp(18);
   
   p.FILTER1      = temp(19);
   p.FILTER2      = temp(20);
   p.FILTER3      = temp(21);
   p.FILTER4      = temp(22);
  	p.GRAMALKN_VERSION   = temp(23);
 	p.BEETHOVEN_VERSION   = temp(24);	
	%p.FREESPACE3   = temp(25);
   %p.FREESPACE4   = temp(26);
  
  
  
  
  if USR_PREAMB_ELEMENTS
      if DUMB_HACK_TO_FIX_DUMBER_BUG
          last_pos = 255;                       % Current position of file pointer
      else
          last_pos = 251;
      end  
%       if VSG_FLAG
% %         last_pos = 219;                       % Current position of file pointer
%          last_pos = 251;                       % Current position of file pointer
%       else
% %         last_pos = 164;
%          last_pos = 251;
%       end
      fseek(fid,PREAMBLENGTH - RESERVED_BYTES - last_pos*2 - 2,0);
      p.RESERVED = fread(fid,USR_PREAMB_ELEMENTS,INT);
      

   end
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----- LOCAL FUNCTIONS -----------------------------------------
%-- Converts character array into a sensible string
function [str] = tostr(d);

ind = find(d==0);
str = char(d(1:(ind(1)-1))');
