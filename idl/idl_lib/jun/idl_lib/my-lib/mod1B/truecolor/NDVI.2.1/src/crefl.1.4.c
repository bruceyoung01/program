/*
SGI:
  cc -64  -fullwarn -O2 crefl.1.4.c -o crefl.1.4 -I$HDFINC -L$HDFLIB -lmfhdf -ldf -lz -lm

DEC:
  cc -std -O crefl.1.4.c -o crefl.1.4 -I$HDFINC -L$HDFLIB -lmfhdf -ldf -lz -lm $HDFLIB/libjpeg.a

Linux
  cc -O crefl.1.4.c -o crefl.1.4 -I$HDFINC -L$HDFLIB -lmfhdf -ldf -lz -lm -ljpeg
*/

/*************************************************************************
Description:

  Simplified atmospheric correction algorithm that transforms MODIS
  top-of-the-atmosphere level-1B radiance data into corrected reflectance
  for Rapid Response applications.
  Required ancillary data: coarse resolution DEM tbase.hdf

References and Credits:

  Jacques Descloitres, MODIS Rapid Response Project, NASA/GSFC/SSAI
  http://rapidfire.sci.gsfc.nasa.gov

Revision history:

  Version 1.0   08/24/01
  Version 1.1   01/25/02
  Version 1.2   05/30/02
  Version 1.3   09/06/02
  Version 1.4   09/02/03

*************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mfhdf.h"

#define MAXNAMELENGTH 200
#define Nbands 7
#define DEG2RAD	0.0174532925199		/* PI/180 */
#define UO3	0.319
#define UH2O	2.93
#define REFLMIN -0.01
#define REFLMAX  1.6
#define ANCPATH		"."
#define DEMFILENAME	"tbase.hdf"
#define DEMSDSNAME	"Elevation"
#define REFSDS	SOLZ
#define MISSING	-2
#define SATURATED	-3
#define MAXSOLZ 86.5
#define MAXAIRMASS 18
#define	SCALEHEIGHT 8000
#define FILL_INT16	32767
#define	NUM1KMCOLPERSCAN	1354
#define	NUM1KMROWPERSCAN	10
#define MAXNUMSPHALBVALUES	3000
#define	TAUMAX	0.3
#define	TAUSTEP4SPHALB	(TAUMAX / (float)MAXNUMSPHALBVALUES)

typedef struct {
  char *name, *filename;
  int32 file_id, id, index, num_type, rank, n_attr, Nl, Np, *plane, Nplanes, rowsperscan;
  int32 start[MAX_VAR_DIMS], edges[MAX_VAR_DIMS], dim_sizes[MAX_VAR_DIMS];
  void *data, *fillvalue;
  float64 factor, offset;
} SDS;

int getatmvariables(float mus, float muv, float phi, int16 height, char *process, float *sphalb, float *rhoray, float *TtotraytH2O, float *tOG);
void chand(float phi, float muv, float mus, float *tau, float *rhoray, float *trup, float *trdown, char *process);
float csalbr(float tau);
double fintexp1(float tau);
double fintexp3(float tau);
float correctedrefl(float refl, float TtotraytH2O, float tOG, float rhoray, float sphalb);

enum {BAND1, BAND2, BAND3, BAND4, BAND5, BAND6, BAND7, SOLZ, SENZ, SOLA, SENA, LON, LAT, Nitems};

