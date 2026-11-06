//RPTRUN   JOB (ACCT),'RUN REGRPT',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID
//*********************************************************************
//* RPTRUN  - App3. Runs REGRPT to print the register report.
//*           Run after CUSTRUN (App1), ACCTDEF (App2) and TXNRUN (App2).
//*           REGRPT only reads both masters and writes to SYSOUT.
//*           REGRPT static-calls DATEUTIL (App1), link-edited into its
//*           load module.
//* Change HLQ below to your own high-level qualifier.
//*********************************************************************
//         SET HLQ=IBMUSER
//RUN      EXEC PGM=REGRPT
//STEPLIB  DD DISP=SHR,DSN=&HLQ..APP3.LOAD
//SYSOUT   DD SYSOUT=*
//CUSTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.CUSTMAST
//ACCTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.ACCTMAST
//ACCTMAS1 DD DISP=SHR,DSN=&HLQ..CROSSAPP.ACCTMAST.PATH
