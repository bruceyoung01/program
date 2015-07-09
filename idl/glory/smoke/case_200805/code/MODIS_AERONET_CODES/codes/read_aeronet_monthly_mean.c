
	/* This program is used to read the aeronet data and save it as the
	following format:  station number, date, time, 670nm optical
	aot. Here the time is float time, 54minitus=0.9hour, which is 
	useful for the time collocate to the CERES or VIRS data*/
	/* The usage is : a.out filename */

	#include "stdio.h"
	#include "math.h"

       /* # of wavelength */
        #define NWL 16 
       
       /* # of Angstrom Exponent */
        #define NANG 6 

       /* # of year *, month */
       /* year starts at 1994 */
        #define NYR 18      
        #define NMN 12 	
       
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
	 int i, j, k, kk;
	 float f_min,f_sec;

         /* adding some statistics */
         /* each, month, wl */
         int MaxP = 2000;    /* maximum  of pionts for each month */
         float AOTMon_Mean[NYR][NMN][NWL], AngMon_Mean[NYR][NMN][NANG]; 
         float AOTMon_Std[NYR][NMN][NWL], AngMon_Std[NYR][NMN][NANG];
         float TmpAOT[NYR][NMN][NWL][MaxP], TmpAng[NYR][NMN][NANG][MaxP];
         int TmpAOTP[NYR][NMN][NWL], TmpAngP[NYR][NMN][NANG];
         float TmpSum = 0;
         int tmpyear, ThisYr ;

         /* program starts */
	sprintf(name,"%s%s", "hour_", argv[1]);
        sprintf(outname,"%s%s", "Monthly_", argv[1]);

	
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
          for (k = 0; k < NWL ; k++)
          TmpAOTP[i][j][k] = 0 ;
          
          for (k = 0; k < NANG ; k++)
          TmpAngP[i][j][k] = 0 ;
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

         printf ( "DATE : %s\n", data.date);
	 printf( "%s\n", data.time);
	
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
	 printf( "last day = %s\n ", data.lastday);
         fscanf( in, "%f", &data.sza);
         printf ( "SZA = %f\n\n", data.sza);

	 
	/* convert ASCII to digital numver */
	min[0]=data.time[3];min[1]=data.time[4];min[2]='\0';
	sec[0]=data.time[6];sec[1]=data.time[7];sec[2]='\0';
	hour[0]=data.time[0];hour[1]=data.time[1];hour[2]='\0';
	f_min=atoi(min)*1.0/60.; /* minutes to hour */
        printf( " time %s min %s hour %s sec %s \n", data.time, hour, min, sec); 
	
	f_sec=atoi(sec)/3600.; /*seconds to hour */

	f_min=f_sec+f_min;
	f_min=f_min+atoi(hour); /* total hour */
	
	/* convert date to integer nube outputing in char format */
	year[0]=data.date[8]; year[1]=data.date[9]; year[2] = '\0';
	mon[0]=data.date[3];  mon[1]=data.date[4];  mon[2] = '\0';
	day[0]=data.date[0];  day[1]=data.date[1];  day[2] = '\0';

        printf ("date %s year, %7.6s\n", data.date, year);
	fgets(temp,30,in);

        /* now the reading process has been done */
        /* start to calcuate monthly averages */

        for (k = 0; k < NWL; k++)
        {
             tmpyear = atoi(year);
             if ( tmpyear <= 10  && tmpyear >= 0) tmpyear = 2000+tmpyear;
             tmpyear = tmpyear - 1994; 
             
             if ( data.aot[k] >  0 ) 
             {
               TmpAOT[tmpyear][atoi(mon)-1][k][TmpAOTP[tmpyear][atoi(mon)-1][k]] = data.aot[k]; 
               TmpAOTP[tmpyear][atoi(mon)-1][k]++;
             }
        }

       for ( k = 0; k < NANG; k++)
       {
             tmpyear = atoi(year);
             if ( tmpyear <= 10 && tmpyear >= 0 ) tmpyear = 2000+tmpyear;
             tmpyear = tmpyear - 1994;

             if ( data.angstrm[k] > 0 )
             {
               TmpAng[tmpyear][atoi(mon)-1][k][TmpAngP[tmpyear][atoi(mon)-1][k]] = data.angstrm[k];
               TmpAngP[tmpyear][atoi(mon)-1][k]++;
             }
        }                    

      }

