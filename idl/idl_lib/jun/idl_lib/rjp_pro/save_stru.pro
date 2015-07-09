;==============================================================================

 function combine, dat01, dat02, dat03, dat04

  Tag   = Tag_names(dat01)

  ; LOOP OVER SITES
  For D = 0, n_elements(dat01)-1 do begin

    ; LOOP OVER TAGS
    For N = 0, N_tags(dat01)-1 do begin
        FLD = DAT01[D].(N)

        If n_elements(FLD) gt 1 then $
           FLD = [FLD, DAT02[D].(N), DAT03[D].(N), DAT04[D].(N)]

        IF (N EQ 0) THEN OUT = CREATE_STRUCT(TAG[N], FLD) ELSE $
        out = create_struct(out, TAG[N], FLD)
    END

    IF D EQ 0 THEN DAT = OUT ELSE DAT = [DAT, OUT]
  End


 return, DAT

 end


    restore, filename='daily_2001.sav'
    restore, filename='daily_2002.sav'
    restore, filename='daily_2003.sav'
    restore, filename='daily_2004.sav'

    restore, filename='monthly_2001.sav'
    restore, filename='monthly_2002.sav'
    restore, filename='monthly_2003.sav'
    restore, filename='monthly_2004.sav'

    dat   = combine(dat01,dat02,dat03,dat04)

    mdat  = combine(d1,d2,d3,d4)
  end
