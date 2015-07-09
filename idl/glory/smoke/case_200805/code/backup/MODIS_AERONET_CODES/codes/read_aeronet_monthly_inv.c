	
      /* This program is used to read the AERONET MONTHLY DATA*/
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
       
       /* # of Extionction Parameter */
        #define NEXT 12 

       /* define SSA */
        #define NSSA 4
   
       /* define ASY */
        #define NASY  12

       /* define tmp */
        #define NTMP  22
        
       /* number of total parameters excluding year, mon, and datatype*/
       #define NPAR  116 
 
        struct data_type
	{int year, month;                                                 // 2
         int datatype;                                                    // 3
	 float aot[NWL];						 // 19 	
	 float water;							// 20				
         float AOTEXT[NEXT];                                            // 32
         float angstrmExt;             // Angstrom exponent 870-440     // 33
	 float SSA[NSSA];           // Single Scattering Albedo         // 37
         float AOTABS[NSSA];                                            // 41 
         float angstrmAbs;             // Absorption                    // 42
         float REFR[NSSA];                                              // 46
         float REFI[NSSA];						// 50
         float ASYM[NASY];                                              // 72
         float TMP[NTMP];                                               // 84 
         float Inflection_P;                                            // 85
         float VolConT;                                                 // 86                   
         float EffRadT;
         float VolMedianRadT;
         float StdDevT;
	 float VolConF;
	 float EffRadF;
	 float VolMedianRadF;
         float StdDevF;
	 float VolConC;
	 float EffRadC;
	 float VolMedianRadC;
	 float StdDevC;
         float AltitudeBOA;
         float AltitudeTOA;
         float DownwardFluxBOA;
 	 float DownwardFluxTOA;
	 float UpwardFluxBOA;
	 float UpwardFluxTOA;
	 float RadiativeForcingBOA;
	 float RadiativeForcingTOA;
	 float ForcingEfficiencyBOA;
	 float ForcingEfficiencyTOA;                                   //  107 
	 float DownwardFlux[NSSA];                                    // 111
	 float UpwardFlux[NSSA];                                       // 115
	 float DiffuseFlux[NSSA];                                      // 119
         int days[NPAR]; 
         } ;

	struct data_type data;

	main(argc, argv)
	int argc;
	char *argv[];
	{
	 FILE *in, *out, *tmpout, *tmpin;
	 char new_line[3000], inname[120], first_line[3000], nnew_line[3000], 
              name[120], tmpname[120],temp[3000],min[3],sec[3],hour[3];
	 char mon[3], day[3];
	 char year[3];
	 int i, ii, k;
	 float f_min,f_sec;

        	
	sprintf(name,"%s/%s%s", argv[3], "inv_mon_", argv[1]);
	sprintf(tmpname,"%s/%s%s", argv[3], "tmp_", argv[1]);
	sprintf(inname,"%s/%s", argv[2],  argv[1]);
	
	 if ( argc < 4 )
	   { printf(" a.out filename inputdir outputdir \n");
             exit(0);
	    }	
        if (( in = fopen ( inname, "r")) == NULL)
	    { printf ( " can not open infile %s \n", inname);
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
           fgets(first_line, 900, in) ;
           ii = 0;
//           printf( "first line %s ", first_line);

           for ( i=0; i < 900; i++)
           {
              if ( first_line[i] == 'N' &&
                   first_line[i+1] == '/' && 
                   first_line[i+2] == 'A' ) 
              {
        //        printf( "change N/A to -99.0000 \n");
                new_line[ii] = '-';
                new_line[ii+1] = '9';
    //            new_line[ii+2] = '.';
    //            new_line[ii+3] = '9';
    //            new_line[ii+4] = '9';
    //            new_line[ii+5] = '9';
    //            new_line[ii+6] = '9';
    //            new_line[ii+7] = '9';
    //            ii = ii + 8; 
                ii = ii + 2; 
                i = i + 2;
               }
       
             else if (first_line[i] == 'F' &&        // from daily avg.
                      first_line[i+1] == 'r' &&
                      first_line[i+2] == 'o' &&
                      first_line[i+3] == 'm' &&
                      first_line[i+4] == ' ' &&
                      first_line[i+5] == 'D' )
                     {
                        new_line[ii] = '1';
                        ii = ii+1;
                        i = i + 18;
                     }  
 
             else if (first_line[i] == 'F' &&        // from Weighted avg.
                      first_line[i+1] == 'r' &&
                      first_line[i+2] == 'o' &&
                      first_line[i+3] == 'm' &&
                      first_line[i+4] == ' ' &&
                      first_line[i+5] == 'W' )
                     {
                        new_line[ii] = '2';
                        ii = ii+1;
                        i = i + 21;
                     }   
             else if (first_line[i] == 'N' &&        // Num of days 
                      first_line[i+1] == 'u' &&
                      first_line[i+2] == 'm' &&
                      first_line[i+3] == 'b' &&
                      first_line[i+7] == 'o' &&
                      first_line[i+10] == 'D' )
                     {
                        new_line[ii] = '3';
                        ii = ii+1;
                        i = i + 13;
                     }   
             else if (first_line[i] == 'N' &&        // Number of Observations 
                      first_line[i+1] == 'u' &&
                      first_line[i+2] == 'm' &&
                      first_line[i+3] == 'b' &&
                      first_line[i+7] == 'o' &&
                      first_line[i+10] == 'O' )
                     {
                        new_line[ii] = '4';
                        ii = ii+1;
                        i = i + 21;
                     }   
                       
 
             else if ( first_line[i] == '/' ) 
               {
                  new_line[ii] = ':';
                  ii = ii + 1;
               }

// JAN
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'J'  &&
                        first_line[i+2] == 'A'  &&
                        first_line[i+3] == 'N') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '1';
              //    new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }

// FEB 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'F'  &&
                        first_line[i+2] == 'E'  &&
                        first_line[i+3] == 'B') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '2';
              //    new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }


// MARCH 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'M'  &&
                        first_line[i+2] == 'A'  &&
                        first_line[i+3] == 'R') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '3';
              //    new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// APR 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'A'  &&
                        first_line[i+2] == 'P'  &&
                        first_line[i+3] == 'R') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '4';
           //       new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// MAY 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'M'  &&
                        first_line[i+2] == 'A'  &&
                        first_line[i+3] == 'Y') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '5';
            //      new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// JUNE
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'J'  &&
                        first_line[i+2] == 'U'  &&
                        first_line[i+3] == 'N') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '6';
             //     new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// JULY
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'J'  &&
                        first_line[i+2] == 'U'  &&
                        first_line[i+3] == 'L') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '7';
            //      new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// AUG 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'A'  &&
                        first_line[i+2] == 'U'  &&
                        first_line[i+3] == 'G') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '8';
            //      new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// SEP 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'S'  &&
                        first_line[i+2] == 'E'  &&
                        first_line[i+3] == 'P') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '0';
                  new_line[ii+2] = '9';
             //     new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// OCT 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'O'  &&
                        first_line[i+2] == 'C'  &&
                        first_line[i+3] == 'T') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '1';
                  new_line[ii+2] = '0';
             //     new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// NOV 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'N'  &&
                        first_line[i+2] == 'O'  &&
                        first_line[i+3] == 'V') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '1';
                  new_line[ii+2] = '1';
            //      new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
