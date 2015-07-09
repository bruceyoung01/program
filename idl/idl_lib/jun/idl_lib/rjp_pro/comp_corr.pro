 function comp_corr, imp, specnames, month=month

 ; compute correlations between two species
  if n_elements(month)     eq 0 then return, -1
  if N_elements(specnames) ne 2 then return, -1
  specnames = strupcase(specnames)

  NAMES = tag_names(imp)
  N1    = where(NAMES eq specnames[0])
  N2    = where(NAMES eq specnames[1])

  if N1[0] eq -1 or N2[0] eq -1 then message, 'there is no matched species', specnames

  print, 'We compuate correlation coefficient between '+names[N1]+' and '+names[N2]
  title = 'R_'+strtrim(names[N1],2)+'_'+strtrim(names[N2],2)

     Jday = imp[0].jday
     mon  = jday2month(Jday)

     jj   = -1.
     For  N = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[N] ) ]
     jj   = jj[1:*]


     Results = Replicate( -999., 3, n_elements(imp) )

     For D = 0, N_elements(imp)-1 do begin

         stat = Replicate(-999., 3)
         Info = imp[D]

         X    = Info.(N1[0])[jj]  
         Y    = Info.(N2[0])[jj]  

         ; remove missing data
         p = where(x lt 0. or y lt 0., complement=c)

         if c[0] eq -1 then goto, jump
         if n_elements(c) le 1 then goto, jump

         X = X[c]
         Y = Y[c]        

         rma     = lsqfitgm(X, Y)
         stat[0] = rma[0]  ; slope
         stat[1] = rma[1]  ; const
         stat[2] = rma[2]  ; R

         p = where(finite(stat) eq 0)
         if p[0] ne -1 then stat[p] = -999.

         Results[*, D] = stat

         jump:         

     End

   return, {R:Reform(Results[2,*]), slope:Reform(Results[0,*]), $
            const:Reform(Results[1,*])}


 end

