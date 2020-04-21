% this script is for scoring the eye calibration data recorded by EyeTrack
%system from EYELINK II 
%input files
 %"'subid'fa_sample.txt" --> eye data
 %"'subid'fa_trigger.txt"--> triggers 
 %"'subid'fa.out" --> trial type
 
%output file 
 %"'subid'fa_sample.txt-calpoly"
 
%Created by Qingyang Li 09/28/2008

%% clear evironment
clear;

%% define variables that will be used in multiple m-files
global respath subid rawtype caloutname outpath outpath eye
global corr dir logtmp logtmpnum trial RESULT_FILE PICK_OUT P FIX_FILE DEG_FILE DEG_NEW

%% USER CHANGE
%path where raw data are located
rawpath='C:\CCNL\sz07\EyeLink\scoring';

subid=['1610111']; %define subid; 


%% specify data file extensions
rawtype=['.fa'];
datapath = [rawpath,'\data\'];

% path where results are stored;
respath=[rawpath,'\output\'];
%path where cal results are stored
caloutname=[respath,subid,'fa_sample.txt'];

%% parameters
SampleRate=500;
WindowLength=13500;%in samples
PreStimTime=0;
time=[2:(1000/SampleRate):WindowLength*(1000/SampleRate)]-PreStimTime;




%% open data file
[s_time,xpos_l,ypos_l,ps_l,xpos_r,ypos_r,ps_r]=textread(caloutname,'%f%f%f%f%f%f%f');
[a1,trigger_time,trigger]=textread([respath,subid,'fa_trigger.txt'],'%s%f%s');
clear a1 ps_r ps_l ypos_r ypos_l;

%%  epoch the eye data

%define the matrix to hold the raw trial data
%x_left=zeros(WindowLength);
%x_right=zeros(WindowLength);


    a=find(s_time==trigger_time(1));%trigger_time(1) should contain the start time of the eye calibration
    if isempty(a);
       a=find(s_time==trigger_time(1)+1);
    end;
    for i=1:WindowLength;
        x_left(i)=xpos_l(a+i);
        x_right(i)=xpos_r(a+i);       
        
    end;


 
    %% plot position data
    figure(1); 
    plot(time,x_left,'b'),axis tight,grid on;
    title({['Calibration for ',num2str(subid),', LEFT EYE ']});
    
    figure(2); 
	plot(time,x_right,'r'),axis tight,grid on;    
    title({['Calibration for ',num2str(subid),', RIGHT EYE ']});       
    
 %% specifying one eye to score.
    eye=input('Specify Eye to Analyze (1=Left; 2=Right): ');
    if eye==1,
        EYE='Left';
        maxfix=max(x_left);
        minfix=min(x_left);
    elseif eye==2, 
        EYE='Right';
        maxfix=max(x_right);
        minfix=min(x_right);        
    else error(['(1=Left Eye; 2=Right). You just entered "',num2str(eye),'". Please restart FA_01_eyecal.m and make sure you hit the correct key.']);
    end
%% aquiring eye position 
   figure(eye);
   for i=1:7;
       if i==1
            DEG_FILE(1,i)=-15;
       elseif i==2
           DEG_FILE(1,i)=-10;
       elseif i==3
           DEG_FILE(1,i)=-5;
       elseif i==4
           DEG_FILE(1,i)=0;
       elseif i==5
           DEG_FILE(1,i)=5;
       elseif i==6
           DEG_FILE(1,i)=10;
       else
           DEG_FILE(1,i)=15;
       end
     %select 
            text(100,maxfix-(maxfix-minfix)*(0.1*i),['Select Fixation ',num2str(DEG_FILE(1,i)),' DEG <LeftMouse>']);
            pickxy;
            fix(i)=round(PICK_OUT(1,2));
            
             FIX_FILE(1,i)=fix(i);
             
   end
            
  
          
 
 

 
%% Plot the fixation function and query polynomial order
figure(3)
plot(DEG_FILE,FIX_FILE,'b'),axis tight,grid on
hold on;
title(['Fixation Function for ',num2str(subid),rawtype,' ',EYE,' Eye']);
porder=input('Specify Polynomial Order (1-5): ');

% Calculate Polynomial and Plot Result
[P,S]=polyfit(FIX_FILE,DEG_FILE,porder);
DEG_NEW=polyval(P,FIX_FILE);

figure(3)
plot(DEG_NEW,FIX_FILE,'r'),axis tight,grid on;

%% Save polynomial coefficients
save_poly
