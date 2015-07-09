;  $ID: calculate_statistics.ncl V01 09/23/2013 12:54 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calculate_statistics CALCULATES AVERAGE, STANDARD DEVIATION, 
;  CORRELATION OF VARIATION, RATIO OF STANDARD DEVIATION BETWEEN REFERENCE 
;  FIELD AND TEST FIELD, CORRELATION BETWEEN REFERENCE FIELD AND TEST FIELD.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv2        (float): FLOAT MISSING VALUE                          [---]
;  (2 ) ref        (float): REFERENCE FIELD (2-D)                        [---]
;  (3 ) test       (float): TEST FILED (2-D)                             [---]
;  (4 ) sstd       (float): STANDARD DEVIATION OF REFERENCE FIELD        [---]
;  (5 ) scv        (float): CORRELATION OF VARIATION OF REFERENCE FIELD  [---]
;  (6 ) savg       (float): AVERAGE OF REFERENCE FIELD                   [---]
;  (7 ) ssum       (float): SUM OF REFERENCE FIELD                       [---]
;  (8 ) rtstd      (float): RATIO OF STANDARD DEVIATION BETWEEN REFERENCE 
;                           AND TEST FIELDS                              [---]
;  (9 ) r          (float): CORRELATION COEFFICIENT BETWEEN REFERENCE AND 
;                           TEST FIELD                                   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/23/2013)
;******************************************************************************
undef("calculate_statistics")
procedure calculate_statistics \
          (bv2      :float,                   \ ;INPUT
           ref      :float,  test    :float,  \ ;INPUT
           sstd     :float,  scv     :float,  \ ;OUTPUT
           savg     :float,  ssum    :float,  \ ;OUTPUT
           rtstd    :float,  r       :float)    ;OUTPUT

begin

  savg   = avg(ref)
  ssum   = sum(ref)
  sstd   = stddev(ref)
  scv    = bv2
  if (savg .eq. 0.0) then
     savg = bv2
  end if
  if (ssum .eq. 0.0) then
     ssum = bv2
  end if
  if (sstd .eq. 0.0) then
     sstd = bv2
  end if

  if (.not.ismissing(savg)) then
     if (savg .ne. 0.0 .and. .not.ismissing(sstd)) then
        scv = sstd/savg
     else if (savg .eq. 0.0) then
        scv = bv2
     end if
     end if
  else if (ismissing(savg) .or. ismissing(sstd)) then
     scv = bv2
  end if
  end if

  rpm25  = dim_avg_n(test, 0)
  ravg   = avg(rpm25)
  rstd   = stddev(rpm25)
  rtstd  = bv2
  r      = bv2
  if (.not.ismissing(rstd)) then
     if (rstd .ne. 0.0 .and. .not.ismissing(sstd)) then
        rtstd = sstd/rstd
     else if (rstd .eq. 0.0) then
        rtstd = bv2
     end if
     end if
  else if (ismissing(sstd) .or. ismissing(rstd)) then
     rtstd = bv2
  end if
  end if

  r      = correlation_nd(ref, test)

end
