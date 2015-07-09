function rdavg_mflux,dd=dd,mmmyy=mmmyy

if n_elements(dd) eq 0 then dd = '~allen/data/geos/'
if n_elements(mmmyy) eq 0 then  mmmyy = 'jan90'

case mmmyy of
'jan90': syymmdd = 'b900101.900131'
'feb90': syymmdd = 'b900201.900228'
'jun90': syymmdd = 'b900601.900630'
'jul90': syymmdd = 'b900701.900731'
'aug90': syymmdd = 'b900801.900831'
'dec90': syymmdd = 'b901201.901231'
'jan91': syymmdd = 'b910101.910131'
'feb91': syymmdd = 'b910201.910228'
'jun91': syymmdd = 'b910601.910630'
'jul91': syymmdd = 'b910701.910731'
'aug91': syymmdd = 'b910801.910831'
'dec91': syymmdd = 'b911201.911231'
'jan92': syymmdd = 'b920101.920131'
'feb92': syymmdd = 'b920201.920229'
'jun92': syymmdd = 'b920601.920630'
'jul92': syymmdd = 'b920701.920731'
'aug92': syymmdd = 'b920801.920831'
'dec92': syymmdd = 'b921201.921231'
else: print,'Please respecify desired month' 
endcase 

fd = fltarr(144,91,20)
dsn = 'e0054A.'+syymmdd+'.avg_mflux'

openr,ilun,dd+dsn,/xdr,/get_lun & readu,ilun,fd & free_lun,ilun 

fd = shift(fd,72,0,0) 
return, fd
end 
