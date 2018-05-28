% clear all
% close all
ICkey_multi

%MonkeyTag = input('Monkey Name: Felix(0), Nicole(1), Simon(2),?')
%DateTag = input('Date?','s')
%DateStr = DateTag;

%switch MonkeyTag
%    case(0)
%        RecordingArea = '?'; %right or left
%        MonkeyName = 'F'; %% FELIX
%        TargetArea = 'FEF';
%    case(1)
%        RecordingArea = '?';
%        MonkeyName = 'N'; %% NICOLE
%        TargetArea = 'FEF';
%    case(2)
%        RecordingArea = '?';
%        MonkeyName = 'S'; %% SIMON
%        TargetArea = 'FEF';
%end


%FileName =  [MonkeyName TargetArea RecordingArea DateStr 'Overlap.dat.cell1'];
%MatName =  [MonkeyName TargetArea RecordingArea DateStr 'Overlap.mat'];

Data = g_read_data(FileName);



sample_interval = 2; %%500Hz 2ms for EYE COIL
Mat = [];
CorrectMat = [];
FigTag =1;

figure(1)
set(gcf,'color','w')

%%%%%%%%%%%%%%%%%%%%%%%%

for i = 2:size(Data,2)
    data = Data(i);
    TrialNum = data.TRIAL_NUMBER;
    TaskType = data.TASKID;  %% 1 - simple saccade;  2 - probe; 3 - overlap
    TrialMode = data.NAME_AMODALITY; %% visual or auditory
    Reward = data.REWARD;
    Samplelost = data.SAMPLESLOST;
    FixationTime = data.FIX/2;
    FixationTime2 = data.FIX2/2;
    statedata =data.statedata;
    StartState = find(statedata(:,end) == 0);
    statedata(1:StartState(end)-1,:) = [];
    SzState = size(statedata,1);
    XFixation = data.TAR(1,1);
    YFixation = data.TAR(1,2);
    XA = data.TAR(2,1);
    YA = data.TAR(2,2);
    eyedata = data.eyedata;
    spkdata = (data.spkdata)/1000;
    WinFixX = data.WINMAJOR(1);
    WinFixY = data.WINMINOR(1);
    WinXA = data.WINMAJOR(2);
    WinYA = data.WINMINOR(2);
    O_A = data.OPLUSA;  %%%%%????????????????????????????????????????????
    
    while(1)
        LostState = find(statedata(:,3)>100);
        if isempty(LostState)
            break
        end
        LostTimeEnd = statedata(LostState,2)/2;
        statedata(LostState-1,1:2) = [statedata(LostState-1,1) statedata(LostState+1,2)];
        statedata(LostState:LostState+1,:) = [];
    end
    
    SzState = size(statedata,1);
    CorrectMat = [CorrectMat; TaskType Reward SzState XA XB];
    statedata(:,1:2) = statedata(:,1:2)./2;
    
    % if Reward ==1  & FixationTime <1000 &   Samplelost < 15  & TaskType ==8  % only for correct overlap trials (num3)
    if FixationTime <1000 &   Samplelost < 15  & TaskType ==8  % only for correct overlap trials (num3)
    
        statedata(statedata(:,3) >8 | statedata(:,3) <2,:) = []; %%  end/ wait
        
        %% all onset times
        PreBaseOn = statedata(statedata(:,3) == 2,1);
        FixOn = statedata(statedata(:,3) == 3,1); %% when fixation comes on
        GetFix = statedata(statedata(:,3) == 4,1);
        TargetOn = statedata(statedata(:,3) == 5,1);
        FixOff = statedata(statedata(:,3) == 6,1);  %% saccade go signal
        GetTarget = statedata(statedata(:,3) == 7,1); %% state 7 starts whenever the monkey's gaze gets into the target window
        Reward = statedata(statedata(:,3) == 8,1);
        %% in case I have more trial type to analyze
        %   Target1In_dat = [7 13];  %% possible state to catch Target1N -
        %   for i1In = 1:length(Target1In_dat)
        %       if ~isempty(find(statedata(:,3) == Target1In_dat(i1In)))
        %           Target1In = statedata(statedata(:,3) == Target1In_dat(i1In),1);
        %       end
        %   end
        %% Times for the graph
        StartTime = PreBaseOn;  %%zero
        PreBaseOnTime = PreBaseOn - StartTime;
        FixOnTime = FixOn - StartTime;
        GetFixTime = GetFix - StartTime;
        TargetOnTime = TargetOn - StartTime;
        FixOffTime = FixOff - StartTime;
        GetTargetTime = GetTarget - StartTime;
        RewardTime = Reward - StartTime;
        %% Times for the calculations
        BaseLineStart = StartTime - 250; %% 500ms before target onset
        SensoryStart = TargetOnTime + 10;
        spkdata = spkdata-TimeStart*2;  %% that's because I have divided TimeStart by two somewhere up there (line 79)
        
        %% Eye trajectory
        HEyeTrace = eyedata(:,1);
        HEyeTrace = HEyeTrace(StartTime:end);
        SizeEyeTrace = length(HEyeTrace);
        
        VEyeTrace = eyedata(:,2);
        VEyeTrace = VEyeTrace(StartTime:end);
        EyeTrace = sqrt(HEyeTrace.^2+VEyeTrace.^2);
        
        time=[-StartTime:(SizeEyeTrace-StartTime-1)];
        
        EyeRawVel = abs(DIFFF(EyeTrace)*ceil(1000./sample_interval)); %%eye velocity 계산
        EyeVelocity = smooth(EyeRawVel); %% smoothing
        % find saccade, sampling rate, threshold velocity 90
        Saccade=Findsac(EyeTrace, sample_interval, 200);
        
        if ~isempty(Saccade) & Saccade(1) ~=999999  %% Saccade가 1개 이상 잡히면
            Saccade = Saccade-StartTime;
            Saccade(Saccade(:,1) <  FixOffTime,:) = [];
            SacOnset = Saccade(1,1);
            SacOffset = Saccade(1,2);
            SacDur = (SacOffset - SacOnset)*sample_interval; %% Saccade Duration
            SacAmp = abs(EyeTrace(SacOnset)-EyeTrace(SacOffset)); %%Saccade Amplitude
            MaxVel = max(EyeVelocity(SacOnset:SacOffset)); %% Saccade동안 최대 속도
            MeanVel = mean(EyeVelocity(SacOnset:SacOffset)); %% Saccade동안 평균 속도
            Latency = (SacOnset- FixOffTime)*2;
            HEndPos = HEyeTrace(SacOffset);
            VEndPos = VEyeTrace(SacOffset);
            
            % Mat = [Mat; TrialNum XFixation YFixation XA YA HEndPos VEndPos Latency SacDur SacAmp MaxVel MeanVel RTTime];
            
            if FigTag ==1
                %                 TitleStr1 = ['Target: (' num2str(XA) ',' num2str(YA) ') Latency: ' num2str(Latency) 'ms' ];
                HEyeTraceInTarget = HEyeTrace(GetTarget:Reward);
                VEyeTraceInTarget = VEyeTrace(GetTarget:Reward);
                TimeTraceTarget = [GetTargetTime:RewardTime];
                %% plot
                clf
                subplot(2,3,[1 2])
                plot(time,HEyeTrace,'r','linewidth',0.8);hold on
                plot(time,VEyeTrace,'b','linewidth',0.8); hold on
                plot(TimeTraceTarget,HEyeTraceInTarget,'r','linewidth',2.5)
                plot(TimeTraceTarget,VEyeTraceInTarget,'b','linewidth',2.5)
                hold on; plot(FixOnTime,[-40:0.1:40],'color','k','linestyle','-','linewidth',0.8);
                hold on; plot(TargetOnTime,[-40:0.1:40],'color','k','linestyle','-','linewidth',0.8);
                hold on; plot(FixOffTime,[-40:0.1:40],'color','k','linestyle','-','linewidth',0.8);
                hold on; plot(RewardTime,[-40:0.1:40],'color','k','linestyle','-','linewidth',0.8);
                
                % Fixation light on
                line([FixOnTime FixOffTime],[-34 -34],'color','k','linestyle',':','linewidth',2)
                % Target light or sound on
                line([TargetOnTime RewardTime],[-38 -38],'color','k','linestyle',':','linewidth',2)
                % sensory response period
                line([TargetOnTime+25 TargetOnTime+250],[-30 -30],'color','c','linestyle','-','linewidth',4)
                % baseline activity periood
                line([FixOnTime-250 FixOnTime],[-30 -30],'color','y','linestyle','-','linewidth',4)
                % motor activity periood
                line([SacOnset-30 SacOffset+30],[-30 -30],'color','m','linestyle','-','linewidth',4)
                
                set(gca,'ylim',[-40 40],'ytick',[-40:20:40])
                xlabel('Time from Pre-Baseline (ms)','fontsize',11)
                ylabel('Eye position (deg)','fontsize',11)
                TitleStr = ['Overlap Task; trial nuber: ' num2str(i), '; modality: ' num2str(data.AMODALITY) ];
                title(TitleStr,'fontsize',12)
                
                subplot(2,3,3)
                plot(HEyeTrace,VEyeTrace,'k.'); hold on
                plot(HEyeTraceInTarget,VEyeTraceInTarget,'r.')
                set(gca,'xlim',[-30 30])
                set(gca,'ylim',[-30 30])
                xlabel('Horizontal eye position (deg)','fontsize',11)
                ylabel('Vertical eye position (deg)','fontsize',11)
                JA_rectangle(XA, WinXA, YA, WinYA,'r')
                JA_rectangle(XFixation, WinFixX, YFixation, WinFixY,'k')
                axis square
                set(gcf,'Units','centimeters','Position',[2  3 23 16]);
                pause
            end
        end  %% saccade~90000
    end %% reward
end %% size(DATA)
%save(MatName, 'Mat','CorrectMat')




