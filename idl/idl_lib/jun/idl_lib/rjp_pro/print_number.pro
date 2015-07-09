pro print_number, data, lon=lon, lat=lat, position=position, format=format

@define_plot_size

    if n_elements(data) ne n_elements(lon) then $
       message, 'data dimension should be eqaul to lon dimension'
    if n_elements(format) eq 0 then format='(F5.2)'

    idw = where(lon le -95., comple=ide)

    l_str = string(mean(data[idw],/nan),format=format)
    r_str = string(mean(data[ide],/nan),format=format)

    x = position[0]
    y = position[3]+0.01
    xyouts, x, y, l_str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = position[2]
    y = position[3]+0.01
    xyouts, x, y, r_str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

end

