; $Id: little_endian.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $


function little_endian

   ; grabbed from the newsgroup 02 Jul 1998 by Robert Mallozzi

   return,(BYTE (1, 0, 1))[0]

end

