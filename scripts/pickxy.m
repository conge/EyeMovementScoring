function out=pickxy(arg)

global PICK_OUT MOUSXY_OUT

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
      'WindowButtonMotionFcn','pickxy(''move'')',...
      'Userdata',Hu)
   figure(Hf)
   
key=waitforbuttonpress;
if ~key
   PICK_OUT(1,1:2)=MOUSXY_OUT;
end
pickxy('end');
                        
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
