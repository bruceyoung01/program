;
  function process, calc

      so4c = mean(calc.so4_conc,2)*96.
      nitc = mean(calc.nit_conc,2)*62.
      nh4c = mean(calc.nh4_conc,2)*18.
      soac = (calc.soa1_conc)*150.                   $
           + (calc.soa2_conc)*160.                   $
           + (calc.soa3_conc)*220.
      soac = mean(soac,2)
      poac = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4
      poac = mean(poac,2)
      omcc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 $
           + (calc.soa1_conc)*150.                   $
           + (calc.soa2_conc)*160.                   $
           + (calc.soa3_conc)*220.
      omcc = mean(omcc,2)
;      dust = (calc.dst1_conc + calc.dst2_conc*0.38)*29.       
;      dust = mean(dust,2)
;      salt = mean(calc.sala_conc,2)*36.
      ecc  = (calc.ecpi_conc + calc.ecpo_conc)*12.
      ecc  = mean(ecc,2)

   return, {so4:so4c,nh4:nh4c,nit:nitc,ec:ecc,omc:omcc,soa:soac,poa:poac}

  end

  function takemean, obs

      so4c = mean(make_zero(obs.so4,val='NaN'),2,/NaN)
      nitc = mean(make_zero(obs.no3,val='NaN'),2,/NaN)
      omcc = mean(make_zero(obs.oc,val='NaN'),2,/NaN)*1.4
      ecc  = mean(make_zero(obs.ec,val='NaN'),2,/NaN)

   return, {so4:so4c,nit:nitc,ec:ecc,omc:omcc}

  end

;======================

  pro values, obs, std, sen0, sen1, sen2


  a = process(std)
  b = process(sen0)
  c = process(sen1)
  d = process(sen2)

  t = takemean(obs)
 
  bdlon = -95.
  bdlat = 35.

;  idnw = where(calc.lon le bdlon and calc.lat gt bdlat and calc.lon gt -130.)
;  idne = where(calc.lon gt bdlon and calc.lat gt bdlat )
;  idsw = where(calc.lon le bdlon and calc.lat le bdlat and calc.lon gt -130. and calc.lat gt 20.)
;  idse = where(calc.lon gt bdlon and calc.lat le bdlat and calc.lat gt 20.)

  idnw = where(obs.lon le bdlon and obs.lat gt bdlat and obs.lon gt -130.)
  idne = where(obs.lon gt bdlon and obs.lat gt bdlat )
  idsw = where(obs.lon le bdlon and obs.lat le bdlat and obs.lon gt -130. and obs.lat gt 20.)
  idse = where(obs.lon gt bdlon and obs.lat le bdlat and obs.lat gt 20.)

  format = '(5x,4(1x,4F5.2))'

  print, 'improve(2001)'
  print, mean(t.so4[idnw]), mean(t.so4[idsw]), mean(t.so4[idne]), mean(t.so4[idse]), $
         mean(t.nit[idnw]), mean(t.nit[idsw]), mean(t.nit[idne]), mean(t.nit[idse]), $
         mean(t.ec[idnw]),  mean(t.ec[idsw]),  mean(t.ec[idne] ), mean(t.ec[idse] ), $
         mean(t.omc[idnw]), mean(t.omc[idsw]), mean(t.omc[idne]), mean(t.omc[idse]), $
         format=format

  print, 'baseline (2001)'
  print, mean(a.so4[idnw]), mean(a.so4[idsw]), mean(a.so4[idne]), mean(a.so4[idse]), $
         mean(a.nit[idnw]), mean(a.nit[idsw]), mean(a.nit[idne]), mean(a.nit[idse]), $
         mean(a.ec[idnw]), mean(a.ec[idsw]),   mean(a.ec[idne] ), mean(a.ec[idse] ), $
         mean(a.omc[idnw]), mean(a.omc[idsw]), mean(a.omc[idne]), mean(a.omc[idse]), $
         format=format

  print, 'background'   
  print, mean(b.so4[idnw]), mean(b.so4[idsw]), mean(b.so4[idne]), mean(b.so4[idse]), $
         mean(b.nit[idnw]), mean(b.nit[idsw]), mean(b.nit[idne]), mean(b.nit[idse]), $
         mean(b.ec[idnw]), mean(b.ec[idsw]),   mean(b.ec[idne] ), mean(b.ec[idse] ), $
;         mean(b.omc[idnw]), mean(b.omc[idsw]), mean(b.omc[idne]), mean(b.omc[idse]), $
         mean(b.poa[idnw])+mean(a.soa[idnw]),  mean(b.poa[idsw])+mean(a.soa[idsw]), $
         mean(b.poa[idne])+mean(a.soa[idne]),  mean(b.poa[idse])+mean(a.soa[idse]), $
         format=format

  print, 'natural'      
  print, mean(c.so4[idnw]), mean(c.so4[idsw]), mean(c.so4[idne]), mean(c.so4[idse]), $
         mean(c.nit[idnw]), mean(c.nit[idsw]), mean(c.nit[idne]), mean(c.nit[idse]), $
         mean(c.ec[idnw]),  mean(c.ec[idsw]),  mean(c.ec[idne] ), mean(c.ec[idse] ), $
