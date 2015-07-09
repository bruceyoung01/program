pro mass, file, time=time, gas=gas

if n_elements(file) eq 0 then  file = pickfile()
if n_elements(time) eq 0 then return
if n_elements(gas) eq 0 then gas = 'o3'

graph = 'X'
start = 1

if (start eq 1) then begin
 ser = cmass(file,gas,mdiff=mdiff,time=time,burden=burden)
endif

dB = burden(time-1)-burden(0)
dTe = ser(time-1,1)
dTg = ser(time-1,2)
dTc = ser(time-1,3)
dTcv = dB - (dTg+dTe+dTc)

print, dB,dTe,dTc,dTg,dTcv

if (graph eq 'ps') then begin
set_plot, 'ps'
device, file=gas+'mass3.ps', xoffset=1.5, yoffset=1.5, xsize= 18, ysize = 24,/color
end

!p.multi = [0,1,2]

plot, ser(*,2), line=0,title='The accumulated changes in mass due to each process , '+gas, xtitle='time/hour', ytitle='Mass/Tg'

for i = 0 , 3 do begin
; oplot, ser(*,i), line=i+1
end

; oplot, ser(*,0), line=1

 oplot, [30,50,70],[150.,150.,150], line=0
 oplot, [30,50,70],[130.,130.,130], line=1
 xyouts, 100, 150, 'HORIZONTAL TRANSPORT'
 xyouts, 100, 130, 'CHAGE IN Meteorology'

; x = findgen(1,time-100)+100 & y = mdiff(100:*,1) & w = replicate(1.0,n_elements(y))
; reg = regress(x,y,w,yfit,const,/relative_weight)

 plot, mdiff(*,2), line=0,title='The changes in mass due to each process , '+gas, xtitle='time/hour',ytitle='Mass/Tg'

;for i = 0 , 4 do begin
; oplot, mdiff(*,i), psym=i
;end

; oplot, mdiff(*,0), line=1
; oplot, x, reform(yfit), line=2


if(graph eq 'ps') then begin
device,/close
set_plot,'X'
end

end
