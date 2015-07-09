;+
;NAME:
;	fieldmap
;PURPOSE:
;	Mapping of various short hand notations of field names to
;	create file names used by vreadphx.pro and hreadphx,.pro
;
;CATEGORY:
;	General Utility
;
;CALLING SEQUENCE:
;	outfield = fieldmap(infield,level=level)
;
;INPUTS:
;	infield	= input field name
;
;OUTPUTS:
;	outfield = output field name
;
;KEYWORDS:
;	level = potential temperature level of Ertel Pot. Vort. field
;
;COMMON BLOCKS:
;	None
;
;SIDE EFFECTS:
;	None known.
;
;RESTRICTIONS:
;	None known.
;
;PROCEDURE:
;	case statements to do mapping of names
;-

function fieldmap,infield,level=level

case strupcase(infield) of
  'PMSL':	return,'SLP'
  'EPV':	return,strlowcase(infield)+string(fix(level),'(i4.4)')
  'U':		return,'UWND'
  'V':		return,'VWND'
  'T':		return,'TMPU'
  'Z':		return,'HGHT'
  'Z1':		return,'01HGHT'
  'Z2':		return,'02HGHT'
  'Z3':		return,'03HGHT'
  'Z4':		return,'04HGHT'
  'W'	:	return,'OMEGA'
  'P0'	:	return,'PS-PTOP'
  'UBAL':	return,'UWND'
  'VBAL':	return,'VWND'
  'TEMP':	return,'TMPU'
  'TKE':	return,'QQ'
  'HNET':	return,'NETRAD'
  else:		return,strupcase(infield)
 endcase
end
