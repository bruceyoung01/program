
// how to read npp data
IDL> fid  =  H5f_open ('SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5')
IDL> d1 = h5d_open(fid, '/All_Data/VIIRS-DNB-SDR_All/Radiance')
IDL> data = h5d_read (d1 )
IDL> help, data
DATA            FLOAT     = Array[4064, 768]


// bring the strcture
d2 = h5g_open(fid, '/All_Data/VIIRS-DNB-SDR_All/')
result = h5_parse(d2, 'Radiance' , PATH = '/All_Data/VIIRS-DNB-SDR_All/',  /read_data)
help, result, /str
** Structure <105bce88>, 13 tags, length=12484760, data length=12484756, refs=1:
   _NAME           STRING    'Radiance'
   _ICONTYPE       STRING    'binary'
   _TYPE           STRING    'DATASET'
   _FILE           STRING    ''
   _PATH           STRING    '/All_Data/VIIRS-DNB-SDR_All/'
   _DATA           FLOAT     Array[4064, 768]
   _NDIMENSIONS    LONG                 2
   _DIMENSIONS     ULONG64   Array[2]
   _NELEMENTS      ULONG64                  3121152
   _DATATYPE       STRING    'H5T_FLOAT'
   _STORAGESIZE    ULONG                4
   _PRECISION      LONG                32
   _SIGN           STRING    ''



// use of h5_parse to get everything.
IDL> result = h5_parse('SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5', /read_data)
IDL> help, result, /structure   
** Structure <10690448>, 15 tags, length=15619472, data length=15619233, refs=1:
   _NAME           STRING    'SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5'
   _ICONTYPE       STRING    'hdf'
   _TYPE           STRING    'GROUP'
   _FILE           STRING    'SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5'
   _PATH           STRING    '/'
   _COMMENT        STRING    ''
   ALL_DATA        STRUCT    -> <Anonymous> Array[1]
   DATA_PRODUCTS   STRUCT    -> <Anonymous> Array[1]
   DISTRIBUTOR     STRUCT    -> <Anonymous> Array[1]
   MISSION_NAME    STRUCT    -> <Anonymous> Array[1]
   N_DATASET_SOURCE
                   STRUCT    -> <Anonymous> Array[1]
   N_HDF_CREATION_DATE
                   STRUCT    -> <Anonymous> Array[1]
   N_HDF_CREATION_TIME
                   STRUCT    -> <Anonymous> Array[1]
   N_GEO_REF       STRUCT    -> <Anonymous> Array[1]
   PLATFORM_SHORT_NAME
                   STRUCT    -> <Anonymous> Array[1]
IDL> help, result.ALL_DATA, /str
** Structure <1065e658>, 7 tags, length=15608272, data length=15608236, refs=2:
   _NAME           STRING    'All_Data'
   _ICONTYPE       STRING    ''
   _TYPE           STRING    'GROUP'
   _FILE           STRING    'SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5'
   _PATH           STRING    '/'
   _COMMENT        STRING    ''
   VIIRS_DNB_SDR_ALL
                   STRUCT    -> <Anonymous> Array[1]
IDL> help, result.ALL_DATA.VIIRS_DNB_SDR_ALL, /str
** Structure <10669b28>, 17 tags, length=15608176, data length=15608140, refs=2:
   _NAME           STRING    'VIIRS-DNB-SDR_All'
   _ICONTYPE       STRING    ''
   _TYPE           STRING    'GROUP'
   _FILE           STRING    'SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5'
   _PATH           STRING    '/All_Data'
   _COMMENT        STRING    ''
   MODEGRAN        STRUCT    -> <Anonymous> Array[1]
   MODESCAN        STRUCT    -> <Anonymous> Array[1]
   NUMBEROFBADCHECKSUMS
                   STRUCT    -> <Anonymous> Array[1]
   NUMBEROFDISCARDEDPKTS
                   STRUCT    -> <Anonymous> Array[1]
   NUMBEROFMISSINGPKTS
                   STRUCT    -> <Anonymous> Array[1]
   NUMBEROFSCANS   STRUCT    -> <Anonymous> Array[1]
   PADBYTE1        STRUCT    -> <Anonymous> Array[1]
   QF1_VIIRSDNBSDR STRUCT    -> <Anonymous> Array[1]
   QF2_SCAN_SDR    STRUCT    -> <Anonymous> Array[1]
   QF3_SCAN_RDR    STRUCT    -> <Anonymous> Array[1]
   RADIANCE        STRUCT    -> <Anonymous> Array[1]

