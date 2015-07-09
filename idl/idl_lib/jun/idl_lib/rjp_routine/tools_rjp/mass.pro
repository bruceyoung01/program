pro mass, file, time=time, gas=gas

if n_elements(file) eq 0 then  file = pickfile()
if n_elements(time) eq 0 then return
if n_elements(gas) eq 0 then gas = 'O3'

graph = 'X'
start = 1


; 0 : dry deposition
; 1 : emission
; 2 : grid scale transport
; 3 : chemistry
; 4 : convection

if (start eq 1) then begin
 ser = cmass(file,gas,mdiff=mdiff,time=time,burden=burden)
endif

dB = burden(time-1)-burden(0)
dTd = ser(time-1,0)
dTe = ser(time-1,1)
dTg = ser(time-1,2)
dTc = ser(time-1,3)
dTcv = dB - (dTg+dTe+dTc+dTd)

print, dB,dTe,dTc,dTg,dTd,dTcv,burden(time-1)

if (graph eq 'ps') then begin
set_plot, 'ps'
device, file=gas+'mass3.ps', xoffset=1.5, yoffset=1.5, xsize= 18, ysize = 24,/color
end

!p.charsize=1.5
;!p.position = [0.1,0.1,0.9,0.9]
!p.multi = [0,1,4]

plot, ser(*,0), line=0, title='Dry deposition, '+gas, ytitle='Mass/Tg'

plot, ser(*,2), line=0,title='Grid scale transport, '+gas, xtitle='time/hour', $
 ytitle='Mass/Tg'
 
plot, ser(*,3), line=0,title='Chemistry, '+gas

plot, ser(*,4), line=0, title='convection, '+gas

;plot, mdiff(*,2), line=0,title='The changes in mass due to each process , '+gas, ;xtitle='time/hour',ytitle='Mass/Tg'

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
