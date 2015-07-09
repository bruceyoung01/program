; $Id: h5_parse.pro,v 1.10 2004/01/21 15:54:53 scottm Exp $
; Copyright (c) 2002-2004, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;   H5_PARSE
;
; PURPOSE:
;   Parses an HDF5 file and returns a nested structure containing all of
;   the groups, datasets, and attributes.
;
; CALLING SEQUENCE:
;
;   Result = H5_PARSE(File [, /READ_DATA])
; or
;   Result = H5_PARSE(Hid, Name
;             [, FILE=string] [, PATH=string] [, /READ_DATA])
;
; RETURN VALUE:
;   Result: A nested structure.
;
; INPUTS:
;
;   File: A scalar string giving the file to parse.
;
;   Hid: An integer giving the identifier of the file or
;        group in which to access the object.
;
;   Name: A string giving the name of the group, dataset, or datatype
;         within Hid to parse.
;
;
; KEYWORD PARAMETERS:
;
;   FILE = Set this optional keyword to a string containing the filename
;          to which the Hid belongs. This value is only used to fill
;          in the FILE field within the structure.
;          This keyword is ignored when the File argument is supplied.
;
;   PATH = Set this optional keyword to a string containing the fully
;          qualified path within the HDF5 file of the Hid group.
;          This value is only used to fill in the PATH field
;          within the structure.
;          This keyword is ignored when the File argument is supplied.
;
;   READ_DATA = Set this keyword to automatically read in all data
;          while parsing the file. The default is to only read datasets
;          or attributes with 10 elements or less.
;
;
; EXAMPLE:
;
;  Parsing an entire file:
;     file = FILEPATH('hdf5_test.h5', SUBDIR=['examples','data'])
;     struc = H5_PARSE(file, /READ_DATA)
;     image = struc.images.eskimo
;     palette = struc.images.eskimo_palette
;     DEVICE, DECOMPOSED=0
;     WINDOW, XSIZE=image._dimensions[0], YSIZE=image._dimensions[1]
;     TVLCT, TRANSPOSE(palette._data)
;     TV, image._data, /ORDER
;
;  Parsing an already open group:
;     hid = H5F_OPEN(file)
;     gid = H5G_OPEN(hid, '/arrays')
;     struc = H5_PARSE(gid, '2D float array', $
;           FILE='hdf5_test.h5', PATH='/arrays', /READ_DATA)
;     TVSCL, struc._data
;
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, June 2002
;   Modified by:
;
;-


;-------------------------------------------------------------------------
function h5_parse_readdata, id, nelements, $
    READ_DATA=readData, ATTRIBUTE=attribute

    compile_opt idl2, hidden

    ; Attempt to read the data.
    data = '<unread>'
    if ((nelements le 10) or KEYWORD_SET(readData)) then begin
        CATCH, error
        ; Use the if/else to do the "try/throw".
        if (error ne 0) then begin
            CATCH, /CANCEL
            data = '<read error>'
        endif else begin
            data = KEYWORD_SET(attribute) ? H5A_READ(id) : H5D_READ(id)
        endelse
    endif

    return, data
end


;-------------------------------------------------------------------------
function H5_attribute_parse, Loc_id, index

    compile_opt idl2, hidden

    attr_id = H5A_OPEN_IDX(Loc_id, index)

    sSpace = H5_DATASPACE_PARSE(attr_id, /ATTRIBUTE)
    datatype_id = H5A_GET_TYPE(attr_id)
    sType = H5_DATATYPE_PARSE(datatype_id)
    H5T_CLOSE, datatype_id

    ; Attempt to read the data.
    data = H5_PARSE_READDATA(attr_id, sSpace._nelements, $
        /READ_DATA, /ATTRIBUTE)


    ; Concatanate
    sAttr = CREATE_STRUCT( $
        '_NAME', H5A_GET_NAME(attr_id), $
        '_ICONTYPE', 'text', $
        '_TYPE', 'ATTRIBUTE', $
        '_DATA', data, $
        sSpace, $
        sType)

    H5A_CLOSE, attr_id

    return, sAttr
end


