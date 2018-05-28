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
%	   eddie 01.01.04 added new preamble variables and updated g_read_data to call this file if preamble version is 3 or 4
%	   eddie 04.11.06 added new preamble variables and updated g_read_data to call this file if preamble version is 7
%     scott 08.17.07 improved data retrieval for newer preamble variables
%	   eddie 04.29.07 added 10 generic variables (short integers) named VARS that can be used to store things


function [p] = g_read_preamble5(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);

%----- Globals, definitions, & constants
KEEP_UNUSED_FIELDS = 0;  % Toggles exclusions of selected fields below
PREAMBLENGTH = 1024;     % # of bytes allocated to entire preamble
RESERVED_BYTES = 256;    % # of bytes reserved at end of preamble for user variables
NWIN = 16;
INT = 'int16';           % 16 bits signed
UINT = 'uint16';         % 16 bits unsigned
CHAR = 'char';           % 8 bits

p.YEAR             = 0;
p.MONTH            = 0;
p.DAY              = 0;                   
p.HOUR             = 0;
p.MIN              = 0;
p.SEC              = 0;
p.MSEC				 = 0;
p.SUBJECTNAME 	    = 'nada';
p.TASKNAME 			 = 'nada';
p.TASKID           = 0;
p.TRIAL_NUMBER      = 0;
p.TIME    = 0;
p.GRAMALKN_VERSION = 0;
p.BEETHOVEN_VERSION= 0;
p.PREAMBLE_VERSION = 0;
p.DATATYPE_VERSION = 0;
p.PERCENT          = 0;
p.SUCCESS          = 0;

if KEEP_UNUSED_FIELDS
   p.START        = temp(5);                   % dataBuffer[59] recording data start time // retained from gram22 for compatibility
   p.END          = temp(6);                   % dataBuffer[60] recording data end // retained from gram22 for compatibility
end

p.REWARD          = 0;
p.WATER           = 0;

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

temp              = fread(fid,9,UINT);        %%%%% eddie changes from 14 - 9, spike time is limited to 16 bits
p.EYERES          = temp(1);                   % dataBuffer[6] eye resolution, currently at 2ms
p.EYERESUNITS	   = 'milliseconds';
p.EYES            = 0;
p.SPIKERES        = temp(2);                   % dataBuffer[7] spike resolution, currently at 1us
p.SPIKERES			= '10 microseconds';
p.LEDGAIN         = temp(3);                   % dataBuffer[8] degree in between two LEDs
%p.EYEGAIN         = temp(4);                   % dataBuffer[9] degrees corresponding to 7.5V ??? outdated

p.BLOCKS1         = temp(5);                   % dataBuffer[10] num of 1024 byte block
p.SAMPLESLOST     = 0;  		                 % dataBuffer[13] spike recording error	(AKA ERROR)
p.NUMADC1         = temp(6);                   % dataBuffer[11] num of adc data
p.NUMSPIKE1       = temp(7);                   % dataBuffer[12] num of spike data
p.SAMPLESLOST     = temp(8);                   % dataBuffer[13] spike recording error	(AKA ERROR)

if KEEP_UNUSED_FIELDS
   p.SPIKETIME    = temp(9);               % dataBuffer[14-19] spike end time after, remvoed 9:end
end

p.NAME_OMODALITY	= '';
p.OMODALITY			= 0;
p.NAME_AMODALITY	= '';
p.AMODALITY			= 0;
p.NAME_BMODALITY	= '';
p.BMODALITY			= 0;
p.NAME_CMODALITY	= '';
p.CMODALITY			= 0;
p.NAME_DMODALITY	= '';
p.DMODALITY			= 0;
p.NAME_OTYPE		= '';
p.OTYPE				= 0;
p.NAME_ATYPE		= '';
p.ATYPE				= 0;
p.NAME_BTYPE		= '';
p.BTYPE				= 0;
p.NAME_CTYPE		= '';
p.CTYPE				= 0;
p.NAME_DTYPE		= '';
p.DTYPE				= 0;
p.OFREQ				= 0;
p.AFREQ				= 0;
p.BFREQ				= 0;
p.CFREQ				= 0;
p.DFREQ				= 0;
p.FREQUNITS			= 'Hz';
p.OSPKRNUM			= 0;
p.ASPKRNUM			= 0;
p.BSPKRNUM			= 0;
p.CSPKRNUM			= 0;
p.DSPKRNUM			= 0;

