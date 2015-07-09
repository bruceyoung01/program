pro GetWRFParameter,strFilePath,strPara,arrResult
  idFile = ncdf_open(strFilePath);
  idvar = ncdf_varid(idFile,strPara);
  ncdf_varget,idFile,idvar,arrResult
  NCDF_CLOSE, idFile
end

  GetWRFParameter,'/home/bruce/sshfs/shw/data/wrf_output/wrfout_cmaq_2006_summer/wrfout/wrfout_d01_2006-06-20_15_00_00','TAUAER2',tao400
  GetWRFParameter,'/home/bruce/sshfs/shw/data/wrf_output/wrfout_cmaq_2006_summer/wrfout/wrfout_d01_2006-06-20_15_00_00','TAUAER3',tao600

  tao400=total(tao400,3)
  tao600=total(tao600,3)
  a=-alog(tao400/tao600)/alog(0.4/0.6)
  tao550=tao600*(0.55/0.6)^(-a)
end

