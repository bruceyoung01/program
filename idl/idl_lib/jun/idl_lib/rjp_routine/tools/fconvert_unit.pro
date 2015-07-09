; $Id: fconvert_unit.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $


function fconvert_unit,data,unit,toparam,result=result,_EXTRA=e

    ; simply take data, call convert_unit procedure and
    ; return data

    convert_unit,data,unit,toparam,result=result,_EXTRA=e

    return,data

end