// DEC 
              else if ( first_line[i] == '-'  &&
                        first_line[i+1] == 'D'  &&
                        first_line[i+2] == 'E'  &&
                        first_line[i+3] == 'C') 
               {
                  new_line[ii] = ',';
                  new_line[ii+1] = '1';
                  new_line[ii+2] = '2';
             //     new_line[ii+3] = ',';
                  ii = ii + 3;
                  i = i + 3;
               }
              
              else     
               {
                 new_line[ii] = first_line[i];
                 ii = ii + 1;
               }
           }
          
//          printf ( "%d \n  %s ", ii, new_line);
          fprintf(tmpout,  "%s", new_line);
          k = k + 1 ;
//          printf ( " %s ", new_line);
        }

        rewind(tmpout); 
        close(in);
        close(tmpout);

        if (( tmpin = fopen ( tmpname, "r")) == NULL)
	    { printf ( " can not open tmp file %s\n", tmpname);
	      exit(0);
	 }

         
        printf( "tmp name is opened .... %s \n", tmpname);	

	/* get first 3 lines */
	fgets(first_line, 2000, tmpin);
	fgets(first_line, 2000, tmpin);
	fgets(first_line, 2000, tmpin);
	fgets(first_line, 2000, tmpin);
//	fgets(first_line, 2900, tmpin);

        printf( "first line ==========%s \n", first_line);

	fprintf( out, "   YEAR MON  AOT    DAY  PW      DAY   SSA     DAY   REFR    DAY  REFI   DAY   ASY    DAY  ASY    DAY   ASY     DAY\n" ); 
	
	while (!feof(tmpin))
	{
//         printf( "start in tmpin ... ") ;
	 fscanf( tmpin , "%d,", &data.year);
	 fscanf( tmpin , "%d,", &data.month);
//         printf ("%d %d \n", data.year, data.month);
 
	 fscanf( tmpin , "%d,", &data.datatype);

/* read averaged, not weighted averaged */
         if ( data.datatype == 1 ) 
     { 
         
         /* printf("%s \n",data.time); */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%f,",&data.aot[i]);
	 }

	 /* scan water */
         fscanf ( tmpin, "%f,", &data.water);
 
         /* AOT EXT */
         for (i=0; i<NEXT; i++)
         {fscanf (tmpin, "%f,", &data.AOTEXT[i]);
         }
 
         /* ANstrom Exp */
         fscanf (tmpin, "%f,", &data. angstrmExt);
  
         /* scan SSA */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.SSA[i]);
         }
 
         /* AOT absorption */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.AOTABS[i]);
         }

         /* scan Angstromabs */
         {fscanf (tmpin, "%f,", &data. angstrmAbs);
         }

         /* scan real part */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.REFR[i]);
         }
 
         /* scan imaginery part */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.REFI[i]);
         }

         /* ASY FACTOR */
         for (i=0; i<NASY; i++)
         {fscanf (tmpin, "%f,", &data.ASYM[i]);
         }

         /* scan tmp points */
         for (i=0; i<NTMP; i++)
         {fscanf (tmpin, "%f,", &data.TMP[i]);
         }
       }

      
