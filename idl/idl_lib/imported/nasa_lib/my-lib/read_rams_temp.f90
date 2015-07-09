!
! This program using read_rams_module to read temperature output, 
! calcualte avg. temp with and without aerosols, and their relationship 
! with smoke AOT
!

      program read_rams_temp 
      use read_rams_module
      implicit none

! specify gird information
      integer:: np,  & ! # of grids in x-direction
                nl,  & ! # of grids in y-direction
		nz0, & ! # of grids in z-direction (needed) 
		nt , & ! # of times for all files
		nzmax  ! # of grids in z-direction (specified in revu)
      
      character*150 :: filename, &    ! input filename
                       varname        ! var name, AOT, smoke, etc.

!output
      real, pointer::   smktime(:, :), &       ! time array (nt, nz)
                        smkaot(:, :, :, :), &  ! var array(np, nl, nt, nz)
		        smkheight(:,:),&       ! height array(nt, nz)
                        tmprOntime(:, :), &      ! time array (nt, nz)
                        tmprOn(:, :, :, :), &    ! var array(np, nl, nt, nz)
		        tmprOnheight(:,:),&      ! height array(nt, nz)
                        tmprOfftime(:, :), &      ! time array (nt, nz)
                        tmprOff(:, :, :, :), &    ! var array(np, nl, nt, nz)
		        tmprOffheight(:,:),&      ! height array(nt, nz)
			cldfracOn(:,:, :,:),&     !cld fraction
			cldfracOff(:,:,:,:),& 
			tmpheight(:,:),&          !tmp var
			tmptime(:,:),&
			masson(:, :, :, :),&      !mass
			massoff(:, :, :, :),&
			swon(:, :, :, :),&        !sw
			swoff(:, :, :, :),&
			hrton(:, :, :, :),&       !ht rate
			hrtoff(:, :, :, :),&
			pblon(:, :, :, :),&       !pbl
			pbloff(:, :, :, :),&
			Geoon(:, :, :, :),&       ! geo
			Geooff(:, :, :, :),&
                        lattime(:, :), &       ! time array (nt, nz)
                        lat(:, :, :, :), &     ! var array(np, nl, nt, nz)
		        latheight(:,:), &      ! height array(nt, nz)
                        lontime(:, :), &       ! time array (nt, nz)
                        lon(:, :, :, :), &     ! var array(np, nl, nt, nz)
		        lonheight(:,:)         ! height array(nt, nz)

! post processing information
     real, allocatable:: AotMean(:,:),&        ! AOT distribution   
                       TmprDiff(:,:),&           ! Temperaute differences
                       Tmpvar(:,:)           ! Temperaute differences
     real:: LatT, LatB, LonL, lonR             ! grid box we're  interested in    
     real:: nt1, nt2, nz2, nz1                 ! time and layer of  interest    
     integer:: i, j, ktt,kt, k                     ! loop index 
     real:: TmpSumAOT, TmpSumN, &
            TmpSumTmprOn, TmpSumTmprOff     ! tmp variables 
     character*150 tmpfile

! initialize values, read lat and lon 
      np  = 48 
      nl  = 48
      nzmax = 1

! specify interest region and time and layer
      LatT = 60.
      LatB = -15.
      LonL = -130.
      LonR = -40.
      nt1 = 1
      nt2 = 10 
      nz1 = 2
      nz2 = 2
     
! read lat and lon
      nz0 = 1
      filename = '../../data/parallel-offline-cld/grid1/LAT.dmp'
      varname = 'LAT'
      call read_rams(filename, varname, lattime, lat, latheight, &
                   nt, nz0, np, nl, nzmax )

      filename = '../../data/parallel-offline-cld/grid1/LON.dmp'
      varname = 'LON'
      call read_rams(filename, varname, lontime, lon, lonheight, &
                   nt, nz0, np, nl, nzmax )
      
! temperature
      nz0 = 20
      nzmax=20
      filename = '../../data/parallel-online-cld/grid1/TEMP.dmp'
      varname = 'TEMP'
      call read_rams(filename, varname, tmprOntime, tmprOn, tmprOnheight, &
                   nt, nz0, np, nl, nzmax )
      
      filename = '../../data/parallel-offline-cld/grid1/TEMP.dmp'
      varname = 'TEMP'
      call read_rams(filename, varname, tmprOfftime, tmprOff, tmprOffheight, &
                   nt, nz0, np, nl, nzmax )

! read smok aot  
      nz0 = 20
      filename = '../../data/parallel-online-cld/grid1/AOT.dmp'
      varname = 'AOT'
      call read_rams(filename, varname, smktime, smkaot, smkheight, &
                   nt, nz0, np, nl, nzmax )

! read cld fraction
      nz0 = 1
      varname = 'CLFRAC'
      filename = '../../data/parallel-online-cld/grid1/CLOUDFRAC.dmp'
      call read_rams(filename, varname, tmptime, CldFracOn, tmpheight, &
                   nt, nz0, np, nl, nzmax )
      filename = '../../data/parallel-offline-cld/grid1/CLOUDFRAC.dmp'
      call read_rams(filename, varname, tmptime, CldFracOff, tmpheight, &
                   nt, nz0, np, nl, nzmax )

