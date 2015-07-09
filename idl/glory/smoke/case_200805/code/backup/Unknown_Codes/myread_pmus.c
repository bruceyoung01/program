/* this program reads the EPA airnow datasets, and split them station by
 * station */ 


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
FILE *Stationptr;  // valid station ptr
char *ValidStationF = "./valid_stationid.txt"; // list stationids that have data.     
char *StationlistF = "./pmfine_airnow_20030701-current_valid.dat"; // file includes informatin of each site. 

/* loop variables */
int i,j, k, im, ihr, id, idd,  blanknum, ValidDataNum;
int MaxLine = 120; /* data maxlimn line is 120lines*/

/* define variabls for reading files */
char SiteID[30] ;
float lat, lon, gmhr, pm; 
int year, jday;
char Nouse[350];

/* define variables for read station list file */
int MaxNumSta = 500;
int NumSta, inx, LineNum;
float OneMonData[31][24];
float  SITELAT[MaxNumSta], SITELON[MaxNumSta];
char SITEIDARRY[MaxNumSta][200];


/* define jday for each month for 2003  */
//int days         31  28  31  30    31   30   31    31   30  31   30   31
int Jdays[] = {1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366};
char *MonChar[] = {"Jan", "Feb", "Mar", "Apr", "May", "June", 
                   "July", "Aug", "Sep", "Oct", "Nov", "Dec"};

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
    printf ( "can not open %s \n", StationlistF );
    exit (-1);
}

/* get station id list file */
if ( (Stationptr = fopen ( ValidStationF, "w" ) ) == NULL )
{
    printf ( "can not open %s \n", ValidStationF );
    exit (-1);
}


/* read the file */
/* read station list information */
 fgets ( Nouse, 300, staptr);
 fgets ( Nouse, 300, staptr);
 printf ( " Nouse %s", Nouse);
 
 NumSta = 0;
 while ( !feof(staptr) ) 
 {
    fscanf ( staptr, "%9s  %f  %f", &SITEIDARRY[NumSta], 
                   &SITELON[NumSta], &SITELAT[NumSta]);
    printf ( "%s, %f, %f \n", SITEIDARRY[NumSta], 
                   SITELAT[NumSta], SITELON[NumSta]);
    fgets (Nouse, 200, staptr); 
    NumSta++;
 }
 fclose(staptr);
 NumSta = NumSta-1;

/* loop through each station and month to split merged file into each station */
for ( j = 0; j < NumSta; j++)
//for ( j = 0; j < 1; j++)
{   
    ValidDataNum = 0;

    for ( im = 0; im < 12; im++)
    {
       /* get output file name */
        sprintf(Outfile, "./processed_cdtime/%s_%s.dat.asc", MonChar[im], SITEIDARRY[j]);
        if ( (Outptr = fopen ( Outfile, "w") ) == NULL )
        {
           printf( "can not open %s \n", Outfile);
           exit(-1);
        }

       /* first initilize the data */
	for (id = Jdays[im]; id < Jdays[im+1]; id++)
	{
	    idd = id - Jdays[im];
	    for ( ihr = 0; ihr < 24; ihr++)
		OneMonData[idd][ihr] = -999;
	} 
	
       LineNum = 0;	

       /* loop through input file to find the corresponding data */
        while ( !feof (inptr) )
	{
           /* reach one line */
             fscanf (inptr, "%9s, %f, %f, %d,%d, %f,%f", SiteID, &lat, &lon, &year, &jday, &gmhr, &pm);
             fgets ( Nouse, 200, inptr);
	     LineNum++;
	     //printf ( "%s, %f, %f, %d, %d, %f,%f",  SiteID, lat, lon, year, jday, gmhr); 
	     //printf ( "%s",  Nouse); 
          
	   /* judge if the ID matches */
	     if ( atol(SITEIDARRY[j]) == atol(SiteID) && 
		  (jday >= Jdays[im] && jday < Jdays[im+1]) &&
		  year  == 2003 )
	       {
	           // here I chaged to CDT time.
		   //ihr = (int) gmhr;
		   ihr = (int) gmhr -5 ;  // added to consider the CDT time
                   if ( ihr < 0 ) 
		   {
		       ihr = 24+ihr;
		       jday = jday-1;
		   }
		   //		   printf ( "Line# %d %f %d jday %d %d %f \n", LineNum, gmhr, ihr, jday, jday - Jdays[im], pm);
	           if ( jday - Jdays[im] >= 0 ) //add by Jun to consider the CDT time 
		   OneMonData[jday - Jdays[im] ][ihr] = pm;

		   if ( pm != -999 ) ValidDataNum++;  
	       }
	}    
  
	/* print out the data */
	fprintf ( Outptr, "EPA #    LAt and Lon, and PM data in UTC time\n");
	fprintf ( Outptr, "%s  %10.2f  %10.2f \n", SITEIDARRY[j], SITELAT[j], SITELON[j]);
	fprintf ( Outptr, "DATE  1  2   ,...... 23 \n");

	for (id = Jdays[im]; id < Jdays[im+1]; id++)
	{
	    idd = id - Jdays[im];
	    fprintf ( Outptr, "%2d ", idd+1 );
	    for (ihr = 0; ihr < 24; ihr++)
		fprintf(Outptr, "%10.2f ", OneMonData[idd][ihr]);
	    fprintf ( Outptr, "\n");
	}


	/* rewind file strems*/
	rewind (inptr);

	fclose(Outptr);
   }  /* end of imon */  

   if ( ValidDataNum > 0 )
       fprintf (Stationptr, "%s \n", SITEIDARRY[j]); 

   }  /* end of istation */
   fclose(inptr);
   fclose(Stationptr);
   
}     

