       IDENTIFICATION DIVISION.
       PROGRAM-ID. STMTGEN.
      *****************************************************************
      * STMTGEN - Batch driver that produces account statements.
      * Owned by App3.
      * Static CALL : ACCTMGR (App2), DATEUTIL (App1).
      *               ACCTMGR in turn calls CUSTVAL (App1) and
      *               ACCTCALC (App2), so those objects are also
      *               link-edited into the STMTGEN load module.
      * Copybooks   : CUSTREC, DATELNK, RETCODES (App1);
      *               ACCTREC, ACCTMLNK (App2); STMTLINE (App3).
      * Data        : DD ACCTMAST account master (App2, READ ONLY)
      *               DD CUSTMAST customer master (App1, READ ONLY)
      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCTMAST ASSIGN TO ACCTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACCT-ID
               ALTERNATE RECORD KEY IS ACCT-CUST-ID
                   WITH DUPLICATES
               FILE STATUS IS WS-ACCT-FS.
           SELECT CUSTMAST ASSIGN TO CUSTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CUST-ID
               FILE STATUS IS WS-CUST-FS.
       DATA DIVISION.
       FILE SECTION.
       FD  ACCTMAST.
           COPY ACCTREC.
       FD  CUSTMAST.
           COPY CUSTREC.
       WORKING-STORAGE SECTION.
           COPY RETCODES.
           COPY ACCTMLNK.
           COPY DATELNK.
           COPY STMTLINE.
       01  WS-ACCT-FS                  PIC X(2).
       01  WS-CUST-FS                  PIC X(2).
       01  WS-EOF-SW                   PIC X(1) VALUE 'N'.
           88  WS-EOF                  VALUE 'Y'.
       01  WS-PRINTED-COUNT            PIC 9(6) VALUE ZERO.
       01  WS-SKIPPED-COUNT            PIC 9(6) VALUE ZERO.
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE RC-OK TO RETURN-CODE
           OPEN INPUT ACCTMAST
           OPEN INPUT CUSTMAST
           IF WS-ACCT-FS NOT = '00' OR WS-CUST-FS NOT = '00'
               DISPLAY 'STMTGEN: OPEN FAILED, STATUS ' WS-ACCT-FS
                       ' ' WS-CUST-FS
               MOVE RC-ERROR TO RETURN-CODE
               GOBACK
           END-IF

           CALL 'DATEUTIL' USING DATE-PARMS

           PERFORM UNTIL WS-EOF
               READ ACCTMAST NEXT RECORD
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       PERFORM PRINT-STATEMENT
               END-READ
               IF WS-ACCT-FS NOT = '00' AND WS-ACCT-FS NOT = '02'
                  AND WS-ACCT-FS NOT = '10'
                   DISPLAY 'STMTGEN: READ FAILED, STATUS ' WS-ACCT-FS
                   MOVE RC-ERROR TO RETURN-CODE
                   SET WS-EOF TO TRUE
               END-IF
           END-PERFORM

           DISPLAY 'STMTGEN: PRINTED=' WS-PRINTED-COUNT
                   ' SKIPPED=' WS-SKIPPED-COUNT
           CLOSE ACCTMAST
           CLOSE CUSTMAST
           GOBACK.

       PRINT-STATEMENT.
           MOVE ACCT-CUST-ID TO CUST-ID
           READ CUSTMAST
               INVALID KEY
                   DISPLAY 'STMTGEN: CUSTOMER NOT FOUND ' ACCT-CUST-ID
                   PERFORM SKIP-ACCOUNT
               NOT INVALID KEY
                   PERFORM CALL-ACCOUNT-MANAGER
           END-READ.

       CALL-ACCOUNT-MANAGER.
           CALL 'ACCTMGR' USING CUSTOMER-RECORD ACCOUNT-RECORD
                                ACCTMGR-RESULT
           IF AM-RETURN-CODE = RC-OK
               MOVE DL-FORMATTED-DATE TO SL-DATE
               MOVE ACCT-ID           TO SL-ACCT-ID
               MOVE CUST-ID           TO SL-CUST-ID
               MOVE CUST-NAME         TO SL-CUST-NAME
               MOVE ACCT-BALANCE      TO SL-BALANCE
               MOVE AM-INTEREST       TO SL-INTEREST
               DISPLAY STATEMENT-LINE
               ADD 1 TO WS-PRINTED-COUNT
           ELSE
               DISPLAY 'STMTGEN: SKIPPED ACCOUNT ' ACCT-ID
                       ' RC=' AM-RETURN-CODE
               PERFORM SKIP-ACCOUNT
           END-IF.

       SKIP-ACCOUNT.
           ADD 1 TO WS-SKIPPED-COUNT
           IF RETURN-CODE < RC-WARNING
               MOVE RC-WARNING TO RETURN-CODE
           END-IF.
