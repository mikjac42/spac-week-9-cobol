       IDENTIFICATION DIVISION.
       PROGRAM-ID. opgave5.
       

       DATA DIVISION.
       

       WORKING-STORAGE SECTION.
       01 KUNDEOPL.
           COPY "copybooks/KUNDEOPL.cpy".

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
       MOVE "1234567890"               TO KUNDE-ID.
       MOVE "Lars"                     TO FORNAVN.
       MOVE "Hansen"                   TO EFTERNAVN.
       MOVE "DK12345678912345"         TO KONTONUMMER.
       MOVE 2500.75                    TO BALANCE.
       MOVE "DKK"                      TO VALUTAKODE.

       MOVE "Lars Hansens Alle"                TO VEJNAVN.
       MOVE "123"                       TO HUSNR.
       MOVE "2"                        TO ETAGE.
       MOVE "tv"                       TO SIDE.
       MOVE "Holte"                TO BYNAVN.
       MOVE "2840"                     TO POSTNR.
       MOVE "DK"                       TO LANDE-KODE.
       MOVE "12345678"                 TO TELEFON.
       MOVE "lars.hansen@example.com"  TO EMAIL.

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
       DISPLAY "Adresse    : " VEJNAVN ", " HUSNR ", " ETAGE ", "
      -    SIDE ", " BYNAVN ", " POSTNR ", " LANDE-KODE.
       DISPLAY "Telefon    : " TELEFON.
       DISPLAY "Email      : " EMAIL.
       DISPLAY "-----------------------------".
       DISPLAY "Group print:".
       DISPLAY KUNDEOPL.
       DISPLAY KONTOINFO.
       DISPLAY "-----------------------------".

       STOP RUN.
