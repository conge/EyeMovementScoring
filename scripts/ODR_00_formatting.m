% this script is for formatting the eye calibration data from ODR task recorded by EyeTrack
%system from EYELINK II 
%input files (examples)
 %"1600101o.asc"  --> output of edf2asc
 %"1600101-ODR.log" --> logfile from presentation
 
%output files 
 %"'subid'odr_sample.txt" --> eye data
 %"'subid'odr_trigger.txt"--> triggers 
 %"'subid'odr.out"        --> trial type

%Created by Qingyang Li 09/28/2008

clear;
%% define variables that will be used in multiple m-files
global respath subid rawtype caloutname outpath taskid eye P FIX_FILE DEG_FILE DEG_NEW
global corr dir logtmp logtmpnum trial RESULT_FILE PICK_OUT





%% USER CHANGE
subidlst=['1610101'];% subid+day
%path where raw data are located
rawpath='C:\CCNL\sz07\EyeLink\scoring';

%% specify data file extensions
rawtype= 'odr';

%path where raw data are located

datapath=[rawpath,'\data\'];

% path where results are stored
respath=[rawpath,'\output\'];
%path where cal results are stored

%specify log file
logdir=[datapath,'logfiles\'];
for id=1:length(subidlst(:,1));
subid=subidlst(id,:); %define subid



logfile=[subid,'-ODR.log'];

%% formating .asc file
fidraw=fopen([datapath,subid,'o.asc'],'r','l');
fidsample=fopen([respath,subid,'odr_sample.txt'],'w');
fidtrigger=fopen([respath,subid,'odr_trigger.txt'],'w');
 while ~feof(fidraw)                                        
   
   tline=fgetl(fidraw);   
   if ~isempty(tline)&& ~(tline(1)==' ') % empty line?
    [m,n]=size(tline);
    
    trigger_flag=0;
    
    for i=1:n
        if i>11 && ((double(tline(i))==76&&double(tline(i-1))==65&&double(tline(i-2))==73&&...
                double(tline(i-3))==82&&double(tline(i-4))==84&&double(tline(i-5))==95&&double(tline(i-6))==82&&...
                double(tline(i-7))==68&&double(tline(i-8))==79)...
                |(double(tline(i))==108&&double(tline(i-1))==97&&double(tline(i-2))==99&&double(tline(i-3))==95 ...
            &&double(tline(i-4))==101&&double(tline(i-5))==121&&double(tline(i-6))==101));% run char(101,121,101,95,99,97,108) and char(79,68,82,95,84,82,73,65,76) in command window to see what do these numbers mean
               trigger_flag=1;
            break;
        end
    end
    if trigger_flag==1 % if all are numbers, write the line into the sample file.
      fprintf(fidtrigger,'%s\n',tline);
    end
 
    flag=1;
    for i=1:n %if there is any letters in line????.Ee???????
        if i>1 && tline(i)=='.' && tline(i-1)==' ';
                tline(i)='0';
        end
      if ~(tline(i)==' '|tline(i)=='-'|tline(i)=='.'|tline(i)=='E'|tline(i)=='e'|tline(i)=='+'|(double(tline(i))>=48&&double(tline(i))<=57)|double(tline(i))==9)
        flag=0;
        break;
      end
    end
   end
 if flag==1 && ~(tline(1)==9) % if all are numbers, write the line into the sample file.
      fprintf(fidsample,'%s\n',tline);
 end
 end
fclose(fidraw);
fclose(fidtrigger);
fclose(fidsample);

%% formating log file
fidlog=fopen([logdir,logfile],'r','l');

fidlogoutput=fopen([respath,subid,'odr.out'],'w');
while ~feof(fidlog);
    tline=fgetl(fidlog);   
   if ~isempty(tline)&& ~(tline(1)==' ') % empty line?
    [m,n]=size(tline);
    
    trigger_flag=0;
 
    for i=1:n
        if i>16 && ((double(tline(i))==82&&double(tline(i-1))==68&&double(tline(i-2)==79)));
               trigger_flag=1;
            break;
        end
    end
    if trigger_flag==1 % if all are numbers, write the line into the sample file.
      fprintf(fidlogoutput,'%s\n',tline);
    end
   end
end

fclose(fidlogoutput);
fclose(fidlog);

[a1,a2,a3,trial_lable,a4,a5,a6,a7,a8,a9,a10]=textread([respath,subid,'odr.out'],'%f%f%s%s%f%f%f%f%f%f%f');
clear a1 a2 a3 a4 a5 a6 a7 a8 a9 a10;

fidlogoutput=fopen([respath,subid,'odr.out'],'w');
trial_lable=char(trial_lable);
[m,n]=size(trial_lable);
for i=1:m
fprintf(fidlogoutput,'%s\n',trial_lable(i,:));
end
fclose(fidlogoutput);
end