;-------------------------------------------------------------------------
pro h5_parse_attributes, sTree, Loc_id

    compile_opt idl2, hidden

    nAttributes = H5A_GET_NUM_ATTRS(Loc_id)
    for i=0,nAttributes-1 do begin
        sAttr = H5_ATTRIBUTE_PARSE(Loc_id, i)
        tagname = STRUPCASE(IDL_VALIDNAME(sAttr._name, /CONVERT_ALL))
        ; Make sure we don't already have this tagname defined, say
        ; for a datatype or dataset. If we do, then just append _ATTR.
        if (MAX(TAG_NAMES(sTree) eq tagname) eq 1) then $
            tagname = tagname + '_ATTR'
        sTree = CREATE_STRUCT(sTree, tagname, sAttr)
    endfor
end


;-------------------------------------------------------------------------
function H5_dataspace_parse, hid, ATTRIBUTE=attribute

    compile_opt idl2, hidden

    ; Open the dataspace within the dataset.
    dataspace_id = KEYWORD_SET(attribute) ? $
        H5A_GET_SPACE(hid) : H5D_GET_SPACE(hid)

    sDataset = { $
        _NDIMENSIONS: H5S_GET_SIMPLE_EXTENT_NDIMS(dataspace_id), $
        _DIMENSIONS: H5S_GET_SIMPLE_EXTENT_DIMS(dataspace_id), $
        _NELEMENTS: H5S_GET_SIMPLE_EXTENT_NPOINTS(dataspace_id)}

    H5S_CLOSE, dataspace_id

    return, sDataset

end


;-------------------------------------------------------------------------
function H5_datatype_parse, datatype_id, $
    MEMBER_NAME=memberName, $
    NAME=name, $
    FILE=fileIn, $
    PATH=pathIn, $
    READ_DATA=readData

    compile_opt idl2, hidden

    file = (N_ELEMENTS(fileIn) eq 1) ? fileIn[0] : ''
    path = (N_ELEMENTS(pathIn) eq 1) ? pathIn[0] : ''

    ; Retrieve properties and store them.
    class = H5T_GET_CLASS(datatype_id)
    sign = H5T_GET_SIGN(datatype_id)
    case sign of
        0: sign = 'unsigned'
        1: sign = 'signed'
        else: sign = ''
    endcase

    sDatatype = { $
        _DATATYPE: class, $
        _STORAGESIZE: H5T_GET_SIZE(datatype_id), $
        _PRECISION: LONG(H5T_GET_PRECISION(datatype_id)), $
        _SIGN: sign}

    ; For compound datatypes, add substructures for each member.
    if (class eq 'H5T_COMPOUND') then begin
        for i=0,H5T_GET_NMEMBERS(datatype_id)-1 do begin
            memName = H5T_GET_MEMBER_NAME(datatype_id, i)
            memberId = H5T_GET_MEMBER_TYPE(datatype_id, i)
            tagname = IDL_VALIDNAME(memName, /CONVERT_ALL)
            sDatatype = CREATE_STRUCT(sDatatype, $
                tagname, $
                H5_DATATYPE_PARSE(memberId, $
                MEMBER_NAME=memName, READ_DATA=readData))
            H5T_CLOSE, memberId
        endfor
    endif

    ; If Named datatype, then store additional properties.
    if (SIZE(name, /TYPE) eq 7) then begin
        ; Concatanate.
        sDatatype = CREATE_STRUCT( $
            '_NAME', name[0], $
            '_ICONTYPE', 'prop', $
            '_TYPE', 'DATATYPE', $
            '_FILE', file, $
            '_PATH', path, $
            sDatatype)
        ; Add attributes.
        H5_PARSE_ATTRIBUTES, sDatatype, datatype_id
    endif

    ; If compound member, then store additional properties.
    if (SIZE(memberName, /TYPE) eq 7) then begin
        ; Concatanate.
        sDatatype = CREATE_STRUCT( $
            '_NAME', memberName[0], $
            '_ICONTYPE', '', $   ; no special icon
            '_TYPE', 'DATATYPE', $
            sDatatype)
    endif

    return, sDatatype

end