temp              = fread(fid,10,UINT);        %%%%%
p.OMODALITY			= temp(1);
   switch(p.OMODALITY)
   case {1}
      p.NAME_OMODALITY = 'SPEAKER';
   case {2}
      p.NAME_OMODALITY = 'LED + SPEAKER';
   case {3}
      p.NAME_OMODALITY = 'LED';
   case (4)
      p.NAME_OMODALITY = 'IMAGE + LED + SPEAKER';
   case (5)
      p.NAME_OMODALITY = 'IMAGE + LED';
   case (6)
      p.NAME_OMODALITY = 'NONE';
  otherwise
      p.NAME_OMODALITY = 'unknown modality';
  end  
  
  p.OTYPE				= temp(2);
   switch(p.OTYPE)
   case {0}
      p.NAME_OTYPE = 'NOISE';
   case {1}
      p.NAME_OTYPE = 'FROZEN NOISE';
   case {2}
      p.NAME_OTYPE = 'TONE';
   case (3)
      p.NAME_OTYPE = 'WAVE FILE';
  otherwise
      p.NAME_OTYPE = 'unknown modality';
  end  

p.OFREQ				= temp(3);
p.OSPKRNUM			= temp(4);
%p.EMPTY1				= temp(5);
%p.EMPTY2				= temp(6);

	p.AMODALITY			= temp(7);
   switch(p.AMODALITY)
   case {1}
      p.NAME_AMODALITY = 'SPEAKER';
   case {2}
      p.NAME_AMODALITY = 'LED + SPEAKER';
   case {3}
      p.NAME_AMODALITY = 'LED';
   case (4)
      p.NAME_AMODALITY = 'IMAGE + LED + SPEAKER';
   case (5)
      p.NAME_AMODALITY = 'IMAGE + LED';
   case (6)
      p.NAME_AMODALITY = 'NONE';
  otherwise
      p.NAME_AMODALITY = 'unknown modality';
  end  
  
  
  p.ATYPE				= temp(8);
  
   switch(p.ATYPE)
   case {0}
      p.NAME_ATYPE = 'NOISE';
   case {1}
      p.NAME_ATYPE = 'FROZEN NOISE';
   case {2}
      p.NAME_ATYPE = 'TONE';
   case (3)
      p.NAME_ATYPE = 'WAVE FILE';
  otherwise
      p.NAME_ATYPE = 'unknown modality';
  end  
  
  
p.AFREQ				= temp(9);
p.ASPKRNUM			= temp(10);

