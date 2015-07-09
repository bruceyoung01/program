  COMMON SHARE, SPEC, MAXD, MAXP

  if n_elements(obs) eq 0 then begin

    path = findfile('improve_data.sav', count=count)

    if count eq 1L then begin
       restore, filename='improve_data.sav'
       goto, skip
    end else begin

    obs    = get_improve_dayly()
    sim    = get_model_day_improve(res=1)
    bkg    = get_model_day_improve(res=11)
    nat    = get_model_day_improve(res=111)
    asi    = get_model_day_improve(res=1111)
    chi    = get_model_day_improve(res=11111)

    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    newnat = syncro( nat, obs )
    newasi = syncro( asi, obs )
    newchi = syncro( chi, obs )
    newobs = group( obs , ID=ID )

    ; reconstruct omc conentrations by replacing soa conc. with baseline soa
    omc    = sim.soa + bkg.poa
    bkg1   = bkg
    bkg1.omc = omc

    omc    = sim.soa + nat.poa
    nat1   = nat
    nat1.omc = omc

    omc    = sim.soa + nat.poa
    asi1   = asi
    asi1.omc = omc

    omc    = sim.soa + chi.poa
    chi1   = chi
    chi1.omc = omc

    ; reconstruct omc conentrations by replacing soa conc. with baseline soa
    omcbkg = newsim.soa + newbkg.poa
    newbkg1= newbkg
    newbkg1.omc = omcbkg

    omcnat = newsim.soa + newnat.poa
    newnat1= newnat
    newnat1.omc = omcnat

    omcasi = newsim.soa + newnat.poa
    newasi1= newasi
    newasi1.omc = omcasi

    omcchi = newsim.soa + newchi.poa
    newchi1= newchi
    newchi1.omc = omcchi

    save, filename='improve_data.sav', obs, sim, bkg, nat, asi, chi, $
          newobs, newsim, newbkg, newnat, newasi, newchi, $
          bkg1, nat1, asi1, chi1, newbkg1, newnat1, newasi1, newchi1

    end

    skip:

  endif

  Maxd   = 15.
  Maxp   = 12.
  maxval = 25.
;  minval = 1.

  ; South Eastern US sites with too much wet scavening
  e_bad1 = [13,25,99,35,77,93,114] ; south east coastal
  e_bad2 = [0,86,72,78]
  mapid  = e_bad1

  @define_plot_size
