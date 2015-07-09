; $Id: strsize.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $



function strsize,strarg,width


     xch = float(!d.x_ch_size)/!d.x_size
     if (strlen(strarg) gt 0) then $
       return,width/(xch*strlen(strarg)) $
     else $
       return,1.

end