% Things that do not need update all the time
%p.MONKNAME = tostr(fread(fid,10,CHAR));        % dataBuffer[20-24] Monkey name moved to a different position at the end of the preamble

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
%   fseek(fid,8*2 + 20,0);
   fseek(fid,8,0);


	temp = fread(fid, 14, INT);

   p.BMODALITY = temp(1);
   switch(p.BMODALITY)
   case {1}
      p.NAME_BMODALITY = 'SPEAKER';
   case {2}
      p.NAME_BMODALITY = 'LED + SPEAKER';
   case {3}
      p.NAME_BMODALITY = 'LED';
   case (4)
      p.NAME_BMODALITY = 'IMAGE + LED + SPEAKER';
   case (5)
      p.NAME_BMODALITY = 'IMAGE + LED';
   case (6)
      p.NAME_BMODALITY = 'NONE';
  otherwise
      p.NAME_BMODALITY = 'unknown modality';
  end  
  
   p.BTYPE 		= temp(2);
   switch(p.BTYPE)
   case {0}
      p.NAME_BTYPE = 'NOISE';
   case {1}
      p.NAME_BTYPE = 'FROZEN NOISE';
   case {2}
      p.NAME_BTYPE = 'TONE';
   case (3)
      p.NAME_BTYPE = 'WAVE FILE';
  otherwise
      p.NAME_BTYPE = 'unknown modality';
  end  
  
  p.BFREQ 		= temp(3);
   p.BSPKRNUM 	= temp(4);
   % skip 1
   p.CMODALITY = temp(6);
   
   switch(p.CMODALITY)
   case {1}
      p.NAME_CMODALITY = 'SPEAKER';
   case {2}
      p.NAME_CMODALITY = 'LED + SPEAKER';
   case {3}
      p.NAME_CMODALITY = 'LED';
   case (4)
      p.NAME_CMODALITY = 'IMAGE + LED + SPEAKER';
   case (5)
      p.NAME_CMODALITY = 'IMAGE + LED';
   case (6)
      p.NAME_CMODALITY = 'NONE';
  otherwise
      p.NAME_CMODALITY = 'unknown modality';
  end  
  
  
   p.CTYPE 		= temp(7);
   switch(p.CTYPE)
   case {0}
      p.NAME_CTYPE = 'NOISE';
   case {1}
      p.NAME_CTYPE = 'FROZEN NOISE';
   case {2}
      p.NAME_CTYPE = 'TONE';
   case (3)
      p.NAME_CTYPE = 'WAVE FILE';
  otherwise
      p.NAME_CTYPE = 'unknown modality';
  end  
  
  p.CFREQ 		= temp(8);
   p.CSPKRNUM 	= temp(9);
   % skip 1 more
   
   p.DMODALITY = temp(11);
   switch(p.DMODALITY)
   case {1}
      p.NAME_DMODALITY = 'SPEAKER';
   case {2}
      p.NAME_DMODALITY = 'LED + SPEAKER';
   case {3}
      p.NAME_DMODALITY = 'LED';
   case (4)
      p.NAME_DMODALITY = 'IMAGE + LED + SPEAKER';
   case (5)
      p.NAME_DMODALITY = 'IMAGE + LED';
   case (6)
      p.NAME_DMODALITY = 'NONE';
  otherwise
      p.NAME_DMODALITY = 'unknown modality';
  end  
  
  p.DTYPE 		= temp(12);
  
   switch(p.DTYPE)
   case {0}
      p.NAME_DTYPE = 'NOISE';
   case {1}
      p.NAME_DTYPE = 'FROZEN NOISE';
   case {2}
      p.NAME_DTYPE = 'TONE';
   case (3)
      p.NAME_DTYPE = 'WAVE FILE';
  otherwise
      p.NAME_DTYPE = 'unknown modality';
  end  
  
  p.DFREQ 		= temp(13);
  p.DSPKRNUM 	= temp(14);
   
end

   
% Things that do need update all the time
%p.TYPENAME = tostr(fread(fid,10,CHAR));        % dataBuffer[50-54] trial type ascii string, moved down
temp					= fread(fid,5,INT);        
p.OLEVEL				= temp(1);
p.ALEVEL				= temp(2);
p.BLEVEL				= temp(3);
p.CLEVEL				= temp(4);
p.DLEVEL				= temp(5);
p.LEVELUNITS		= 'dB(SPL)';

temp              = fread(fid,11,UINT);        %%%%%
p.TRIAL_NUMBER    = temp(1);                   % dataBuffer[55] trial# (number of trials run so far)
p.TASKID          = temp(2);                   % dataBuffer[56] trial type number, in sequential order
p.PERCENT         = temp(3);                   % dataBuffer[57] percentage of the type specified in qui
p.SUCCESS         = temp(4);                   % dataBuffer[58] trial success or not

if KEEP_UNUSED_FIELDS
   p.START        = temp(5);                   % dataBuffer[59] recording data start time // retained from gram22 for compatibility
   p.END          = temp(6);                   % dataBuffer[60] recording data end // retained from gram22 for compatibility
end

p.TIME  = temp(7);                   % dataBuffer[61] total time of the trial (ms?)
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
p.WINTYPE			= zeros(NWIN,1);
p.WINMAJOR 			= zeros(NWIN,1);
p.WINMINOR 			= zeros(NWIN,1);
p.WINMAJOR (1:5)  = temp(1:5);                 % dataBuffer[81-85] win1-win5, remaining window information is appended lower down

