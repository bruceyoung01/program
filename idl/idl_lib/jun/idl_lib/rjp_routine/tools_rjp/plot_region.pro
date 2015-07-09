
 pro plot_region, fd2d, Modelinfo=Modelinfo, Gridinfo=Gridinfo, limit=limit,$
                  mindata=mindata,maxdata=maxdata,$
                  Unit=Unit,title=title,xtitle=xtitle,ytitle=ytitle,$
                  divis=ndiv,isotropic=isotropic,min_valid=min_valid,$
                  margin=margin,contour=contour,c_levels=c_levels,$
                  Nlevels=Nlevels,fcontour=fcontour,cbar=cbar,$
                  sample=sample, cbposition=cbposition,$
                  cbformat=cbformat,csfac=csfac,ncolors=ncolors, $
                  tcsfac=tcsfac, NoGYLabels=NoGYLabels, NoGXLabels=NoGXLabels, $
                  position=position, c_labels=c_labels, NoLabels=NoLabels, $
                  c_colors=c_colors, continents=continents, rjpmap=rjpmap, $
                  Data=Data, Log=Log, charthick=charthick, noadvance=noadvance
            

 If N_elements(fd2d) eq 0 then return
 If N_elements(xarr) eq 0 then begin
    dim = size(fd2d,/dim)
    Case dim[1] of
       181 : ModelInfo = CTM_TYPE('GEOS3',res=1)
       180 : ModelInfo = CTM_Type('generic',Res=[1.0, 1.0],HalfPolar=0,Center180=0)
       91  : ModelInfo = CTM_TYPE('GEOS3',res=2)
       46  : ModelInfo = CTM_TYPE('GEOS3',res=4)
       51  : begin
             ModelInfo = CTM_TYPE('GEOS3',res=1)
             temp = fltarr(360,181)
             temp[40:140, 100:150] = fd2d[*,*]
             FD2D = temp
             end
       else: begin
	       we = 360./float(dim[0])
		 ns = 180./float(dim[1])
		 Modelinfo = CTM_TYPE('generic',res=[we, ns],Halfpolar=0.,center180=0)
		 end
    Endcase         
 Endif

    GridInfo = ctm_grid(ModelInfo)

 If N_elements(limit) eq 0  then limit = [20., -130., 55., -60.]

  CTM_INDEX,Modelinfo,I,J,edge=limit, $
          WE_INDEX=we, SN_INDEX=sn,/non_interactive

;  i1 = min(we)
;  i2 = max(we)
;  j1 = min(sn)
;  j2 = max(sn)

   DATA = fltarr(N_elements(we), N_elements(sn))
   Xarr = fltarr(N_elements(we))
   Yarr = fltarr(N_elements(sn))


   For J = 0, N_elements(sn)-1 Do begin
   For I = 0, N_elements(we)-1 Do begin
      X = WE[I]
      Y = SN[J]
      DATA[I,J] = FD2D[X,Y]
      XARR[I]   = Gridinfo.xmid[X]
      If (Limit[3] lt Limit[1]) and (XARR[I] le 0.) then XARR[I] = XARR[I] + 360.
      YARR[J]   = Gridinfo.ymid[Y]
   End
   End


@define_plot_size

  If Keyword_set(fcontour) then begin

  Tvmap, DATA, Xarr, Yarr, $
         /countries,/coasts,/usa, $
         xstyle=1,ystyle=1,mindata=mindata,maxdata=maxdata,$
         Unit=Unit,title=title,xtitle=xtitle,ytitle=ytitle,$
         isotropic=isotropic,min_valid=min_valid,margin=margin, $
         /Fcontour, C_thick=thick, $
         C_levels=C_levels, Nlevels=Nlevels, $ 
         C_charsize=charsize, C_charthick=charthick, csfac=csfac, $
         tcsfac=tcsfac, NoGYLabels=NoGYLabels, NoGXLabels=NoGXLabels, $
         position=position, cbar=cbar, NoLabels=NoLabels, $
         c_colors=c_colors, cbformat=cbformat, charthick=charthick, noadvance=noadvance

  end else if Keyword_set(contour) then begin

  Tvmap, DATA, Xarr, Yarr, $
         /countries,/coasts,/usa, $
         xstyle=1,ystyle=1,mindata=mindata,maxdata=maxdata,$
         Unit=Unit,title=title,xtitle=xtitle,ytitle=ytitle,$
         isotropic=isotropic,min_valid=min_valid,margin=margin, $
         /contour, /C_LINES, C_thick=C_thick, $
         C_levels=C_levels, Nlevels=Nlevels, $ 
         C_charsize=charsize, C_charthick=charthick,$
         C_colors=1, tcsfac=tcsfac, NoGYLabels=NoGYLabels, $
         NoGXLabels=NoGXLabels, position=position, charthick=charthick, noadvance=noadvance

  end else if Keyword_set(rjpmap) then begin

  rjpmap, DATA, Xarr, Yarr, $
         /countries,/coasts,divis=ndiv,/usa, $
         xstyle=1,ystyle=1,mindata=mindata,maxdata=maxdata,$
         Unit=Unit,title=title,xtitle=xtitle,ytitle=ytitle,$
         isotropic=isotropic,min_valid=min_valid,margin=margin,$
         sample=sample,cbposition=cbposition,$
         cbformat=cbformat,csfac=csfac,ncolors=ncolors, tcsfac=tcsfac, $
         NoGYLabels=NoGYLabels, NoGXLabels=NoGXLabels, position=position, $
         charthick=charthick, noadvance=noadvance

  end else begin

  Tvmap, DATA, Xarr, Yarr, $
         /countries,/coasts,divis=ndiv,/usa, $
         xstyle=1,ystyle=1,mindata=mindata,maxdata=maxdata,$
         Unit=Unit,title=title,xtitle=xtitle,ytitle=ytitle,$
         isotropic=isotropic,min_valid=min_valid,margin=margin,$
         cbar=cbar,sample=sample,cbposition=cbposition,$
         cbformat=cbformat,csfac=csfac,ncolors=ncolors, tcsfac=tcsfac, $
         NoGYLabels=NoGYLabels, NoGXLabels=NoGXLabels, position=position, $
         Log=Log, charthick=charthick, noadvance=noadvance
  end


 End
