% this script is for scoring the eye data for ODR task recorded by EYELINK II 
%input files
 %"'subid'odr_sample.txt" --> eye data
 %"'subid'odr_trigger.txt"--> triggers 
 %"'subid'odr.out"        --> trial type
 %"'subid'odr_sample.txt-calpoly"--> calibration parameters
%output file
 %"SZ07_odr.res" --> result file

%Created by Qingyang Li 09/28/2008


clear;

%% define variables that will be used in multiple m-files
global respath subid rawtype rawpath caloutname outpath  eye
global corr dir logtmp logtmpnum trial RESULT_FILE PICK_OUT P FIX_FILE DEG_FILE DEG_NEW
global flag_correction flag_scorable flag_blink4100 flag_mem cor_trls err_trls P flag_mem_sacc_dirc


%%  USER CHANGE
%path where raw data are located
rawpath='C:\CCNL\sz07\EyeLink\scoring';
subid=['1610101']; %define subid

%% specify data file extensions
rawtype=['odr'];

%path where raw data are located

datapath=[rawpath,'\data\'];

% path where results are stored
respath=[rawpath,'\output\'];
%path where cal results are stored
caloutname=[respath,subid,'odr_sample.txt'];
%specify log file
logdir=[datapath,'logfiles\'];



%% parameters
SampleRate=500;
WindowLength=100+50+2000+750+150;%fix+cue+fixation+response+peripheral cue+feed back in samples (see logfiles for durations)
PreStimTime=200;% in ms
time=[2:(1000/SampleRate):WindowLength*(1000/SampleRate)]-PreStimTime;% in ms


%% READing DATA FILE, TRIGGER FILE AND EPOCHing THE EYE DATA
[s_time,xpos_l,ypos_l,ps_l,xpos_r,ypos_r,ps_r]=textread(caloutname,'%f%f%f%f%f%f%f');
[a1,trigger_time,trigger]=textread([respath,subid,'odr_trigger.txt'],'%s%f%s','headerlines',2);
clear a1 ps_r ps_l ypos_r ypos_l;

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

%% READ LOGFILE & Calibration parameters

trial_type=textread([respath,subid,'odr.out'],'%s');
s=length(trial_type);

%% define the digital filter characteristics /no need to do this for SMI data?
%n=3; Wn=[.1 50]/(60/2);             % n is the filter order, [x1 x2] 
%are the low and high pass filter settings
%[b,a]=fir1(n,Wn);

read_poly;

%% PLOTTING EYE DATA and SCORING
for trial=1:trial_num
     %% initializing output viarables 
                            RESULT_FILE = zeros(1,27);
                            flag_blink4100=0;
                            error_type=0;
                            bad_reason=0;
                            ant=0;
                            flag_mem_sacc_dirc=0;
                            
    
    if eye==1,
        EYE='Left';
        pos=x_left(trial,:);
        clear x_right;
    else
        EYE='Right';
        pos=x_right(trial,:);
        clear x_left;
    end
    
    if strcmp(trial_type(trial),'ODRL16') logtmpnum=0; logtmp='ODR1'; end
    if strcmp(trial_type(trial),'ODRL08') logtmpnum=0; logtmp='ODR2'; end
    if strcmp(trial_type(trial),'ODRR08') logtmpnum=1; logtmp='ODR3'; end
    if strcmp(trial_type(trial),'ODRR16') logtmpnum=1; logtmp='ODR4'; end
 
% Specify the correct line direction of each trial
if logtmpnum==1 
    direction='Line should go UP';dirc_num=1;%"UP" means participant looked to the right.
elseif logtmpnum==0
    direction='Line should go DOWN';dirc_num=2;%"Down" means participant looked to the left.
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
hold off;
 plot(time,dpos), axis tight, grid on;
 title(['[',EYE,' eye Trajectory of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);
 hold on;

%plot velocity data
                       figure(2);
                            x1=[4180,4180];
                            x2=[4100,4100];
                            y1=[maxvel,minvel];
                        hold off;
                        plot(time,vel,'b',x1,y1,'--rs',x2,y1,'--rs'),axis tight,grid on;
                        title([' [',EYE,' eye Velocity of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);
                         set(gca,'Ytick',[-250 -200 -100 -20 0 20 100 200 250]);
                         ylim([minvel maxvel]);
                       hold on;
%%
figure(1)
    %query whether to score trial
    text(-100,maxdpos-(maxdpos-mindpos)*(0.1*1),'Scorable Trial? <1=Yes; 0=No>');
    key=input('1=Yes; 0=No; ');
          if key == 1
                           flag_scorable=1;
                        else
                            flag_scorable=0;
                        end
                           
                             %query anticipatory saccades
    if flag_scorable           
            figure(1)
            text(-100,maxdpos-(maxdpos-mindpos)*0.2,'Blink at 4100? <1=yes;0=no>');
                            key=input('Blink at 4100? <1=yes;0=no>: ');
                        if key == 1
                           flag_blink4100=1;
                        else
                           flag_blink4100=0;
                        end
                            
            figure(1)
                            text(-100,maxdpos-(maxdpos-mindpos)*0.3,'Number of anticipatory saccades <0-6>');
                            key=input('how many anticipatory saccades? <Range [0,6]>: ');
                            if key
                                ant=key; 
                                if ant>6
                                    error('This script is designed to score trials with no more than 6 anticipatory saccades. For more info, plese contact Qingyang Li: yang@uga.edu');
                                end
                            else
                                ant=0;
                            end
                            %query if there is a memorial saccade
                            
                            text(-100,maxdpos-(maxdpos-mindpos)*0.4,'Score memorial sccade? <1=Yes; 0=no>');
                            key=input('Score memorial sccade? <1=Yes; 0=no>: ');
                            if key
                                flag_mem=1;
                            else
                               flag_mem=0;
                            end
                            
%% ************************************Anticipatory saccades scoring*******************   
 
         if ant~=0 %if there are anticipatory saccades, then scored them
             RESULT_FILE(1,8)=ant; %record the number of antipatory saccades
             n=0;%counter
                   
            for i= 1:ant %score anticipatory saccades
             figure(2)
             hold off;
                            plot (1:length(time),vel,'b'),axis tight,grid on;
                            title([' [',EYE,' eye Velocity of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);
                            set(gca,'Ytick',[-200 -100 -20 20 100 200]);
                            ylim([minvel maxvel]);
                            hold on;
                             y1=[maxvel,minvel];
                             x2=[2150,2150];
                             x3=[2190,2190];
                             plot(x2,y1,'--rs',x3,y1,'--rs');
                            
                             
                            num_ant_sacc=num2str(i);
                            % Select Velocity End From Velocity Plot
                            text(50,maxvel-(maxvel-minvel)*n/10,['Select Start of Anticipatory Saccade No.',num_ant_sacc,' <LeftMouse>']);
                            n=n+1;
                            pickxy;
                            ants(i,1)=round(PICK_OUT(1,1));

                            % Select Velocity Final Eye Pos From Velocity Plot
                            text(50,maxvel-(maxvel-minvel)*n/10,['Select End of Anticipatory Saccade No.',num_ant_sacc,' <LeftMouse>']);
                            n=n+1;
                            pickxy;
                            ants(i,2)=round(PICK_OUT(1,1));
                            RESULT_FILE(1,7+n)=time(ants(i,1));%RT of first anticipatory saccade
                            RESULT_FILE(1,8+n)=pos(ants(i,2))-pos(ants(i,1))  ;%amplitude of first anticipatory saccade
            end; % end for i= 1:ant
                             clear n;
         end
%******************************End of anticipatory saccades scoring *******************    

%% memorial saccade
            if flag_mem
              figure(2)
              hold off
                            plot (1:length(time),vel,'b'),axis tight,grid on;
                            
                            title([' [',EYE,' eye Velocity of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);

                            set(gca,'Ytick',[-250 -200 -100 -20 20 100 200 250]);
                            ylim([minvel maxvel]);
                            hold on;
                            
                             y1=[maxvel,minvel];
                             x2=[2190,2190];
                             x3=[2150,2150];
                             plot(x2,y1,'--rs',x3,y1,'--rs');  
                             
                             text(50,maxvel-(maxvel-minvel)*0.1,'Line direction is <1=up; 2=down; 0=flat>');  
                             key=input('Line direction is <1=up; 2=down; 0=flat>: ');
                              if key
                                  Line_dirc=key;
                              else
                                   Line_dirc=0;
                              end
                              if Line_dirc
                               
                            text(50,maxvel-(maxvel-minvel)*0.2,'Select Memory Saccade Start <LeftMouse>');
                            pickxy;
                            lat1=round(PICK_OUT(1,1));
                                     
                            % Select Velocity End From Velocity Plot
                            text(50,maxvel-(maxvel-minvel)*0.3,'Select Saccade End <LeftMouse>');
                            pickxy;lat2=round(PICK_OUT(1,1));

                            % Select Velocity Final Eye Pos From Velocity Plot
                            text(50,maxvel-(maxvel-minvel)*0.4,'Select Final Eye Position <LeftMouse>');
                            pickxy;
                            lat3=round(PICK_OUT(1,1));
   
            % Put latency,amplitude,duration,average velocity,peak velocity,
            %    and time to peak velocity in RESULT_FILE
                            RESULT_FILE(1,1)=time(lat1)-4100; %RT ? why minus 4100ms
                            RESULT_FILE(1,2)=dpos(lat2)-dpos(lat1); %initial saccade amplitude
                            RESULT_FILE(1,3)=dpos(lat3)-dpos(lat1); %final saccade amplitude
                            RESULT_FILE(1,4)=time(lat2)-time(lat1); %duration of saccade
                            RESULT_FILE(1,5)=abs(mean(vel(lat1:lat2))); %average velocity
                            [Y,I]=max(abs(vel(lat1:lat2)));
                            RESULT_FILE(1,6)=Y; %peak velocity
                            RESULT_FILE(1,7)=time(I+lat1)-time(lat1); %time to peak velocity
                            
                             if Line_dirc~=dirc_num
                                    flag_mem_sacc_dirc=0;% 0= wrong saccadic reponse
              % query whether an error correction
               figure(1)
               text(-100,maxdpos-(maxdpos-mindpos)*0.6,'Error Correction? <1=Yes; 0=No>');
               key=input('Error Correction? <1=Yes; 0=No>: ');
               if key, flag_correction=1;else flag_correction=0;end
               
                            RESULT_FILE(1,21)=flag_correction;
                              if flag_correction==1
                  figure(2)
                  hold off;
                             plot (1:length(time),vel,'b'),axis tight,grid on;
                            
                            title([' [',EYE,' eye Velocity of ',num2str(subid),'] [Trial type = ',logtmp,'] [',direction,sprintf(']\n'),num2str(trial),'/',num2str(trial_num)]);
                            
                            set(gca,'Ytick',[-250 -200 -100 -20 20 100 200 250]);
                            ylim([minvel maxvel]);
                            hold on;
                            
                             y1=[maxvel,minvel];
                             x2=[2190,2190];
                             x3=[2150,2150];
                             plot(x2,y1,'--rs',x3,y1,'--rs');  
                text(50,maxvel-(maxvel-minvel)*0.2,'Error Correction Start <LeftMouse>');
                  %%%set(gca,'Ytick',[-200 -100 -50 -20 20 50 100 200]);
                  set(gca,'Ytick',[-200 -100 -20 20 100 200]);
                  pickxy;
                  lat1=round(PICK_OUT(1,1));
                  
                  text(50,maxvel-(maxvel-minvel)*0.3,'Error Correction End <LeftMouse>');
                  pickxy;
                  lat2=round(PICK_OUT(1,1));
                  
                  RESULT_FILE(1,21)=pos(lat2)-pos(lat1);

                  
                            RESULT_FILE(1,22)=time(lat1)-4100; %RT ? why minus 4100ms
                            RESULT_FILE(1,23)=dpos(lat2)-dpos(lat1); %correction saccade amplitude
                            RESULT_FILE(1,24)=time(lat2)-time(lat1); %duration of correction saccade
                            RESULT_FILE(1,25)=abs(mean(vel(lat1:lat2))); %average velocity
                            [Y,I]=max(abs(vel(lat1:lat2)));
                            RESULT_FILE(1,26)=Y; %peak velocity
                            RESULT_FILE(1,27)=time(I+lat1)-time(lat1); %time to peak velocity
                              end

                                else
                                    flag_mem_sacc_dirc=1;% 1=correct response
                             end
                                
                              end
          else
              flag_mem_sacc_dirc=0; 
          end


          
                    else
                            text(-200,maxdpos-(maxdpos-mindpos)*0.2,'Main reason for not scoring? <1=Noisy data; 2=blink at 0; 3=cutoff; 4=no saccade; 5=Other>');
                            key=input('<1=Noisy data; 2=blink at 0; 3=cutoff; 4=no saccade; 5=Other; 0=skip>');
                            if key 
                                bad_reason=key;
                            end
    
    end% end if key
%% error type
if flag_mem
    
 if ant>0 && flag_mem_sacc_dirc==1
    error_type=1; %anticipatory saccades only
 elseif ant==0 && flag_mem_sacc_dirc==0
    error_type=2;%wrong memory saccades only
 elseif ant>0 && flag_mem_sacc_dirc==0
    error_type=3; % 1+3
 elseif ant==0 && flag_mem_sacc_dirc==1
    error_type=0; % correct trial
 end
else % no memorial saccades
    if ant==0 
        error_type=4;% no memorial saccades
    else
        error_type=5;%anticipatory saccades + no memorial saccades
    end
end
%% Save results
          if ~(flag_scorable==0 && bad_reason==0)  
                            fidres = fopen([respath,'SZ07_odr.res'],'a');

                            fprintf(fidres,'%c' ,subid);
                            fprintf(fidres, '%c' ,rawtype);
                            fprintf(fidres, '%-6s' ,EYE);
                            fprintf(fidres, '%12.6f' ,trial);
                            fprintf(fidres, '%12.6f' ,flag_scorable);
                            fprintf(fidres, '%12.6f' ,bad_reason);
                            fprintf(fidres, '%12.6f' ,error_type);
                            fprintf(fidres, '%12.6f' ,flag_blink4100);
                            fprintf(fidres,'%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f',RESULT_FILE);
                            fprintf(fidres, '\r\n');
                            
                            fclose(fidres);
          end
      
         end % end loop for each trial
  