% Time intervals
p.ITI             = temp(6);                   % dataBuffer[86] 
p.WAIT            = temp(7);                   % dataBuffer[87] 
p.FIX             = temp(8);                   % dataBuffer[88] 
p.OPLUSA          = temp(9);                   % dataBuffer[89] 
p.CUE             = 0;                  % dataBuffer[92] 
p.FIX2            = 0;                  % dataBuffer[93] 
p.DELAY           = 0;                  % dataBuffer[94] 
p.LATENCY         = 0;                  % dataBuffer[95] 
p.GAP             = 0;                  % dataBuffer[96] 
p.A               = temp(10);                  % dataBuffer[90] 
p.B               = temp(11);                  % dataBuffer[91] 
p.C               = 0;
p.D               = 0;
p.E               = 0;
p.F               = 0;
p.G               = 0;
p.H               = 0;
p.I               = 0;
p.J               = 0;
p.K               = 0;
p.L               = 0;
p.M               = 0;
p.N               = 0;
p.O               = 0;
p.P               = 0;
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
p.WINMAJOR(6:11) = fread(fid,6,INT);                % dataBuffer[148-153] win6-win11
   
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
      p.VIDEOSTIM1 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[165-169]
      p.VIDEOSTIM2 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[170-174]
      p.VIDEOSTIM3 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[175-179]
      p.VIDEOSTIM4 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[180-184]
      p.VIDEOSTIM5 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[185-189]
      p.VIDEOSTIM6 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[190-194]
      p.VIDEOSTIM7 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[195-199]
      p.VIDEOSTIM8 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[200-204]
      p.VIDEOSTIM9 = tostr([fread(fid,10,CHAR);0]);   % dataBuffer[205-209]
      p.VIDEOSTIM10 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[210-214]
      p.VIDEOSTIM11 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[215-219]
      p.VIDEOSTIM12 = tostr([fread(fid,10,CHAR);0]); % dataBuffer[220-224]
      p.VIDEOSTIM13 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[225-229]
      p.VIDEOSTIM14 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[230-234]
      p.VIDEOSTIM15 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[235-239]
      p.VIDEOSTIM16 = tostr([fread(fid,10,CHAR);0]);  % dataBuffer[240-244]
      p.VIDEOSTIM17 = '';
      p.VIDEOSTIM18 = '';
      p.VIDEOSTIM19 = '';
  	 	p.VIDEOSTIM20 = '';
      p.VIDEOSTIM21 = '';
  	 	p.VIDEOSTIM22 = '';
      p.VIDEOSTIM23 = '';
      p.VIDEOSTIM24 = '';
      p.VIDEOSTIM25 = '';
      p.VIDEOSTIM26 = '';
                 
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
   
   %fidpos = ftell(fid)
   % added by eddie, this has something to do with the dumb hack. It only works if I move forward 
   fseek(fid,4*2,'cof'); % 
   
   temp              = fread(fid,11,INT);     %%%%%
   p.WINMAJOR(12:16) = temp(1:5);              % dataBuffer[241-245] win12-win16
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
   
   switch(temp(1))
   case {1}
      p.INPUTCHANNEL1 = 'Analog Input';
   case {2}
      p.INPUTCHANNEL1 = 'ASL Eye Tracker';
   case {3}
      p.INPUTCHANNEL1 = 'Eyelink Eye Tracker';
   case (4)
      p.INPUTCHANNEL1 = 'Riverbend Eye Tracker';
   case (5)
      p.INPUTCHANNEL1 = 'Viewpoint Eye Tracker';
   case (6)
      p.INPUTCHANNEL1 = 'Mouse/Touch Screen';
   case (7)
      p.INPUTCHANNEL1 = 'Joystick';
   otherwise
      p.INPUTCHANNEL1 = 'unknown device type';
   end  
  switch(temp(2))
   case {1}
      p.INPUTCHANNEL2 = 'Analog Input';
   case {2}
      p.INPUTCHANNEL2 = 'ASL Eye Tracker';
   case {3}
      p.INPUTCHANNEL2 = 'Eyelink Eye Tracker';
   case (4)
      p.INPUTCHANNEL2 = 'Riverbend Eye Tracker';
   case (5)
      p.INPUTCHANNEL2 = 'Viewpoint Eye Tracker';
   case (6)
      p.INPUTCHANNEL2 = 'Mouse/Touch Screen';
   case (7)
      p.INPUTCHANNEL2 = 'Joystick';
   otherwise
      p.INPUTCHANNEL2 = 'unknown device type';
   end  
   switch(temp(3))
   case {1}
      p.INPUTCHANNEL3 = 'Analog Input';
   case {2}
      p.INPUTCHANNEL3 = 'ASL Eye Tracker';
   case {3}
      p.INPUTCHANNEL3 = 'Eyelink Eye Tracker';
   case (4)
      p.INPUTCHANNEL3 = 'Riverbend Eye Tracker';
   case (5)
      p.INPUTCHANNEL3 = 'Viewpoint Eye Tracker';
   case (6)
      p.INPUTCHANNEL3 = 'Mouse/Touch Screen';
   case (7)
      p.INPUTCHANNEL3 = 'Joystick';
   otherwise
      p.INPUTCHANNEL3 = 'unknown device type';
   end  
   switch(temp(4))
   case {1}
      p.INPUTCHANNEL4 = 'Analog Input';
   case {2}
      p.INPUTCHANNEL4 = 'ASL Eye Tracker';
   case {3}
      p.INPUTCHANNEL4 = 'Eyelink Eye Tracker';
   case (4)
      p.INPUTCHANNEL4 = 'Riverbend Eye Tracker';
   case (5)
      p.INPUTCHANNEL4 = 'Viewpoint Eye Tracker';
   case (6)
      p.INPUTCHANNEL4 = 'Mouse/Touch Screen';
   case (7)
      p.INPUTCHANNEL4 = 'Joystick';
  otherwise
      p.INPUTCHANNEL4 = 'unknown device type';
   end  
   
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
   
   p.COUNTERTYPE         = temp(18);
      
   p.SAMPLES_AVERAGED_CHANNEL1      = temp(19);
   p.SAMPLES_AVERAGED_CHANNEL2      = temp(20);
   p.SAMPLES_AVERAGED_CHANNEL3      = temp(21);
   p.SAMPLES_AVERAGED_CHANNEL4      = temp(22);
   p.GRAMALKN_VERSION    = temp(23);
   p.BEETHOVEN_VERSION   = temp(24);
   p.SESSION             = temp(25);
   p.PROBLEM             = temp(26);
  
	if VSG_FLAG % Additional bitmap file names appended 11/15/04
        p.VIDEOSTIM17 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM18 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM19 = tostr([fread(fid, 10, CHAR);0]);
  	 	p.VIDEOSTIM20 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM21 = tostr([fread(fid, 10, CHAR);0]);
  	 	p.VIDEOSTIM22 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM23 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM24 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM25 = tostr([fread(fid, 10, CHAR);0]);
        p.VIDEOSTIM26 = tostr([fread(fid, 10, CHAR);0]);
    else
        fread(fid, 100, CHAR)
    end
     
   temp             = fread(fid, 17, INT);
   p.T1             = temp(1);                  %dataBuffer[345]
   p.T2             = temp(2);                  
   p.T3             = temp(3);                  
   p.T4             = temp(4);                  
   p.A1             = temp(5);                  
   p.A2             = temp(6);                  
   p.A3             = temp(7);                  
   p.A4             = temp(8);                  

	p.C1				  = temp(9);
	p.C2				  = temp(10);
	p.C3				  = temp(11);
	p.C4				  = temp(12);
	p.C5				  = temp(13);
	p.C6				  = temp(14);
	p.C7				  = temp(15);
	p.C8				  = temp(16);
   
   p.MSEC				= temp(17);			% dataBuffer[361]
   
  
	temp             = fread(fid, 16, INT);
	p.WINMINOR(1:16) = temp(1:16);          %dataBuffer[362:377]
      
    temp             = fread(fid, 6, INT);  %dataBuffer[378:383]
    p.WINTYPE			= temp(1:6);    
   
    temp             = fread(fid, 23, INT); 
    % temp(1:13) refer to Lau variables, include them if you want them
   
    %Schafer variables
    %p.MATCHPROB1		= temp(14);
    %p.MATCHPROB2		= temp(15);
    %p.MATCHREWARD1      = temp(16);
    %p.MATCHREWARD2		= temp(17);
    %end Schafer variables
   
    p.TAR1STATES(1:2) = temp(14:15);
    p.TAR2STATES(1:2) = temp(16:17);
    p.TAR3STATES(1:2) = temp(18:19);
    p.TAR4STATES(1:2) = temp(20:21);
    p.TAR5STATES(1:2) = temp(22:23);
   
 
	p.SUBJECTNAME		= tostr(fread(fid,20,CHAR));        % dataBuffer[50-54] trial type ascii string  
	p.TASKNAME 			= tostr(fread(fid,20,CHAR));        % dataBuffer[50-54] trial type ascii string
   
 	temp             = fread(fid, 10, INT); 

   p.VARS(1)		= temp(1);
   p.VARS(2)		= temp(2);
   p.VARS(3)		= temp(3);
   p.VARS(4)		= temp(4);
   p.VARS(5)		= temp(5);
   p.VARS(6)		= temp(6);
   p.VARS(7)		= temp(7);
   p.VARS(8)		= temp(8);
   p.VARS(9)		= temp(9);
   p.VARS(10)		= temp(10);
           
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
function [str] = tostr(d)

ind = find(d==0);
str = char(d(1:(ind(1)-1))');
