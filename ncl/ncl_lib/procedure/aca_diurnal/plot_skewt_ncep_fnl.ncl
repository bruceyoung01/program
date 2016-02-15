;  $ID: plot_skewt_ncep_fnl.ncl V01 08/08/2015 19:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_skewt_ncep_fnl.ncl PLOTS SKEW-T DIAGRAM USING NCEP FNL DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic):WORKSTATION                                      [   ]
;  (2 ) stime (a string):TIME OF NCEP FNL                                 [   ]
;  (3 ) p          (1-D):NCEP FNL PRESSURE                                [hPa]
;  (4 ) t          (1-D):NCEP FNL TEMPERATURE                             [C  ]
;  (5 ) td         (1-D):NCEP FNL DEW POINT TEMPERATURE                   [C  ]
;  (6 ) z          (1-D):NCEP FNL GEOPOTENTIAL HEIGHT                     [gpm]
;  (7 ) wspd       (1-D):NCEP FNL WIND SPEED                              [m/s]
;  (8 ) wdir       (1-D):NCEP FNL WIND DIRECTION                          [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2015)
;******************************************************************************
undef("plot_skewt_ncep_fnl")
procedure plot_skewt_ncep_fnl \
          (wks       :graphic,    stime :string, \;INPUT
           p         :numeric,                   \;INPUT
           t         :float,      td    :float,  \;INPUT
           z         :float,      wspd  :float,  \;INPUT
           wdir      :float)                     \;INPUT

begin

;  SETUP RESOURCE FOR PLOT IMAGE
   skewtOpts                   = True
   skewtOpts@DrawColAreaFill   = True
   skewtOpts@tiMainString      = "NCEP FNL Vertical Profile " + stime
   skewtOpts@DrawFahrenheit    = False
   skewtOpts@DrawHeightScaleFt = False

;  SETUP RESOURCE FOR DATA
   dataOpts                    = True
   dataOpts@PrintZ             = True

   skewt_bkgd = skewT_BackGround(wks, skewtOpts)
   skewt_data = skewT_PlotData  (wks, skewt_bkgd, p, t, td, z, \
                                 wspd, wdir, dataOpts)

   draw (skewt_bkgd)
   draw (skewt_data)

end
