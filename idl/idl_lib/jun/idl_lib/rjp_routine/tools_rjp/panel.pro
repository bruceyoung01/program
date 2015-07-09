  Pro panel, num, landscape=landscape, title=title, xfrac=xfrac, yfrac=yfrac

  If N_elements(num) eq 0 then num=0
  If N_elements(xfrac) eq 0 then xfrac = 1.
  if N_elements(yfrac) eq 0 then yfrac = 1.

  Xsize = 582.*xfrac
  Ysize = 755.*yfrac

  If Keyword_set(landscape) then $
   window, num, xsize=Ysize, ysize=Xsize, title=title else $
   window, num, xsize=Xsize, ysize=Ysize, title=title 


  End
