
 PRO read_atlanta_rh, viskm, rh, wdsp, prcp
 ; merget Atlanta RH case
  readcol, 'Atlanta_RH_project.txt', siteid, wban, yymmdd, temp, dewp, slp, stp, vis, $
           wdsp, mxspd, gust, matT, minT, prcp, SNDP, frshitt, rh, viskm, $
           format = 'A6, A5, A8, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F', skipline = 1, $
           DELIMITER = ' '
  yymmddflt = double (yymmdd)
  yy = fix((yymmddflt/10000))
  mm = fix( (yymmddflt - yy * 10000D)/100)
  dd  =fix( yymmddflt - yy*10000D - mm*100)
  end
