; pro bar_plot 
; example in idl book
; author: bruce
; date: Nov 11, 2009

sites = fltarr(5)
years = string
; read data
; web sites
  sites = [20, 55, 102, 235, 350]
; years
  years = ['1995', '1996', '1997', '1998', '1999']
; plot image
  window, xsize = 600, ysize = 400
  xtitle = 'Year'
  ytitle = 'Number of sites'
  title = 'IDL Web Sites Worldwide'

  bar_plot, sites, $
            barnames = years, colors = [1, 2, 3, 4, 5],$
            title = title, xtitile = xtitle, ytitle = ytitle, /outline
  

  end
