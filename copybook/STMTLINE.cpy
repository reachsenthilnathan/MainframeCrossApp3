      *****************************************************************
      * STMTLINE - Statement print line layout (owned by App3)
      *****************************************************************
       01  STATEMENT-LINE.
           05  SL-DATE                 PIC X(10).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  SL-ACCT-ID              PIC 9(10).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  SL-CUST-ID              PIC 9(8).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  SL-CUST-NAME            PIC X(30).
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  SL-BALANCE              PIC -(9)9.99.
           05  FILLER                  PIC X(2)  VALUE SPACES.
           05  SL-INTEREST             PIC -(9)9.99.
