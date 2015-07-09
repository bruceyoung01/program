;  $ID: write_smoke_monthly.ncl V01 09/23/2013 10:25 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_smoke_monthly WRITES MONTHLY SMOKE DATA INTO AN ASCII 
;  FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) switch    (string) : SWITCH FOR OVERWRITING OR APPENDING          [---]
;  (2 ) smoke_id  (string) : SMOKE EMISSION                               [---]
;  (3 ) year      (integer): YEAR                                         [---]
;  (4 ) month     (integer): MONTH                                        [---]
;  (5 ) sstd      (float)  : STANDARD DEVIATION OF REFERENCE FIELD        [---]
;  (6 ) cv        (float)  : CORRELATION OF VARIATION OF REFERENCE FIELD  [---]
;  (7 ) savg      (float)  : AVERAGE OF REFERENCE FIELD                   [---]
;  (8 ) ssum      (float)  : SUM OF REFERENCE FIELD                       [---]
;  (9 ) ratio     (float)  : RATIO OF STANDARD DEVIATION BETWEEN REFERENCE 
;                            AND TEST FIELDS                              [---]
;  (10) r         (float)  : CORRELATION COEFFICIENT BETWEEN REFERENCE AND 
;                            TEST FIELD                                   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/13/2013)
;  (2 ) MODIFIED FROM write_viirs_epa_site.ncl. (06/13/2013)
;  (3 ) MODIFIED FROM write_wrfchem_site.ncl. (09/23/2013)
;******************************************************************************
undef("write_smoke_monthly")
procedure write_smoke_monthly \
          (switch    :integer,   smoke_id     :string,  \ ; INPUT
           year      :integer,   month        :integer, \ ; INPUT
           sstddev   :float,     cv           :float,   \ ; INPUT
           savg      :float,     ssum         :float,   \ ; INPUT
           ratio     :float,     r            :float)     ; INPUT

begin

;  SPECIFY HEADER
   header1 = (/"year, month, Standard_Deviation, Correlation_of_Variation, Average(Gg), Sum(Gg), ratio, correlation_coefficient"/)
;  COMBINE ARRAY TO THE LIST
   hlist1 = [/header1/]

   alist1 = [/year, month, sstddev, cv, savg, ssum, ratio, r/]

   afmt1  = "%4i, %02i, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f"

   if (switch .eq. 0) then
      write_table(smoke_id + "_2010_monthly.txt", "w", hlist1, "%s")
   end if
   write_table(smoke_id + "_2010_monthly.txt", "a", alist1, afmt1)

end
