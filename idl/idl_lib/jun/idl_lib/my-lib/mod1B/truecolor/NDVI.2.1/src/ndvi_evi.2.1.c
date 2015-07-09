/*
SGI:
  cc -64 -fullwarn -O2 ndvi_evi.2.1.c -o ndvi_evi.2.1 -I$HDFINC -L$HDFLIB -lmfhdf -ldf -lz -ljpeg -lm

Linux:
  cc -O ndvi_evi.2.1.c -o ndvi_evi.2.1 -I$HDFINC -L$HDFLIB -lmfhdf -ldf -lz -lm -ljpeg
*/

/*************************************************************************
Description:

  This code computes NDVI a simplified EVI from a corrected reflectance
  product derived from MODIS data for Rapid Response applications.

References and Credits:

  Jacques Descloitres, MODIS Rapid Response Project, NASA/GSFC/SSAI
  http://rapidfire.sci.gsfc.nasa.gov

Revision history:

  Version 1.0   08/15/01
  Version 2.0   05/30/02
  Version 2.1   09/02/03

*************************************************************************/

#include <stdio.h>
#include "mfhdf.h"
#include <math.h>

#define MAXNAMELENGTH 200
#define UNDEF -9999
#define MAXVI	1.1
#define MINVI	-0.1
#define DEFAULTFILLVALUE 32767
#define DEFSCALEFACTOR 0.0001
#define DEFSCALEOFFSET 0.

typedef struct {
  char name[MAXNAMELENGTH];
  int32 id, index, num_type, rank, n_attr, Nl, Np;
  int32 start[MAX_VAR_DIMS], edges[MAX_VAR_DIMS], dim_sizes[MAX_VAR_DIMS];
  void *data, *fillvalue;
  float64 factor, offset;
  int pixszratio;
} SDS;

float NDVI(float red, float nir, float fillvalue);
float EVI(float blue, float red, float nir, float fillvalue);
void compute_250m_row(void *row500m, void *row250m, int ncols, int32 datatype, float *fillvalue);

enum {BLUE, RED, NIR, NUMSDS};

