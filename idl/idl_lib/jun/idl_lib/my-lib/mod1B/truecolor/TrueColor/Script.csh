#!/bin/csh -f
setenv MS2GT_DIR $HOME/ms2gt/bin
cd run
../src/Crefl.csh \
  ../data/MOD021KM.A2003021.1600.004.2003022113345.hdf \
  ../data/MOD02HKM.A2003021.1600.004.2003022113345.hdf \
  ../data/MOD02QKM.A2003021.1600.004.2003022113345.hdf \
  ../data/MOD03.A2003021.1600.004.2003022060031.hdf
cp ../src/map_parameters.in .
source /usr/local/rsi/idl/bin/idl_setup
idl ../src/idl_script.pro
../src/Convert.csh
