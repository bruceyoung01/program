 function get_gfed2, CYEAR, mask=mask

    file = collect('/users/ctm/rjp/Data/DM_1997-2002/gfed2/*'+CYEAR+'*')
    data = fltarr(360,180,12) ; gC/m2

    if n_elements(mask) eq 0 then mask = replicate(1.,360,180)

    For d = 0, n_elements(file)-1 do begin
       ctm_get_data, datainfo, file=file[d]
       temp = *(datainfo.data)
       data[*,*,d] = temp * mask
       Undefine, datainfo
    End

    Undefine, file
    CTM_cleanup
    return, Data/0.45  ; gdm/m2

 end
