
 function knon, imp

; compute nonsoil potassium from biomass burning emissions
; make carb array including both OC and EC

      For D = 0, N_elements(imp)-1 do begin

         Info = imp[D]

         X    = Info.K         ; potassium
         Z    = Info.FE        ; Iron
         KNON = Replicate(-999., N_elements(X)); nonsoil potassium

         ; remove missing data
         p = where(x lt 0. or z lt 0., complement=c)

         if c[0] eq -1 then goto, jump

         KNON[c] = X[c] - (0.6*Z[c])  ; nonsoil potassium from fires

         jump:

         ; Make carb array
         EC   = Info.EC
         OMC  = Info.OMC
         ; remove missing data
         p = where(EC lt 0. or OMC lt 0., complement=c)
         if c[0] eq -1 then goto, jump1

         CARB    = Replicate(-999., N_elements(EC)); Carbonaceous aerosols
         CARB[c] = EC[c] + OMC[c]/1.4

         jump1:
         NewInfo = create_struct(Info, 'KNON', KNON, 'CARB', CARB)

         If D eq 0 then Newimp = Newinfo else Newimp = [Newimp, Newinfo]
     End

;  newimp = corr( newimp, ['KNON','OMC'] )
;  newimp = corr( newimp, ['KNON','EC'] )
;  newimp = corr( newimp, ['EC','OMC'] )

 return, newimp

 end
