;  $ID: read_smoke_text_hourly.ncl V01 09/24/2013 09:23 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM read_smoke_text_hourly READS PREPARED HORLY SMOKE EMISSIN DATA, 
;  INCLUDING AVERAGE, SUM, STANDARD DEVIATION, RATIO, AND CORRELATION 
;  CORFFICIENT WITH REFERENCE FIELD.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string) : PREPARED TEXT DATA DIRECTORY                 [---]
;  (2 ) filename  (string) : FILE NAME OF SMOKE EMISSION                  [---]
;  (3 ) year      (integer): YEAR                                         [---]
;  (4 ) month     (integer): MONTH                                        [---]
;  (5 ) day       (integer): DAY                                          [---]
;  (6 ) hour      (integer): HOUR                                         [---]
;  (7 ) sstd      (float)  : STANDARD DEVIATION OF REFERENCE FIELD        [---]
;  (8 ) scv       (float)  : CORRELATION OF VARIATION OF REFERENCE FIELD  [---]
;  (9 ) savg      (float)  : AVERAGE OF REFERENCE FIELD                   [---]
;  (10) ssum      (float)  : SUM OF REFERENCE FIELD                       [---]
;  (11) sratio    (float)  : RATIO OF STANDARD DEVIATION BETWEEN REFERENCE 
;                            AND TEST FIELDS                              [---]
;  (12) sr        (float)  : CORRELATION COEFFICIENT BETWEEN REFERENCE AND 
;                            TEST FIELD                                   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/24/2013)
;******************************************************************************
;
undef("read_smoke_text_hourly")
procedure read_smoke_text_hourly \
         (dir       :string,        filename     :string,   \; INPUT
          year      :integer,       month        :integer,  \; OUTPUT
          day       :integer,       hour         :integer,  \; OUTPUT
          sstd      :float,         scv          :float,    \; OUTPUT
          savg      :float,         ssum         :float,    \; OUTPUT
          sratio    :float,         sr           :float)     ; OUTPUT

begin
;  READ THE WHOLE FILE
   sdata      = asciiread(dir + filename, -1, "string")
   nline      = dimsizes(sdata)-1
   nfield     = 10

;  DEFINE MISSING VALUE
   bv         = -9999.
;  FIELD DELIMITER
   delimiter  = ","

   data       = sdata(1::)

;  READ ALL THE DATA
   year(0:nline-1)   = stringtoint(str_get_field(data, 1, delimiter))
   month(0:nline-1)  = stringtoint(str_get_field(data, 2, delimiter))
   day(0:nline-1)    = stringtoint(str_get_field(data, 3, delimiter))
   hour(0:nline-1)   = stringtoint(str_get_field(data, 4, delimiter))
   sstd(0:nline-1)   = stringtofloat(str_get_field(data, 5,  delimiter))
   scv(0:nline-1)    = stringtofloat(str_get_field(data, 6,  delimiter))
   savg(0:nline-1)   = stringtofloat(str_get_field(data, 7,  delimiter))
   ssum(0:nline-1)   = stringtofloat(str_get_field(data, 8,  delimiter))
   sratio(0:nline-1) = stringtofloat(str_get_field(data, 9,  delimiter))
   sr(0:nline-1)     = stringtofloat(str_get_field(data, 10, delimiter))

end