/* read number of days */
         if (data.datatype == 3) 
     {
	 for (i = 0; i<NPAR; i++)
        {
          fscanf( tmpin , "%d,", &data.days[i]);
        }

         fscanf (tmpin, "%f,", &data.Inflection_P);
         fscanf (tmpin, "%f,", &data.VolConT);          
         fscanf (tmpin, "%f,", &data.EffRadT);         
         fscanf (tmpin, "%f,", &data.VolMedianRadT);         
         fscanf (tmpin, "%f,", &data.StdDevT);
         fscanf (tmpin, "%f,", &data.VolConF);
         fscanf (tmpin, "%f,", &data.EffRadF);
         fscanf (tmpin, "%f,", &data.VolMedianRadF);
         fscanf (tmpin, "%f,", &data.StdDevF);
         fscanf (tmpin, "%f,", &data.VolConC);
         fscanf (tmpin, "%f,", &data.EffRadC);
         fscanf (tmpin, "%f,", &data.VolMedianRadC);
         fscanf (tmpin, "%f,", &data.StdDevC);
         fscanf (tmpin, "%f,", &data.AltitudeBOA);
         fscanf (tmpin, "%f,", &data.AltitudeTOA);
         fscanf (tmpin, "%f,", &data.DownwardFluxBOA);
         fscanf (tmpin, "%f,", &data.DownwardFluxTOA);
         fscanf (tmpin, "%f,", &data.UpwardFluxBOA);
         fscanf (tmpin, "%f,", &data.UpwardFluxTOA);
         fscanf (tmpin, "%f,", &data.RadiativeForcingBOA);
         fscanf (tmpin, "%f,", &data.RadiativeForcingTOA);
         fscanf (tmpin, "%f,", &data.ForcingEfficiencyBOA);
         fscanf (tmpin, "%f,", &data.ForcingEfficiencyTOA);
         
         /* Scan Downward Flux */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.DownwardFlux[i]);
         }

         /* Scan UPward Flux */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.UpwardFlux[i]);
         }

         /* Scan Diffuse Flux */
         for (i=0; i<NSSA; i++)
         {fscanf (tmpin, "%f,", &data.DiffuseFlux[i]);
         }

