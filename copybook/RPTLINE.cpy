      *****************************************************************
      * RPTLINE - Regulatory report line layout (owned by App3)
      *****************************************************************
       01  REPORT-LINE.
           05  RL-LABEL                PIC X(30).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  RL-COUNT                PIC Z(8)9.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  RL-AMOUNT               PIC -(9)9.99.
