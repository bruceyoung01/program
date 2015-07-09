;*******************************************************************************
; NAME:
;	GET_H5_DATASET
;
; PURPOSE:
;	This IDL program will read multi-dimensional arrays from a file stored
;	in the new version 5 Hierarchical Data Format (HDF5). Multi-dimensional
;       array data are stored in the HDF5 model known as a dataset. Users may
;	select a dataset along with the accompanying attribute information
;	by either specifying its name or full path.
;
;       If you don't know the name of the dataset you can use the list command
;       to display all the datasets found in the file with their full path.
;
;         GET_H5_DATASET, FILE='foo.h5', /LIST
;
;       You can then choose one of those to read on a subsequent call.
;       Note the default will just list datasets, you can add the /GROUP
;       keyword to just list the groups in the file, or /ALL for everything.
;
;         GET_H5_DATASET, data, FILE='foo.h5', NAME='/a/b/c/mydataset'
;
;      Or you can simply pass the name without the full path
;
;         GET_H5_DATASET, data, FILE='foo.h5', NAME='mydataset'
;
;      But be warned if there are multiple datasets with the same name but
;      different paths, this call will only pick up the first dataset with
;      that name. That may not be the one you wanted. See /LIST above.
;
; CALLING SEQUENCE:
; 	GET_H5_DATASET, data [, attr], FILE=file, NAME=name
;                   [ , /LIST, /GROUP, /ALL ]
;
; INPUTS:
;	file:	The name of the file.
;	name:	The name of the dataset to read.
;
; OUTPUTS:
;	data:	The array containing the data.
;
; OPTIONAL OUTPUT PARAMETERS:
;	attr:	Attributes belonging to the dataset.
;
; KEYWORDS Parameters:
;	File:	The name of the file to open.
;	Name:   The name of the dataset to read.
;	List:   List all the datasets in a file (optional).
;	Group:  Select just the groups (optional).
;	All:    Select all objects: dataset or group (optional).
;
; RESTRICTIONS:
;	None.
;
; AUTHOR:
;	James Johnson, GES DISC DAAC
;
; MODIFICATION HISTORY:
;	Oct.  8, 2004 - Version 1.0. 
;	Dec. 12, 2006 - Can now list and find a dataset without path.
;
;*******************************************************************************


FUNCTION LIST_OBJS, file_id, path, group=group, dataset=dataset

  ret = ""

  IF (SIZE(PATH,/TYPE) EQ 0) THEN path=""	; Undefined

  IF (STRLEN(PATH) EQ 0) THEN new_path="/" $
  ELSE new_path = path

  group_id = H5G_OPEN(file_id, new_path)

  FOR i=0, H5G_GET_NMEMBERS(group_id, new_path)-1 DO BEGIN

    obj_name = H5G_GET_MEMBER_NAME(group_id, new_path, i)
    obj_info = H5G_GET_OBJINFO(group_id, obj_name, /FOLLOW_LINK)

    IF (obj_info.type EQ 'GROUP') THEN BEGIN
      IF NOT KEYWORD_SET(dataset) THEN PRINT, path + "/" + obj_name
      ret = LIST_OBJS(file_id, path+"/"+obj_name, group=group, dataset=dataset)
    ENDIF

    IF (obj_info.type EQ 'DATASET') THEN BEGIN
      IF NOT KEYWORD_SET(group) THEN PRINT, path+"/"+obj_name
    ENDIF

  ENDFOR

  done:
  H5G_CLOSE, group_id

  RETURN, ret

END


FUNCTION FIND_OBJECT, file_id, name, path

  ret = ""

  IF (SIZE(PATH,/TYPE) EQ 0) THEN path=""	; Undefined

  IF (STRLEN(path) EQ 0) THEN new_path = "/" $
  ELSE new_path = path

  group_id = H5G_OPEN(file_id, new_path)

  FOR i=0, H5G_GET_NMEMBERS(group_id, new_path)-1 DO BEGIN

    obj_name = H5G_GET_MEMBER_NAME(group_id, new_path, i)
    obj_info = H5G_GET_OBJINFO(group_id, obj_name, /FOLLOW_LINK)

    IF (obj_info.type EQ 'GROUP') THEN BEGIN
      ret = FIND_OBJECT(file_id, name, path + "/" + obj_name)
      IF (STRLEN(ret) GT 0) THEN GOTO, done
    ENDIF

    IF (obj_info.type EQ 'DATASET' AND obj_name EQ name) THEN BEGIN
      ret = path
      GOTO, done
    ENDIF

  ENDFOR

  done:
  H5G_CLOSE, group_id

  RETURN, ret

END


PRO GET_H5_DATASET, data, attr, FILE=file, NAME=name, LIST=list, GROUP=group, ALL=all

  ON_ERROR, 1

  IF NOT KEYWORD_SET(file) THEN BEGIN		; Prompt user for file name
    file = ''
    PRINT, FORMAT='("Please enter file name", $)'
    READ, file
    file = STRTRIM(file)
  ENDIF

  IF NOT H5F_IS_HDF5(file) THEN BEGIN		; Check if this is an HDF5 file
    PRINT, "Error: ", file, " is not a valid HDF5 file"
    GOTO, done
  ENDIF

  file_id = H5F_OPEN(file)

  IF KEYWORD_SET(list) THEN BEGIN		; List objects in the HDF file

    IF KEYWORD_SET(all) THEN $
      ret = LIST_OBJS(file_id) $		; Show all, or
    ELSE IF KEYWORD_SET(group) THEN $
      ret = LIST_OBJS(file_id, /GROUP) $	; Only show groups, or
    ELSE $
      ret = LIST_OBJS(file_id, /DATASET)	; Only show datasets

    H5F_CLOSE, file_id
    GOTO, done

  ENDIF

  objpath = FIND_OBJECT(file_id, name)
  objname = objpath + "/" + name

  dataset_id = H5D_OPEN(file_id, objname)
  data = H5D_READ(dataset_id)

  n_attrs = H5A_GET_NUM_ATTRS(dataset_id)

  FOR i=0, n_attrs-1 DO BEGIN
    attr_id = H5A_OPEN_IDX(dataset_id, i)
    attrname = H5A_GET_NAME(attr_id)
    value = H5A_READ(attr_id)
    IF (SIZE(value,/N_DIMENSIONS) EQ 1 AND SIZE(value,/N_ELEMENTS) EQ 1) THEN $
      value = value[0]
    IF (i EQ 0) THEN $
      attr = create_struct(attrname, value) $
    ELSE $
      attr = create_struct(attr, attrname, value)
    H5A_CLOSE, attr_id
  ENDFOR

  H5D_CLOSE, dataset_id

  H5F_CLOSE, file_id

  done:						 ; End of program.

END

