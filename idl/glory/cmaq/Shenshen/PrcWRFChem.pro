Pro PrcWRFChem
  data=READ_ASCII(FILE_WHICH('WRF_Lon.txt'))
  arrLon=data.FIELD001
  data=READ_ASCII(FILE_WHICH('WRF_Lat.txt'))
  arrLat=data.FIELD001
  
  filename='F:\WRF-Chem\2006\wrfout_d01_2006-06-20_15_00_00'
  
  GetParameter,filename,'TAUAER2',tao400
  GetParameter,filename,'TAUAER3',tao600
  
  tao400=total(tao400,3)
  tao600=total(tao600,3)
  a=-alog(tao400/tao600)/alog(0.4/0.6)
  tao550=tao600*(0.55/0.6)^(-a)
  
  CreateShapeFile,'F:\wrfout_d01_2007-01-30_15_00_00.sph', tao550,arrLon,arrLat
end

pro GetParameter,strFilePath,strPara,arrResult
  idFile = ncdf_open(strFilePath);
  idvar = ncdf_varid(idFile,strPara);
  ncdf_varget,idFile,idvar,arrResult
  NCDF_CLOSE, idFile
end

pro CreateShapeFile,strShpPath, arrValue,arrLon,arrLat
  NewShape = OBJ_NEW('IDLffShape', strShpPath, /UPDATE, ENTITY_TYPE=1)
  NewShape->AddAttribute, 'Longitude', 5, 8, PRECISION = 8
  NewShape->AddAttribute, 'Latitude', 5, 8, PRECISION = 8
  NewShape->AddAttribute, 'Value', 5, 8, PRECISION = 8
  s=size(arrLon)
  
  for i=0L, s[1]-1 do begin
    for j= 0L, s[2]-1 do begin
      ;Create structure for new entity
    
      entNew = {IDL_SHAPE_ENTITY}
      
      ; Define the values for the new entity
      entNew.SHAPE_TYPE = 1
      entNew.ISHAPE = 1458
      entNew.BOUNDS[0] = arrLon[i,j]
      entNew.BOUNDS[1] = arrLat[i,j]    ;fire pixel's lati and long
      entNew.BOUNDS[2] = 0.00000000
      entNew.BOUNDS[3] = 0.00000000
      entNew.BOUNDS[4] = arrLon[i,j]
      entNew.BOUNDS[5] = arrLat[i,j]
      entNew.BOUNDS[6] = 0.00000000
      entNew.BOUNDS[7] = 0.00000000
      entNew.N_VERTICES = 1
      
      NewShape->PutEntity, entNew
      attrNew = NewShape->GetAttributes(/ATTRIBUTE_STRUCTURE)
      attrNew.ATTRIBUTE_0 = arrLon[i,j]
      attrNew.ATTRIBUTE_1 = arrLat[i,j]
      attrNew.ATTRIBUTE_2 = arrValue[i,j]
      id=i*s[2]+j
      NewShape->SetAttributes, id, attrNew
    endfor
  endfor
  OBJ_DESTROY, NewShape
end