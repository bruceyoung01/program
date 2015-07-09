;  $ID: write_smoke_hourly.ncl V01 09/23/2013 10:25 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_smoke_hourly WRITES HOURLY SMOKE DATA INTO AN ASCII 
;  FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) switch    (string) : SWITCH FOR OVERWRITING OR APPENDING          [---]
;  (2 ) smoke_id  (string) : SMOKE EMISSION                               [---]
;  (3 ) year      (integer): YEAR                                         [---]
;  (4 ) month     (integer): MONTH                                        [---]
;  (5 ) day       (integer): DAY                                          [---]
;  (6 ) hour      (integer): HOUR                                         [---]
;  (7 ) sstd      (float)  : STANDARD DEVIATION OF REFERENCE FIELD        [---]
;  (8 ) cv        (float)  : CORRELATION OF VARIATION OF REFERENCE FIELD  [---]
;  (9 ) savg      (float)  : AVERAGE OF REFERENCE FIELD                   [---]
;  (10) ssum      (float)  : SUM OF REFERENCE FIELD                       [---]
;  (11) ratio     (float)  : RATIO OF STANDARD DEVIATION BETWEEN REFERENCE 
;                            AND TEST FIELDS                              [---]
;  (12) r         (float)  : CORRELATION COEFFICIENT BETWEEN REFERENCE AND 
;                            TEST FIELD                                   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/13/2013)
;  (2 ) MODIFIED FROM write_viirs_epa_site.ncl. (06/13/2013)
;  (3 ) MODIFIED FROM write_wrfchem_site.ncl. (09/23/2013)
;******************************************************************************
undef("write_smoke_hourly")
procedure write_smoke_hourly \
          (switch    :integer,   smoke_id     :string,  \ ; INPUT
           year      :integer,   month        :integer, \ ; INPUT
           day       :integer,   hour         :integer, \ ; INPUT
           sstddev   :float,     cv           :float,   \ ; INPUT
           savg      :float,     ssum         :float,   \ ; INPUT
           ratio     :float,     r            :float)     ; INPUT

begin

;  SPECIFY HEADER
   header1 = (/"Year, Month, Day, Hour, Standard_Deviation, Correlation_of_Variation, Average(Gg), Sum(Gg), Ratio, Correlation_Coefficient"/)
;  COMBINE ARRAY TO THE LIST
   hlist1 = [/header1/]

   alist1 = [/year, month, day, hour, sstddev, cv, savg, ssum, ratio, r/]

   afmt1  = "%4i, %02i, %02i, %02i, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f"

   if (switch .eq. 0) then
    write_table(smoke_id + "_2010_hourly.txt", "w", hlist1, "%s")
   end if
   write_table(smoke_id + "_2010_hourly.txt", "a", alist1, afmt1)

end