;         mean(c.omc[idnw]), mean(c.omc[idsw]), mean(c.omc[idne]), mean(c.omc[idse]), $
         mean(c.poa[idnw])+mean(a.soa[idnw]),  mean(c.poa[idsw])+mean(a.soa[idsw]), $
         mean(c.poa[idne])+mean(a.soa[idne]),  mean(c.poa[idse])+mean(a.soa[idse]), $
         format=format

  print, 'canada and mexico'
  print, mean(b.so4[idnw])-mean(d.so4[idnw]), mean(b.so4[idsw])-mean(d.so4[idsw]), $
         mean(b.so4[idne])-mean(d.so4[idne]), mean(b.so4[idse])-mean(d.so4[idse]), $
         mean(b.nit[idnw])-mean(d.nit[idnw]), mean(b.nit[idsw])-mean(d.nit[idsw]), $
         mean(b.nit[idne])-mean(d.nit[idne]), mean(b.nit[idse])-mean(d.nit[idse]), $
         mean(b.ec[idnw])-mean(d.ec[idnw]), mean(b.ec[idsw])-mean(d.ec[idsw]), $
         mean(b.ec[idne])-mean(d.ec[idne]), mean(b.ec[idse])-mean(d.ec[idse]), $
         mean(b.omc[idnw])-mean(d.omc[idnw]), mean(b.omc[idsw])-mean(d.omc[idsw]), $
         mean(b.omc[idne])-mean(d.omc[idne]), mean(b.omc[idse])-mean(d.omc[idse]), $
         format=format

  print, 'Asia'
  print, mean(d[idnw].so4)-mean(c.so4[idnw]), mean(d.so4[idsw])-mean(c.so4[idsw]), $
         mean(d[idne].so4)-mean(c.so4[idne]), mean(d.so4[idse])-mean(c.so4[idse]), $
         mean(d.nit[idnw])-mean(c.nit[idnw]), mean(d.nit[idsw])-mean(c.nit[idsw]), $
         mean(d.nit[idne])-mean(c.nit[idne]), mean(d.nit[idse])-mean(c.nit[idse]), $
         mean(d.ec[idnw])-mean(c.ec[idnw]), mean(d.ec[idsw])-mean(c.ec[idsw]), $
         mean(d.ec[idne])-mean(c.ec[idne]), mean(d.ec[idse])-mean(c.ec[idse]), $
         mean(d.omc[idnw])-mean(c.omc[idnw]), mean(d.omc[idsw])-mean(c.omc[idsw]), $
         mean(d.omc[idne])-mean(c.omc[idne]), mean(d.omc[idse])-mean(c.omc[idse]), $
         format=format

  end

