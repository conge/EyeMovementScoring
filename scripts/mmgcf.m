function Hf=mmgcf(flag)

Hf=get(0,'CurrentFigure');
if isempty(Hf) & nargin==1 & flag~=0
   error('No Figure Window Exists')
end
