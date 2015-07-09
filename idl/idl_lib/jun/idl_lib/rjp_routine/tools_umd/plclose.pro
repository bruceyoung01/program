pro  plclose,dum

;+
; NAME:
;	PLCLOSE
; PURPOSE:
;	Closes the currently opened graphics file.
; CATEGORY:
;	Graphics.
; CALLING SEQUENCE:
;	PLCLOSE
;
; INPUTS:
;	None.
; OUTPUTS
;	None.
; COMMON BLOCKS: (PLOPCL)
;	OLD_DEVICE	= Device type to reset.
;
; SIDE EFFECTS:
;	Closes the currently opened graphics file and resets the device type
;		to the value before calling PLOPEN.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	Closes output file and restores device.
;-

  common  plopcl,old_device

; *****Close files
  if  (not execute('device,/close'))  then  begin


;   *****write out message that user is in X session
    message,/cont,'You are in the X window: there is no file to close.'
    return
  endif

; *****If no old device specified, exit
  if  (n_elements(old_device) eq 0)  then  return

; *****Rest old device
  set_plot,old_device

  return

end
