; $Id: undefine.pro,v 1.2 2004/06/03 18:01:28 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;       UNDEFINE
;
; PURPOSE:
;       The purpose of this program is to delete or undefine
;       an IDL program variable from within an IDL program or
;       at the IDL command line. It is a more powerful DELVAR.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       2642 Bradbury Court
;       Fort Collins, CO 80521 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;       Utilities.
;
; CALLING SEQUENCE:
;       UNDEFINE, variable
;
; REQUIRED INPUTS:
;       variable: The variable to be deleted.
;
; SIDE EFFECTS:
;       The variable no longer exists.
;
; EXAMPLE:
;       To delete the variable "info", type:
;
;        IDL> Undefine, info
;
; MODIFICATION HISTORY:
;       Written by David Fanning, 8 June 97, from an original program
;       given to me by Andrew Cool, DSTO, Adelaide, Australia.
;       Simplified program so you can pass it an undefined variable. :-) 17 May 2000. DWF
;       Simplified it even more by removing the unnecessary SIZE function. 28 June 2002. DWF.
;-
;-----------------------------------------------------------------------

PRO UNDEFINE, varname
   IF (N_Elements(varname) NE 0) THEN tempvar = Temporary(varname)
END
