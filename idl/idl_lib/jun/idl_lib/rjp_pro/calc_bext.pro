  ; Light extinction from IMPROVE obs
  ammso4_bext = make_zero(obs.ammso4_bext, val='NaN')
  ammno3_bext = make_zero(obs.ammno3_bext, val='NaN')
  ec_bext     = make_zero(obs.ec_bext,     val='NaN')
  omc_bext    = make_zero(obs.omc_bext,    val='NaN')
  soil_bext   = make_zero(obs.soil_bext,   val='NaN')
  cm_bext     = make_zero(obs.cm_bext,     val='NaN')

  ; replace soil and cm contribution with EPA default
;  soil_bext[*,*] = 0.5
;  cm_bext[*,*]   = 1.8

  if n_elements(sim) ne 0 then begin

  ; Light extinction from GEOS-CHEM simulation at IMPROVE sites
  ammno3      = sim.nit*1.29
  ammso4      = sim.so4*1.375 ; +makevector(sim.nh4)-ammno3
  EC          = sim.ec
  OMC         = sim.omc
  SOIL        = sim.dst1 + sim.dst2*0.38
  CM          = sim.dst2*0.62 + sim.dst3 + sim.dst4
  sim_frh     = make_zero(sim.frho, val='NaN') ; observation

  ; Reconstructed light extinction
  rbext_ammso4 = 3.*sim_frh*ammso4
  rbext_ammno3 = 3.*sim_frh*ammno3
  rbext_omc    = 4.*omc
  rbext_ec     = 10.*ec
  rbext_soil   = soil
  rbext_cm     = 0.6*cm

  end

  if n_elements(bkg) ne 0 then begin

  ; Light extinction from GEOS-CHEM simulation at IMPROVE sites
  bkg_ammno3      = bkg.nit*1.29
  bkg_ammso4      = bkg.so4*1.375 ; +makevector(sim.nh4)-ammno3
  bkg_EC          = bkg.ec
  bkg_OMC         = bkg.omc
  bkg_SOIL        = bkg.dst1 + bkg.dst2*0.38
  bkg_CM          = bkg.dst2*0.62 + bkg.dst3 + bkg.dst4
  bkg_sim_frh     = make_zero(bkg.frho, val='NaN') ; observation

  ; Reconstructed light extinction
  bbext_ammso4 = 3.*bkg_sim_frh*bkg_ammso4
  bbext_ammno3 = 3.*bkg_sim_frh*bkg_ammno3
  bbext_omc    = 4.*bkg_omc
  bbext_ec     = 10.*bkg_ec
  bbext_soil   = bkg_soil
  bbext_cm     = 0.6*bkg_cm

  end

  if n_elements(nat) ne 0 then begin

  ; Light extinction from GEOS-CHEM simulation at IMPROVE sites
  nat_ammno3      = nat.nit*1.29
  nat_ammso4      = nat.so4*1.375 ; +makevector(sim.nh4)-ammno3
  nat_EC          = nat.ec
  nat_OMC         = nat.omc
  nat_SOIL        = nat.dst1 + nat.dst2*0.38
  nat_CM          = nat.dst2*0.62 + nat.dst3 + nat.dst4
  nat_sim_frh     = make_zero(nat.frho, val='NaN') ; observation

  ; Reconstructed light extinction
  nbext_ammso4 = 3.*nat_sim_frh*nat_ammso4
  nbext_ammno3 = 3.*nat_sim_frh*nat_ammno3
  nbext_omc    = 4.*nat_omc
  nbext_ec     = 10.*nat_ec
  nbext_soil   = nat_soil
  nbext_cm     = 0.6*nat_cm

  end


  if n_elements(asi) ne 0 then begin

  ; Light extinction from GEOS-CHEM simulation at IMPROVE sites
  asi_ammno3      = asi.nit*1.29
  asi_ammso4      = asi.so4*1.375 ; +makevector(sim.nh4)-ammno3
  asi_EC          = asi.ec
  asi_OMC         = asi.omc
  asi_SOIL        = asi.dst1 + asi.dst2*0.38
  asi_CM          = asi.dst2*0.62 + asi.dst3 + asi.dst4
  asi_sim_frh     = make_zero(asi.frho, val='NaN') ; observation

  ; Reconstructed light extinction
  abext_ammso4 = 3.*asi_sim_frh*asi_ammso4
  abext_ammno3 = 3.*asi_sim_frh*asi_ammno3
  abext_omc    = 4.*asi_omc
  abext_ec     = 10.*asi_ec
  abext_soil   = asi_soil
  abext_cm     = 0.6*asi_cm

  end

  if n_elements(chi) ne 0 then begin

  ; Light extinction from GEOS-CHEM simulation at IMPROVE sites
  chi_ammno3      = chi.nit*1.29
  chi_ammso4      = chi.so4*1.375 ; +makevector(sim.nh4)-ammno3
  chi_EC          = chi.ec
  chi_OMC         = chi.omc
  chi_SOIL        = chi.dst1 + chi.dst2*0.38
  chi_CM          = chi.dst2*0.62 + chi.dst3 + chi.dst4
  chi_sim_frh     = make_zero(chi.frho, val='NaN') ; observation

  ; Reconstructed light extinction
  cbext_ammso4 = 3.*chi_sim_frh*chi_ammso4
  cbext_ammno3 = 3.*chi_sim_frh*chi_ammno3
  cbext_omc    = 4.*chi_omc
  cbext_ec     = 10.*chi_ec
  cbext_soil   = chi_soil
  cbext_cm     = 0.6*chi_cm

  end

  ; Background - (no NA - natural) [intercontinental transport]
  int_so4 = bbext_ammso4 - (abext_ammso4 - nbext_ammso4)
  int_no3 = bbext_ammno3 - (abext_ammno3 - nbext_ammno3)
  int_omc = bbext_omc    - (abext_omc    - nbext_omc)
  int_ec  = bbext_ec     - (abext_ec     - nbext_ec)
  int_soil= soil_bext    
  int_cm  = cm_bext

  int_bext= int_so4+int_no3+int_omc+int_ec+int_soil+int_cm
  int_vis = chk_undefined(10. * Alog( (int_bext+10.) / 10. ))
  
  ; Background - (sim - no_asia) [Asian transport]
  trn_so4 = bbext_ammso4 - (rbext_ammso4 - cbext_ammso4)
  trn_no3 = bbext_ammno3 - (rbext_ammno3 - cbext_ammno3 )
  trn_omc = bbext_omc    - (rbext_omc    - cbext_omc)
  trn_ec  = bbext_ec     - (rbext_ec     - cbext_ec)
  trn_soil= soil_bext    
  trn_cm  = cm_bext

  trn_bext= trn_so4+trn_no3+trn_omc+trn_ec+trn_soil+trn_cm
  trn_vis = chk_undefined(10. * Alog( (trn_bext+10.) / 10. ))

  CASE SPEC OF
   'ALL4': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc
           chi_bext = cbext_ammso4+cbext_ammno3+cbext_ec+cbext_omc
           end
   '+SO4': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = ammso4_bext+rbext_ammno3+rbext_ec+rbext_omc
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc
           end
   '+NO3': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = rbext_ammso4+ammno3_bext+rbext_ec+rbext_omc
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc
           end
   '+IOA': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = ammso4_bext+ammno3_bext+rbext_ec+rbext_omc
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc
           end
   '+OMC': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = rbext_ammso4+rbext_ammno3+rbext_ec+omc_bext
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc
           end
   '+EC': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = rbext_ammso4+rbext_ammno3+ec_bext+rbext_omc
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc
           end
   'SO4' : begin
           obs_bext = ammso4_bext
           sim_bext = rbext_ammso4
           bkg_bext = bbext_ammso4
           nat_bext = nbext_ammso4
           asi_bext = abext_ammso4
           end
   'OMC' : begin
           obs_bext = omc_bext
           sim_bext = rbext_omc
           bkg_bext = bbext_omc
           nat_bext = nbext_omc
           asi_bext = abext_omc
           end
   'NO3' : begin
           obs_bext = ammno3_bext
           sim_bext = rbext_ammno3
           bkg_bext = bbext_ammno3
           nat_bext = nbext_ammno3
           asi_bext = abext_ammno3
           end        
   'EC' : begin
           obs_bext = ec_bext
           sim_bext = rbext_ec
           bkg_bext = bbext_ec
           nat_bext = nbext_ec
           asi_bext = abext_ec
           end        
   'IOA' : begin
           obs_bext = ammso4_bext + ammno3_bext
           sim_bext = rbext_ammso4 + rbext_ammno3
           bkg_bext = bbext_ammso4 + bbext_ammno3
           nat_bext = nbext_ammso4 + nbext_ammno3
           asi_bext = abext_ammso4 + abext_ammno3
           end
   'CARB' : begin
           obs_bext = omc_bext + ec_bext
           sim_bext = rbext_omc + ec_bext
           bkg_bext = bbext_omc + ec_bext
           nat_bext = nbext_omc + ec_bext
           asi_bext = abext_omc + ec_bext
           end
   'ALL' : begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext
           sim_bext = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+soil_bext+cm_bext
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+soil_bext+cm_bext
           nat_bext = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+soil_bext+cm_bext
           asi_bext = abext_ammso4+abext_ammno3+abext_ec+abext_omc+soil_bext+cm_bext
           chi_bext = cbext_ammso4+cbext_ammno3+cbext_ec+cbext_omc+soil_bext+cm_bext
           end
  END

     obs_vis = chk_undefined(10. * Alog( (obs_bext+10.) / 10. ))
     sim_vis = chk_undefined(10. * Alog( (sim_bext+10.) / 10. ))
     bkg_vis = chk_undefined(10. * Alog( (bkg_bext+10.) / 10. ))
     nat_vis = chk_undefined(10. * Alog( (nat_bext+10.) / 10. ))
     asi_vis = chk_undefined(10. * Alog( (asi_bext+10.) / 10. ))
     chi_vis = chk_undefined(10. * Alog( (chi_bext+10.) / 10. ))

