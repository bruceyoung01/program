
	/* This program is used to read the aeronet data and save it as the
	following format:  station number, date, time, 670nm optical
	aot. Here the time is float time, 54minitus=0.9hour, which is 
	useful for the time collocate to the CERES or VIRS data*/
	/* The usage is : a.out filename */

	#include "stdio.h"
	#include "math.h"

       /* wavelength selected, 675um*/
        #define NWL 16 
       
       /* # of Angstrom Exponent 500-870 */
        #define NANG 6

       /* # of day */
        #define NDAY 31  

       /* # of year *, month */
       /* year starts at 1994 */
        #define NYR 18      
        #define NMN 12 
        #define NHR 24 
        #define NANGS 3


       /* wavelength selected, 675um*/
        #define NWLS 3 

       /* wavelength selected, 430um*/
       /* #define NWLS 12 */ 


       /* data structure */ 
        struct data_type
	{char date[12], time[10];
	 float jday;   
	 float aot[NWL];
	 float water;
	 float aoterr[NWL];
	 float watererr;
	 float angstrm[NANG];
	 char  lastday[12];
	 float sza;
	} ;
	struct data_type data;

	main(argc, argv)
	int argc;
	char *argv[];
	{
	 FILE *in, *out;
         FILE *outstatis;
	 char first_line[800],name[120], outname[120], temp[30],min[3],sec[3],hour[3];
	 char mon[3], day[3];
	 char year[7];
	 int i, j, k, kk, tmphr, tmpk, kkk;
	 float f_min,f_sec;

         /* adding some statistics */
         /* each, month, wl */
         int MaxP = 20;    /* maximum  of pionts for each month */
         float AOTMon_Mean[NYR][NMN][NDAY], AngMon_Mean[NYR][NMN][NDAY]; 
         float AOTMon_Std[NYR][NMN][NDAY], AngMon_Std[NYR][NMN][NDAY];
         float TmpAOT[NYR][NMN][NDAY][NHR][MaxP], TmpANG[NYR][NMN][NDAY][NHR][MaxP];
         int TmpAOTP[NYR][NMN][NDAY][NHR], TmpANGP[NYR][NMN][NDAY][NHR];
         float AOT[NYR][NMN][NDAY][NHR], Ang[NYR][NMN][NDAY][NHR];  
         float AOTDaily_HR[NYR][NMN][NDAY][NHR], AngDaily_HR[NYR][NMN][NDAY][NHR]; 
         float AOTDaily_HRPENCT[NYR][NMN][NDAY][NHR], AngDaily_HRPENCT[NYR][NMN][NDAY][NHR]; 

         float AOTMon_HR_Mean[NYR][NMN][NHR], AngMon_HR_Mean[NYR][NMN][NHR] ;
         int AOTMon_HR_N[NYR][NMN][NHR]; 
         float AOTMon_HR_PENCT[NYR][NMN][NHR], AngMon_HR_PCENT[NYR][NMN][NHR] ;
         
         float AOTTmp[NHR], AngTmp[NHR];
         int AOTTmpN[NHR], AngTmpN[NHR];
  
         float TmpSum = 0;
         int tmpyear, ThisYr ;
         int TmpSumN, TmpSumHrN;
         float TmpSumHr;

         /* program starts */
	sprintf(name,"%s%s", "hour_", argv[1]);
        sprintf(outname,"%s%s", "Diurnal_", argv[1]);
        printf ( " Program starts \n");
	
	 if ( argc < 2 )
	   { printf(" you need to enter the data name \n");
             exit(0);
	    }	
          if (( in = fopen ( argv[1], "r")) == NULL)
	    { printf ( " can not open infile \n");
	      exit(0);
	    }	
	if (( out = fopen ( name, "w")) == NULL)
	    { printf ( " can not open outfile \n");
	      exit(0);
	    }

        if (( outstatis = fopen ( outname, "w")) == NULL)
         { printf ( " can not open outfile \n");
           exit(0);
         }
 	
	printf("ok \n");

        /* initialize the data */
        for (i = 0; i < NYR; i++)
        for (j = 0; j < NMN; j++)
        {
          for (k = 0; k < NDAY ; k++)
          for ( kk = 0; kk < NHR; kk++)
          {
             TmpAOTP[i][j][k][kk] = 0 ;
             TmpANGP[i][j][k][kk] = 0 ;
          }
        }     


	/* get first 3 lines */
	fgets(first_line, 150, in);
	fgets(first_line, 150, in);
	fgets(first_line, 150, in);
	fgets(first_line, 500, in);
	fgets(first_line, 700, in);
        printf( "first line %s ", first_line);

	fprintf( out, "   Date         Time  JulianD  SZA  AOT_1640  AOT_1020  AOT_870  AOT_675  AOT_667  AOT_555  AOT_551 AOT_532 AOT_531 AOT_500 AOT_490 AOT_443 AOT_440 AOT_412 AOT_380 AOT_340 Water(cm) Alpha_440_870 Alpha_380_500 Alpha_440_675 Alpha_500_870 Alpha340_440 Alpha_440_675  \n" ); 

	
	while (!feof(in))
	{fgets(data.date,12,in);
	 fgets(data.time,10,in);

/*         printf ( "DATE : %s\n", data.date);
	 printf( "%s\n", data.time);
*/	
	 fscanf( in , "%f,", &data.jday);
 
         /* printf("%s \n",data.time); */
	 for (i=0; i<NWL; i++)
	 {fscanf(in,"%f,",&data.aot[i]);
	 }

	 /* scan water */
         fscanf ( in, "%f,", &data.water);
	 
	 /* scan aot errors */
	 for (i=0; i<NWL; i++)
	 {fscanf(in,"%f,",&data.aoterr[i]);
	 }
         
	 /* scan water err */
	 fscanf ( in, "%f,", &data.watererr);
	
         /* scan  anstrm */
	 for (i=0; i<NANG; i++)
	 {fscanf(in,"%f,",&data.angstrm[i]);
	 }
	
	 fgets(data.lastday, 12, in);
/*	 printf( "last day = %s\n ", data.lastday); */
         fscanf( in, "%f", &data.sza);
/*         printf ( "SZA = %f\n\n", data.sza);   */

	 
	/* convert ASCII to digital numver */
	min[0]=data.time[3];min[1]=data.time[4];min[2]='\0';
	sec[0]=data.time[6];sec[1]=data.time[7];sec[2]='\0';
	hour[0]=data.time[0];hour[1]=data.time[1];hour[2]='\0';
	f_min=atoi(min)*1.0/60.; /* minutes to hour */


  /*    printf( " time %s min %s hour %s sec %s \n", data.time, hour, min, sec); */ 
	
	f_sec=atoi(sec)/3600.; /*seconds to hour */

	f_min=f_sec+f_min;
	f_min=f_min+atoi(hour); /* total hour */
	
	/* convert date to integer nube outputing in char format */
	year[0]=data.date[8]; year[1]=data.date[9]; year[2] = '\0';
	mon[0]=data.date[3];  mon[1]=data.date[4];  mon[2] = '\0';
	day[0]=data.date[0];  day[1]=data.date[1];  day[2] = '\0';

  /*      printf ("date %s year, %7.6s\n", data.date, year); */

	fgets(temp,30,in);

        /* now the reading process has been done */
        /* start to calcuate monthly averages */

             tmpyear = atoi(year);
             if ( tmpyear <= 10  && tmpyear >= 0) tmpyear = 2000+tmpyear;
             tmpyear = tmpyear - 1994; 
             
             if ( data.aot[NWLS] >  0 ) 
             {
               tmphr = atoi(hour)-1;
               tmpk = TmpAOTP[tmpyear][atoi(mon)-1][atoi(day)-1][tmphr];
               TmpAOT[tmpyear][atoi(mon)-1][atoi(day)-1][tmphr][tmpk] = data.aot[NWLS];
               TmpAOTP[tmpyear][atoi(mon)-1][atoi(day)-1][tmphr] ++;
    /* 
              printf ( " %f \n", data.aot[NWLS] );
    */  
              } 


             if ( data.angstrm[NANGS] > 0 )
             {
               tmphr = atoi(hour)-1; 
               tmpk = TmpANGP[tmpyear][atoi(mon)-1][atoi(day)-1][tmphr];
               TmpANG[tmpyear][atoi(mon)-1][atoi(day)-1][tmphr][tmpk] = data.angstrm[NANGS];
               TmpANGP[tmpyear][atoi(mon)-1][atoi(day)-1][tmphr] ++;
             }
      }

close(in);
close(out);
printf ( " file processing is over \n"); 



     /* to calcualte the diurnal variation */
     /* fist calculate the daily averages */

      for ( i = 0; i < NYR; i++)
      {
        for ( j = 0; j < NMN; j++)
        {
          
          for ( k = 0; k <NHR; k++)
          {
             AOTTmp[k] = 0.0;
             AOTTmpN[k] = 0;         
          }

          for ( kk = 0; kk < NDAY; kk++)
          {
            AOTMon_Mean[i][j][kk] = -99;
            TmpSum = 0;
            TmpSumN = 0.0 ;

             for ( k =0 ; k < NHR; k++)
             {
               
               TmpSumHr = 0.0 ;
               TmpSumHrN = 0;
               AOT[i][j][kk][k] = -99.0;

               if ( TmpAOTP[i][j][kk][k] > 0 )
               {
                  for ( kkk = 0; kkk <  TmpAOTP[i][j][kk][k]; kkk++ )
                   {
                      TmpSumHr = TmpSumHr + TmpAOT[i][j][kk][k][kkk];     
                      TmpSumHrN = TmpSumHrN + 1;
                 /*     printf ( " AOT value is %f hr %d day %d mon %d # ponit %d\n", 
                               TmpAOT[i][j][kk][k][kkk], k, kk, j, kkk );     
                 */  
                  }               

                    AOT[i][j][kk][k] = TmpSumHr/TmpSumHrN;     /* hourly averages */  
  
                    TmpSum = TmpSum+TmpSumHr;
                    TmpSumN = TmpSumN + TmpSumHrN ;
                }
              }  /* end of hour */
                
            if ( TmpSumN > 0 && kk == 23 && j == 0 ) 
            {
               printf ( " TmpSum %f  TmpSumN %d \n", TmpSum, TmpSumN );
            }  

            if ( TmpSumN > 0 )     /* for every day */ 
            { 
                   AOTMon_Mean[i][j][kk] = TmpSum/TmpSumN;     /* daily averages */
                   
                   for (k=0; k < NHR; k++)
                   {
                       AOTDaily_HRPENCT[i][j][kk][k] = -99; 
                       if ( AOT[i][j][kk][k] > 0 )
                       { 
                         AOTDaily_HRPENCT[i][j][kk][k] = AOT[i][j][kk][k] / AOTMon_Mean[i][j][kk];
                         AOTTmp[k] = AOT[i][j][kk][k]+AOTTmp[k];
                         AOTTmpN[k] ++;
                       } 
                   }   
             }
          }  /* end of a month */


          /* now calculate the monthly diurnal variation */
          for ( k = 0; k < NHR; k++)
          { 
            AOTMon_HR_Mean[i][j][k] = - 99; 
            if ( AOTTmpN[k] > 0 )
            { 
              AOTMon_HR_Mean[i][j][k] =  AOTTmp[k]/ AOTTmpN[k];
              AOTMon_HR_N[i][j][k] =   AOTTmpN[k];
            }
          }
      }
    }

     printf ( "average is over \n");

     /* output data */
        
        for  (i = 0; i < NYR; i++)
        {
           ThisYr = 0; 
           for ( j = 0; j < NMN; j++)
           {
              for ( k = 0; k < NHR; k++)
              {
                if (  AOTMon_HR_Mean[i][j][k] > 0 ) 
                   ThisYr = 1; 
              }
           }

          if (ThisYr == 1 )
          {                
              for ( j = 0; j < NMN; j++)
              {
                   
                   fprintf(outstatis, "%d %d ", i + 1994, j+1) ; 
                    
                   for ( k = 0; k < NHR; k++)
                     fprintf (outstatis, "  %10.6f ",  AOTMon_HR_Mean[i][j][k]);

                   fprintf(outstatis, "\n");
                   fprintf(outstatis, "%d %d ", i + 1994, j+1) ; 
                   
                   for ( k = 0; k < NHR; k++)
                     fprintf (outstatis, "  %10d ",  AOTMon_HR_N[i][j][k]);
             
                   fprintf(outstatis, "\n");
                /*   
                   fprintf(outstatis, "%d %d ", i + 1994, j+1) ; 
                
                   for ( k = 0; k < NWL; k++)
                    fprintf (outstatis, "  %10.6f ",  AOTMon_Std[i][j][k]);
                   
                   for ( k = 0; k < NANG; k++)
                    fprintf (outstatis, "  %10.6f ", AngMon_Std[i][j][k]);
                   fprintf(outstatis, "\n");
                */

              }
           }
         }

        close(outstatis);

}
	
