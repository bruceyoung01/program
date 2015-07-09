
 function syncro, sim, obs

  tag = tag_names(sim[0])
  ntg = n_tags(sim[0])
  sot = Long(obs[0].jday)-1L

  For D = 0, N_elements(sim.siteid)-1 do begin

     info = sim[D]
     
     a_str = create_struct(tag[0],info.(0), $
                           tag[1],info.(1), $
                           tag[2],info.(2), $
                           tag[3],info.(3), $
                           'ID', D  )

     for n = 4, ntg-1 do begin
         d1    = info.(N)
         data  = d1(sot)
         a_str = create_struct(a_str, tag[N], data)
     end

     a_str = create_struct(a_str, 'FRHO', obs[D].frhgrid)
     if D eq 0 then newsim = a_str else newsim = [newsim, a_str]
  End

  return, newsim
 end
