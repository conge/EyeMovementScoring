function data = read_matrix(fid)
sz = fscanf(fid,'%d',[1,2]);
data = zeros(sz);
for i=1:sz(1)
  data(i,:) = fscanf(fid,'%f',[1,sz(2)]);
end
