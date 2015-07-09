  if n_elements(imp) eq 0 then begin

     path = findfile('icartt_data.sav', count=count)

     if count eq 1L then begin
        restore, filename='icartt_data.sav'
        goto, skip
     end else begin

        imp   = get_improve_daily( 2004L )
        imp   = knon( imp ) ; compute nonsoil potassium
        imp   = corr( imp, ['KNON','OMC'] )
        imp   = corr( imp, ['KNON','EC'] )
        imp   = corr( imp, ['KNON','CARB'] )
        imp   = corr( imp, ['EC','OMC'] )

        gc    = rd_gc('./geos_test/out_trop/*_daily.txt')
        gc    = sync( imp, gc )
        gc2   = rd_gc('./geos_test/out_nofire/*_daily.txt' )
        gc2   = sync( imp, gc2 )

        save, filename='icartt_data.sav', imp, gc, gc2

     end

  skip: imp_m = month_mean( imp )

  end
