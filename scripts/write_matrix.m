function write_matrix(fid,data)
sz = size(data);
fprintf(fid,'%d %d\n',sz(1),sz(2));
for i=1:sz(1)
   for j=1:sz(2)
      fprintf(fid,'%e ',data(i,j));
   end
   fprintf(fid,'\n',data(i,j));
end
