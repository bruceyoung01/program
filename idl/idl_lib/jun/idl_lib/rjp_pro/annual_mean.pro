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

; file = '/users/ctm/rjp/Asim/run_v7-02-01_NA_nested_1x1/no_us_run/OUTPUT/IJ-24H_2001_01-12.1x1_bkgn.bpch'
; file = '/users/ctm/rjp/Asim/run_v7-02-01_NA_nested_1x1/natural_run/OUTPUT/IJ-24H_2001_01-12.1x1_nat.bpch'

 if n_elements(file) eq 0 then $
    file = pickfile(filter = '/users/ctm/rjp/Asim/run_v7-02-01_NA_nested_1x1/' )

 tracer = [27,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]

 spec = 'SOA'

 if n_elements(calc) eq 0 then $
 calc = readmodel_mass(file,category,tracer=tracer,YYMM=YYMM,$
                       modelinfo=modelinfo)

 case spec of 
  'SO4' : begin
           conc = calc.so4_conc*96.
           maxdata = 8.
          end
  'NO3' : begin
           conc = calc.nit_conc*62.
           maxdata = 4.
          end
  'NH4' : begin
           conc = calc.nh4_conc*18.
          end
  'SOA' : begin
          conc  = (calc.soa1_conc)*150.                   $
                + (calc.soa2_conc)*160.                   $
                + (calc.soa3_conc)*220.
          maxdata=8.
          end
  'OMC' : begin          
           conc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 $
                + (calc.soa1_conc)*150.                   $
                + (calc.soa2_conc)*160.                   $
                + (calc.soa3_conc)*220.
           soa  = (calc.soa1_conc)*150.                   $
                + (calc.soa2_conc)*160.                   $
                + (calc.soa3_conc)*220.
          maxdata=8.
          end
  'DUST': begin
           conc = (calc.dst1_conc + calc.dst2_conc*0.38)*29.
           maxdata = 8.
          end
  'SEA-SALT' : begin
           conc = calc.sala_conc*36.
           maxdata = 2.
          end
  'EC'  : begin
           conc = (calc.ecpi_conc + calc.ecpo_conc)*12.
           maxdata = 2.
          end
 end

  dim = size(conc)
  if dim[0] eq 3 then $
     conc = total(conc,3)/float(n_elements(calc.time))

  fld = fltarr(gridinfo.imx, gridinfo.jmx)  
  x1 = calc.first[0]
  x2 = x1 + dim[1] - 1L
  y1 = calc.first[1]
  y2 = y1 + dim[2] - 1L

  fld[x1:x2,y1:y2] = conc
  fld = region_only(fld, region='US')

  figfile = SPEC+'_conc_1x1.ps'

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape

;  tvmap, conc, calc.xmid, calc.ymid, /coast, /usa, /cbar, divis=4, /sample,$
;    charsize=charsize, charthick=charthick, title=spec

;  tvmap, fld, /coast, /usa, /cbar, divis=4, /sample,$
;    charsize=charsize, charthick=charthick, title=spec

   limit =[10.,-140., 60., -40.]
   plot_region, fld, /sample, /cbar, divis=5, title=spec, $
     maxdata=maxdata, limit=limit, mindata=0., cbformat='(F3.1)'

   westeast, fld, gridinfo=gridinfo

  if !D.name eq 'PS' then close_device

 End
