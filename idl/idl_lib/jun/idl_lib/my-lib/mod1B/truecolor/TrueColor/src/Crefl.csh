#!/bin/csh

# Script to create MODIS corrected reflectance files

# Check the input arguments
if ($#argv != 4) then
  echo "Usage: Crefl.csh MOD01KM MOD02HKM MOD02QKM MOD03"
  exit(1)
endif
echo "(Creating MODIS corrected reflectance)"
ln -f -s $1 MOD021KM.hdf
ln -f -s $2 MOD02HKM.hdf
ln -f -s $3 MOD02QKM.hdf
ln -f -s $4 MOD03.hdf
setenv ANCPATH $HOME/NDVI/run
$HOME/NDVI/NDVI.src/crefl -f -v -1km  \
  MOD02HKM.hdf MOD02QKM.hdf MOD021KM.hdf -of=crefl.1km.hdf
$HOME/NDVI/NDVI.src/crefl -f -v -500m \
  MOD02HKM.hdf MOD02QKM.hdf MOD021KM.hdf -of=crefl.hkm.hdf
$HOME/NDVI/NDVI.src/crefl -f -v -250m \
  MOD02HKM.hdf MOD02QKM.hdf MOD021KM.hdf -of=crefl.qkm.hdf
