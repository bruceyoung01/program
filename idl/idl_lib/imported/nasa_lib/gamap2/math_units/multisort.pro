; $Id: multisort.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MULTISORT
;
; PURPOSE:
;        hierarchical sorting of a data set, each column can be sorted
;        reversely. Works well together with W_SORT, a widget interface 
;        that handles up to three sort levels/columns. COLUMNS are defined
;        as first array index (e.g. DATA=FLTARR(5,20) has 5 columns).
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        multisort,data,index=index,revert=revert
;
; INPUTS:
;        DATA --> a 2D array to be sorted
;
; KEYWORD PARAMETERS:
;        INDEX --> an integer or integer array containing the indices for
;            which the array shall be sorted (e.g. [ 3,1,0 ] will sort DATA
;            first by column 3, then within groups of same values for column
;            3 values will be sorted by column 1, and finally by column 0.
;            Default is to sort by the first column.
;
;        REVERT --> an integer or integer array indicating which columns shall
;            be sorted in reverse order. REVERT=1 reverts all sorting,
;            REVERT=[0,1,0] reverts the sort order only for the 2nd column.
;            Default is 0, i.e. do not revert.
;
;
; OUTPUTS:
;        The DATA array will be sorted according to the specifications.
;
; SUBROUTINES:
;        testsort : little test program (historic debugging purposes)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        MULTISORT, DATA, INDEX=[3,1,0], REVERT=[0,1,0]
;
;             ; Sort data first in column 3, then in reverse order 
;             ; for column 1, and finally ascending order for column 0.
;
; MODIFICATION HISTORY:
;        mgs, 30 Jun 1997: VERSION 1.00
;        mgs, 08 Apr 1998: - now stand-alone routine and documentation
;        mgs, 22 Dec 1998: - bug fix (startindex must be -1)
;        mgs, 17 Mar 1999: - bug fix: now has default 0 for revert
;                            (thanks to G. Fireman)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1997-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine multisort"
;-----------------------------------------------------------------------


pro multisort,data,index=index,revert=revert,level=level

; sorts a 2-dim data array (vars, obs) recursively for all indices passed 
; in index. If no index field is passed, the data is sorted according to 
; the first variable (index = 0)
; /revert produces a data set with reversed sort order in all indices 
; the level keyword is for internal purposes only


if(n_elements(index) lt 1) then index = 0
if(not keyword_set(level)) then level=0
; handle revert parameter
if(n_elements(revert) eq 0) then revert = 0
if(n_elements(revert) eq 1 AND keyword_set(revert)) then revertall=1  $
else revertall = 0
if(n_elements(revert) gt 1 AND revert(0)) then revertthis=1 else revertthis=0
if(n_elements(revert) gt 1) then reverti = 1 else reverti=0

; due to pecularities of the implementation, all revert indices following
; a set value must be reverted
if (reverti and level eq 0) then begin
  for i = 0,n_elements(revert)-2 do begin
     if(revert(i)) then for j=i+1,n_elements(revert)-1 do $
        if(revert(j)) then revert(j)=0 else revert(j) = 1
  endfor
endif


; perform simple sort
nind = n_elements(index)
x = data(index(0),*)
ind = sort(x)
data = data(*,ind)

; extract boundaries of equal values in major index
uind = uniq(x(ind))
uind = [ -1, uind ]   ; add first startindex (use -1 because it is 
                      ; interpreted as last index from previous item)

; create subset of index terms for recursive sort
; if only one index was passed, the sort process is terminating
if nind gt 1 then begin
   subindex = index(1:nind-1) 
   if (reverti) then subrevert = revert(1:nind-1) else subrevert=0
   if(n_elements(subrevert) eq 1) then subrevert = subrevert(0)
endif else goto,revertdata

; perform sort on subsets of data with equal major variable
for i=0,n_elements(uind)-2 do begin
   i1 = uind(i)+1
   i2 = uind(i+1)
   if(i2 ge i1) then begin
      subdat = data(*,i1:i2)
      multisort,subdat,index=subindex,revert=subrevert,level=level+1
   endif else subdat = data(*,uind(i))
   if (i eq 0) then newdat = transpose(subdat)  $
   else newdat = [ newdat, transpose(subdat) ]
endfor

data = transpose(newdat) 

; reverse data if positive sort completed and keyword revert set
revertdata:
; if(level eq 0 AND revertall) then data = reverse(data,2) $
; else if(revertthis) then data = reverse(data,2)
if(revertall OR revertthis) then data = reverse(data,2) 

return
end




pro sorttest,index=index,revert=revert 

if(not keyword_set(index)) then index = [1,2]
if(not keyword_set(revert)) then revert=0

col0 = findgen(20)
col1 = [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4 ]
col2 = [ 2, 2, 2, 3, 5, 4, 3, 2, 2, 2, 4, 3, 3, 3, 5, 4, 4, 3, 3, 1 ] 
col3 = [ 8, 7, 6, 5, 4, 3, 2, 1, 8, 7, 6, 5, 4, 3, 2, 1, 8, 7, 6, 5 ]

data = [ transpose(col0),transpose(col1),transpose(col2),transpose(col3) ]

print,'Calling multisort with INDEX=',index,'   REVERT=',revert
multisort,data,index=index,revert=revert

for i=0,n_elements(data(0,*))-1 do $
    print,fix(data(0,i)),data(1,i),data(2,i),data(3,i)

print

return
end
 
