% clear all
% close all
ICkey_multi
% MonkeyTag = input('Monkey Name: Paris(O)?')
%MonkeyTag  =0;

%DateTag = input('Date?','s')
% DateStr = num2str(DateTag);
%DateStr = DateTag;

%if MonkeyTag ==0
    % RecordingArea = 'L';
%    MonkeyName = 'PS'; %% WYSK
%    TargetArea = 'IC';
%else
    % RecordingArea = 'R';
%    MonkeyName = 'PR'; %% PARIS
%    TargetArea = 'SC';
%end
%
% FileName =  [MonkeyName TargetArea DateStr 'DoubleOverlap1.dat.cell1'];
% MatName = [MonkeyName TargetArea DateStr 'DoubleOverlap1.mat'];

%FileName =  [MonkeyName TargetArea DateStr 'DoubleSimulOverlap.dat.cell1'];
%MatName = [MonkeyName TargetArea DateStr 'DoubleSimulOverlap.mat'];
% Date = input('Date?:');

% Data = g_read_data('PSIC0506DoubleSimulOverlap.dat.cell1');
Data = g_read_data(FileName);
sample_interval = 2; %%500Hz 2ms
Mat = [];
CorrectMat = [];
FigTag =1;

figure(1)
set(gcf,'color','w')
                
 %for i = 1:size(Data,2)
     i=431;
%% cut first 50 trials & last 50trials
%   for i = 20:size(Data,2)-20
    data = Data(i);
    TrialNum = data.TRIAL_NUMBER;
    TaskType = data.TASKID;  %% 8 - single overlap 11- double probe 12 - double overlap
    Reward = data.REWARD;
    Samplelost = data.SAMPLESLOST;
    ThisAFreq = data.AFREQ;
    ThisBFreq = data.BFREQ;
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
    XB = data.TAR(3,1);
    YB = data.TAR(3,2);
    eyedata = data.eyedata;
    spkdata = (data.spkdata)/1000;
    WinFixX = data.WINMAJOR(1);
    WinFixY = data.WINMINOR(1);
    WinXA = data.WINMAJOR(2);
    WinYA = data.WINMINOR(2);
    WinXB = data.WINMAJOR(3);
    WinYB = data.WINMINOR(3);
    O_A = data.OPLUSA;

    
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
    CorrectMat = [CorrectMat; TaskType ThisAFreq ThisBFreq Reward SzState XA XB];
    
    statedata(:,1:2) = statedata(:,1:2)./2;
            
    if FixationTime <1000 &   Samplelost < 15  & TaskType ==8  % only for correct trials
        statedata(statedata(:,3) >18 | statedata(:,3) <3,:) = []; %%  end/ wait
        TargetOn = statedata(statedata(:,3) == 5,1);
        FixOff = statedata(statedata(:,3) == 6,1);  %% saccade go signal 
        RewardOn = statedata(statedata(:,3) == 9,1);
        Target1In_dat = [7 13];  %% possible state to catch Target1N -
        Target2In_dat = [9 11]; %% possible state to catch Target2N -
        for i1In = 1:length(Target1In_dat)
            if ~isempty(find(statedata(:,3) == Target1In_dat(i1In)))
                Target1In = statedata(statedata(:,3) == Target1In_dat(i1In),1);
            end
        end
        for i2In = 1:length(Target2In_dat)
            if ~isempty(find(statedata(:,3) == Target2In_dat(i2In)))
                Target2In = statedata(statedata(:,3) == Target2In_dat(i2In),1);
            end
        end
        TimeStart = TargetOn;
        TargetOnTime = TimeStart-TargetOn;
        PlotStart = TimeStart -FixationTime;
        FixOffTime = FixOff - TimeStart;
        BaseCalStart = TimeStart - 250; %% 500ms before target onset 
        Target1InTime = Target1In - TimeStart;
        Target2InTime = Target2In-TimeStart;
        RewardTime = RewardOn-TimeStart;
        RTTime = [RewardTime-TimeStart]*2;
        spkdata = spkdata-TimeStart*2;  
        
        HEyeTrace = eyedata(:,1); HEyeTrace = HEyeTrace(PlotStart:end);
        SizeEyeTrace = length(HEyeTrace);
        TimeTrace = [FixationTime*(-1):SizeEyeTrace+FixationTime*(-1)-1];
        VEyeTrace = eyedata(:,2); VEyeTrace = VEyeTrace(PlotStart:end);
        EyeTrace = sqrt(HEyeTrace.^2+VEyeTrace.^2);
        EyeRawVel = abs(DIFFF(EyeTrace)*ceil(1000./sample_interval)); %%eye velocity 계산
        EyeVelocity = smooth(EyeRawVel); %% smoothing
        % find saccade, sampling rate, threshold velocity 90
        Saccade=Findsac(EyeTrace, sample_interval, 200);
        Saccade = Saccade-FixationTime;
        Saccade(Saccade(:,1) <  FixOffTime,:) = [];
        
        if ~isempty(Saccade) & Saccade(1) ~=999999  %% Saccade가 1개 이상 잡히면
            
            SacOnset = Saccade(1,1);
            SacOffset = Saccade(1,2);
            SacDur = (SacOffset - SacOnset)*sample_interval; %% Saccade Duration
            SacAmp = abs(EyeTrace(SacOnset)-EyeTrace(SacOffset)); %%Saccade Amplitude
            MaxVel = max(EyeVelocity(SacOnset:SacOffset)); %% Saccade동안 최대 속도
            MeanVel = mean(EyeVelocity(SacOnset:SacOffset)); %% Saccade동안 평균 속도
            Latency = (SacOnset- FixOffTime)*2;
            HEndPos = HEyeTrace(SacOffset);
            VEndPos = VEyeTrace(SacOffset);

          %  Mat = [Mat; TrialNum XFixation YFixation XA YA HEndPos VEndPos Latency SacDur SacAmp MaxVel MeanVel...
         %       ThisAFreq ThisBFreq RTTime];
            
            if FigTag ==1
