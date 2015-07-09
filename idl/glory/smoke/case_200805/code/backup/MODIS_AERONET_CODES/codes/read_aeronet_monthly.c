	
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
       
       /* # of Angstrom Exponent */
        #define NANG 6 	
        
        struct data_type
	{int year, month;
	 float aot[NWL];
	 float water;
         float angstrm[NANG];
	 float aotw[NWL];
	 float waterw;
         float angstrmw[NANG];
         int ndaot[NWL];
         int ndwater;
         int ndangstrm[NANG];
         int nobsaot[NWL];
         int nobswater;
         int nobsangstrm[NANG];
         int nmonthaot[NWL];
         int nmonthwater;
         int nmonthangstrm[NANG];	
         } ;
	struct data_type data;

	main(argc, argv)
	int argc;
	char *argv[];
	{
	 FILE *in, *out, *tmpout, *tmpin;
	 char new_line[3000], inname[120], first_line[3000], nnew_line[3000], 
              name[120], tmpname[120],temp[30],min[3],sec[3],hour[3];
	 char mon[3], day[3];
	 char year[3];
	 int i, ii, k;
	 float f_min,f_sec;

        	
	sprintf(name,"%s/%s%s", argv[3], "mon_", argv[1]);
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
	fgets(first_line, 2900, tmpin);

        printf( "first line ==========%s \n", first_line);

	fprintf( out, "   YEAR,   MON,   AOT_675 Daily Avg,  AOT_551 Daily Avg,  Water(cm) [935nm] of Daily Avg,  500-870 Angstrom of Daily Avg,  AOT_675 of Weighted Avg,   AOT_551 of Weighted Avg, 500-870 Angstrom of Weighted Avg, N Days[AOT_675], N Days[AOT_551], ,N Days[Water(cm)], N Days[500-870 Angstrom],  N Obs[AOT_675],  N Obs[Water(cm), N Obs[500-870 Angstrom, N Months[AOT_675], N Months[Water(cm)], N Months[500-870 Angstrom\n" ); 
	
	while (!feof(tmpin))
	{
//         printf( "start in tmpin ... ") ;
	 fscanf( tmpin , "%d,", &data.year);
	 fscanf( tmpin , "%d,", &data.month);
//         printf ("%d %d \n", data.year, data.month);
 
         /* printf("%s \n",data.time); */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%f,",&data.aot[i]);
	 }

	 /* scan water */
         fscanf ( tmpin, "%f,", &data.water);
	 
         /* scan  anstrm */
	 for (i=0; i<NANG; i++)
	 {fscanf(tmpin,"%f,",&data.angstrm[i]);
	 }
	 
         /* scan aotw  */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%f,",&data.aotw[i]);
	 }
	 /* scan water weighted */
	 fscanf ( tmpin, "%f,", &data.waterw);
	
         /* scan  anstrm weighted*/
	 for (i=0; i<NANG; i++)
	 {fscanf(tmpin,"%f,",&data.angstrmw[i]);
	 }

         /* scan nday aot */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%d,",&data.ndaot[i]);
	 }
          fscanf(tmpin,"%d,",&data.ndwater);
 
         /* scan nday angstrm */ 
	 for (i=0; i<NANG; i++)
	 {fscanf(tmpin,"%d,",&data.ndangstrm[i]);
	 }

         /* scan nday aot */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%d,",&data.nobsaot[i]);
	 }
          fscanf(tmpin,"%d,",&data.nobswater);
 
         /* scan nday angstrm */ 
	 for (i=0; i<NANG; i++)
	 {fscanf(tmpin,"%d,",&data.nobsangstrm[i]);
	 }

         /* scan nday aot */
	 for (i=0; i<NWL; i++)
	 {fscanf(tmpin,"%d,",&data.nmonthaot[i]);
	 }
          fscanf(tmpin,"%d,",&data.nmonthwater);
 
         /* scan nday angstrm */ 
	 for (i=0; i<NANG; i++)
	 {fscanf(tmpin,"%d,",&data.nmonthangstrm[i]);
	 }

         /* print out */
	 fprintf( out, " %4d %2d ", data.year, data.month );

           /* AOT at 0.675 um */
         fprintf( out, " %f ",  data.aot[3]);
         fprintf( out, " %f ",  data.aot[6]);
         fprintf( out, " %f ",  data.water);
         fprintf( out, " %f ",  data.angstrm[3]);

         fprintf( out, " %f ",  data.aotw[3]);
         fprintf( out, " %f ",  data.aotw[6]);
         fprintf( out, " %f ",  data.waterw);
         fprintf( out, " %f ",  data.angstrmw[3]);
          
         fprintf( out, " %3d ",  data.ndaot[3]);
         fprintf( out, " %3d ",  data.ndaot[6]);
         fprintf( out, " %3d ",  data.ndwater);
         fprintf( out, " %3d ",  data.ndangstrm[3]);

         fprintf( out, " %3d ",  data.nobsaot[3]);
         fprintf( out, " %3d ",  data.nobsaot[6]);
         fprintf( out, " %3d ",  data.nobswater);
         fprintf( out, " %3d ",  data.nobsangstrm[3]);

         fprintf( out, " %3d ",  data.nmonthaot[3]);
         fprintf( out, " %3d ",  data.nmonthaot[6]);
         fprintf( out, " %3d ",  data.nmonthwater);
         fprintf( out, " %3d ",  data.nmonthangstrm[3]);
         fprintf ( out,  "\n"); 

	fgets(temp,30,tmpin);
	}
	close(tmpin);
	close(out);
        remove(tmpname);
	}
	
