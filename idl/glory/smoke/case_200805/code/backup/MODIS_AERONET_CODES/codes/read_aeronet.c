	
      /* This program is used to read the AERONET RAW DATA  */
      /* and process it into an easier text format that IDL */
      /* can read it.                                       */ 
      /* before processing:                                 */
      /*   replace N/A to -99.0000                          */
      /*  replace / to :                                    */
      /* The usage is : a.out filename */

	#include "stdio.h"
	#include "math.h"

       /* # of wavelength */
        #define NWL 16 
       
       /* # of Angstrom Exponent */
        #define NANG 6 	
        
        struct data_type
	{char date[12], time[10];
	 float jday;   
	 float aot[NWL];
	 float water;
	 float aoterr[10];
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
	 FILE *in, *out, *tmpout, *tmpin;
	 char new_line[800], inname[120], first_line[800], nnew_line[800], 
              name[120], tmpname[120],temp[30],min[3],sec[3],hour[3];
	 char mon[3], day[3];
	 char year[3];
	 int i, ii, k;
	 float f_min,f_sec;

        	
	sprintf(name,"%s/%s%s", argv[3], "hour_", argv[1]);
	sprintf(tmpname,"%s/%s%s", argv[3], "tmp_", argv[1]);
	sprintf(inname,"%s/%s", argv[2],  argv[1]);
	
	 if ( argc < 4 )
	   { printf(" a.out filename inputdir outputdir \n");
             exit(0);
	    }	
        if (( in = fopen ( inname, "r")) == NULL)
	    { printf ( " can not open infile \n");
	      exit(0);
	    }	
	if (( tmpout = fopen ( tmpname, "w")) == NULL)
	    { printf ( " can not open outfile \n");
	      exit(0);
	    }	
	if (( out = fopen ( name, "w")) == NULL)
	    { printf ( " can not open outfile \n");
	      exit(0);
	    }	
	printf("ok \n");

        /* scann each line to replace N/A with -99.0000
           replace / with : */
        k = 0 ;         
//	while (!feof(in) && k < 20)
	while (!feof(in) )
        {
//           printf( "KKKKKKKK = %d \n", k);
           fgets(first_line, 400, in) ;
           ii = 0;
        //   printf( "first line %s ", first_line);

           for ( i=0; i < 400; i++)
           {
              if ( first_line[i] == 'N' &&
                   first_line[i+1] == '/' && 
                   first_line[i+2] == 'A' ) 
              {
        //        printf( "change N/A to -99.0000 \n");
                new_line[ii] = '-';
                new_line[ii+1] = '9';
                new_line[ii+2] = '9';
                new_line[ii+3] = '.';
                new_line[ii+4] = '0';
                new_line[ii+5] = '0';
                new_line[ii+6] = '0';
                new_line[ii+7] = '0';
                ii = ii + 8; 
                i = i + 2;
               }
              else if ( first_line[i] == '/' ) 
               {
                  new_line[ii] = ':';
                  ii = ii + 1;
               }
              else     
               {
                 new_line[ii] = first_line[i];
                 ii = ii + 1;
               }
           }

          
          fprintf(tmpout,  "%s", new_line);
  //        k = k + 1 ;
        }

        rewind(tmpout); 
        close(in);
        close(tmpout);

        sleep(2); 
        if (( tmpin = fopen ( tmpname, "r")) == NULL)
	    { printf ( " can not open tmp file %s\n", tmpname);
	      exit(0);
	    }

         
        printf( "tmp name is opened .... %s \n", tmpname);	

	/* get first 3 lines */
	fgets(nnew_line, 250, tmpin);
        printf( "first line ==========%s ", nnew_line);
	fgets(first_line, 250, tmpin);
	fgets(first_line, 250, tmpin);
	fgets(first_line, 500, tmpin);
	fgets(first_line, 700, tmpin);

	fprintf( out, "   Date         Time  JulianD  SZA  AOT_1640  AOT_1020  AOT_870  AOT_675  AOT_667  AOT_555  AOT_551 AOT_532 AOT_531 AOT_500 AOT_490 AOT_443 AOT_440 AOT_412 AOT_380 AOT_340 Water(cm) Alpha_440_870 Alpha_380_500 Alpha_440_675 Alpha_500_870 Alpha340_440 Alpha_440_675  \n" ); 

	
	while (!feof(tmpin))
	{
         printf( "start in tmpin ... ") ;
         fgets(data.date,12, tmpin);
	 fgets(data.time,10, tmpin);

         printf ( "DATE : %s\n", data.date);
	 printf( "%s\n", data.time);
	
	 fscanf( tmpin , "%f,", &data.jday);
 
         /* printf("%s \n",data.time); */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%f,",&data.aot[i]);
	 }

	 /* scan water */
         fscanf ( tmpin, "%f,", &data.water);
	 
	 /* scan aot errors */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%f,",&data.aoterr[i]);
	 }
         
	 /* scan water err */
	 fscanf ( tmpin, "%f,", &data.watererr);
	
         /* scan  anstrm */
	 for (i=0; i<NANG; i++)
	 {fscanf(tmpin,"%f,",&data.angstrm[i]);
	 }
	
	 fgets(data.lastday, 12, tmpin);
	 printf( "last day = %s\n ", data.lastday);
         fscanf( tmpin, "%f", &data.sza);
         printf ( "SZA = %f\n\n", data.sza);

	 
	/* convert ASCII to digital numver */
	min[0]=data.time[3];min[1]=data.time[4];min[2]='\0';
	sec[0]=data.time[6];sec[1]=data.time[7];sec[2]='\0';
	hour[0]=data.time[0];hour[1]=data.time[1];hour[2]='\0';
	f_min=atoi(min)*1.0/60.; /* minutes to hour */
//        printf( " time %s min %s hour %s sec %s \n", data.time, hour, min, sec); 
	
	f_sec=atoi(sec)/3600.; /*seconds to hour */

	f_min=f_sec+f_min;
	f_min=f_min+atoi(hour); /* total hour */
	
	/* convert date to integer nube outputing in char format */
	year[0]=data.date[8]; year[1]=data.date[9]; year[2] = '\0';
	mon[0]=data.date[3];  mon[1]=data.date[4];  mon[2] = '\0';
	day[0]=data.date[0];  day[1]=data.date[1];  day[2] = '\0';

 //       printf ("date %s year, %7.6s\n", data.date, year);
// 16 AOD, 1 WATER, 6 ANG
	/****** NOTE data.aot[3] is at 0.675 ****/	

	 fprintf( out, " %2s %2s %2s %8.3f  %f %f", year, mon, day, f_min, data.jday, data.sza );
         for (k = 0; k < NWL; k++)
         {
            fprintf( out, " %f ",  data.aot[k]);
         }
         
            fprintf( out, " %f ",  data.water);

         for (k = 0; k < NANG; k++)
         {
            fprintf( out, " %f ",  data.angstrm[k]);
         }
          
         fprintf ( out,  "\n"); 

	fgets(temp,30,tmpin);
	}
	close(tmpin);
	close(out);
        remove(tmpname);
	}
	
