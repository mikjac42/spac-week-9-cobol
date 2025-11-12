       IDENTIFICATION DIVISION.
       PROGRAM-ID. Opgave4.
       

       DATA DIVISION.
       

       WORKING-STORAGE SECTION.
      * Variabler til kundeinformation
       01  KUNDEOPL.
           02  KUNDE-ID        PIC X(10)   VALUE SPACES.
           02  FORNAVN         PIC X(20)   VALUE SPACES.
           02  EFTERNAVN       PIC X(20)   VALUE SPACES.

      * Variabler til kontoinformation     
       01  KONTOINFO.
           02  KONTONUMMER     PIC X(20)   VALUE SPACES.
           02  BALANCE         PIC 9(7)V99 VALUE 0.
           02  VALUTAKODE      PIC X(3)    VALUE SPACES.

      * Komposit variabel til fuldt navn
       01  FULDT-NAVN      PIC X(41)   VALUE SPACES.

      * Indekser og midlertidige variabler til strengbehandling
       01  READ-INDEX      PIC 9(2)    VALUE 0.
       01  WRITE-INDEX     PIC 9(2)    VALUE 0.
       01  CURRENT-CHAR    PIC X       VALUE SPACE.
       01  PREVIOUS-CHAR   PIC X       VALUE SPACE.
       01  OUTPUT-BUFFER   PIC X(100)  VALUE SPACES.
       
      * Tildel værdier til kundeinformations variabler
       PROCEDURE DIVISION.
       MOVE "1234567890"         TO KUNDE-ID.
       MOVE "Lars"               TO FORNAVN.
       MOVE "Hansen"             TO EFTERNAVN.
       MOVE "DK12345678912345"   TO KONTONUMMER.
       MOVE 2500.75              TO BALANCE.
       MOVE "DKK"                TO VALUTAKODE.

      * Sammensæt fornavn og efternavn til fuldt-navn
       STRING FORNAVN DELIMITED BY SIZE
              " " DELIMITED BY SIZE
              EFTERNAVN DELIMITED BY SIZE
              INTO FULDT-NAVN.

      * Fjern dobbelte mellemrum i fuldt-navn
       PERFORM VARYING READ-INDEX FROM 1 BY 1
        UNTIL READ-INDEX > LENGTH OF FULDT-NAVN
       
           MOVE FULDT-NAVN(READ-INDEX:1) TO CURRENT-CHAR
           IF CURRENT-CHAR = " " AND PREVIOUS-CHAR = " "
               CONTINUE
           ELSE
               ADD 1 TO WRITE-INDEX
               MOVE CURRENT-CHAR TO OUTPUT-BUFFER(WRITE-INDEX:1)
               
           END-IF
           MOVE CURRENT-CHAR TO PREVIOUS-CHAR
       END-PERFORM.

       MOVE OUTPUT-BUFFER TO FULDT-NAVN.

      * Print kundeinformation
       DISPLAY "-----------------------------".
       DISPLAY "Kunde ID   : " KUNDE-ID.
       DISPLAY "Navn       : " FULDT-NAVN.
       DISPLAY "Kontonummer: " KONTONUMMER.
       DISPLAY "Balance    : " BALANCE " " VALUTAKODE.
       DISPLAY "-----------------------------".
       DISPLAY "Group print:".
       DISPLAY KUNDEOPL.
       DISPLAY KONTOINFO.
       DISPLAY "-----------------------------".

       STOP RUN.
