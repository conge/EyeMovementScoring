% this script is for formatting the eye data recorded by EyeTrack
%system from EYELINK II and Presentation.
%To run this script, the eye data and logfiles must be named following some
%specific rules.

%input files
 %- name of edf files "'subid'.edf", e.g."1600121a"
 %- name of logfile "'subid'-Fix_anti.log", e.g. "160012-1_Fix_anti.log" 
%output files
 %"'sudid'fa_sample.txt" --> eye data
 %"'sudid'fa_trigger.txt"--> triggers 
 %"'sudid'fa.out" --> trial type
%Created by Qingyang Li 09/28/2008



clear;
%% define variables that will be used in multiple m-files
global respath subid rawtype caloutname outpath taskid eye P FIX_FILE DEG_FILE DEG_NEW
global corr dir logtmp logtmpnum trial RESULT_FILE PICK_OUT


%% USER CHANGE
subidlst=['1610111'];% subid+day
%path where raw data are located
rawpath='C:\CCNL\sz07\EyeLink\scoring';


%% specify data file extensions
rawtype= 'fa';
datapath=[rawpath,'\data\'];

% path where results are stored
respath=[rawpath,'\output\'];
%path where cal results are stored

%specify log file
logdir=[datapath,'logfiles\'];



for id=1:length(subidlst(:,1));
subid=subidlst(id,:); %define subid

logfile=[subid,'-Fix_Anti.log'];

%%
fidraw=fopen([datapath,subid,'a.asc'],'r','l');
fidsample=fopen([respath,subid,'fa_sample.txt'],'w');
fidtrigger=fopen([respath,subid,'fa_trigger.txt'],'w');
 while ~feof(fidraw)                                        
   
   tline=fgetl(fidraw);   
   if ~isempty(tline)&& ~(tline(1)==' ') % empty line?
    [m,n]=size(tline);
    
    trigger_flag=0;

    for i=1:n
        if i>11 && ((double(tline(i))==76&&double(tline(i-1))==65&&double(tline(i-2))==73&&...
                double(tline(i-3))==82&&double(tline(i-4))==84&&double(tline(i-5))==95&&double(tline(i-6))==73&&...
                double(tline(i-7))==84&&double(tline(i-8))==78&&double(tline(i-9))==65&&double(tline(i-10))==95)...
                |(double(tline(i))==108&&double(tline(i-1))==97&&double(tline(i-2))==99&&double(tline(i-3))==95 ...
            &&double(tline(i-4))==101&&double(tline(i-5))==121&&double(tline(i-6))==101)); %see char(101,121,101,95,99,97,108), char(95,65,78,84,73,95,84,82,73,65,76) for details
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

%% formatting log file
fidlog=fopen([logdir,logfile],'r','l');

fidlogoutput=fopen([respath,subid,'fa.out'],'w');
while ~feof(fidlog);
    tline=fgetl(fidlog);   
   if ~isempty(tline)&& ~(tline(1)==' ') % empty line?
    [m,n]=size(tline);
    
    trigger_flag=0;

    for i=1:n
        if i>7 && ((double(tline(i))==83&&double(tline(i-1))==65));
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

[a1,a2,a3,trial_lable,a4,a5,a6,a7,a8,a9,a10]=textread([respath,subid,'fa.out'],'%f%f%s%s%f%f%f%f%f%f%f');
clear a1 a2 a3 a4 a5 a6 a7 a8 a9 a10;

fidlogoutput=fopen([respath,subid,'fa.out'],'w');
trial_lable=char(trial_lable);
[m,n]=size(trial_lable);
for i=1:m
fprintf(fidlogoutput,'%s\n',trial_lable(i,:));
end
fclose(fidlogoutput);
end