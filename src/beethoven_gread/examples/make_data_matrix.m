function[output]=make_data_matrix(file_name);

% Reads data raw data file and interprets it, turns into spreadsheet.

%SENSOR_RELEASE=17;  %% this may vary from day to day?
%MAGIC=-12345;  % a dummy value;
%WRONG=85;
%disp('This message concerns the function make_mba');
%disp('This program assumes that the statecode'); 
%disp('indicating trial not performed correctly is:');
%WRONG
%disp('If that is not the case, OR IF YOU DO NOT UNDERSTAND THIS MESSAGE');
%disp('please tell Jenni.  Now beginning analysis - could take a moment');

%tic         % start clock

data=g_read_data(file_name);  % this is Eddie's data file reader
%disp('Raw data file read in; beginning analysis..');
%toc

%%% define some columns
data_matrix_col; %% I need to modify that with my own columns

output=ones(length(data),MAX_COLS).*NaN;

for i_trialnum=1:length(data);
    this_data=data(i_trialnum);
    task_name=this_data.TASKNAME;
    
    %%% preamble info
    output(i_trialnum,TRIAL)=this_data.TRIAL_NUMBER;
    output(i_trialnum,TASKID)=this_data.TASKID;
    output(i_trialnum,X_FIX)=this_data.TAR(1,1);
    output(i_trialnum,Y_FIX)=this_data.TAR(1,2);
    output(i_trialnum,X_TAR)=this_data.TAR(2,1);
    output(i_trialnum,Y_TAR)=this_data.TAR(2,2);
    output(i_trialnum,MODE)=this_data.M;
    output(i_trialnum,REWARD)=this_data.REWARD;
    output(i_trialnum,SOUND_DUR)=this_data.H; %%%...it has to be one of those a,b,c,d,... check it up!
    output(i_trialnum,SAMPLE_LOSS)=this_data.SAMPLESLOST;
    
       %%%  Stim, no stim? %%%  Begin JMG
     isstim=strfind(this_data.TASKNAME,'Stim');
     if length(isstim)>0  % it's a stim trial
         output(i_trialnum,STIM)=1;
     else
         output(i_trialnum,STIM)=0;
     end
    
    output(i_trialnum,YEAR_FROM_FILE)=this_data.YEAR;
    output(i_trialnum,MONTH_FROM_FILE)=this_data.MONTH;
    output(i_trialnum,DAY_FROM_FILE)=this_data.DAY;
    output(i_trialnum,HOURS)=this_data.HOUR;
    output(i_trialnum,MINUTES)=this_data.MIN;
    output(i_trialnum,SECONDS)=this_data.SEC;
    output(i_trialnum,MSEC)=this_data.MSEC;
 
    %%%% state data
    state_times=this_data.statedata;
    
         %%  If got trial wrong because blew fixation, exclude from further
       %%  analysis. 
       if this_data.REWARD==0
           thistimes=2*[1:1:length(hep)];
           %keyboard
           %figure(3);
           %clf
           %plot(thistimes,hep,'r-');
           %hold on;
           %plot(thistimes,vep,'g-');
           %plot(this_data.statedata(:,1),this_data.statedata(:,3),'k-');
           time_of_screwup=this_data.statedata( (this_data.statedata(:,3)==WRONG),1);  %WRONG = state85
           if length(time_of_screwup)>0  %might not get to state 85 if Beethoven ended/crashed before trial complete.
            time_of_screwup=time_of_screwup(1);  % in case of sample loss, can have many lines here.
           else
            time_of_screwup=this_data.statedata(end,2);  %% last time 
           end
           %catch
           %    baz=lasterror;
           %    baz.message
           %    keyboard
           %end
           hep_at_screwup=hep(thistimes==time_of_screwup);
           vep_at_screwup=vep(thistimes==time_of_screwup);
           if isnan(hep_at_screwup)  %% sometimes a sampleloss right then
               hep_at_screwup=hep(thistimes==(time_of_screwup-2));
               vep_at_screwup=vep(thistimes==(time_of_screwup-2));
           end
           error=sqrt((hep_at_screwup-this_data.TAR(1,1))^2+(vep_at_screwup-this_data.TAR(1,2))^2);  %% put in subtraction of target location
           %keyboard
           if error>this_data.WINMAJOR(2)/2  %% then treat the trial the same as if it was never started
                %time_first_ref=[NaN];
                %hitime=NaN;  %% never initiated the trial
                %rt=NaN;
                %end_window=NaN;
                %longest=NaN;
                %this_initial=NaN;
                output(i_trialnum,INCLUDE)=0;
           end
           %%%%  Maggie data - "go later" strategy introduced.
           %%%%  Incorporated here:
           if length(strfind(this_data.SUBJECTNAME,'Ernie'))==0  %% Not ernie data
              if time_of_screwup < rt
                  %% Never went - exclude trial.
                  output(i_trialnum,INCLUDE)=0;
              end
           end
           %pause
       end
    end  %% end of if length(time_first_ref)==0 
end

output(((output(:,REF_FREQ)<output(:,PROBE_FREQ))&(output(:,REWARD)==1)),GONOGO)=1;
output(((output(:,REF_FREQ)>=output(:,PROBE_FREQ))&(output(:,REWARD)==1)),GONOGO)=0;
output(((output(:,REF_FREQ)<output(:,PROBE_FREQ))&(output(:,REWARD)==0)),GONOGO)=0;  % blew it, assume no go on go 
output(((output(:,REF_FREQ)>=output(:,PROBE_FREQ))&(output(:,REWARD)==0)),GONOGO)=1;  % trial or vice versa.  Not really right but
                                                                                      % need to do this for convenience.
                                                                                      % of the rest of the analysis.

output((output(:,REF_FREQ)<output(:,PROBE_FREQ)),PROBEHI)=1;
output((output(:,REF_FREQ)>=output(:,PROBE_FREQ)),PROBELOW)=1;

%% check dates
if sum(output(:,STUDYDAY_FROM_FILE)-output(:,STUDYDAY_FROM_NAME))~=0
    disp('WARNING:  Date mismatch - file name date does not agree with date in file')
    
    %keyboard
end




save 'draft.mba' output -ascii -double