close(in);
close(out);
      printf ( " file processing is over \n"); 


     /* now reading part is done, calculate the monthly mean values
      * in each year and their standard deviation */

      for ( i = 0; i < NYR; i++)
      {
        for ( j = 0; j < NMN; j++)
        {
          for ( kk = 0; kk < NWL; kk++)
          {
            AOTMon_Mean[i][j][kk] = -99;
            AOTMon_Std[i][j][kk]  = -99;
            TmpSum = 0;
            if ( TmpAOTP[i][j][kk] > 0 )
             {
                 for ( k = 0; k <  TmpAOTP[i][j][kk]; k++ )
                        TmpSum = TmpSum+TmpAOT[i][j][kk][k];
                 AOTMon_Mean[i][j][kk] = TmpSum/TmpAOTP[i][j][kk];
                 printf( "%d %d %d %f \n", i, j, k, AOTMon_Mean[i][j][kk]);  
             }

             TmpSum = 0;
             if ( TmpAOTP[i][j][kk] > 0 )
              {
                  for ( k = 0; k <  TmpAOTP[i][j][kk]; k++ )
                   TmpSum = TmpSum+(TmpAOT[i][j][kk][k] - AOTMon_Mean[i][j][kk])*
                                     (TmpAOT[i][j][kk][k] - AOTMon_Mean[i][j][kk]);

                   if ( TmpAOTP[i][j][kk] == 1 )
                       AOTMon_Std[i][j][kk] = 0;
                    else
                      AOTMon_Std[i][j][kk] = sqrt(TmpSum/(TmpAOTP[i][j][kk]-1));
                }
           }
      
       for ( kk = 0; kk < NANG; kk++)
       {
             /* Ang Storm */
               AngMon_Mean[i][j][kk] = -99;
               AngMon_Std[i][j][kk] = -99;
               TmpSum = 0;
               if ( TmpAngP[i][j][kk] > 0 )
                {
                     for ( k = 0; k <  TmpAngP[i][j][kk]; k++ )
                        TmpSum = TmpSum+TmpAng[i][j][kk][k];

                     AngMon_Mean[i][j][kk] = TmpSum/TmpAngP[i][j][kk];
                   /*  printf ( "TmpSum = %f \n", TmpSum); */
                }

                TmpSum = 0;
                if ( TmpAngP[i][j][kk] > 0 )
                {
                     for ( k = 0; k <  TmpAngP[i][j][kk]; k++ )
                        TmpSum = TmpSum+(TmpAng[i][j][kk][k] - AngMon_Mean[i][j][kk])*
                                     (TmpAng[i][j][kk][k] - AngMon_Mean[i][j][kk]);

                     if ( TmpAngP[i][j][kk] == 1 )
                       AngMon_Std[i][j][kk] = 0;
                     else
                     AngMon_Std[i][j][kk] = sqrt(TmpSum/(TmpAngP[i][j][kk]-1));
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
              for ( k = 0; k < NWL; k++)
              {
                if (  AOTMon_Mean[i][j][k] > 0 ) 
                   ThisYr = 1; 
              }
           }

          if (ThisYr == 1 )
          {                
              for ( j = 0; j < NMN; j++)
              {
                   
                   fprintf(outstatis, "%d %d ", i + 1994, j+1) ; 
                    
                   for ( k = 0; k < NWL; k++)
                     fprintf (outstatis, "  %10.6f ",  AOTMon_Mean[i][j][k]);
                   
                   for ( k = 0; k < NANG; k++)
                     fprintf (outstatis, "  %10.6f ",  AngMon_Mean[i][j][k]);
                   fprintf(outstatis, "\n");
                   
                   fprintf(outstatis, "%d %d ", i + 1994, j+1) ; 
                
                   for ( k = 0; k < NWL; k++)
                    fprintf (outstatis, "  %10.6f ",  AOTMon_Std[i][j][k]);
                   
                   for ( k = 0; k < NANG; k++)
                    fprintf (outstatis, "  %10.6f ", AngMon_Std[i][j][k]);
                   fprintf(outstatis, "\n");
              }
           }
         }

        close(outstatis);

}
	
