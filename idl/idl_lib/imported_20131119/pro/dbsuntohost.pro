 pro dbsuntohost,name
;+
;  NAME:
;	DBSUNTOHOST 
;  PURPOSE:
;	Routine to convert Sun database files to the host computer form.
;	Needed for machines that do not implement the IEEE standard such as
;	OpenVMS and Decstations.    Requires that the ASCII .dbd file and 
;	the binary .dbf file already be present in the current directory, 
;	exactly as copied from the SUN
;  CALLING SEQUENCE:  
;	DBSUNTOHOST, NAME 
; INPUTS:    
;	name - database name, scalar string
; RESTRICTIONS:
;	The logical name or environment ZDBASE must be defined to point to
;	the current directory.    The non-standard system variable !PRIV
;	must be set to 2.
;
;	This procedure must recreate the entire database and is quite time
;	consuming.   Hopefully, one only has to run the procedure once.
; EXAMPLE:
;	gliese.dbf and gliese.dbd files have been FTPed over from a SUN
;	to a VAX.     Convert the internal format so that these files work
;	with the database software on the VAX
;    
;          IDL> !PRIV = 2
;          IDL> dbsuntohost,'gliese'
;     The logical name ZDBASE must have been set to point to the current
;     directory.
;  REVISION HISTORY:
;	Written W. Landsman              May 1992
;	Make sure that the IEEE flag is turned off     June 1996
;
;-
;--------------------------------------------------------------------------
if N_params() LT 1 then begin
       print,'Syntax - dbsuntohost,name
       print,'The <name>.dbf and <name>.dbd files must exist on the disk'
       return
endif
dbcreate,name,1
; open data base file
;
common db_com,qdb,qitems,qdrec
dbopen,name,1
;
; get some information on it
;
n_items = db_info( 'ITEMS' )  
length = db_info('LENGTH')
db_item,indgen(n_items),itnums,ivalnum,idltype,sbyte,numvals,nbytes
print,'n_items=',n_items
;
; convert header record
;
header=qdrec(0)
v=long(header,0,2)
byteorder, v, /NTOHL
n_entries=v(0)
header(0) = byte(v,0,8)
qdrec(0) = header
reclen = n_elements(header)
print,'n_entries = ',n_entries
;
; process in groups of 500 entries
;
block = bytarr(reclen,500)		;array to store 500 entries
nblocks = (n_entries+499)/500
for iblock = 0l,nblocks-1 do begin
;
; read block
;
	first = iblock*500+1		;first record in block
	last = (first+499)<n_entries	;last record in block
	nrecs = last-first+1		;number of records in block
	for i = 0l,nrecs-1 do block(0,i) = qdrec(first+i)	;read block
;
; convert block
;
	for it = 0,n_items-1 do begin
	    if (idltype(it) ne 1) and (idltype(it) ne 7) then begin
		b1 = sbyte(it)			;first byte to extract
		b2 = nbytes(it)*numvals(it)+b1-1 	;last byte to extract
		nb = b2-b1+1			;number of bytes
		data = block(b1:b2,0:nrecs-1)	;extract column
;
		case idltype(it) of
			2: byteorder,data,/NTOHS
			3: byteorder,data,/NTOHL
			4: byteorder,data,/XDRTOF
			5: byteorder,data,/XDRTOD
                        else:
		endcase

		 block(b1,0) = byte(data,0,nb,nrecs)
	    end
	end
;
; write block
;
	for i = 0,nrecs-1 do qdrec(first+i) = block(*,i)
end
qdb(119) = 0
units = qdb(96:97,0)			;unit numbers
for i = 0,1 do begin		;loop on units (2 per data base)
	if units(i) gt 0 then free_lun,units(i)
end

qdb = 0					;mark as closed

;   Check if the indexed file needs to be updated

dbopen,name,1
indextype = db_item_info('index',itnums)
index = where(indextype,nindex)                  ;Indexed items
if nindex GT 0 then begin
     message,'Now updating indexed file',/INFORM     
     dbindex,itnums(index)
endif
return
end			 

