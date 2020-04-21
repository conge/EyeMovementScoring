global respath caloutname caltype eye P
fid = fopen([caloutname,'-calpoly'],'r');
eye = read_matrix(fid);
P   = read_matrix(fid);
fclose(fid);