;-------------------------------------------------------------------------
function H5_dataset_parse, group_id, dataset_name, $
    FILE=fileIn, $
    PATH=pathIn, $
    READ_DATA=readData

    compile_opt idl2, hidden

    file = (N_ELEMENTS(fileIn) eq 1) ? fileIn[0] : ''
    path = (N_ELEMENTS(pathIn) eq 1) ? pathIn[0] : ''

    dataset_id = H5D_OPEN(group_id, dataset_name)
    datatype_id = H5D_GET_TYPE(dataset_id)
    sSpace = H5_DATASPACE_PARSE(dataset_id)

    ; Attempt to read the data.
    data = H5_PARSE_READDATA(dataset_id, sSpace._nelements, $
        READ_DATA=readData)

    ; Concatanate
    sDataset = CREATE_STRUCT( $
        '_NAME', dataset_name, $
        '_ICONTYPE', 'binary', $
        '_TYPE', 'DATASET', $
        '_FILE', file, $
        '_PATH', path, $
        '_DATA', TEMPORARY(data), $
        sSpace, $
        H5_DATATYPE_PARSE(datatype_id, READ_DATA=readData))

    H5T_CLOSE, datatype_id
    H5D_CLOSE, dataset_id

    return, sDataset

end


;-------------------------------------------------------------------------
function h5_object_parse, group_id, member_name, $
    CACHE=cache, $
    FILE=file, $
    PATH=path, $
    READ_DATA=readData

    compile_opt idl2, hidden

    objinfo = H5G_GET_OBJINFO(group_id, member_name)

    ; It is impossible to tell a "hard" link from an actual
    ; group or dataset. So we need to check our cache of members
    ; to see if we've already displayed this member.
    ; If so, then it is a hard link.
    ; AJ: Use the fileno and objno pairs for identification.
    ; Convert them to joined strings for easy comparison.
    strcache = STRJOIN([objinfo.fileno, objinfo.objno],' ')

    if (N_ELEMENTS(cache) gt 0) then begin
        ; If we've already displayed this member, then it is actually
        ; a link, so change its type.
        if (TOTAL(cache eq strcache) gt 0) and (objinfo.type EQ 'GROUP') then $
            objinfo.type = 'LINK' $
        else $
            cache = [cache, strcache]
    endif else begin
        ; First time thru.
        cache = strcache
    endelse

    case objinfo.type of

        'GROUP': begin
            ; Add a new group branch.
            sTree = H5_GROUP_PARSE(group_id, member_name, $
                CACHE=cache, FILE=file, PATH=path, READ_DATA=readData)
            end

        'DATASET': begin
            ; Add our dataset container.
            sTree = H5_DATASET_PARSE(group_id, member_name, $
                FILE=file, PATH=path, READ_DATA=readData)

            ; Add attributes.
            dataset_id = H5D_OPEN(group_id, member_name)
            H5_PARSE_ATTRIBUTES, sTree, dataset_id
            H5D_CLOSE, dataset_id

            end

        'TYPE': begin
            ; Add the datatype leaf node.
            datatype_id = H5T_OPEN(group_id, member_name)
            sTree = H5_DATATYPE_PARSE(datatype_id, $
                NAME=member_name, FILE=file, PATH=path, READ_DATA=readData)
            H5T_CLOSE, datatype_id
            end

        'LINK': begin
            ; Add the link leaf node.
            ; Include the path and file in the structure
            ; Also if non-empty, store the resolved link
            ; in the data structure
            CATCH, errno
            if (errno ne 0) then begin
                CATCH, /CANCEL
                ; This seems to be a link to nothing or
                ; it is a link to a group. In both cases
                ; the H5G_GET_LINKVAL can not retrieve it's value.
                ; Just create the sTree, leaving the Data empty and return it
                linkval = ''
            endif else begin
                linkval = H5G_GET_LINKVAL(group_id, member_name)
            endelse

            sTree = {$
                _NAME: member_name, $
                _ICONTYPE: 'up1lvl', $
                _TYPE: 'LINK', $
                _DATA: linkval, $
                _FILE: file, $
                _PATH: path}

            end


        'UNKNOWN': sTree = 0 ; do nothing

    endcase

    return, sTree