%                 TitleStr1 = ['Target: (' num2str(XA) ',' num2str(YA) ') Latency: ' num2str(Latency) 'ms' ];
                HEyeTraceTarget1 = HEyeTrace(Target1InTime:Target1InTime+FixationTime2);
                VEyeTraceTarget1 = VEyeTrace(Target1InTime:Target1InTime+FixationTime2);
                TimeTraceTarget1 = [Target1InTime:Target1InTime+FixationTime2];
                HEyeTraceTarget2 = HEyeTrace(Target2InTime:Target2InTime+FixationTime2);
                VEyeTraceTarget2 = VEyeTrace(Target2InTime:Target2InTime+FixationTime2);
                TimeTraceTarget2 = [Target2InTime:Target2InTime+FixationTime2];

                clf
                subplot(2,3,[1 2])
                plot(TimeTrace,HEyeTrace,'r','linewidth',0.8)
                hold on
                plot(TimeTrace,VEyeTrace,'b','linewidth',0.8)
                plot(spkdata,24,'*')
                
                plot(TimeTraceTarget1,HEyeTraceTarget1,'r','linewidth',2.5)
                plot(TimeTraceTarget1,VEyeTraceTarget1,'b','linewidth',2.5)
                plot(TimeTraceTarget2,HEyeTraceTarget2,'r','linewidth',2.5)
                plot(TimeTraceTarget2,VEyeTraceTarget2,'b','linewidth',2.5)
                %                 line([GapOnTime GapOnTime],[-50 50],'color','k','linestyle',':','linewidth',2)
                line([TargetOnTime TargetOnTime],[-50 50],'color','k','linestyle','-','linewidth',0.8)
                %% sensory response period
                line([TargetOnTime+25 TargetOnTime+250],[-30 -30],'color','y','linestyle','-','linewidth',4)
                %% baseline activity periood
                line([TargetOnTime-250 TargetOnTime],[-30 -30],'color','c','linestyle','-','linewidth',4)
                line([FixOffTime FixOffTime],[-50 50],'color','k','linestyle','-','linewidth',0.8)
                line([SacOnset SacOnset],[-50 50],'color','k','linestyle',':','linewidth',0.8)
                line([RewardTime RewardTime],[-50 50],'color','k','linestyle',':','linewidth',0.8)
                %                 line([Target1InTime Target1InTime],[-50 50],'color','r','linestyle',':','linewidth',1)
                %                 line([Target2InTime Target2InTime],[-50 50],'color','b','linestyle',':','linewidth',1)
                %                 line([Target1InTime+FixationTime2 Target1InTime+FixationTime2],[-50 50],'color','r','linestyle',':','linewidth',1)
                %                 line([Target2InTime+FixationTime2 Target2InTime+FixationTime2],[-50 50],'color','b','linestyle',':','linewidth',1)
                %                 line([SacOnset SacOnset],[-30 30],'color','k')
                %                 line([SacOffset SacOffset],[-30 30],'color','k')
                set(gca,'ylim',[-40 40],'ytick',[-40:20:40])
                set(gca,'xlim',[-300 800],'xtick',[-300:100:800],'xticklabel',[-600:200:1600])
                xlabel('Time from target onset (ms)','fontsize',11)
                ylabel('Eye position (deg)','fontsize',11)
                FreDiff = abs(ThisAFreq - ThisBFreq);
                TitleStr = ['Freq A: ' num2str(ThisAFreq) 'Hz  Freq B:' num2str(ThisBFreq) 'Hz  RT:' num2str(RTTime) 'ms'];
                TitleStr1 = ['Freq A: ' num2str(ThisAFreq) 'Hz  Freq B:' num2str(ThisBFreq) 'Hz  Latency:' num2str(Latency) 'ms  O+A:'...
                    num2str(O_A) 'ms'];
                title(TitleStr1,'fontsize',9)

                %                 title(TitleStr1,'fontsize',12)
                subplot(2,3,3)
                plot(HEyeTrace,VEyeTrace,'k.')
                hold on
                plot(HEyeTraceTarget1,VEyeTraceTarget1,'r.')
                plot(HEyeTraceTarget2,VEyeTraceTarget2,'b.')
                set(gca,'xlim',[-30 30])
                set(gca,'ylim',[-30 30])
                xlabel('Horizontal eye position (deg)','fontsize',11)
                ylabel('Vertical eye position (deg)','fontsize',11)
                JA_rectangle(XA, WinXA, YA, WinYA,'r')
                JA_rectangle(XB, WinXB, YB, WinYB,'b')
                axis square
                set(gcf,'Units','centimeters','Position',[2  3 23 16]);
                pause
            end
        end  %% saccade~90000
    end %% reward
%end %% size(DATA)
%save(MatName, 'Mat','CorrectMat')




