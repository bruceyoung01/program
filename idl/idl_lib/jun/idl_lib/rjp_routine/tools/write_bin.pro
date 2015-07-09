

pro write_bin,data,filename,_EXTRA=e

    ; save a 2-D data array into a binary file together with
    ; it's size info. Use read_bin.pro to read it.
    ;
    ; _EXTRA keyword may be useful to save files for workstation
    ; processing on a PC: /SWAP_ENDIAN

    if (n_elements(data) eq 0) then return

    if (size(data,/N_Dimensions) ne 2) then begin
       message,'Data not 2-dimensional!',/Continue
       return
    endif

    if (N_elements(filename) eq 0) then $
        filename = '*'

    open_file,filename,olun,/WRITE,/F77_UNFORMATTED,_EXTRA=e, $
             title='Choose a filename for output'


    if (olun le 0) then return


    ; print dimensions, then write data
    s = size(Data,/Dimensions)

    writeu,olun,long(s)

    writeu,olun,float(data)

    free_lun,olun

    return
end

