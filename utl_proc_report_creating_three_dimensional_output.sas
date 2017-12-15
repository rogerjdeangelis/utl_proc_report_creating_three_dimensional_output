Proc report creating three dimensional output

You can use proc report with the corrresp output

https://goo.gl/GCFw3L
https://communities.sas.com/t5/SAS-Procedures/Proc-report-condensed-3-way-output/m-p/421631


INPUT
=====

WORK.HAVE total obs=4,410

 Obs    SURVEY    COHORT  BIRTHS   AGE

   1     1991      2011      2      19
   2     1991      2011     61      29
   3     1991      2011     36      23
   4     1991      2011     80      13
   5     1991      2011     70      19
   6     1991      2011     98      19
   7     1991      2011     28      19
   8     1991      2011      8      23
   9     1991      2011     37      23
  10     1991      2011     34      23
 .....


WORKING CODE
============

  * bucket age and years;

  surveygrp=cats('Survey_',put(round(survey,5)-4,4.),'_',put(round(survey,5)+5,4.));
  cohortgrp=cats('Cohort_',put(round(cohort,5)-4,4.),'_',put(round(cohort,5)+5,4.));

  *pseudo code;
  select;
     when (Age in (11-15))  agegrp="Age-11-15";
     when (Age in (16-20))  agegrp="Age-16-20";
     when (Age in (21-25))  agegrp="Age-21-25";
     when (Age in (26-30))  agegrp="Age-26-30";
     otherwise              agegrp="Age-31-35";
  end;

  proc corresp data=hav1st dim=1 observed cross=both;
    tables agegrp cohortgrp, surveygrp;
    weight births;
  run;quit;

OUTPUT
======

  WORK.WANT  total obs=26          SURVEY_    SURVEY_    SURVEY_    SURVEY_    SURVEY_
                                    1986_      1991_      1996_      2001_      2006_
   COHORT                            1995       2000       2005       2010       2015        SUM

   Age-11-15 * Cohort_1986_1995       377       1176       1076       1129       1331       5089
   Age-11-15 * Cohort_1991_2000       974       1880       2226       2681       1754       9515
   Age-11-15 * Cohort_1996_2005       890       2737       2473       1688       2280      10068
   Age-11-15 * Cohort_2001_2010       823       3260       2024       2523       1350       9980
   Age-11-15 * Cohort_2006_2015       775       2456       2116       1846       1554       8747
   Age-16-20 * Cohort_1986_1995       457       1297       1545       1191       1164       5654
   Age-16-20 * Cohort_1991_2000      1733       3881       3919       3650       3395      16578
   Age-16-20 * Cohort_1996_2005      1487       4302       3981       3513       3372      16655
  ...
  ...
   Age-31-35 * Cohort_1996_2005       457        289        344        546        290       1926
   Age-31-35 * Cohort_2001_2010       192        721        542        451        424       2330
   Age-31-35 * Cohort_2006_2015       117        183        287        618        464       1669

   Sum                              21089      51434      53121      51236      42561     219441


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

* i have augmented the data instead of creating a second dataset;
data have(drop=i);
 retain survey cohort births age;
 do survey=1991 to 2011;
    do cohort=2011 to 1991 by -1;
      do i=1 to 10;
         births = max(int(100*uniform(5731)),1);
         surveygrp=cats('Survey_',put(round(survey,5)-4,4.),'_',put(round(survey,5)+5,4.));
         cohortgrp=cats('Cohort_',put(round(cohort,5)-4,4.),'_',put(round(cohort,5)+5,4.));
         select;
            when (uniform(1234)<.2) do; age=13; agegrp="Age-11-15"; end;
            when (uniform(1234)<.4) do; age=19; agegrp="Age-16-20"; end;
            when (uniform(1234)<.6) do; age=23; agegrp="Age-21-25"; end;
            when (uniform(1234)<.8) do; age=29; agegrp="Age-26-30"; end;
            otherwise               do; age=33; agegrp="Age-31-35"; end;
         end;
         output;
      end;
    end;
  end;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

ods exclude all;
ods output observed=want(rename=label=Cohort);
proc corresp data=hav1st dim=1 observed cross=both;
tables agegrp cohortgrp, surveygrp;
weight births;
run;quit;
ods select all;

proc print data=want width=min;
run;quit;




