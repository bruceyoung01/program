
 if N_elements(mdat) eq 0 then begin

    restore, filename='./datasav/nsk_ibf.sav'
    restore, filename='./datasav/monthly_2001-2004.sav' ; mdat
    restore, filename='./datasav/daily_2001-2004.sav'   ; dat014

  end

  @define_plot_size

  multipanel, col=2, row=1 
  Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.35,0.35], $
        xgap=0.02,ygap=0.02,order=0)


  if !D.name eq 'PS' then $
    open_device, file='nsk_bkgn.ps', /color, /ps, /landscape

  print, quantile(nsk_ibf,[0.1,0.5,0.9])
  comment = ' '
  data    = nsk_ibf
  nogylabel=0
  meanvalue=1
  CBFormat = '(F5.3)'
  mindata  = 0.
  maxdata  = 0.04
  ndiv     = 5

  position = pos[*,0]
  mapplot, data, mdat, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, $
   meanvalue=meanvalue

  c_shift = 0
  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom
  UNIT   = '!4l!3g m!u-3!n'
  CBFormat = '(F5.2)'
  CBPosition = [0.15,0.26,0.45,0.31]
     ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,        $
       	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition,   $
       	   Unit=Unit,       Divisions=Ndiv, Log=Log,               $
	         Format=CBFormat, Charsize=csfac,                        $
    	         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

  if !D.name eq 'PS' then close_device

End