int main(int argc, char *argv[])
{
char MOD021KMfile[MAXNAMELENGTH], MOD02HKMfile[MAXNAMELENGTH], MOD02QKMfile[MAXNAMELENGTH], filename[MAXNAMELENGTH];
char *ancpath;
SDS sds[Nitems], outsds[Nbands], dem, height;
int32 MOD02QKMfile_id, MOD02HKMfile_id, MOD021KMfile_id, sd_id, attr_index, count, num_type;
int ib, j, iscan, Nscans, irow, jcol, idx, crsidx;
char SDSlocatorQKM[Nitems][30] = {"EV_250_RefSB", "EV_250_RefSB", "EV_500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "SolarZenith", "SensorZenith", "SolarAzimuth", "SensorAzimuth", "Longitude", "Latitude"};
char SDSlocatorHKM[Nitems][30] = {"EV_250_Aggr500_RefSB", "EV_250_Aggr500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "EV_500_RefSB", "SolarZenith", "SensorZenith", "SolarAzimuth", "SensorAzimuth", "Longitude", "Latitude"};
char SDSlocator1KM[Nitems][30] = {"EV_250_Aggr1km_RefSB", "EV_250_Aggr1km_RefSB", "EV_500_Aggr1km_RefSB", "EV_500_Aggr1km_RefSB", "EV_500_Aggr1km_RefSB", "EV_500_Aggr1km_RefSB", "EV_500_Aggr1km_RefSB", "SolarZenith", "SensorZenith", "SolarAzimuth", "SensorAzimuth", "Longitude", "Latitude"};
char indexlocator[Nitems] = {0, 1, 0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0};
char numtypelocator[Nitems] = { DFNT_UINT16, DFNT_UINT16, DFNT_UINT16, DFNT_UINT16, DFNT_UINT16, DFNT_UINT16, DFNT_UINT16, DFNT_INT16, DFNT_INT16, DFNT_INT16, DFNT_INT16, DFNT_FLOAT32, DFNT_FLOAT32 };
int16 *l1bdata[Nbands], *sola, *solz, *sena, *senz, *solzfill;
float32 *lon, *lat, *lonfill, *latfill;
char attr_name[50];
float64 scale_factor[Nitems], add_offset[Nitems];
char TOA=FALSE, nearest=FALSE, sealevel=FALSE, verbose=FALSE, force=FALSE, process[Nbands], gzip=FALSE;
char output1km=FALSE, output500m=FALSE;
char *ptr;
float refl, *mus, muv, phi;
float *rhoray, *sphalb, *TtotraytH2O, *tOG;
int aggfactor, crsrow1, crsrow2, crscol1, crscol2;
float mus0, mus11, mus12, mus21, mus22;
float fractrow, fractcol, t, u;
float rhoray0, rhoray11, rhoray12, rhoray21, rhoray22;
float sphalb0, sphalb11, sphalb12, sphalb21, sphalb22;
float reflmin=REFLMIN, reflmax=REFLMAX, maxsolz=MAXSOLZ;
int demrow1, demcol1, demrow2, demcol2;
int height11, height12, height21, height22;
HDF_CHUNK_DEF chunk_def;

  MOD021KMfile[0] = (char)NULL;
  MOD02HKMfile[0] = (char)NULL;
  MOD02QKMfile[0] = (char)NULL;
  filename[0] = (char)NULL;
  for (ib=0; ib<Nbands; ib++)
    process[Nbands] = FALSE;

  process[BAND1] = process[BAND3] = process[BAND4] = TRUE;

  for (j=1; j<argc; j++) {
    if ( strstr(argv[j], "-bands=") == argv[j] ) {
      while ( ptr = strchr(argv[j], 44) ) *ptr = 32;
      ptr = argv[j] + strlen("-bands=");
      while ( sscanf(ptr, "%d", &ib) == 1 ) {
        if (ib >= 1  &&  ib <= Nbands) process[ib - 1] = TRUE;
        if ( ptr = strchr(ptr, 32) ) ptr++;
                                else ptr = strchr(argv[j], (char)NULL);
      }
    } else if ( strstr(argv[j], "-of=") == argv[j] ) {
        if ( sscanf(argv[j], "-of=%s", filename) != 1 ) {
          fprintf(stderr, "Cannot parse output file\n");
          exit(-1);
        }
        if (verbose)
          printf("Output file: %s\n", filename);
    } else if ( strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MOD02QKM.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MYD02QKM.") == ptr ) {
        strcpy(MOD02QKMfile, argv[j]);
        if (verbose)
          printf("Input MOD02QKM/MYD02QKM file: %s\n", MOD02QKMfile);
    } else if ( strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MOD02HKM.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MYD02HKM.") == ptr ) {
        strcpy(MOD02HKMfile, argv[j]);
        if (verbose)
          printf("Input MOD02HKM/MYD02HKM file: %s\n", MOD02HKMfile);
    } else if ( strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MOD021KM.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MYD021KM.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MOD02CRS.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MYD02CRS.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MOD09CRS.") == ptr  ||
                strstr(ptr = MAX(strrchr(argv[j], 47) + 1, argv[j]), "MYD09CRS.") == ptr ) {
        strcpy(MOD021KMfile, argv[j]);
        if (verbose)
          printf("Input geolocation file: %s\n", MOD021KMfile);
    } else if ( strstr(argv[j], "-range=") == argv[j] ) {
        if ( sscanf(argv[j], "-range=%g,%g", &reflmin, &reflmax) != 2 ) {
          fprintf(stderr, "Cannot parse output range\n");
          exit(-1);
        }
        if (verbose)
          printf("Output range: %g-%g\n", reflmin, reflmax);
    } else if ( strstr(argv[j], "-maxsolz=") == argv[j] ) {
        if ( sscanf(argv[j], "-maxsolz=%g", &maxsolz) != 1 ) {
          fprintf(stderr, "Cannot parse max. solar zenith angle\n");
          exit(-1);
        }
        if (verbose)
          printf("Max. solar zenith angle: %g\n", maxsolz);
    } else if ( strcmp(argv[j], "-1km") == 0 ) {
        output1km = TRUE;
        printf("1km-resolution output requested\n");
    } else if ( strcmp(argv[j], "-500m") == 0 ) {
        output500m = TRUE;
        printf("500m-resolution output requested\n");
    } else if ( strcmp(argv[j], "-gzip") == 0 ) {
        gzip = TRUE;
        if (verbose)
          printf("Gzip compression requested\n");
    } else if ( strcmp(argv[j], "-v") == 0 ) {
        verbose = TRUE;
        printf("Verbose mode requested\n");
    } else if ( strcmp(argv[j], "-f") == 0 ) {
        force = TRUE;
        printf("Force overwrite existing output file\n");
    }
  }
  if ( MOD021KMfile[0] == (char)NULL  ||	/* Mandatory for angles */
       MOD02HKMfile[0] == (char)NULL  &&	/* HKM file is mandatory */
       ! output1km  ||			/* Unless 1km output is requested */
       MOD02QKMfile[0] == (char)NULL  &&	/* QKM file is mandatory */
       ! output500m  &&			/* Unless 500m or 1km output is requested */
       ! output1km  ||
       filename[0] == (char)NULL ) {		/* Output filename is mandatory */
    fprintf(stderr, "Unable to parse all arguments\n");
    fprintf(stderr, "Usage: crefl [-f] [-1km|-500m] [-v] [-range=min,max] <MOD02HKM file> <MOD02QKM file> <MOD021KM|MOD02CRS|MOD09CRS file> -of=<output file> -bands=<band1,band2,band3,...>\n");
    exit(-1);
  }

  if ( MOD02QKMfile[0]  &&
       ! output500m  &&
       ! output1km  &&
       (MOD02QKMfile_id = SDstart(MOD02QKMfile, DFACC_READ)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", MOD02QKMfile);
    exit(-1);
  }
  if ( MOD02HKMfile[0]  &&
       ! output1km  &&
       (MOD02HKMfile_id = SDstart(MOD02HKMfile, DFACC_READ)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", MOD02HKMfile);
    exit(-1);
  }
  if ( MOD021KMfile[0]  &&
       (MOD021KMfile_id = SDstart(MOD021KMfile, DFACC_READ)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", MOD021KMfile);
    exit(-1);
  }
  dem.filename = (char*)malloc(MAXNAMELENGTH * sizeof(char));
  if ((ancpath = getenv("ANCPATH")) == NULL)
    sprintf(dem.filename, "%s/%s", ANCPATH, DEMFILENAME);
  else
    sprintf(dem.filename, "%s/%s", ancpath, DEMFILENAME);
  if ( (dem.file_id = SDstart(dem.filename, DFACC_READ)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", dem.filename);
    exit(-1);
  }
  if ( ! force  &&  fopen(filename, "r") != NULL ) {
    fprintf(stderr, "File %s already exits.\n", filename);
    exit(-1);
  }

  if (output500m) {
      sds[BAND1].file_id = sds[BAND2].file_id = MOD02HKMfile_id;
      sds[BAND1].filename = sds[BAND2].filename = MOD02HKMfile;
  } else if (output1km) {
      sds[BAND1].file_id = sds[BAND2].file_id = MOD021KMfile_id;
      sds[BAND1].filename = sds[BAND2].filename = MOD021KMfile;
  } else {
      sds[BAND1].file_id = sds[BAND2].file_id = MOD02QKMfile_id;
      sds[BAND1].filename = sds[BAND2].filename = MOD02QKMfile;
  }
  if (output1km) {
      sds[BAND3].file_id = sds[BAND4].file_id = sds[BAND5].file_id = sds[BAND6].file_id = sds[BAND7].file_id = MOD021KMfile_id;
      sds[BAND3].filename = sds[BAND4].filename = sds[BAND5].filename = sds[BAND6].filename = sds[BAND7].filename = MOD021KMfile;
  } else {
      sds[BAND3].file_id = sds[BAND4].file_id = sds[BAND5].file_id = sds[BAND6].file_id = sds[BAND7].file_id = MOD02HKMfile_id;
      sds[BAND3].filename = sds[BAND4].filename = sds[BAND5].filename = sds[BAND6].filename = sds[BAND7].filename = MOD02HKMfile;
  }
  sds[SOLZ].file_id = sds[SOLA].file_id = sds[SENZ].file_id = sds[SENA].file_id = sds[LON].file_id = sds[LAT].file_id = MOD021KMfile_id;
  sds[SOLZ].filename = sds[SOLA].filename = sds[SENZ].filename = sds[SENA].filename = sds[LON].filename = sds[LAT].filename = MOD021KMfile;

  for (ib=0; ib<Nitems; ib++) {
    if ( ib < Nbands  &&
         ! process[ib] ) {
      sds[ib].id = -1;
      continue;
    }
    if (output500m)
      sds[ib].name = SDSlocatorHKM[ib];
    else if (output1km)
      sds[ib].name = SDSlocator1KM[ib];
    else
      sds[ib].name = SDSlocatorQKM[ib];
    if ( (sds[ib].index = SDnametoindex(sds[ib].file_id, sds[ib].name)) == -1 ) {
      fprintf(stderr, "Cannot find SDS %s in file %s.\n", sds[ib].name, sds[ib].filename);
      continue;
    }
    if ( (sds[ib].id = SDselect(sds[ib].file_id, sds[ib].index)) == -1 ) {
      fprintf(stderr, "Cannot select SDS no. %d\n", sds[ib].index);
      if (ib < Nbands)
        process[ib] = FALSE;
      continue;
    }
    if (SDgetinfo(sds[ib].id, sds[ib].name, &sds[ib].rank, sds[ib].dim_sizes, &sds[ib].num_type, &sds[ib].n_attr) == -1) {
      fprintf(stderr, "Can't get info from SDS \"%s\" in file %s.\n", sds[ib].name, sds[ib].filename);
      SDendaccess(sds[ib].id);
      sds[ib].id = -1;
      if (ib < Nbands)
        process[ib] = FALSE;
      continue;
    }

    sds[ib].factor = 1;
    strcpy(attr_name, "reflectance_scales");
    if ( (attr_index = SDfindattr(sds[ib].id, attr_name)) != -1  &&
         SDattrinfo(sds[ib].id, attr_index, attr_name, &num_type, &count) != -1  &&
         SDreadattr(sds[ib].id, attr_index, scale_factor) != -1 )
      sds[ib].factor = ((float32 *)scale_factor)[indexlocator[ib]];
    else if ( strcpy(attr_name, "scale_factor") != NULL  &&
              (attr_index = SDfindattr(sds[ib].id, attr_name)) != -1  &&
              SDattrinfo(sds[ib].id, attr_index, attr_name, &num_type, &count) != -1  &&
              SDreadattr(sds[ib].id, attr_index, scale_factor) != -1 )
      sds[ib].factor = *scale_factor;

    sds[ib].offset = 0;
    strcpy(attr_name, "reflectance_offsets");
    if ( (attr_index = SDfindattr(sds[ib].id, attr_name)) != -1  &&
         SDattrinfo(sds[ib].id, attr_index, attr_name, &num_type, &count) != -1  &&
         SDreadattr(sds[ib].id, attr_index, add_offset) != -1 )
      sds[ib].offset = ((float32 *)add_offset)[indexlocator[ib]];
    else if ( strcpy(attr_name, "add_offset") != NULL  &&
              (attr_index = SDfindattr(sds[ib].id, attr_name)) != -1  &&
              SDattrinfo(sds[ib].id, attr_index, attr_name, &num_type, &count) != -1  &&
              SDreadattr(sds[ib].id, attr_index, add_offset) != -1 )
      sds[ib].offset = *add_offset;

    sds[ib].fillvalue = (void *) malloc(1 * DFKNTsize(sds[ib].num_type));
    if ( SDgetfillvalue(sds[ib].id, sds[ib].fillvalue) != 0 ) {
      fprintf(stderr, "Cannot read fill value of SDS \"%s\".\n", sds[ib].name);
      exit(-1);
    }

    switch (sds[ib].rank) {
      case 2:
        sds[ib].Nl = sds[ib].dim_sizes[0];
        sds[ib].Np = sds[ib].dim_sizes[1];
        sds[ib].rowsperscan = (int)(NUM1KMROWPERSCAN * sds[ib].Np / (float)NUM1KMCOLPERSCAN + 0.5);
        sds[ib].start[1] = 0;
        sds[ib].edges[0] = sds[ib].rowsperscan;
        sds[ib].edges[1] = sds[ib].Np;
        break;
      case 3:
        sds[ib].Nl = sds[ib].dim_sizes[1];
        sds[ib].Np = sds[ib].dim_sizes[2];
        sds[ib].rowsperscan = (int)(NUM1KMROWPERSCAN * sds[ib].Np / (float)NUM1KMCOLPERSCAN + 0.5);
        sds[ib].start[0] = indexlocator[ib];
        sds[ib].start[2] = 0;
        sds[ib].edges[0] = 1;
        sds[ib].edges[1] = sds[ib].rowsperscan;
        sds[ib].edges[2] = sds[ib].Np;
        break;
      default:
        fprintf(stderr, "SDS rank must be 2 or 3.\n");
        continue;
    }
    if (verbose)
      printf("SDS \"%s\": %dx%d   scale factor: %g  offset: %g\n", sds[ib].name, sds[ib].Np, sds[ib].Nl, sds[ib].factor, sds[ib].offset);
    if (sds[ib].num_type != numtypelocator[ib]) {
      fprintf(stderr, "SDS \"%s\" has not the expected data type.\n", sds[ib].name);
      exit(-1);
    }
    sds[ib].data = malloc(sds[ib].Np * sds[ib].rowsperscan * DFKNTsize(sds[ib].num_type));
  }

  dem.name = strdup(DEMSDSNAME);
  if ( (dem.index = SDnametoindex(dem.file_id, dem.name)) == -1 ) {
    fprintf(stderr, "Cannot find SDS %s in file %s.\n", dem.name, dem.filename);
    exit(-1);
  }
  if ( (dem.id = SDselect(dem.file_id, dem.index)) == -1 ) {
    fprintf(stderr, "Cannot select SDS no. %d\n", dem.index);
    exit(-1);
  }
  if (SDgetinfo(dem.id, dem.name, &dem.rank, dem.dim_sizes, &dem.num_type, &dem.n_attr) == -1) {
    fprintf(stderr, "Can't get info from SDS \"%s\" in file %s.\n", dem.name, dem.filename);
    SDendaccess(dem.id);
    exit(-1);
  }
  dem.Nl = dem.dim_sizes[0];
  dem.Np = dem.dim_sizes[1];
  dem.rowsperscan = (int)(NUM1KMROWPERSCAN * dem.Np / (float)NUM1KMCOLPERSCAN + 0.5);

  if ( sds[SOLZ].id == -1  ||
       sds[SOLA].id == -1  ||
       sds[SENZ].id == -1  ||
       sds[SENA].id == -1  ||
       sds[LON].id == -1  ||
       sds[LAT].id == -1  ||
       dem.id == -1  ) {
    fprintf(stderr, "Solar and Sensor angles and DEM are necessary to process granule.\n");
    exit(-1);
  }

  if ( sds[REFSDS].Np != sds[SOLZ].Np  ||
       sds[REFSDS].Np != sds[SOLA].Np  ||
       sds[REFSDS].Np != sds[SENZ].Np  ||
       sds[REFSDS].Np != sds[SENA].Np  ||
       sds[REFSDS].Np != sds[LON].Np  ||
       sds[REFSDS].Np != sds[LAT].Np ) {
    fprintf(stderr, "Solar and Sensor angles must have identical dimensions.\n");
    exit(-1);
  }

  ib = 0;
  while (sds[ib].id == -1) ib++;
  if (ib >= Nbands) {
    fprintf(stderr, "No L1B SDS can be read successfully.\n");
    exit(-1);
  }
  Nscans = sds[ib].Nl / sds[ib].rowsperscan;

  if ( (sd_id = SDstart(filename, DFACC_CREATE)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", filename);
    exit(-1);
  }

  for (ib=0; ib<Nbands; ib++) {
    if (! process[ib])
      continue;
    outsds[ib].num_type = DFNT_INT16;
    outsds[ib].factor = 0.0001;
    outsds[ib].offset = 0;
    outsds[ib].rank = 2;
    outsds[ib].name = (char *) malloc(50 * sizeof(char));
    sprintf(outsds[ib].name, "CorrRefl_%2.2d", ib + 1);
    outsds[ib].Nl = outsds[ib].dim_sizes[0] = sds[ib].Nl;
    outsds[ib].Np = outsds[ib].dim_sizes[1] = sds[ib].Np;
    outsds[ib].rowsperscan = sds[ib].rowsperscan;
    if (verbose)
      printf("Creating SDS %s: %dx%d\n", outsds[ib].name, outsds[ib].Np, outsds[ib].Nl);
    if ((outsds[ib].id = SDcreate(sd_id, outsds[ib].name, outsds[ib].num_type, outsds[ib].rank, outsds[ib].dim_sizes)) == -1) {
      fprintf(stderr, "Cannot create SDS %s\n", outsds[ib].name);
      exit(-1);
    }
    outsds[ib].fillvalue = (void *) malloc(1 * DFKNTsize(outsds[ib].num_type));
    *(int16 *)outsds[ib].fillvalue = FILL_INT16;
    if ( SDsetfillvalue(outsds[ib].id, outsds[ib].fillvalue) != 0 ) {
      fprintf(stderr, "Cannot write fill value of SDS %s\n", outsds[ib].name);
      exit(-1);
    }
    outsds[ib].start[1] = 0;
    outsds[ib].edges[0] = outsds[ib].rowsperscan;
    outsds[ib].edges[1] = outsds[ib].Np;
    outsds[ib].data = malloc(outsds[ib].rowsperscan * outsds[ib].Np * DFKNTsize(outsds[ib].num_type));
    if (gzip) {
      chunk_def.chunk_lengths[0] = chunk_def.comp.chunk_lengths[0] = outsds[ib].edges[0];
      chunk_def.chunk_lengths[1] = chunk_def.comp.chunk_lengths[1] = outsds[ib].edges[1];
      chunk_def.comp.comp_type = COMP_CODE_DEFLATE;
      chunk_def.comp.cinfo.deflate.level = 4;
      if (SDsetchunk(outsds[ib].id, chunk_def, HDF_CHUNK | HDF_COMP) == FAIL) {
        fprintf(stderr, "Cannot set chunks for SDS %s\n", outsds[ib].name);
        exit(-1);
      }
    }
  }

  mus = (float *) malloc(sds[REFSDS].rowsperscan * sds[REFSDS].Np * sizeof(float));
  height.data = (int16 *) malloc(sds[REFSDS].rowsperscan * sds[REFSDS].Np * sizeof(int16));
  dem.data = (int16 *) malloc(dem.Nl * dem.Np * sizeof(int16));
  if (! TOA) {
    rhoray =      (float *) malloc(Nbands * sds[REFSDS].rowsperscan * sds[REFSDS].Np * sizeof(float));
    sphalb =      (float *) malloc(Nbands * sds[REFSDS].rowsperscan * sds[REFSDS].Np * sizeof(float));
    TtotraytH2O = (float *) malloc(Nbands * sds[REFSDS].rowsperscan * sds[REFSDS].Np * sizeof(float));
    tOG =         (float *) malloc(Nbands * sds[REFSDS].rowsperscan * sds[REFSDS].Np * sizeof(float));
  }

  solz = sds[SOLZ].data;
  sola = sds[SOLA].data;
  senz = sds[SENZ].data;
  sena = sds[SENA].data;
  solzfill = sds[SOLZ].fillvalue;
  lon = sds[LON].data;
  lat = sds[LAT].data;
  lonfill = sds[LON].fillvalue;
  latfill = sds[LAT].fillvalue;
  for (ib=0; ib<Nbands; ib++)
    l1bdata[ib] = sds[ib].data;

  dem.start[0] = 0;
  dem.start[1] = 0;
  dem.edges[0] = dem.Nl;
  dem.edges[1] = dem.Np;
  if (SDreaddata(dem.id, dem.start, NULL, dem.edges, dem.data) == -1) {
    fprintf(stderr, "  Can't read SDS \"%s\"\n", dem.name);
    exit(-1);
  }

  for (iscan=0; iscan<Nscans; iscan++) {

    if ( iscan % NUM1KMROWPERSCAN == 0  &&
         verbose )
      printf("Processing scan %d...\n", iscan);
    for (ib=0; ib<Nitems; ib++) {
      if (sds[ib].id == -1)
        continue;
      switch (sds[ib].rank) {
        case 2: sds[ib].start[0] = iscan * sds[ib].rowsperscan;  break;
        case 3: sds[ib].start[1] = iscan * sds[ib].rowsperscan;  break;
      }
      if (SDreaddata(sds[ib].id, sds[ib].start, NULL, sds[ib].edges, sds[ib].data) == -1) {
        fprintf(stderr, "  Can't read scan %d of SDS \"%s\"\n", iscan, sds[ib].name);
        break;
      }
    }
    if (ib < Nitems) break;

    for (idx=0; idx<sds[REFSDS].rowsperscan*sds[REFSDS].Np; idx++) {
      if (solz[idx] * sds[SOLZ].factor >= maxsolz)
        solz[idx] = *solzfill;
      if ( ! sealevel  &&
           (lon[idx] == *lonfill  ||  lat[idx] == *latfill) )
	solz[idx] = *solzfill;
      if (solz[idx] != *solzfill)
        mus[idx] = cos(solz[idx] * sds[SOLZ].factor * DEG2RAD);
    }

    for (idx=0; idx<sds[REFSDS].rowsperscan*sds[REFSDS].Np; idx++)
      if (solz[idx] != *solzfill) {
        if (sealevel)
          ((int16 *)height.data)[idx] = 0;
        else {
          fractrow = ( 90 - lat[idx]) * dem.Nl / 180;
          demrow1 = floor(fractrow);
          demrow2 = demrow1 + 1;
          if (demrow1 < 0) demrow1 = demrow2 + 1;
          if (demrow2 > dem.Nl - 1) demrow2 = demrow1 - 1;
          t = (fractrow - demrow1) / (demrow2 - demrow1);
          fractcol = (lon[idx] + 180) * dem.Np / 360;
          demcol1 = floor(fractcol);
          demcol2 = demcol1 + 1;
          if (demcol1 < 0) demcol1 = demcol2 + 1;
          if (demcol2 > dem.Np - 1) demcol2 = demcol1 - 1;
          u = (fractcol - demcol1) / (demcol2 - demcol1);
          height11 = ((int16 *)dem.data)[demrow1 * dem.Np + demcol1];
          height12 = ((int16 *)dem.data)[demrow1 * dem.Np + demcol2];
          height21 = ((int16 *)dem.data)[demrow2 * dem.Np + demcol1];
          height22 = ((int16 *)dem.data)[demrow2 * dem.Np + demcol2];
          ((int16 *)height.data)[idx] = t * u * height22 + t * (1 - u) * height21 + (1 - t) * u * height12 + (1 - t) * (1 - u) * height11;
          if (((int16 *)height.data)[idx] < 0)
            ((int16 *)height.data)[idx] = 0;
        }
      }

    if (! TOA) {

      for (irow=0; irow<sds[REFSDS].rowsperscan; irow++) {
        for (jcol=0; jcol<sds[REFSDS].Np; jcol++) {
          idx = irow * sds[REFSDS].Np + jcol;
          if (solz[idx] == *solzfill)
            continue;
          phi = sola[idx] * sds[SOLA].factor - sena[idx] * sds[SENA].factor;
          muv = cos(senz[idx] * sds[SENZ].factor * DEG2RAD);
          if ( getatmvariables(mus[idx], muv, phi, ((int16 *)height.data)[idx], process,
                               &sphalb[idx * Nbands], &rhoray[idx * Nbands],
                               &TtotraytH2O[idx * Nbands], &tOG[idx * Nbands]) == -1 )
            solz[idx] = *solzfill;
        }
      }

    }

    for (ib=0; ib<Nbands; ib++) {
      if (! process[ib])
        continue;
      aggfactor = outsds[ib].rowsperscan / sds[REFSDS].rowsperscan;
      for (irow=0; irow<outsds[ib].rowsperscan; irow++) {
        if (! nearest) {
          fractrow = (float)irow / aggfactor - 0.5;	/* We want fractrow integer on coarse pixel center */
          crsrow1 = floor(fractrow);
          crsrow2 = crsrow1 + 1;
          if (crsrow1 < 0)
            crsrow1 = crsrow2 + 1;
          if (crsrow2 > sds[REFSDS].rowsperscan - 1)
            crsrow2 = crsrow1 - 1;
          t = (fractrow - crsrow1) / (crsrow2 - crsrow1);
        }
        for (jcol=0; jcol<outsds[ib].Np; jcol++) {
          idx = irow * outsds[ib].Np + jcol;
          crsidx = (int)(irow / aggfactor) * sds[REFSDS].Np + (int)(jcol / aggfactor);
          if ( solz[crsidx] == *solzfill  ||	/* Bad geolocation or night pixel */
               l1bdata[ib][idx] < 0 ) {		/* L1B is read as int16, not uint16, so faulty is negative */
            if (l1bdata[ib][idx] == MISSING)
              ((int16 *)outsds[ib].data)[idx] = 32768 + MISSING;
            else if (l1bdata[ib][idx] == SATURATED)
              ((int16 *)outsds[ib].data)[idx] = 32768 + SATURATED;
            else
              ((int16 *)outsds[ib].data)[idx] = *(int16 *)outsds[ib].fillvalue;
            continue;
          }
          if (nearest) {
              mus0 = mus[crsidx];
              if (! TOA) {
                rhoray0 = rhoray[crsidx * Nbands + ib];
                sphalb0 = sphalb[crsidx * Nbands + ib];
              }
          } else {
              fractcol = (float)jcol / aggfactor - 0.5;	/* We want fractcol integer on coarse pixel center */
              crscol1 = floor(fractcol);
              crscol2 = crscol1 + 1;
              if (crscol1 < 0)
                crscol1 = crscol2 + 1;
              if (crscol2 > sds[REFSDS].Np - 1)
                crscol2 = crscol1 - 1;
              u = (fractcol - crscol1) / (crscol2 - crscol1);		/* We want u=0 on coarse pixel center */
              mus11 = mus[crsrow1 * sds[REFSDS].Np + crscol1];
              mus12 = mus[crsrow1 * sds[REFSDS].Np + crscol2];
              mus21 = mus[crsrow2 * sds[REFSDS].Np + crscol1];
              mus22 = mus[crsrow2 * sds[REFSDS].Np + crscol2];
              mus0 = t * u * mus22 + (1 - t) * u * mus12 + t * (1 - u) * mus21 + (1 - t) * (1 - u) * mus11;
              if (! TOA) {
                rhoray11 = rhoray[(crsrow1 * sds[REFSDS].Np + crscol1) * Nbands + ib];
                rhoray12 = rhoray[(crsrow1 * sds[REFSDS].Np + crscol2) * Nbands + ib];
                rhoray21 = rhoray[(crsrow2 * sds[REFSDS].Np + crscol1) * Nbands + ib];
                rhoray22 = rhoray[(crsrow2 * sds[REFSDS].Np + crscol2) * Nbands + ib];
                rhoray0 = t * u * rhoray22 + (1 - t) * u * rhoray12 + t * (1 - u) * rhoray21 + (1 - t) * (1 - u) * rhoray11;
                sphalb11 = sphalb[(crsrow1 * sds[REFSDS].Np + crscol1) * Nbands + ib];
                sphalb12 = sphalb[(crsrow1 * sds[REFSDS].Np + crscol2) * Nbands + ib];
                sphalb21 = sphalb[(crsrow2 * sds[REFSDS].Np + crscol1) * Nbands + ib];
                sphalb22 = sphalb[(crsrow2 * sds[REFSDS].Np + crscol2) * Nbands + ib];
                sphalb0 = t * u * sphalb22 + (1 - t) * u * sphalb12 + t * (1 - u) * sphalb21 + (1 - t) * (1 - u) * sphalb11;
              }
          }
          refl = (l1bdata[ib][idx] - sds[ib].offset) * sds[ib].factor / mus0;
          if (! TOA)
            refl = correctedrefl(refl, TtotraytH2O[crsidx * Nbands + ib], tOG[crsidx * Nbands + ib], rhoray0, sphalb0);
          if (refl > reflmax) refl = reflmax;
          if (refl < reflmin) refl = reflmin;
          ((int16 *)outsds[ib].data)[idx] = refl / outsds[ib].factor + 0.5;
        }
      }
    }
    for (ib=0; ib<Nbands; ib++) {
      if (! process[ib])
        continue;
      outsds[ib].start[0] = iscan * outsds[ib].rowsperscan;
      if (SDwritedata(outsds[ib].id, outsds[ib].start, NULL, outsds[ib].edges, outsds[ib].data) == -1) {
        fprintf(stderr, "Cannot write scan %d of SDS %s\n", iscan, outsds[ib].name);
        exit(-1);
      }
    }
  }

  for (ib=0; ib<Nitems; ib++)
    if (sds[ib].id != -1)
      SDendaccess(sds[ib].id);

  for (ib=0; ib<Nbands; ib++)
    if (process[ib])
      SDendaccess(outsds[ib].id);

  SDend(MOD02QKMfile_id);
  SDend(MOD02HKMfile_id);
  SDend(MOD021KMfile_id);
  SDend(sd_id);

  return 0;

}




float csalbr(float tau)
{
  return (3 * tau - fintexp3(tau) * (4 + 2 * tau) + 2 * expf(-tau)) / (4 + 3 * tau);
}




double fintexp1(float tau)
{
double xx, xftau;
int i;
const float a[6] = {-.57721566, 0.99999193,-0.24991055,
                    0.05519968,-0.00976004, 0.00107857};
  xx = a[0];
  xftau = 1.;
  for (i=1; i<6; i++) {
    xftau *= tau;
    xx += a[i] * xftau;
  }
  return xx - logf(tau);
}




double fintexp3(float tau)
{
  return (expf(-tau) * (1. - tau) + tau * tau * fintexp1(tau)) / 2.;
}




void chand(float phi, float muv, float mus, float *taur, float *rhoray, float *trup, float *trdown, char *process)
{
/*
phi: azimuthal difference between sun and observation in degree
     (phi=0 in backscattering direction)
mus: cosine of the sun zenith angle
muv: cosine of the observation zenith angle
taur: molecular optical depth
rhoray: molecular path reflectance
constant xdep: depolarization factor (0.0279)
         xfd = (1-xdep/(2-xdep)) / (1 + 2*xdep/(2-xdep)) = 2 * (1 - xdep) / (2 + xdep) = 0.958725775
*/
const double xfd=0.958725775;
const float xbeta2=0.5;
float pl[5];
double fs01,fs02,fs0, fs1,fs2;
const float as0[10] = {0.33243832, 0.16285370, -0.30924818, -0.10324388, 0.11493334,
                       -6.777104e-02, 1.577425e-03, -1.240906e-02, 3.241678e-02, -3.503695e-02};
const float as1[2] = {.19666292, -5.439061e-02};
const float as2[2] = {.14545937,-2.910845e-02};
float phios,xcosf1,xcosf2,xcosf3;
float xph1,xph2,xph3,xitm1,xitm2;
float xlntaur,xitot1,xitot2,xitot3;
int i,ib;

  phios = phi + 180;
  xcosf1 = 1.;
  xcosf2 = cosf(phios * DEG2RAD);
  xcosf3 = cosf(2 * phios * DEG2RAD);
  xph1 = 1 + (3 * mus * mus - 1) * (3 * muv * muv - 1) * xfd / 8.;
  xph2 = - xfd * xbeta2 * 1.5 * mus * muv * sqrtf(1 - mus * mus) * sqrtf(1 - muv * muv);
  xph3 =   xfd * xbeta2 * 0.375 * (1 - mus * mus) * (1 - muv * muv);
  pl[0] = 1.;
  pl[1] = mus + muv;
  pl[2] = mus * muv;
  pl[3] = mus * mus + muv * muv;
  pl[4] = mus * mus * muv * muv;
  fs01 = fs02 = 0;
  for (i=0; i<5; i++) fs01 += pl[i] * as0[i];
  for (i=0; i<5; i++) fs02 += pl[i] * as0[5 + i];
  for (ib=0; ib<Nbands; ib++) {
    if (process[ib]) {
      xlntaur = logf(taur[ib]);
      fs0 = fs01 + fs02 * xlntaur;
      fs1 = as1[0] + xlntaur * as1[1];
      fs2 = as2[0] + xlntaur * as2[1];
      trdown[ib] = expf(-taur[ib]/mus);
      trup[ib]   = expf(-taur[ib]/muv);
      xitm1 = (1 - trdown[ib] * trup[ib]) / 4. / (mus + muv);
      xitm2 = (1 - trdown[ib]) * (1 - trup[ib]);
      xitot1 = xph1 * (xitm1 + xitm2 * fs0);
      xitot2 = xph2 * (xitm1 + xitm2 * fs1);
      xitot3 = xph3 * (xitm1 + xitm2 * fs2);
      rhoray[ib] = xitot1 * xcosf1 + xitot2 * xcosf2 * 2 + xitot3 * xcosf3 * 2;
    }
  }

}




int getatmvariables(float mus, float muv, float phi, int16 height, char *process, float *sphalb, float *rhoray, float *TtotraytH2O, float *tOG)
{
double m, Ttotrayu, Ttotrayd, tO3, tO2, tH2O, psurfratio;
int j, ib;
const float aH2O[Nbands]={ -5.60723, -5.25251, 0, 0, -6.29824, -7.70944, -3.91877 };
const float bH2O[Nbands]={ 0.820175, 0.725159, 0, 0, 0.865732, 0.966947, 0.745342 };
const float aO3[Nbands]={ 0.0715289, 0, 0.00743232, 0.089691, 0, 0, 0 };
const float taur0[Nbands] = { 0.05100, 0.01631, 0.19325, 0.09536, 0.00366, 0.00123, 0.00043 };
float taur[Nbands], trup[Nbands], trdown[Nbands];
float sphalb0[MAXNUMSPHALBVALUES];
static char first_time=TRUE;

  if (first_time) {
    sphalb0[0] = 0;
    for(j=1; j<MAXNUMSPHALBVALUES; j++)		/* taur <= 0.3 for bands 1 to 7 (including safety margin for height<~0) */
      sphalb0[j] = csalbr(j * TAUSTEP4SPHALB);
    first_time = FALSE;
  }

  m = 1 / mus + 1 / muv;
  if (m > MAXAIRMASS) return -1;

  psurfratio = expf(-height / (float)SCALEHEIGHT);
  for (ib=0; ib<Nbands; ib++)
    if (process[ib])
      taur[ib] = taur0[ib] * psurfratio;

  chand(phi, muv, mus, taur, rhoray, trup, trdown, process);

  for (ib=0; ib<Nbands; ib++)
    if (process[ib]) {
      sphalb[ib] = sphalb0[(int)(taur[ib] / TAUSTEP4SPHALB + 0.5)];
      Ttotrayu = ((2 / 3. + muv) + (2 / 3. - muv) * trup[ib])   / (4 / 3. + taur[ib]);
      Ttotrayd = ((2 / 3. + mus) + (2 / 3. - mus) * trdown[ib]) / (4 / 3. + taur[ib]);
      tO3 = tO2 = tH2O = 1;
      if (aO3[ib] != 0) tO3 = expf(-m * UO3 * aO3[ib]);
      if (bH2O[ib] != 0) tH2O = expf(-expf(aH2O[ib] + bH2O[ib] * logf(m * UH2O)));
/*
      t02 = expf(-m * aO2);
*/
      TtotraytH2O[ib] = Ttotrayu * Ttotrayd * tH2O;
      tOG[ib] = tO3 * tO2;
    }

  return 0;

}




float correctedrefl(float refl, float TtotraytH2O, float tOG, float rhoray, float sphalb)
{
float corr_refl;

  corr_refl = (refl / tOG - rhoray) / TtotraytH2O;
  corr_refl /= (1 + corr_refl * sphalb);
  return corr_refl;
}