;==================================================================================

  pro value2, obs, std, sen0, sen1, sen2


  a = process(std)
  b = process(sen0)
  c = process(sen1)
  d = process(sen2)

  t = takemean(obs)
 
  bdlon = -95.
  bdlat = 35.

  idw = where(obs.lon le bdlon and obs.lon gt -130.)
  ide = where(obs.lon gt bdlon and obs.lat gt   20.)

  format = '(5x,4(1x,2F5.2))'

  print, 'improve(2001)'
  print, mean(t.so4[idw]), mean(t.so4[ide]), $
         mean(t.nit[idw]), mean(t.nit[ide]), $
         mean(t.ec[idw]),  mean(t.ec[ide] ), $
         mean(t.omc[idw]), mean(t.omc[ide]), $
         format=format

  print, 'baseline (2001)'
  print, mean(a.so4[idw])+mean(a.nh4[idw])-mean(a.nit[idw])*0.29, $
         mean(a.so4[ide])+mean(a.nh4[ide])-mean(a.nit[ide])*0.29, $
         mean(a.nit[idw])*1.29, $
         mean(a.nit[ide])*1.29, $
         mean(a.ec[idw]),       $
         mean(a.ec[ide]),       $
         mean(a.omc[idw]),      $
         mean(a.omc[ide]), $
         format=format

  print, 'background'   
  print, mean(b.so4[idw])+mean(b.nh4[idw])-mean(b.nit[idw])*0.29, $
         mean(b.so4[ide])+mean(b.nh4[ide])-mean(b.nit[ide])*0.29, $               
         mean(b.nit[idw])*1.29, $
         mean(b.nit[ide])*1.29, $               
         mean(b.ec[idw]),       $
         mean(b.ec[ide]),       $            
         mean(b.omc[idw]),      $
         mean(b.omc[ide]),      $
         format=format

  print, 'natural'      
  print, mean(c.so4[idw])+mean(c.nh4[idw])-mean(c.nit[idw])*0.29, $
         mean(c.so4[ide])+mean(c.nh4[ide])-mean(c.nit[ide])*0.29, $
         mean(c.nit[idw])*1.29,  $
         mean(c.nit[ide])*1.29,  $
         mean(c.ec[idw]),        $
         mean(c.ec[ide]),        $
         mean(c.omc[idw]),       $
         mean(c.omc[ide]),       $
         format=format

  print, 'canada and mexico'
  print, (mean(b.so4[idw])-mean(d.so4[idw])) +     $
         (mean(b.nh4[idw])-mean(d.nh4[idw])) -     $
         (mean(b.nit[idw])-mean(d.nit[idw]))*0.29, $
         (mean(b.so4[ide])-mean(d.so4[ide])) + $
         (mean(b.nh4[ide])-mean(d.nh4[ide])) - $
         (mean(b.nit[ide])-mean(d.nit[ide]))*0.29, $
         (mean(b.nit[idw])-mean(d.nit[idw]))*1.29, $
         (mean(b.nit[ide])-mean(d.nit[ide]))*1.29, $
         mean(b.ec[idw]) -mean(d.ec[idw]),  $
         mean(b.ec[ide]) -mean(d.ec[ide]),  $
         mean(b.poa[idw])-mean(d.poa[idw]), $
         mean(b.poa[ide])-mean(d.poa[ide]), $
         format=format

  print, 'Asia'
  print, (mean(d.so4[idw])-mean(c.so4[idw])) + $
         (mean(d.nh4[idw])-mean(c.nh4[idw])) - $
         (mean(d.nit[idw])-mean(c.nit[idw]))*0.29, $

         (mean(d.so4[ide])-mean(c.so4[ide])) + $
         (mean(d.nh4[ide])-mean(c.nh4[ide])) - $
         (mean(d.nit[ide])-mean(c.nit[ide]))*0.29, $

         (mean(d.nit[idw])-mean(c.nit[idw]))*1.29, $
         (mean(d.nit[ide])-mean(c.nit[ide]))*1.29, $
         mean(d.ec[idw])-mean(c.ec[idw]),   $
         mean(d.ec[ide])-mean(c.ec[ide]),   $
         mean(d.poa[idw])-mean(c.poa[idw]), $
         mean(d.poa[ide])-mean(c.poa[ide]), $
         format=format

  end


  pro value3, obs, std, sen0, sen1, sen2


  a = process(std)
  b = process(sen0)
  c = process(sen1)
  d = process(sen2)

  t = takemean(obs)
 
  bdlon = -95.
  bdlat = 35.

  idw = where(obs.lon le bdlon and obs.lon gt -130.)
  ide = where(obs.lon gt bdlon and obs.lat gt   20.)

  format = '(5x,4(1x,2F5.2))'

  print, 'improve(2001)'
  print, mean(t.so4[idw]), mean(t.so4[ide]), $
         mean(t.nit[idw]), mean(t.nit[ide]), $
         mean(t.ec[idw]),  mean(t.ec[ide] ), $
         mean(t.omc[idw]), mean(t.omc[ide]), $
         format=format

  print, 'baseline (2001)'
  print, mean(a.so4[idw])+mean(a.nh4[idw])-mean(a.nit[idw])*0.29, $
         mean(a.so4[ide])+mean(a.nh4[ide])-mean(a.nit[ide])*0.29, $
         mean(a.nit[idw])*1.29, $
         mean(a.nit[ide])*1.29, $
         mean(a.ec[idw]),       $
         mean(a.ec[ide]),       $
         mean(a.omc[idw]),      $
         mean(a.omc[ide]), $
         format=format

  print, 'background'   
  print, mean(b.so4[idw])+mean(b.nh4[idw])-mean(b.nit[idw])*0.29, $
         mean(b.so4[ide])+mean(b.nh4[ide])-mean(b.nit[ide])*0.29, $               
         mean(b.nit[idw])*1.29, $
         mean(b.nit[ide])*1.29, $               
         mean(b.ec[idw]),       $
         mean(b.ec[ide]),       $            
         mean(b.poa[idw])+mean(a.soa[idw]),      $
         mean(b.poa[ide])+mean(a.soa[ide]),      $
         format=format

  print, 'natural'      
  print, mean(c.so4[idw])+mean(c.nh4[idw])-mean(c.nit[idw])*0.29, $
         mean(c.so4[ide])+mean(c.nh4[ide])-mean(c.nit[ide])*0.29, $
         mean(c.nit[idw])*1.29,  $
         mean(c.nit[ide])*1.29,  $
         mean(c.ec[idw]),        $
         mean(c.ec[ide]),        $
         mean(c.poa[idw])+mean(a.soa[idw]),       $
         mean(c.poa[ide])+mean(a.soa[ide]),       $
         format=format

  print, 'canada and mexico'
  print, (mean(b.so4[idw])-mean(d.so4[idw])) +     $
         (mean(b.nh4[idw])-mean(d.nh4[idw])) -     $
         (mean(b.nit[idw])-mean(d.nit[idw]))*0.29, $
         (mean(b.so4[ide])-mean(d.so4[ide])) + $
         (mean(b.nh4[ide])-mean(d.nh4[ide])) - $
         (mean(b.nit[ide])-mean(d.nit[ide]))*0.29, $
         (mean(b.nit[idw])-mean(d.nit[idw]))*1.29, $
         (mean(b.nit[ide])-mean(d.nit[ide]))*1.29, $
         mean(b.ec[idw]) -mean(d.ec[idw]),  $
         mean(b.ec[ide]) -mean(d.ec[ide]),  $
         mean(b.poa[idw])-mean(d.poa[idw]), $
         mean(b.poa[ide])-mean(d.poa[ide]), $
         format=format

  print, 'Asia'
  print, (mean(d.so4[idw])-mean(c.so4[idw])) + $
         (mean(d.nh4[idw])-mean(c.nh4[idw])) - $
         (mean(d.nit[idw])-mean(c.nit[idw]))*0.29, $

         (mean(d.so4[ide])-mean(c.so4[ide])) + $
         (mean(d.nh4[ide])-mean(c.nh4[ide])) - $
         (mean(d.nit[ide])-mean(c.nit[ide]))*0.29, $

         (mean(d.nit[idw])-mean(c.nit[idw]))*1.29, $
         (mean(d.nit[ide])-mean(c.nit[ide]))*1.29, $
         mean(d.ec[idw])-mean(c.ec[idw]),   $
         mean(d.ec[ide])-mean(c.ec[ide]),   $
         mean(d.poa[idw])-mean(c.poa[idw]), $
         mean(d.poa[ide])-mean(c.poa[ide]), $
         format=format

  end

