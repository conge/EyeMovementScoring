% this script is for scoring the antisaccade eye data recorded by EYELINK II 

%input files
 %"'subid'fa_sample.txt" --> eye data
 %"'subid'fa_trigger.txt"--> triggers 
 %"'subid'fa.out"        --> trial type
 %"'subid'fa_sample.txt-calpoly"--> calibration parameters
%output file
 %"SZ07_practice.res" --> result file
 
%Created by Qingyang Li 09/28/2008


clear;

%% define variables that will be used in multiple m-files
global respath subid rawtype rawpath caloutname outpath  eye
global corr dir logtmp logtmpnum trial RESULT_FILE PICK_OUT P FIX_FILE DEG_FILE DEG_NEW

%% USER CHANGE
%path where raw data are located
rawpath='C:\CCNL\sz07\EyeLink\scoring';

subid=['1610111']; %define subid; 

%% specify data file extensions
rawtype=['fa'];

%path where raw data are located

datapath=[rawpath,'\data\'];

% path where results are stored
respath=[rawpath,'\output\'];
%path where cal results are stored
caloutname=[respath,subid,'fa_sample.txt'];




%% parameters
SampleRate=500;
WindowLength=100+700;%Gap+peripheral cue in samples (see logfiles for durations)
PreStimTime=200;% in ms
time=[2:(1000/SampleRate):WindowLength*(1000/SampleRate)]-PreStimTime;% in ms


%% open data file
[s_time,xpos_l,ypos_l,ps_l,xpos_r,ypos_r,ps_r]=textread(caloutname,'%f%f%f%f%f%f%f');
[a1,trigger_time,trigger]=textread([respath,subid,'fa_trigger.txt'],'%s%f%s','headerlines',2);
clear a1 ps_r ps_l ypos_r ypos_l;

%% epoch the eye data
trial_num=length(trigger);
x_left=zeros(trial_num,WindowLength);
x_right=zeros(trial_num,WindowLength);

for trial= 1:trial_num;
    

    a=find(s_time==trigger_time(trial));
    if isempty(a);
       a=find(s_time==trigger_time(trial)-1);
    end;
 
    for i=1:WindowLength;
        x_left(trial,i)=xpos_l(a-WindowLength-1+i);
        x_right(trial,i)=xpos_r(a-WindowLength-1+i);       
        
    end;
    
end;
%% read logfile

trial_type=textread([respath,subid,'fa.out'],'%s');
s=length(trial_type);

%% define the digital filter characteristics /no need to do this for SMI data?
%n=3; Wn=[.1 50]/(60/2);             % n is the filter order, [x1 x2] 
%are the low and high pass filter settings
%[b,a]=fir1(n,Wn);

%% read calibration file
read_poly;


for trial=1:trial_num
     %% initializing output viarables 
    bad_flag=0;
    bad_reason=0;
    corr=0;
    ecorr=0;
    RESULT_FILE=zeros(1,13);
    
    if eye==1,
        EYE='Left';
        pos=x_left(trial,:);
        clear x_right;
    else
        EYE='Right';
        pos=x_right(trial,:);
        clear x_left;
    end
    if strcmp(trial_type(trial),'ASL10') logtmpnum=1; logtmp='AS1'; end
    if strcmp(trial_type(trial),'ASL05') logtmpnum=1; logtmp='AS2'; end
    if strcmp(trial_type(trial),'ASR05') logtmpnum=0; logtmp='AS3'; end
    if strcmp(trial_type(trial),'ASR10') logtmpnum=0; logtmp='AS4';end
 
% Specify the correct line direction of each trial
if logtmpnum==1 
    direction='Line should go UP';%"UP" means participant looked to the right.
elseif logtmpnum==0
    direction='Line should go DOWN';%"Down" means participant looked to the left.
else 
    direction='N/A';
end
    
%% filter the raw data
%pos=filtfilt(b,a,pos);

%% transform to degrees
  dpos=polyval(P,pos);
   maxdpos=max(dpos);
   mindpos=min(dpos);
% get velocity
vel=gradient(dpos)/(1/SampleRate);
  maxvel=max(vel);
  minvel=min(vel);
  if maxvel > 500 || minvel < -500
        maxvel=500;
        minvel=-500;
  end
      

%% plot Trajectory and velocity data

% plot Trajectory data
figure (1);
plot(time,dpos), axis tight, grid on;
%ylim([-12 12]);
%set(gca,'Xtick',[0 200 500 1000 1500 2000 2500]);
title(['[',EYE,' eye Trajectory of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);

%plot velocity data
figure (2);
plot(time,vel), axis tight, grid on;
set(gca,'Ytick',[-250 -200 -100 -20 0 20 100 200 250]);
ylim([minvel maxvel]);
title([' [',EYE,' eye Velocity of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);

%%
figure(1)
    %query whether to score trial
    text(-100,maxdpos-(maxdpos-mindpos)*(0.1*1),'Scorable Trial? <1=Yes; 0=No>');
    key=input('1=Yes; 0=No; ');

    if key   
            %query correct trial
            figure(1)
            text(-100,maxdpos-(maxdpos-mindpos)*(0.1*2),'Correct trial <1=yes; 0=no>');
            key=input('1=Yes; 0=No: ');
            
            if key 
                corr=1;
            else
                corr=0;
            end
            
            %select saccade start
            figure(2)
            plot (1:length(time),vel,'b'),axis tight, grid on;
            ylim([minvel maxvel]);
            set(gca,'Ytick',[-250 -200 -100 -20 0 20 100 200 250]);

            title([' [',EYE,' eye Velocity of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);
            text(50,maxvel-(maxvel-minvel)*(0.1*1),'Select Saccade Start <LeftMouse>');
            pickxy;
            lat1=round(PICK_OUT(1,1));
            
            %select saccade end
            text(50,maxvel-(maxvel-minvel)*(0.1*2),'Select Saccade End <LeftMouse>');
            pickxy;
            lat2=round(PICK_OUT(1,1));
            
            %select final eye position
            text(50,maxvel-(maxvel-minvel)*(0.1*3),'Select Final Eye Position <LeftMouse>');
            pickxy;
            lat3=round(PICK_OUT(1,1));
            
                        
            %Put latency, amplitude, duration, and time in RESULT_FILE
            
            RESULT_FILE(1,1)=time(lat1); %RT
            RESULT_FILE(1,2)=dpos(lat2)-dpos(lat1); %initial saccade amplitude
            RESULT_FILE(1,3)=dpos(lat3)-dpos(lat1); %final saccade amplitude
            RESULT_FILE(1,4)=time(lat2)-time(lat1); %length of saccade
            
            RESULT_FILE(1,5)=abs(mean(vel(lat1:lat2)));% mean velocity of first saccadic response
            [Y,I]=max(abs(vel(lat1:lat2)));            
            RESULT_FILE(1,6)=Y;                        % Max velocity of first saccadic response
            RESULT_FILE(1,7)=time(I+lat1)-time(lat1);  % Time to reach the max velocity of first saccadic response
            

            
            if corr==1;  
                ecorr=0;%correct trial - no correction necessary
            RESULT_FILE(1,8)=0;   % error correction RT
            RESULT_FILE(1,9)=0;   % amplitude of correction
            RESULT_FILE(1,10)=0;  % length of correction response
            RESULT_FILE(1,11)=0;  % mean velocity of correction
            RESULT_FILE(1,12)=0;  % max velocity of correction
            RESULT_FILE(1,13)=0;  % Time to reach the max velocity of correction saccadic response
            
            end
           
            if corr==0;
                %query whether a correction
                figure(1)
                text(-100,maxdpos-(maxdpos-mindpos)*(0.1*3),'To Score Correction <1=Yes; 0=No>');
                key=input('1=Yes; 0=No; ');
                if key, ecorr=1;else ecorr=0;end
                
                if ecorr==1; %there is an error correction
                %select beginning of correction
                figure(2)
                text(300,maxvel-(maxvel-minvel)*(0.1*2.5),'Select Error Correction Start <LeftMouse>');
                pickxy;
                lat4=round(PICK_OUT(1,1));
                
                %select end of correction
                text(300,maxvel-(maxvel-minvel)*(0.1*3.5),'Select Error Correction End <LeftMouse>');
                pickxy;
                lat5=round(PICK_OUT(1,1));
                
                RESULT_FILE(1,8)=time(lat4); %error correction RT
                RESULT_FILE(1,9)=dpos(lat5)-dpos(lat1); %amplitude of correction
                RESULT_FILE(1,10)=time(lat5)-time(lat4);%length of correction response
                RESULT_FILE(1,11)=abs(mean(vel(lat4:lat5)));%mean velocity of correction
                [Y,I]=max(abs(vel(lat4:lat5)));
                RESULT_FILE(1,12)=Y;%max velocity of correction
                RESULT_FILE(1,13)=time(I+lat4)-time(lat4);  % Time to reach the max velocity of correction saccadic response
                
                else %if no correction
                RESULT_FILE(1,8)=0; %error correction RT - if no correction
                RESULT_FILE(1,9)=0; %amplitude of correction - if no correction
                RESULT_FILE(1,10)=0;%length of correction response
                RESULT_FILE(1,11)=0;%mean velocity of correction
                RESULT_FILE(1,12)=0;%max velocity of correction
                RESULT_FILE(1,13)=0;% Time to reach the max velocity of correction saccadic response

                
            end
            end
            
    else
            bad_flag=1;
            
            text(-100,maxdpos-(maxdpos-mindpos)*(0.1*2),'Main reason for not scoring? <1=Anticipatory saccade; 2=Eye blinks at stimulis onset; 3=;no movement; 4=Other; 0=skip>');
            key=input('<1=Anticipatory saccade; 2=Eye blinks at stimulis onset; 3=;no movement; 4=Other; 0=skip>');
            if key 
                bad_reason=key;
            end
            
    end
        if ~(bad_flag && ~bad_reason)
            fidres = fopen([respath,'SZ07_practice.res'],'a');  %change extension for diff runs            
            fprintf(fidres,'%-8s' ,subid);      % Participant's ID
            fprintf(fidres, '%-6s' ,rawtype);   % Run Type 
            fprintf(fidres, '%-6s' ,EYE);        % EYE             
            fprintf(fidres, '%-3.0f' ,trial);    % Trial number
            fprintf(fidres, '%-5s' , logtmp);    % Trial type
            fprintf(fidres, '%-3.0f' , bad_flag);    % Bad trial? 1= bad; 0=good
            fprintf(fidres, '%-3.0f' , bad_reason);  % Why it is bad? <1=Noisy data; 2=movement before target; 3=cutoff; 4=;no movement; 5=Other; 0=skip>
            fprintf(fidres, '%-3.0f' ,corr);      % Is this trial a correct one? (1=yes; 0=no)
            fprintf(fidres, '%-3.0f' ,ecorr);     % Does the participant make an error correction? (1=yes; 0=no)
            fprintf(fidres, '%-3.0f' ,logtmpnum); % Theoretical correct resposne (1 means participants should look to rihgt, 0 means partiicpant should look to left)
            fprintf(fidres,'%12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f',RESULT_FILE);
            fprintf(fidres, '\r\n');
            fclose(fidres);
        end
        
        
end
