; $Id: ind_comb.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        IND_COMB
;
; PURPOSE:
;        combine two index arrays that result from different
;        WHERE calls to the same data set.
;
; CATEGORY:
;        tools
;
; CALLING SEQUENCE:
;        result = IND_COMB(INDEX1,INDEX2,TYPE [,keywords])
;
; INPUTS:
;        INDEX1, INDEX2 --> the two index arrays (may be single integers
;              or -1, but must be given)
;
;        TYPE --> a string containing the type of index combination:
;              The result will contain an index value if the index is 
;              contained in ...
;              type eq "OR":   ... at least one of INDEX1 or INDEX2
;              type eq "AND":  ... INDEX1 and INDEX2
;              type eq "NOR":  ... neither INDEX1 nor INDEX2
;              type eq "XOR":  ... only one of INDEX1 or INDEX2
;              type eq "NAND": ... not in both
;        The default combination is "OR".
;
; KEYWORD PARAMETERS:
;        TOTALN --> optional: number of elements in the data set. If not
;              given, this value is calculated as max([index1,index2]).
;              If this argument is passed, the user has full responsibility
;              that array indices are not exceeded.
;              ATTENTION: types NAND and NOR may give wrong results if 
;              TOTALN is not specified (see example).
;
; OUTPUTS:
;        an array of type lon that contains the combined indices and can be 
;        used as array subscript.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        data = findgen(100)+1
;        ind1 = where(data le 50)
;        ind2 = where(data ge 50 AND data lt 80)
;        res = ind_comb(ind1,ind2,"OR")
;            print,'1:',min(data(res)),max(data(res)) 
;        res = ind_comb(ind1,ind2,"AND")
;            print,'2:',min(data(res)),max(data(res))
;        res = ind_comb(ind1,ind2,"NOR")   ; <------  WRONG !!
;            print,'3:',res                         
;        res = ind_comb(ind1,ind2,"NOR",totaln=100)
;            print,'4:',min(data(res)),max(data(res))
;        res = ind_comb(ind1,ind2,"XOR")
;            print,'5:',min(data(res)),max(data(res))
;        res = ind_comb(ind1,ind2,"NAND")  ; <------  WRONG !!
;            print,'6:',min(data(res)),max(data(res))
;        res = ind_comb(ind1,ind2,"NAND",totaln=100)
;            print,'7:',min(data(res)),max(data(res))
;
;        IDL will print:
;            1:  1    79
;            2: 50    50 
;            3: -1           <------  WRONG !!
;            4: 80   100
;            5:  1    79
;            6:  1    79     <------  WRONG !!
;            7:  1   100
;
; MODIFICATION HISTORY:
;        mgs, 04 Dec 1997: VERSION 1.00
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine ind_comb"
;-------------------------------------------------------------


function ind_comb,index1,index2,type,totaln=totaln
 
 
    on_error,2    ; return to caller

    ; check if both index arrays are "empty" 
    if(index1(0) lt 0 AND index2(0) lt 0) then return,-1

    ; find maximum number of elements and create tmp array
    if (n_elements(totaln) le 0) then $
       totaln = max([index1,index2])+1
 
    tmp = lonarr(totaln)
 
    ; increment all indexed elements of tmp
    if(index1(0) ge 0) then tmp(index1) = tmp(index1) + 1
    if(index2(0) ge 0) then tmp(index2) = tmp(index2) + 1
 
    ; return combination according to keyword
    if(n_elements(type) le 0) then type = "OR"
    type = strupcase(type)
    if (type eq "OR") then return,where(tmp ge 1)
    if (type eq "AND") then return,where(tmp eq 2)
    if (type eq "NOR") then return,where(tmp eq 0)
    if (type eq "XOR") then return,where(tmp eq 1)
    if (type eq "NAND") then return,where(tmp lt 2)
 
    ; if the following line is reached, an invalid type has been given
    message,'*** IND_COMB ERROR: invalid combination type '+type
 
end
