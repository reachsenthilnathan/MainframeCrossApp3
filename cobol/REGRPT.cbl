       IDENTIFICATION DIVISION.
       PROGRAM-ID. REGRPT.
      *****************************************************************
      * REGRPT - Regulatory summary report: customer counts, account
      * counts and total balances.
      * Owned by App3.
      * Static CALL : DATEUTIL (App1).
      * Copybooks   : CUSTREC, DATELNK, RETCODES (App1);
      *               ACCTREC (App2); RPTLINE (App3).
      * Data        : DD CUSTMAST customer master (App1, READ ONLY)
      *               DD ACCTMAST account master (App2, READ ONLY)
      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTMAST ASSIGN TO CUSTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS CUST-ID
               FILE STATUS IS WS-CUST-FS.
           SELECT ACCTMAST ASSIGN TO ACCTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACCT-ID
               ALTERNATE RECORD KEY IS ACCT-CUST-ID
                   WITH DUPLICATES
               FILE STATUS IS WS-ACCT-FS.
       DATA DIVISION.
       FILE SECTION.
       FD  CUSTMAST.
           COPY CUSTREC.
       FD  ACCTMAST.
           COPY ACCTREC.
       WORKING-STORAGE SECTION.
           COPY RETCODES.
           COPY DATELNK.
           COPY RPTLINE.
       01  WS-CUST-FS                  PIC X(2).
       01  WS-ACCT-FS                  PIC X(2).
       01  WS-EOF-SW                   PIC X(1).
           88  WS-EOF                  VALUE 'Y'.
       01  WS-TOTALS.
           05  WS-ACTIVE-CUSTS         PIC 9(8) VALUE ZERO.
           05  WS-CLOSED-CUSTS         PIC 9(8) VALUE ZERO.
           05  WS-OPEN-ACCTS           PIC 9(8) VALUE ZERO.
           05  WS-CLOSED-ACCTS         PIC 9(8) VALUE ZERO.
           05  WS-OPEN-BALANCE         PIC S9(11)V99 COMP-3 VALUE ZERO.
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE RC-OK TO RETURN-CODE
           OPEN INPUT CUSTMAST
           OPEN INPUT ACCTMAST
           IF WS-CUST-FS NOT = '00' OR WS-ACCT-FS NOT = '00'
               DISPLAY 'REGRPT: OPEN FAILED, STATUS ' WS-CUST-FS
                       ' ' WS-ACCT-FS
               MOVE RC-ERROR TO RETURN-CODE
               GOBACK
           END-IF

           CALL 'DATEUTIL' USING DATE-PARMS

           PERFORM COUNT-CUSTOMERS
           PERFORM COUNT-ACCOUNTS
           PERFORM PRINT-REPORT

           CLOSE CUSTMAST
           CLOSE ACCTMAST
           GOBACK.

       COUNT-CUSTOMERS.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
               READ CUSTMAST NEXT RECORD
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       IF CUST-CLOSED
                           ADD 1 TO WS-CLOSED-CUSTS
                       ELSE
                           ADD 1 TO WS-ACTIVE-CUSTS
                       END-IF
               END-READ
               IF WS-CUST-FS NOT = '00' AND WS-CUST-FS NOT = '10'
                   DISPLAY 'REGRPT: CUSTMAST READ FAILED, STATUS '
                           WS-CUST-FS
                   MOVE RC-ERROR TO RETURN-CODE
                   SET WS-EOF TO TRUE
               END-IF
           END-PERFORM.

       COUNT-ACCOUNTS.
           MOVE 'N' TO WS-EOF-SW
           PERFORM UNTIL WS-EOF
               READ ACCTMAST NEXT RECORD
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       IF ACCT-CLOSED
                           ADD 1 TO WS-CLOSED-ACCTS
                       ELSE
                           ADD 1 TO WS-OPEN-ACCTS
                           ADD ACCT-BALANCE TO WS-OPEN-BALANCE
                       END-IF
               END-READ
               IF WS-ACCT-FS NOT = '00' AND WS-ACCT-FS NOT = '02'
                  AND WS-ACCT-FS NOT = '10'
                   DISPLAY 'REGRPT: ACCTMAST READ FAILED, STATUS '
                           WS-ACCT-FS
                   MOVE RC-ERROR TO RETURN-CODE
                   SET WS-EOF TO TRUE
               END-IF
           END-PERFORM.

       PRINT-REPORT.
           DISPLAY 'REGULATORY SUMMARY REPORT  ' DL-FORMATTED-DATE
           MOVE 'ACTIVE CUSTOMERS' TO RL-LABEL
           MOVE WS-ACTIVE-CUSTS    TO RL-COUNT
           MOVE ZERO               TO RL-AMOUNT
           DISPLAY REPORT-LINE
           MOVE 'CLOSED CUSTOMERS' TO RL-LABEL
           MOVE WS-CLOSED-CUSTS    TO RL-COUNT
           DISPLAY REPORT-LINE
           MOVE 'OPEN ACCOUNTS'    TO RL-LABEL
           MOVE WS-OPEN-ACCTS      TO RL-COUNT
           MOVE WS-OPEN-BALANCE    TO RL-AMOUNT
           DISPLAY REPORT-LINE
           MOVE 'CLOSED ACCOUNTS'  TO RL-LABEL
           MOVE WS-CLOSED-ACCTS    TO RL-COUNT
           MOVE ZERO               TO RL-AMOUNT
           DISPLAY REPORT-LINE.