! heating rate
      nz0 = 20
      varname = 'HRT'
      filename = '../../data/parallel-online-cld/grid1/HRT.dmp'
      call read_rams(filename, varname, tmptime, HrtOn, tmpheight, &
                   nt, nz0, np, nl, nzmax )
      filename = '../../data/parallel-offline-cld/grid1/HRT.dmp'
      call read_rams(filename, varname, tmptime, HrtOff, tmpheight, &
                   nt, nz0, np, nl, nzmax )

! Mass
      nz0 = 20
      varname = 'MASS'
      filename = '../../data/parallel-online-cld/grid1/MASS.dmp'
      call read_rams(filename, varname, tmptime, MassOn, tmpheight, &
                   nt, nz0, np, nl, nzmax )
      filename = '../../data/parallel-offline-cld/grid1/MASS.dmp'
      call read_rams(filename, varname, tmptime, MassOff, tmpheight, &
                   nt, nz0, np, nl, nzmax )
!PBL
      nz0 = 1
      varname = 'PBL'
      filename = '../../data/parallel-online-cld/grid1/PBL.dmp'
      call read_rams(filename, varname, tmptime, PblOn, tmpheight, &
                   nt, nz0, np, nl, nzmax )
      filename = '../../data/parallel-offline-cld/grid1/PBL.dmp'
      call read_rams(filename, varname, tmptime, PblOff, tmpheight, &
                   nt, nz0, np, nl, nzmax )

! print smk aot
      print*, smkaot(1:np, 1:nl, 5, 2) 

! seach regions
     allocate(AOTMean(np,nl))
     allocate(TmprDiff(np,nl))
     allocate(TmpVar(np,nl))
      
      do i = 1, np 
        do j = 1, nl
          SumTmpr = 0.0
          SumAOT = 0.0
	  SumMass = 0.0
	  SumPBL = 0.0
	  SumCLDFRAC = 0.0
	  SumHrt = 0.0
          SumN = 0.0

!Diff values	  
	  AOTMean(i,j) = 0.0
	  TmprDiff(i,j) = 0.0
	  MassDiff(i,j) = 0.0
	  CldFracFiff(i,j) = 0.0
	  PblDiff(i,j) = 0.0
	  MassDiff(i,j) = 0.0
	  HRTDiff(i,j)  = 0.0
	  
          if ( lat(i,j) .lt. LatT .and. lat(i,j) .gt. LatB .and. &
	      lon(i,j) .lt. LonR .and. lon(i,j) .gt. LonL ) then
	    do kt = nt1, nt2
	      ktt = kt*24+10
	      do k =  nz1, nz2 
	        SumTmpr = tmpron(i,j, ktt, k) - tmproff(i,j, ktt, k)+SumTmpr  
	        SumMass = Masson(i,j, ktt, k) - Massoff(i,j, ktt, k)+SumMass  
	        SumPBL = PBL(i,j, ktt, k) - tmproff(i,j, ktt, k)+SumPBL  
	        SumCLDFRAC = CldFracOn(i,j, ktt, k) - CldfRacoff(i,j, ktt, k)+SumCLFRAC  
	        SumHRTDiff = HrtOn(i,j, ktt, k) - Hrtoff(i,j, ktt, k)+SumHrt  
                SumAOT = smkaot(i,j, ktt, k) + SumAOT
	        TmpSumN = TmpSumN+1
	      enddo
	    enddo  
	  endif
	  AOTMean (i,j) = SumAOT/TmpSumN 
	  TmprDiff(i,j) = SumTmpr/TmpSumN 
	  MassDiff(i,j) = SumMass/TmpSumN 
	  CldFracDiff(i,j) = SumCldFrac/TmpSumN 
	  PblDiff(i,j) = SumPbl/TmpSumN 
	  HrtDiff(i,j) = SumHrt/TmpSumN 
	 enddo
	enddo 

! output files
        tmpfile = 'AOT_monthly.dat'        
	call outputF(tmpfile, np, nl, AOTmean)
	tmpfile = 'Tmpr_diff.dat'
        call outputF(tmpfile, np, nl, TmprDiff)

!       
        tmpvar(1:np, 1:nl) = lat(1:np,1:nl, 1,1) 
	tmpfile = 'lat.dat'
        call outputF(tmpfile, np, nl, tmpvar)
	tmpfile = 'lon.dat'
        tmpvar(1:np, 1:nl) = lon(1:np,1:nl, 1,1) 
        call outputF(tmpfile, np, nl, Tmpvar)


! print temperature distribution in last output
!      print*, 'temp = ', vararry(1:np, 1:nl, nt, nz0)


! get mean avg AOT values and temperature differences
      print*, 'AOT mean = ', AOTmean      
      print*, 'Lat = ', lat(1:np,1:nl, 1,1)
      print*, 'lon = ', lon(1:np,1:nl, 1,1)
!      print*, 'nt = ', nt 
END

      
