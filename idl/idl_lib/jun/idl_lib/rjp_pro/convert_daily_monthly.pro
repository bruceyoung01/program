
function convert_daily_monthly, info


 jday = info[0].jday
 tag  = tag_names(info)

 for d = 0, n_elements(info)-1L do begin

    for n = 0, n_tags(info)-1 do begin
        fld = info[D].(n)

        if n_elements(fld) gt 1 then dat = daily2monthly( fld, jday ) $
        else dat = fld

        if n eq 0 then str = create_struct( tag[n], dat ) else $
                       str = create_struct( str, tag[n], dat )
     end

    if d eq 0 then newinfo = str else newinfo = [newinfo, str]

 end

 return, newinfo

end
