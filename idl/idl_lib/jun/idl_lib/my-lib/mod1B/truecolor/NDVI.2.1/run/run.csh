#!/bin/csh -x

limit stacksize 65435 

  #  Set BINPATH to the directory which contains the binaries
  setenv BINPATH ../src/

  #  Set ANCPATH to the directory which contains tbase.hdf
  setenv ANCPATH ./

  #  Set WORKPATH to a directory for the intermediate file and output file
  setenv WORKPATH ./

  #  Set the three input Level 1 .hdf files
  setenv L1DIR /raid/pub/gsfcdata/aqua/modis/level1/
  setenv MOD02QKM ${L1DIR}/MYD02QKM.A2003252.1734.001.2003259134515.hdf
  setenv MOD02HKM ${L1DIR}/MYD02HKM.A2003252.1734.001.2003259134515.hdf
  setenv MOD021KM ${L1DIR}/MYD021KM.A2003252.1734.001.2003259134515.hdf

  #  Set the desired output filename
  setenv NDVIFilename ${WORKPATH}/NDVI.A2003252.1734.001.2003259134515.hdf


  #  Run the algorithms
  ${BINPATH}/crefl.1.4 -v -f $MOD02HKM $MOD02QKM $MOD021KM -of=${WORKPATH}/crefl_output -bands=1,2,3,4,5,6,7
  ${BINPATH}/ndvi_evi.2.1  -of=$NDVIFilename -blue=3 -red=1 -nir=2  ${WORKPATH}/crefl_output

  #  Remove the intermediate file
  rm -f ${WORKPATH}/crefl_output