;===========================================================================

  pro westeast, fld, gridinfo=gridinfo

    west = 0. & iw = 0.
    east = 0. & ie = 0.

    For J = 0, gridinfo.jmx-1L do begin
    For I = 0, gridinfo.imx-1L do begin
      if fld[i,j] gt 0. and gridinfo.ymid[j] gt 20. then begin
         if gridinfo.xmid[I] le -95. then begin
            west = west + fld[i,j]
            iw   = iw + 1.
         end else begin
            east = east + fld[i,j]
            ie   = ie + 1.
         end
      end
    end
    end

   print, west/iw, east/ie
   print, iw, ie

  end

;===========================================================================

  Year   = 2001L
  RES    = 1
  TYPE   = 'T' ; 'A', 'S', 'T'
  YYMM   = Year*100L + Lindgen(12)+1L
  MTYPE  = 'GEOS3_30L'
  CATEGORY = 'IJ-24H-$'

  Comment = '1x1 Nested NA run for 2001'
;  Comment = 'Cooke et al. emission'

  FAC  = 1.
 ;=========================================================================;
  CASE RES of
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

 @define_plot_size

  Modelinfo = CTM_TYPE(MTYPE, RES=RES)
  Gridinfo  = CTM_GRID(MODELINFO)

  tracer = [27,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]

; Observations are in ug/m3
  if N_elements(improve_Obs) eq 0 then $
     improve_Obs  = improve_datainfo(year=Year)

  if N_elements(STD) eq 0 then begin

     file = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/STDNEW_2001_01-12.1x1.bpch'
     read_model, file, CATEGORY, YYMM=YYMM, Modelinfo=Modelinfo, $
                 calc=STD,   obs=Improve_obs,  Tracer=Tracer

     file = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/NOUSNEW_2001_01-12.1x1.bpch'
     read_model, file, CATEGORY, YYMM=YYMM, Modelinfo=Modelinfo, $
                 calc=SEN0,   obs=Improve_obs,  Tracer=Tracer

     file = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/NATURAL_2001_01-12.1x1.bpch'
     read_model, file, CATEGORY, YYMM=YYMM, Modelinfo=Modelinfo, $
                 calc=SEN1,   obs=Improve_obs,  Tracer=Tracer

     file = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/NONA_2001_01-12.1x1.bpch'
     read_model, file, CATEGORY, YYMM=YYMM, Modelinfo=Modelinfo, $
                 calc=SEN2,   obs=Improve_obs,  Tracer=Tracer

  endif

;  values, Improve_obs, std, sen0, sen1, sen2
  print, '================================='
  value2, Improve_obs, std, sen0, sen1, sen2
  print, '================================='
  value3, Improve_obs, std, sen0, sen1, sen2
 End
