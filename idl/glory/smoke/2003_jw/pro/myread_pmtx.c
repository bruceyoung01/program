/* purpose: this program reads the PM10, PM2.5, and OZONE
 content on different days and merge them into one file.
 to mearge differnt type of data, just specify the VARB with different
 names OZONE, PM10 etc */

#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#define VARB "PM2.5APRIL02"

int  main ( int argc, char *argv[])
{

/* define variables for input and output */
char Onefile[300];
char Outfile[300];
FILE *inptr;
FILE *Outptr;
FILE *staptr;  // station file list ptr
char *StationlistF = "./site_location_region.dat"; // file includes informatin of each site. 

/* loop variables */
int i, k, blanknum;
int MaxLine = 120; /* data maxlimn line is 120lines*/

/* define variabls for reading files */
char OneLine[350];
char Nouse[350];
int StateID, CountyID, StationNum, CAMSID;  

/* define variables for read station list file */
int MaxNumSta = 100;
int NumSta, inx;
int CAMSIDARRY[MaxNumSta], Elevation[MaxNumSta], RegionBox[MaxNumSta];
float lat[MaxNumSta], lon[MaxNumSta];

/* chaeck cmd parameter */
if ( argc < 2 ) 
{
    printf ( "Usuage: read_pm inptfilename \n");
    exit(-1);
}
	    
/* get input file name*/
strcpy(Onefile, argv[1]);
if ( (inptr = fopen ( Onefile, "r") ) == NULL )
{
    printf( "can not open %s \n", Onefile);
    exit(-1);
}

/* get station id list file */
if ( (staptr = fopen ( StationlistF, "r" ) ) == NULL )
{
    printf ( "can not open %s \n", Onefile );
    exit (-1);
}

/* get output file name */
sprintf(Outfile, "%s.asc", argv[1]);
if ( (Outptr = fopen ( Outfile, "w") ) == NULL )
{
    printf( "can not open %s \n", Outfile);
    exit(-1);
}

/* read the file */
/* read station list information */
 fgets ( Nouse, 200, staptr);
 printf ( " Nouse %s\n", Nouse);
 
 NumSta = 0;
 while ( !feof(staptr) ) 
 {
    fscanf ( staptr, "%d %f %f %d %d \n", &CAMSIDARRY[NumSta], 
                   &lat[NumSta], &lon[NumSta],
	           &Elevation[NumSta], &RegionBox[NumSta]);
    printf( "%d %f %f %d %d \n", CAMSIDARRY[NumSta], lat[NumSta], 
	    lon[NumSta], Elevation[NumSta], RegionBox[NumSta]);
    NumSta++;
 }
 fclose(staptr);

/* read the CAMS ID, EPA site ID, EPA paramters, Month, and Year */
  
  /* first line: get the CAMS ID */
  fscanf (inptr, "%s %d ", Nouse, &CAMSID);
  fgets ( Nouse, 200, inptr);

  /* find the lat, lon and elevation , and region box for this site */
  inx = -1;
  for ( i = 0; i < NumSta; i++)
  {
    if ( CAMSIDARRY[i] == CAMSID )
    {
	inx = i;
    }
  }

  if (inx == -1 )
  {
    printf ( " can not fine the station id \n");
    exit(-1);
  }
  
  printf ( "inx = %d camsid = %d \n", inx, CAMSIDARRY[inx]); 

  /* seoncd line: blank  */
  fgets ( Nouse, 200, inptr);

  /* third line: get EPA ID */
  fscanf( inptr,  "%s ", Nouse);  
  fscanf( inptr,  "%s ", Nouse);  
  fscanf ( inptr, "%2d-%3d-%4d", &StateID, &CountyID, &StationNum);
  fgets ( Nouse, 200, inptr);

 /* 4th - 12th are useless */
  for ( i = 0; i < 9; i++)
    fgets ( Nouse, 300, inptr);

 /* print out the ID and relevant information */
  fprintf (Outptr, "StateID  County ID  StationNum CAMSID LAT LON HEIGHT REGIONBOX \n") ;
  printf ("StateID  County ID  StationNum CAMSID  \n") ;
  fprintf (Outptr, "%10d %10d %10d %10d %11.6f %11.6f %10d %10d \n", 
	  StateID, CountyID, StationNum, CAMSID, lat[inx], 
	  lon[inx], Elevation[inx], RegionBox[inx]);
  
  printf ( "%10d %10d %10d %10d %11.6f %11.6f %10d %10d \n", 
	  StateID, CountyID, StationNum, CAMSID, lat[inx], 
	  lon[inx], Elevation[inx], RegionBox[inx]);
 
/* printout column names */
  fprintf (Outptr, "%s\n", Nouse);
    
 /* the following reads the data into the bottom of the file */
   i = 0;
   while ( !feof (inptr) &&  i < MaxLine) 
   {
       /* get one line */
       fgets ( OneLine, 300, inptr);
       printf ( "%s", OneLine);    
       k = 0;
       blanknum = 0;

       /* check data availability, novalid data is assigned to 999 */
       while ( k < 300 &&  (OneLine[k] !=13 || OneLine[k] !=10) )
       {
	   if ( OneLine[k] >= 48 && OneLine[k] <=57  )
	   {    
	       blanknum ++; 
	   }
	   
	   if ( OneLine[k] == 44 ) 
	       OneLine[k] = 32;
	   else if ( OneLine[k] >= 65 && OneLine[k] <= 90 )
	       OneLine[k] = 57;
	   else if ( OneLine[k] == 37 )
	       OneLine[k] = 32;
	  
	   /* number of characters in this line */
	   k++;
       }
   printf ( "blank number =  %d, k = %d", blanknum, k);   
   if ( blanknum == 0)  /* a blank line, fileends */ 
      i = MaxLine; 
   else
   {
      
      fprintf( Outptr, "%s",  OneLine);    
      printf(  "%s\n",  OneLine);    
      printf ( "....%d \n", i);   
      
      /* Inportnat, refresh the string before next input.*/
      for ( k = 0; k < 300; k++ )
	   OneLine[k] = 0;
      i++;
   }   
   }
   fclose(inptr);
   fclose(Outptr);
}     

       

	       



      
  

