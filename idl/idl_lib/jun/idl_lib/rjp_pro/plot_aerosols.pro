 pro ann_stat, data, str
 
 ; data structure should be [48,134]  = [months,sites]

    lon = str.lon
    idw = where(lon le -95.)
    ide = where(lon gt -95.) 

    wval = fltarr(4)
    eval = wval

   For D = 0, 3 do begin
     pb = D * 12
     pe = pb + 11

     samp    = reform(data[pb:pe,*])
     fld     = composite(samp)
     wval[d] = mean(fld.mean[idw],/nan)
     eval[d] = mean(fld.mean[ide],/nan)

   End

   print, mean(wval), stddev(wval), '  west'
   print, mean(eval), stddev(eval), '  east'

 end

;===========================================================

 pro plot2d, month, str, specname, pos=pos, cbar=cbar, $
     mindata=mindata, maxdata=maxdata, cbformat=cbformat, $
     nogxlabel=nogxlabel, nogylabel=nogylabel, comment=comment, $
     meanvalue=meanvalue, title=title

  specname = strupcase(specname)
  NAMES    = tag_names(str)
  N        = where(NAMES eq specname)

  if N eq -1 then message, 'there is no matched species', specname

  Jday = str[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For D = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[D] ) ]
  jj   = jj[1:*]

  data = str.(N)[jj]
  
  ann_stat, data, str

  data = composite(data)
  fld  = data.mean

  mapplot, fld, str, mindata=mindata, maxdata=maxdata, pos=pos,  $
   cfac=cfac,cbformat=cbformat, comment=comment, title=title,    $
   discrete=discrete, ndiv=ndiv, cbar=cbar, nogxlabel=nogxlabel, $
   nogylabel=nogylabel, meanvalue=meanvalue

 end

;================================================================================


 @define_plot_size


 if N_elements(dat01) eq 0 then begin

    restore, filename='./datasav/nsk_ibf.sav'

    restore, filename='./datasav/daily_2001.sav'
    restore, filename='./datasav/daily_2002.sav'
    restore, filename='./datasav/daily_2003.sav'
    restore, filename='./datasav/daily_2004.sav'

    restore, filename='./datasav/monthly_2001-2004.sav'
  end

  multipanel, col=2, row=2 
  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.10,0.15], $
        xgap=0.02,ygap=0.15,order=0)

  annual   = indgen(12) + 1L

  specname = 'RCFM'
  position = pos[*,0]
  cbformat = '(F5.2)'
  mindata = 0. & maxdata = 3.
  cbar = 1 & meanvalue = 1 & title = specname
  plot2d, annual, mdat, specname, pos=position, cbar=cbar, $
     mindata=mindata, maxdata=maxdata,  cbformat=cbformat, $
     nogxlabel=nogxlabel, nogylabel=nogylabel, comment=comment, $
     meanvalue=meanvalue, title=title

  specname = 'AMMSO4'
  position = pos[*,1]
  cbformat = '(F5.2)'
  mindata = 0. & maxdata = 6. & title = specname
  cbar = 1 & meanvalue = 1 & nogylabel = 1
  plot2d, annual, mdat, specname, pos=position, cbar=cbar, $
     mindata=mindata, maxdata=maxdata,  cbformat=cbformat, $
     nogxlabel=nogxlabel, nogylabel=nogylabel, comment=comment, $
     meanvalue=meanvalue, title=title

  specname = 'AMMNO3'
  position = pos[*,2]
  cbformat = '(F5.2)'
  mindata = 0. & maxdata = 2. & title = specname
  cbar = 1 & meanvalue = 1 & nogylabel = 1
  plot2d, annual, mdat, specname, pos=position, cbar=cbar, $
     mindata=mindata, maxdata=maxdata,  cbformat=cbformat, $
     nogxlabel=nogxlabel, nogylabel=nogylabel, comment=comment, $
     meanvalue=meanvalue, title=title

  specname = 'SOIL'
  position = pos[*,3]
  cbformat = '(F5.2)'
  mindata = 0. & maxdata = 2. & title = specname
  cbar = 1 & meanvalue = 1 & nogylabel = 1
  plot2d, annual, mdat, specname, pos=position, cbar=cbar, $
     mindata=mindata, maxdata=maxdata,  cbformat=cbformat, $
     nogxlabel=nogxlabel, nogylabel=nogylabel, comment=comment, $
     meanvalue=meanvalue, title=title

End