end


;-------------------------------------------------------------------------
;
; Hid:        HDF5 identifier for the file or group
;             in which the Group_name belongs.
; Group_name: Name of the group within HID to open.
;
; CACHE:      Internal list of currently open groups within the HID.
;             Used for checking for hard links.
; FILENAME:   If HID is a file identifier, the corresponding filename.
; PATH:       Absolute path for the current Hid.
;
function h5_group_parse, hid, group_name, $
    CACHE=cache, $
    FILE=fileIn, $
    PATH=pathIn, $
    READ_DATA=readData

    compile_opt idl2, hidden

    file = (N_ELEMENTS(fileIn) eq 1) ? fileIn[0] : ''

    ; Put the filename and a different bitmap for the top level.
    if (group_name eq '/') then begin
        bitmap = 'hdf'
        name = file
    endif else begin
        ; (use the default folder bitmap)
        bitmap = ''
        name = group_name
    endelse

    ; If PATH is initially undefined, then is this an absolute
    ; path "/" or a relative path?
    path = (N_ELEMENTS(pathIn) eq 1) ? pathIn[0] : '/'

    group_id = H5G_OPEN(hid, group_name)

    ; Construct our container.
    sTree = { $
        _NAME: name, $
        _ICONTYPE: bitmap, $
        _TYPE: 'GROUP', $
        _FILE: file, $
        _PATH: path, $
        _COMMENT: H5G_GET_COMMENT(hid, group_name)}

    ; Append the group to the end of the path.
    ; Avoid duplicate / separators.
    endPath = STRMID(path, 0, 1, /REVERS) eq '/'
    begGroup = STRMID(group_name, 0, 1) eq '/'
    path = STRMID(path, 0, STRLEN(path)-endPath) + '/' + $
        STRMID(group_name, begGroup)

    ; Retrieve the number of groups or datasets within our group.
    ngroup = H5G_GET_NMEMBERS(hid, group_name)

    ; Loop thru all children, adding containers.
    for i=0,ngroup-1 do begin

        member_name = H5G_GET_MEMBER_NAME(hid, group_name, i)

        ; Parse this object, depending upon what type it is.
        sMember = H5_OBJECT_PARSE(group_id, member_name, $
            CACHE=cache, FILE=file, PATH=path, READ_DATA=readData)

        ; Did we get a valid result?
        if (SIZE(sTree,/TYPE) eq 8) then begin
            tagname = IDL_VALIDNAME(member_name, /CONVERT_ALL)
            sTree = CREATE_STRUCT(sTree, tagname, sMember)
        endif

    endfor


    ; Make sure we parse the Attributes if needed.
    H5_PARSE_ATTRIBUTES, sTree, group_id

    H5G_CLOSE, group_id

    return, sTree
end


;-------------------------------------------------------------------------
function h5_parse, arg0, name, $
    FILE=fileIn, $
    PATH=path, $
    READ_DATA=readData

    compile_opt idl2

    ON_ERROR, 2

    if (N_PARAMS() eq 0) then $
        MESSAGE, 'Incorrect number of arguments.'

    ; File or identifier?
    if (SIZE(arg0, /TYPE) eq 7) then begin

        if (N_PARAMS() gt 1) then $
            MESSAGE, 'Incorrect number of arguments.'

        file = arg0[0]

        if (not H5F_IS_HDF5(file)) then $
            MESSAGE, '"'+file+'" is not a valid HDF5 file.'

        hid = H5F_OPEN(file)

        ; Recursively loop thru the entire file, constructing
        ; a nested container.
        sTree = H5_GROUP_PARSE(hid, '/', FILE=file, READ_DATA=readData)

        H5F_CLOSE, hid

    endif else begin

        if (N_PARAMS() lt 2) then $
            MESSAGE, 'Incorrect number of arguments.'

        ; Parse this object, depending upon what type it is.
        sTree = H5_OBJECT_PARSE(arg0, name, $
            FILE=fileIn, PATH=path, READ_DATA=readData)

    endelse

    return, sTree
end


