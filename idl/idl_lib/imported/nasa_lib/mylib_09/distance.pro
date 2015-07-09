;----------------------------------------------------------------------------
; SCCS/s.distance.pro 1.15 01/05/08 13:05:03
;
;                            function distance
;
; Purpose:
;   Given two points on the surface of a sphere, given by longitude and
;   latitude pairs, computes the linear distance along the surface of 
;   the sphere between the two points (i.e. the Great Circle distance).
;
; File I/O:
;   None.
;
; Entry and Exit States:
;   N/A.
;
; Input Parameter:
;   in_pt1_lon  "Point 1" longitude, in decimal degrees.
;   in_pt1_lat  "Point 1" latitude, in decimal degrees.
;   in_pt2_lon  "Point 2" longitude, in decimal degrees.
;   in_pt2_lat  "Point 2" latitude, in decimal degrees.
;
; Output Parameter:
;   out_dist    Linear distance between the 2 points, in meters.  Same
;               dimensions as input parameters.  Type DOUBLE.  Created.
;               If any of the input was NaN, out_dist at that location
;               will also equal NaN.
;
; Keywords (optional unless otherwise noted):
;   SPH_RADIUS  Radius of the surface of the sphere the points are on.  If
;               this variable isn't defined, the radius of the Earth is
;               assumed.  In meters.
;
; Revision History:
; - 8 Feb 2001:  Orig. ver. by Johnny Lin, CIRES/Univ. of Colo.  Email:
;   air_jlin@yahoo.com.  Passed moderately reasonable tests.
;
; Notes:
; - Written for IDL 5.0.
; - Copyright (c) 2001 Johnny Lin.  For licensing and contact information
;   see http://www.johnny-lin.com/lib.html.  
; - Input can be scalars or arrays of any dimension.  If input are arrays/
;   vectors (i.e. array of different point 1 and point 2), the out_dist 
;   calculated are between equivalent array addresses.
; - Equations from two web pages, by Paul Kirby and Frank Wattenberg.
; - Computations are done in double precision.
; - No procedures called with _EXTRA keyword invoked.
; - No user-written procedures called.
; - No common blocks are used in this program.
;----------------------------------------------------------------------------

FUNCTION DISTANCE, in_pt1_lon, in_pt1_lat, in_pt2_lon, in_pt2_lat  $
                 , SPH_RADIUS = in_sph_radius  $
                 , _EXTRA     = extra



; -------------------- Error Check and Parameter Setting -------------------- 

ON_ERROR, 0

if (N_PARAMS() ne 4) then MESSAGE, 'error-bad param list'

pt1_lon = DOUBLE(in_pt1_lon)        ;- protect input
pt1_lat = DOUBLE(in_pt1_lat)
pt2_lon = DOUBLE(in_pt2_lon)
pt2_lat = DOUBLE(in_pt2_lat)

if (N_ELEMENTS(pt1_lon) ne N_ELEMENTS(pt1_lat)) then MESSAGE, 'error-mismatch'
if (N_ELEMENTS(pt1_lon) ne N_ELEMENTS(pt2_lon)) then MESSAGE, 'error-mismatch'
if (N_ELEMENTS(pt1_lat) ne N_ELEMENTS(pt2_lat)) then MESSAGE, 'error-mismatch'

if (N_ELEMENTS(in_sph_radius) eq 1) then  $  ;- set sphere radius:  default
   sph_radius = DOUBLE(in_sph_radius)  $        is Earths mean radius (in m)
else  $
   sph_radius = 6.371d6



; -------------------------------- Calculation ------------------------------

dradeg = DOUBLE(!RADEG)              ;- double precision version !RADEG

phi1 = (!DPI/2.d0) - (pt1_lat / dradeg)        ;- calc. spherical coord.:
phi2 = (!DPI/2.d0) - (pt2_lat / dradeg)        ;  + phi is pi-latitude
theta1 = pt1_lon / dradeg                      ;  + theta is longitude
theta2 = pt2_lon / dradeg

x1 = sph_radius * SIN(phi1) * COS(theta1)     ;- spherical to cartesian coord.
x2 = sph_radius * SIN(phi2) * COS(theta2)

y1 = sph_radius * SIN(phi1) * SIN(theta1)
y2 = sph_radius * SIN(phi2) * SIN(theta2)

z1 = sph_radius * COS(phi1)
z2 = sph_radius * COS(phi2)

dot_prod         = (x1*x2) + (y1*y2) + (z1*z2)
angle_center_arg = dot_prod / (sph_radius^2)

test = WHERE(ABS(angle_center_arg) gt 1.00001, test_count)  ;- test to make
if (test_count gt 0) then MESSAGE, 'error-bad arguments'    ;  sure argument
                                                            ;  for ACOS is
arg_out_of_rng = WHERE(angle_center_arg gt 1.0, count)      ;  within range;
if (count gt 0) then  $                                     ;  this accts. for
   angle_center_arg[arg_out_of_rng] = 1.d0                  ;  case pt1 & pt2
arg_out_of_rng = WHERE(angle_center_arg lt -1.0, count)     ;  are the same
if (count gt 0) then  $
   angle_center_arg[arg_out_of_rng] = -1.d0

angle_center = ACOS(angle_center_arg)         ;- angle at center of sphere
dist_surf    = angle_center * sph_radius      ;- Great Circle distance



; ---------------------------- Clean-Up and Output --------------------------

out_dist = dist_surf
RETURN, out_dist



END         ; ===== end of function =====

; ========== end file ==========
