function out=mousxy(arg)

global MOUSXY_OUT
global RESULT_FILE

if ~nargin
   Hf=mmgcf(1);
   Ha=findobj(Hf, 'Type','axes');
   if isempty(Ha), error('No axes in current Figure'),end
   
   Hu=uicontrol(Hf, 'Style','text',...
      'units','pixels',...
      'Position',[1 5 170 20],...
      'FontUnits','points',...
      'FontSize',12,...
      'FontWeight','bold',...
      'HorizontalAlignment','left');
   set(Hf,'Pointer','crossh',...
      'WindowButtonMotionFcn','mousxy(''move'')',...
      'Userdata',Hu)
   figure(Hf)
   
key=waitforbuttonpress;
if key
   RESULT_FILE(1,5:6)=MOUSXY_OUT;
   key=waitforbuttonpress;
   if key
      RESULT_FILE(1,7:8)=MOUSXY_OUT;
   end
else
   key=waitforbuttonpress;
   if key
      RESULT_FILE(1,7:8)=MOUSXY_OUT;
   end
end
mousxy('end');
                        
elseif strcmp(arg,'move')
   cp=get(gca,'CurrentPoint');
   MOUSXY_OUT=cp(1,1:2);
   xystr=sprintf('[%6.4g,%6.4g]',MOUSXY_OUT);
   Hu=get(gcf,'Userdata');
   set(Hu,'String',xystr)
   
elseif strcmp(arg,'end')
   Hu=get(gcf,'Userdata');
   delete(Hu);
   set(gcf,'Pointer','arrow',...
      'WindowButtonMotionFcn','',...
      'WindowButtonDownFcn','',...
      'Userdata',[])
end
% 'WindowButtonDownFcn','mousxy(''end'')',...
