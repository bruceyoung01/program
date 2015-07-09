 @define_plot_size

 if n_elements(bravo) eq 0 then begin

 bravofile = '/users/ctm/rjp/Data/emission_inventory/BRAVO/bravo_so2.bin'
 bravo = fltarr(360,181)

 openr, il, bravofile, /get
 readu, il, bravo
 free_lun, il

 end

ModelInfo = CTM_TYPE('GEOS3',res=1)
 GridInfo = ctm_grid(ModelInfo)

; .r diag_sulf

 if n_elements(anthsrc) eq 0 then stop

 ; you need to first execute diag_sulfur for Mexican emission
   maxdata=136.
   mindata=0.

  if (!D.name eq 'PS') then $
    open_device, file='so2_mexico.ps', /landscape, /color, /ps
 
    multipanel, row=1, col=2, omargin=[0.05,0.3,0.1,0.2]
    margin = [0.02,0.,0.,0.]
    Limit = [10., -140., 60., -60.]

    i = where(xmid ge limit[1] and xmid le limit[3])
    j = where(ymid ge limit[0] and ymid le limit[2])

    tvmap, anthsrc[min(i):max(i),min(j):max(j)]*1.e-6, xmid[min(i):max(i)], $
           ymid[min(j):max(j)], /conti, /coast, /usa, /sample, $
           title='GEOS-CHEM (2001) 1.9 Tg S yr!u-1!n', $
           maxdata=maxdata, mindata=mindata, position=[0.,0.,1.,1.], margin=margin, $
           /countries, charthick=charthick, charsize=tcharsize

    plot_region, bravo*1.e-6, limit=limit, /conti, /sample, $
     title='BRAVO (1999): 1.3 Tg S yr!u-1!n', unit='ton S/yr', maxdata=maxdata, $
     mindata=mindata, /nogylabe, position=[0.,0.,1.,1.], margin=margin


 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom
 Ndiv   = 4
 Format = '(I3)'
 csfac  = 1.2
 unit  ='Gg S/yr'

  CBPosition = [ 0.20, 0.21, 0.80, 0.25 ]  
  ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

 if (!D.name eq 'PS') then close_device

 End
