//STMTRUN  JOB (ACCT),'RUN STMTGEN',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID
//*********************************************************************
//* STMTRUN - App3. Runs STMTGEN to print account statements.
//*           Run after CUSTRUN (App1), ACCTDEF (App2) and TXNRUN (App2).
//*           STMTGEN only reads both masters and writes to SYSOUT.
//*
//* STMTGEN static-calls ACCTMGR (App2), which static-calls CUSTVAL
//* and ACCTCALC (App1/App2), and DATEUTIL (App1). All are link-edited
//* into the STMTGEN load module, so only the App3 load library is
//* needed.
//* Change HLQ below to your own high-level qualifier.
//*********************************************************************
//         SET HLQ=IBMUSER
//RUN      EXEC PGM=STMTGEN
//STEPLIB  DD DISP=SHR,DSN=&HLQ..APP3.LOAD
//SYSOUT   DD SYSOUT=*
//CUSTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.CUSTMAST
//ACCTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.ACCTMAST
//ACCTMAS1 DD DISP=SHR,DSN=&HLQ..CROSSAPP.ACCTMAST.PATH
