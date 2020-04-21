% Save Calibration Polynomial Coefficients
global respath caloutname eye P FIX_FILE DEG_FILE DEG_NEW
fid = fopen([caloutname,'-calpoly'],'w');
write_matrix(fid,eye);
write_matrix(fid,P);
write_matrix(fid,FIX_FILE);
write_matrix(fid,DEG_FILE);
write_matrix(fid,DEG_NEW);
fclose(fid);