int main(int argc, char *argv[])
{
char filename1[MAXNAMELENGTH], filename2[MAXNAMELENGTH];
SDS *sds, ndvi, evi;
int32 sd_id1, sd_id2, attr_index, count, num_type;
char attr_name[50];
int k, j, Nl=0, Np=0;
int write_mode=DFACC_CREATE;
float blue, red, nir, fillvalue, val;
float64 scale_factor, add_offset;
void *row250m;
char make_ndvi=FALSE, make_evi=FALSE;

  if (argc < 5) {
    fprintf(stderr, "Usage: ndvi_evi -of=<output file> -blue=<SDS index of blue band> -red=<SDS index of Red band> -nir=<SDS index of NIR band> <Input file>\n");
    exit(-1);
  }
  sds = (SDS *) malloc(NUMSDS * sizeof(SDS));
  filename1[0] = (char)NULL;
  filename2[0] = (char)NULL;
  sds[BLUE].index = -1;
  sds[RED].index = -1;
  sds[NIR].index = -1;
  for (j=1; j<argc; j++) {
    if (strstr(argv[j], "-of=") == argv[j] ) {
        if ( sscanf(argv[j], "-of=%s", filename2) != 1 ) {
          printf("Cannot read output file\n");
          exit(-1);
        }
        printf("Output file: %s\n", filename2);
    } else if (strstr(argv[j], "-blue=") == argv[j] ) {
        if (sscanf(argv[j], "-blue=%d", &sds[BLUE].index) != 1) {
          printf("Cannot read blue band index\n");
          exit(-1);
        }
        printf("Blue band index: %d\n", sds[BLUE].index);
        sds[BLUE].index--;
    } else if (strstr(argv[j], "-red=") == argv[j] ) {
        if (sscanf(argv[j], "-red=%d", &sds[RED].index) != 1) {
          printf("Cannot read red band index\n");
          exit(-1);
        }
        printf("Red band index: %d\n", sds[RED].index);
        sds[RED].index--;
    } else if (strstr(argv[j], "-nir=") == argv[j] ) {
        if (sscanf(argv[j], "-nir=%d", &sds[NIR].index) != 1) {
          printf("Cannot read near-infrared band index\n");
          exit(-1);
        }
        printf("Near infrared band index: %d\n", sds[NIR].index);
        sds[NIR].index--;
    } else if ( strcmp(argv[j], "-append") == 0 ) {
        write_mode = DFACC_RDWR;
        fprintf(stderr, "Append mode\n");
    } else if ( strcmp(argv[j], "-ndvi") == 0 ) {
        make_ndvi = TRUE;
        fprintf(stderr, "NDVI requested\n");
    } else if ( strcmp(argv[j], "-evi") == 0 ) {
        make_evi = TRUE;
    } else {
        strcpy(filename1, argv[j]);
        printf("Input file: %s\n", filename1);
    }
  }

  if ( ! make_ndvi  &&  ! make_evi )
    make_ndvi = make_evi = TRUE;
  if ( filename1[0] == (char)NULL  ||
       filename2[0] == (char)NULL  ||
       ( sds[BLUE].index == -1  &&  make_evi ) ||
       sds[RED].index == -1  ||
       sds[NIR].index == -1 ) {
    printf("Unable to get all arguments\n");
    exit(-1);
  }

  if ( (sd_id1 = SDstart(filename1, DFACC_RDWR)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", filename1);
    exit(-1);
  }
  num_type = -1;
  for (j=0; j<NUMSDS; j++) {
    if (sds[j].index == -1)
      continue;
    if ( (sds[j].id = SDselect(sd_id1, sds[j].index)) == -1 ) {
      fprintf(stderr, "Cannot select SDS no. %d\n", sds[j].index);
      SDend(sd_id1);
      exit(-1);
    }
    if (SDgetinfo(sds[j].id, sds[j].name, &sds[j].rank, sds[j].dim_sizes, &sds[j].num_type, &sds[j].n_attr) == -1) {
      fprintf(stderr, "Can't get info from SDS \"%s\".\n", sds[j].name);
      SDendaccess(sds[j].id);
      SDend(sd_id1);
      exit(-1);
    }
    if (sds[j].dim_sizes[0] > Nl) {
      Nl = sds[j].dim_sizes[0];
      Np = sds[j].dim_sizes[1];
    }
    if (num_type == -1)
      num_type = sds[j].num_type;
    if ( sds[j].num_type != num_type ) {
      fprintf(stderr, "Data types of SDSs are different\n");
      SDendaccess(sds[j].id);
      SDend(sd_id1);
      exit(-1);
    }
    sds[j].fillvalue = (void *) malloc(1 * DFKNTsize(sds[j].num_type));
    if (SDgetfillvalue(sds[j].id, sds[j].fillvalue) == -1) {
      fprintf(stderr, "Can't get fill value from SDS \"%s\". %g is assumed.\n", sds[j].name, DEFAULTFILLVALUE);
      switch (sds[j].num_type) {
        case DFNT_INT16:  *(int16  *)sds[j].fillvalue = DEFAULTFILLVALUE;  break;
        case DFNT_UINT16: *(uint16 *)sds[j].fillvalue = DEFAULTFILLVALUE;  break;
        default:
          printf("Data type not supported\n");
          SDendaccess(sds[j].id);
          SDend(sd_id1);
          exit(-1);
      }
    }
    if ( strcpy(attr_name, "scale_factor") != NULL  &&
              (attr_index = SDfindattr(sds[j].id, attr_name)) != -1  &&
              SDattrinfo(sds[j].id, attr_index, attr_name, &num_type, &count) != -1  &&
              SDreadattr(sds[j].id, attr_index, &scale_factor) != -1 )
      sds[j].factor = scale_factor;
    else {
      sds[j].factor = DEFSCALEFACTOR;
      fprintf(stderr, "Can't get scale_factor attribute from SDS \"%s\". %lg is assumed.\n", sds[j].name, sds[j].factor);
    }
    if ( strcpy(attr_name, "add_offset") != NULL  &&
              (attr_index = SDfindattr(sds[j].id, attr_name)) != -1  &&
              SDattrinfo(sds[j].id, attr_index, attr_name, &num_type, &count) != -1  &&
              SDreadattr(sds[j].id, attr_index, &add_offset) != -1 )
      sds[j].offset = add_offset;
    else {
      sds[j].offset = DEFSCALEOFFSET;
      fprintf(stderr, "Can't get add_offset attribute from SDS \"%s\". %lg is assumed.\n", sds[j].name, sds[j].offset);
    }
    sds[j].data = (void *) malloc(Np * DFKNTsize(sds[j].num_type));
  }
  for (j=0; j<NUMSDS; j++) {
    if (sds[j].index == -1)
      continue;
    sds[j].pixszratio = Nl / sds[j].dim_sizes[0];
    if ( sds[j].dim_sizes[0] * sds[j].pixszratio != Nl  ||
         sds[j].dim_sizes[1] * sds[j].pixszratio != Np ) {
      fprintf(stderr, "Dimensions of SDSs are different\n");
      SDendaccess(sds[j].id);
      SDend(sd_id1);
      exit(-1);
    }
  }
  if (make_evi)
    printf("Blue band: SDS no. %d, Name \"%s\", Dimensions %dx%d\n", sds[BLUE].index + 1, sds[BLUE].name, sds[BLUE].dim_sizes[1], sds[BLUE].dim_sizes[0]);
  printf("Red band: SDS no. %d, Name \"%s\", Dimensions %dx%d\n", sds[RED].index + 1, sds[RED].name, sds[RED].dim_sizes[1], sds[RED].dim_sizes[0]);
  printf("NIR band: SDS no. %d, Name \"%s\", Dimensions %dx%d\n", sds[NIR].index + 1, sds[NIR].name, sds[NIR].dim_sizes[1], sds[NIR].dim_sizes[0]);
  if (make_ndvi) {
    ndvi.data = (int16 *) malloc(Np * sizeof(int16));
    ndvi.fillvalue = (int16 *) malloc(1 * sizeof(int16));
    ndvi.factor = DEFSCALEFACTOR;
    ndvi.offset = DEFSCALEOFFSET;
  }
  if (make_evi) {
    evi.data = (int16 *) malloc(Np * sizeof(int16));
    evi.fillvalue = (int16 *) malloc(1 * sizeof(int16));
    evi.factor = DEFSCALEFACTOR;
    evi.offset = DEFSCALEOFFSET;
  }
  row250m = (void *) malloc(Np * DFKNTsize(sds[RED].num_type));
  printf("Output dimensions: %dx%d\n", Np, Nl);
  if ( (sd_id2 = SDstart(filename2, write_mode)) == -1 ) {
    fprintf(stderr, "Cannot open file %s.\n", filename2);
    exit(-1);
  }
  if (make_ndvi) {
    sprintf(ndvi.name, "NDVI");
    ndvi.rank = 2;
    ndvi.num_type = DFNT_INT16;
    ndvi.dim_sizes[0] = Nl;
    ndvi.dim_sizes[1] = Np;
    if ((ndvi.id = SDcreate(sd_id2, ndvi.name, ndvi.num_type, ndvi.rank, ndvi.dim_sizes)) == -1) {
      fprintf(stderr, "Cannot create SDS \"%s\"\n",  ndvi.name);
      exit(-1);
    }
    if ( SDsetattr(ndvi.id, "scale_factor", DFNT_FLOAT64, 1, &ndvi.factor) == -1  ||
         SDsetattr(ndvi.id, "add_offset",   DFNT_FLOAT64, 1, &ndvi.offset) == -1 ) {
      fprintf(stderr, "Cannot write attributes for SDS \"%s\"\n",  ndvi.name);
      exit(-1);
    }
  }
  if (make_evi) {
    sprintf(evi.name, "EVI");
    evi.rank = 2;
    evi.num_type = DFNT_INT16;
    evi.dim_sizes[0] = Nl;
    evi.dim_sizes[1] = Np;
    if ((evi.id = SDcreate(sd_id2, evi.name, evi.num_type, evi.rank, evi.dim_sizes)) == -1) {
      fprintf(stderr, "Cannot create SDS \"%s\"\n",  evi.name);
      exit(-1);
    }
    if ( SDsetattr(evi.id, "scale_factor", DFNT_FLOAT64, 1, &evi.factor) == -1  ||
         SDsetattr(evi.id, "add_offset",   DFNT_FLOAT64, 1, &evi.offset) == -1 ) {
      fprintf(stderr, "Cannot write attributes for SDS \"%s\"\n",  evi.name);
      exit(-1);
    }
  }
  for (k=0; k<Nl; k++) {
    for (j=0; j<NUMSDS; j++) {
      if (sds[j].index == -1)
        continue;
      sds[j].start[0] = k / sds[j].pixszratio;
      sds[j].start[1] = 0;
      sds[j].edges[0] = 1;
      sds[j].edges[1] = sds[j].dim_sizes[1];
      if ( k % sds[j].pixszratio == 0  &&
           SDreaddata(sds[j].id, sds[j].start, NULL, sds[j].edges, sds[j].data) == -1 ) {
        printf("  Can't read SDS \"%s\".\n\n", sds[j].name);
        SDendaccess(sds[j].id);
        SDend(sd_id1);
        exit(-1);
      }
    }
    if ( make_evi  &&
         k % sds[BLUE].pixszratio == 0 )
      compute_250m_row(sds[BLUE].data, row250m, Np, sds[BLUE].num_type, sds[BLUE].fillvalue);
    for (j=0; j<Np; j++) {
      if (make_ndvi)
        ((int16 *)ndvi.data)[j] = UNDEF;
      if (make_evi)
        ((int16 *)evi.data)[j] = UNDEF;
      switch (sds[RED].num_type) {
        case DFNT_INT16:
          if (make_evi)
            blue = sds[BLUE].factor * ( ((int16 *)row250m)[j]       - sds[BLUE].offset );
          red =  sds[RED].factor  * ( ((int16 *)sds[RED].data)[j] - sds[RED].offset  );
          nir =  sds[NIR].factor  * ( ((int16 *)sds[NIR].data)[j] - sds[NIR].offset  );
          fillvalue = *(int16 *)sds[RED].fillvalue;
          if (make_ndvi) {
            val = NDVI(red, nir, fillvalue);
            if (val != UNDEF)
              ((int16 *)ndvi.data)[j] = val / ndvi.factor + ndvi.offset + 0.5;
          }
          if (make_evi) {
            val = EVI(blue, red, nir, fillvalue);
            if (val != UNDEF)
              ((int16 *)evi.data)[j] = val / evi.factor + evi.offset + 0.5;
          }
          break;
        case DFNT_UINT16:
          if (make_evi)
            blue = sds[BLUE].factor * ( ((uint16 *)row250m)[j]       - sds[BLUE].offset );
          red =  sds[RED].factor  * ( ((uint16 *)sds[RED].data)[j] - sds[RED].offset  );
          nir =  sds[NIR].factor  * ( ((uint16 *)sds[NIR].data)[j] - sds[NIR].offset  );
          fillvalue = *(uint16 *)sds[RED].fillvalue;
          if (make_ndvi) {
            val = NDVI(red, nir, fillvalue);
            if (val != UNDEF)
              ((uint16 *)ndvi.data)[j] = val / ndvi.factor + ndvi.offset + 0.5;
          }
          if (make_evi) {
            val = EVI(blue, red, nir, fillvalue);
            if (val != UNDEF)
              ((uint16 *)evi.data)[j] = val / evi.factor + evi.offset + 0.5;
          }
          break;
        default:
          printf("Data type not supported\n");
          exit(-1);
      }
    }
    if (make_ndvi) {
      ndvi.start[0] = k;
      ndvi.start[1] = 0;
      ndvi.edges[0] = 1;
      ndvi.edges[1] = Np;
      if (SDwritedata(ndvi.id, ndvi.start, NULL, ndvi.edges, (VOIDP)ndvi.data) == -1) {
        fprintf(stderr, "Cannot write SDS \"%s\"\n", ndvi.name);
        exit(-1);
      }
    }
    if (make_evi) {
      evi.start[0] = k;
      evi.start[1] = 0;
      evi.edges[0] = 1;
      evi.edges[1] = Np;
      if (SDwritedata(evi.id, evi.start, NULL, evi.edges, (VOIDP)evi.data) == -1) {
        fprintf(stderr, "Cannot write SDS  \"%s\"\n", evi.name);
        exit(-1);
      }
    }

  }
    
  SDend(sd_id1);
  SDend(sd_id2);

}




float NDVI(float red, float nir, float fillvalue)
{
float ndvi;

  if ( red != fillvalue  &&
       nir != fillvalue  &&
       red + nir != 0 ) {
      ndvi = (nir - red) / (nir + red);
      if (ndvi < MINVI) ndvi = MINVI;
      if (ndvi > MAXVI) ndvi = MAXVI;
  } else
      ndvi = UNDEF;
  return ndvi;
}




float EVI(float blue, float red, float nir, float fillvalue)
{
float evi;
static float L=1, c1=6, c2=7.5;
double val;

  if ( red == fillvalue  ||
       nir == fillvalue )
    evi = UNDEF;
  else {
    if ( blue != fillvalue  &&              /* Most cases - EVI formula */
         ( blue <= red  ||  red <= nir ) ) {
        if ( (val = L + nir + c1 * red - c2 * blue) == 0 )
          evi = UNDEF;
        else {
          evi = 2.5 * (nir - red) / val;
          if (evi < MINVI) evi = MINVI;
          if (evi > MAXVI) evi = MAXVI;
        }
    } else {                            /* Backup - SAVI formula */
        if ( (val = 0.5 + nir + red) == 0 )
          evi = UNDEF;
        else {
          evi = 1.5 * (nir - red) / val;
          if (evi < MINVI) evi = MINVI;
          if (evi > MAXVI) evi = MAXVI;
        }
    }
  }
  return evi;
}




void compute_250m_row(void *row500m, void *row250m, int ncols, int32 num_type, float *fillvalue)
{
float x,t;
int j, col1, col2;

  for (j=0; j<ncols; j++) {
    x = j / 2. - 0.5;
    col1 = floor(x);
    col2 = col1 + 1;
    if (col1 < 0) {
      col1 = 1;
      col2 = 0;
    }
    if (col2 > ncols - 1) {
      col1 = ncols - 1;
      col2 = ncols - 2;
    }
    t = (x - col1) / (col2 - col1);
    switch (num_type) {
      case DFNT_INT16:
        if ( ((int16*)row500m)[col1] != *(int16*)fillvalue  &&
             ((int16*)row500m)[col2] != *(int16*)fillvalue )
          ((int16*)row250m)[j] = (1 - t) * ((int16*)row500m)[col1] + t * ((int16*)row500m)[col2];
        else
          ((int16*)row250m)[j] = *(int16*)fillvalue;
        break;
      case DFNT_UINT16:
        if ( ((uint16*)row500m)[col1] != *(uint16*)fillvalue  &&
             ((uint16*)row500m)[col2] != *(uint16*)fillvalue )
          ((uint16*)row250m)[j] = (1 - t) * ((uint16*)row500m)[col1] + t * ((uint16*)row500m)[col2];
        else
          ((uint16*)row250m)[j] = *(uint16*)fillvalue;
        break;
    }
  }
}
