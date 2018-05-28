% EXTRACT                    Extract data from defined struct array
% 
%     [out] = extract(structarray,field,varargin);
%
%     INPUTS
%     structarray - struct array defined as 'rawdata', 'eyestats', or 'spkstats'
%     field       - string specifying the desired structure field
%
%     OPTIONAL
%     varargin    - if field has multiple values (like TAR), additional
%                   parameters can be passed in to specify output
%
%     OUTPUTS
%     out         - numeric or cell array 
%
%     EXAMPLE
%     >> out = extract(dat,'success'); % gets success value for each trial
%     >> out = extract(dat,'tar',4) % get the x,y and color info for target 4
%     >> out = extract(dat,'tar',4,1) % get only x-pos info for target 4
%     >> out = extract(dat,'statedata',4,1) % get start time for state 4
%     >> out = extract(dat,'statedata',4,2) % get end time for state 4

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 01.01.02 written

function [out] = extract(structarray,field,varargin);

if isempty(structarray)
   error('Empty STRUCTARRAY passed into EXTRACT!');
end

if ~isfield(structarray,'def')
   error('STRUCTARRAY has no definition field');
end

if strcmp(structarray(1).def,'rawdata')
   %----- DAT FIELDS --------------------------------------------------
   field = upper(field);
   switch field
   %-- Things that can be returned as vectors
   case {'ERROR','TRIAL','TYPE','PERCENT','SUCCESS','TIME','REWARD','WATER',...
            'ITI','WAIT','FIX','OPLUSA','CUE','FIX2','DELAY',...
            'LATENCY','GAP','WATERVR','A','B','C','D','E','F',...
            'G','H','I','J','K','L','M','N','O','P','MAXLAG','NASH','DATATYPE_VERSION',...
            'YEAR','MONTH','DAY','HOUR','MIN','SEC'}
      
      eval(['out = [structarray.' field ']'';']);
      if ~isempty(varargin)
         fprintf('   Arguments after input FIELD ignored.\n');
      end 
      return
   %-- Things that can be returned as arrays
   case 'TAR'
      temp = cat(1,structarray.TAR);
      if isempty(varargin)
         out = temp;
      else
         if length(varargin) == 1
            out = temp(varargin{1}:16:end,:);
         else
            out = temp(varargin{1}:16:end,varargin{2});
         end
      end
      return
%   case 'RESERVED'
%      temp = cat(1,structarray.RESERVED);
%      len = length(structarray(1).RESERVED);
%      
%      return
   %-- Things that need to be returned as cell arrays
   case {'SUBJECTNAME','TASKNAME'}    
      eval(['out = {structarray.' field '}'';']);
      if ~isempty(varargin)
         fprintf('   Arguments after input FIELD ignored.\n');
      end
      return
   case {'SPKDATA'}
      eval(['out = {structarray.' lower(field) '}'';']);
      if ~isempty(varargin)
         fprintf('   Arguments after input FIELD ignored.\n');
      end
      return
   case {'STATEDATA'}
      if isempty(varargin)
         eval(['out = {structarray.' lower(field) '}'';']);
      else
         state = varargin{1};
         for i = 1:length(structarray)
            temp = structarray(i).statedata;
            ind = find(temp(:,3)==state);
            if isempty(ind)
               out(i,1:3) = NaN;
            else
               out(i,:) = temp(ind,:);
            end
         end
         if length(varargin)>1
            out = out(:,varargin{2});
         end
      end
   otherwise      
      error('FIELD not found in STRUCTARRAY.');
   end
   
elseif strcmp(structarray(1).def,'eyestats')
   %----- EYESTATS FIELDS ---------------------------------------------
   field = lower(field);
   switch field
      %-- Things that can be returned as vectors
   case {'peak_velocity','amplitude','start_t'}    
      out = eval(['cat(1,structarray.' field ')']);
      return
      %-- Things that can be returned as arrays
   case {'saccade_times','endpoint','states'}
      out = eval(['cat(1,structarray.' field ')']);
      if ~isempty(varargin)
         out = out(:,varargin{1});
      end
      return
   otherwise 
      error('FIELD not found in STRUCTARRAY.');
   end   
elseif strcmp(structarray(1).def,'spkstats')
   %----- SPKSTATS FIELDS ---------------------------------------------
   field = lower(field);
   switch field
      %-- Things that can be returned as vectors
   case {'count','abs_t','state'}    
      out = eval(['cat(1,structarray.' field ')']);
      return
      %-- Things that can be returned as arrays
   case {'window'}
      out = eval(['cat(1,structarray.' field ')']);
      if ~isempty(varargin)
         out = out(:,varargin{1});
      end
      return
   otherwise 
      error('FIELD not found in STRUCTARRAY.');
   end   
else
   error('Undefined STRUCTARRAY');
end

return