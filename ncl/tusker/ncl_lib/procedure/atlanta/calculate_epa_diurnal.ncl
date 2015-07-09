;  $ID: calculate_epa_diurnal.ncl V01 02/24/2013 16:21 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calculate_epa_diurnal CALCULATES EPA HOURLY AVERAGE, STANDARD 
;  DEVIATION, AND TOTAL AVERAGE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/24/2013)
;******************************************************************************
undef("calcualte_epa_diurnal")
procedure calculate_epa_diurnal \
         (hour          :integer,    site_id       :string,  \; INPUT
          site_name     :string,     site_geo      :float,   \; INPUT
          site_date     :integer,    site_pm       :float,   \; INPUT
          select_geo    :float,      select_pm_avg :float,   \; OUTPUT
          select_pm_std :float)                               ; OUTPUT

begin
   index1 = ind(site_name(:, 0) .eq. site_id .and. \
                site_date(:, 3) .eq. hour)
   if (.not.all(ismissing(index1))) then
    select_geo(:) = site_geo(index1(0), :)
    select_pm_avg = avg(site_pm(index1, 0))
    select_pm_std = stddev(site_pm(index1, 0))
   end if
   delete([/index1/])
end