/**** START TO PRINT OUT THINGS ***********/
         /* print out */
	 fprintf( out, " %4d %2d ", data.year, data.month );

           /* AOT at 0.675 um find index of days by subtracing line #
             in monthly_parameter_inversion.txt with 4*/
         fprintf( out, " %7.4f ",  data.aot[3]);
         fprintf( out, " %2d ",  data.days[3]);
        
	 fprintf( out, " %7.4f ",  data.water);
         fprintf( out, " %2d ",  data.days[16]);
        
//	 fprintf( out, " %7.4f ",  data.SSA[1]);  // at 0.675 um
//         fprintf( out, " %2d ",  data.days[31]);

/*
	 fprintf( out, " %7.4f ",  data.SSA[0]);  // at 0.440 um 
         fprintf( out, " %2d ",  data.days[30]);
 */

//	 fprintf( out, " %7.4f ",  data.SSA[2]);  // at 0.875 um 
//         fprintf( out, " %2d ",  data.days[32]);
 
	 fprintf( out, " %7.4f ",  data.SSA[3]);  // at 1020 um 
         fprintf( out, " %2d ",  data.days[33]);

         fprintf( out, " %7.4f ",  data.REFR[1]);
         fprintf( out, " %2d ",  data.days[40]);
        
	 fprintf( out, " %7.4f ",  data.REFI[1]);
         fprintf( out, " %2d ",  data.days[44]);

/*   @0.675      
	 fprintf( out, " %7.4f ",  data.ASYM[1]);  
         fprintf( out, " %2d ",  data.days[48]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[5]);
         fprintf( out, " %2d ",  data.days[52]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[9]);
         fprintf( out, " %2d ",  data.days[56]);
*/

/******** 440 nm *************/
/*	 fprintf( out, " %7.4f ",  data.ASYM[0]);  
         fprintf( out, " %2d ",  data.days[47]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[4]);
         fprintf( out, " %2d ",  data.days[51]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[8]);
         fprintf( out, " %2d ",  data.days[55]);
*/
/* 875um **************/
/*
	 fprintf( out, " %7.4f ",  data.ASYM[2]);  
         fprintf( out, " %2d ",  data.days[49]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[6]);
         fprintf( out, " %2d ",  data.days[53]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[10]);
         fprintf( out, " %2d ",  data.days[57]);
*/

	 fprintf( out, " %7.4f ",  data.ASYM[3]);  
         fprintf( out, " %2d ",  data.days[50]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[7]);
         fprintf( out, " %2d ",  data.days[54]);
        
	 fprintf( out, " %7.4f ",  data.ASYM[11]);
         fprintf( out, " %2d ",  data.days[58]);

         fprintf( out, " %7.4f ",  data.angstrmExt);
         fprintf( out, " %2d ",  data.days[31]);

         fprintf ( out,  "\n"); 
       }
      
	fgets(temp,3000,tmpin);
      
       }
	close(tmpin);
	close(out);
        remove(tmpname);
}
	
