; define colors
PRO loadcolors, bottom=bottom, names=names

;- copied from "Practical IDL Programing', by Liam Gumley
;
;- example:
;   IDL> loadcolors
;   IDL> x=findgen(200)*0.1
;   IDL> plot,x,sin(x),color=4

;- check arguments
IF (n_elements(bottom) EQ 0) THEN bottom=0

;- load graphics colors
red=[0,255,0,255,0,255,0,255,0,255,255,112,219,127,0,255]
grn=[0,0,255,255,255,0,0,255,0,187,127,219,112,127,163,171]
blu=[0,255,255,0,0,0,255,255,115,0,127,147,219,127,255,127]
tvlct,red,grn,blu

;- set color names
names=['black','magenta','cyan','yellow','green','red','blue','white', $
       'navy','gold','pink','aquamarine','orchid','gray','sky','beige']
end
; END of define colors
