       IDENTIFICATION DIVISION.
       PROGRAM-ID. Opgave7.


       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO "files/Kundeoplysninger.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT OUTPUT-FILE ASSIGN TO "files/KundeoplysningerOut.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD INPUT-FILE.
       01 INPUT-RECORD.
           05 KUNDE-ID        PIC X(10).
           05 FORNAVN         PIC X(20).
           05 EFTERNAVN       PIC X(20).
           05 VEJNAVN         PIC X(30).
           05 HUSNR           PIC X(5).
           05 ETAGE           PIC X(5).
           05 SIDE            PIC X(5).
           05 BYNAVN          PIC X(20).
           05 POSTNR          PIC X(4).
           05 LANDE-KODE      PIC X(2).
           05 TELEFON         PIC X(8).
           05 EMAIL           PIC X(50).

       FD OUTPUT-FILE.
       01  KUNDE-ADR.
           05 NAVN-ADR        PIC X(100).

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

      * Midlertidige variabler til filhåndtering
       01  END-OF-FILE     PIC X       VALUE "N".
           88  EOF-REACHED             VALUE "Y".
           88  EOF-NOT-REACHED         VALUE "N".


       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
       OPEN INPUT INPUT-FILE.
       OPEN OUTPUT OUTPUT-FILE.
       PERFORM UNTIL EOF-REACHED
           READ INPUT-FILE INTO INPUT-RECORD
               AT END
                   SET EOF-REACHED TO TRUE
               NOT AT END
                   MOVE INPUT-RECORD TO KUNDEOPL
                   PERFORM SAMMENSAET-FULDT-NAVN
                   PERFORM PRINT-KUNDEINFO
      *            Skriv kundeoplysninger til output fil
                   PERFORM SKRIV-KUNDE-ID-TIL-OUTPUT
                   PERFORM SKRIV-NAVN-TIL-OUTPUT
                   PERFORM SKRIV-ADRESSE-TIL-OUTPUT
                   PERFORM SKRIV-POST-BY-LAND-TIL-OUTPUT
                   PERFORM SKRIV-KONTAKTOPL-TIL-OUTPUT
                   PERFORM SKRIV-BLANK-LINJE-TIL-OUTPUT
           END-READ
       END-PERFORM.
       CLOSE INPUT-FILE.
       CLOSE OUTPUT-FILE.
       STOP RUN.


       SAMMENSAET-FULDT-NAVN.
      * TODO: Denne procedure kan simplificeres vha. TRIM funktioner
      * Nulstil indekser og buffer
       MOVE 0 TO READ-INDEX
       MOVE 0 TO WRITE-INDEX
       MOVE SPACES TO OUTPUT-BUFFER
       MOVE SPACE TO PREVIOUS-CHAR.

      * Sammensæt fornavn og efternavn til fuldt-navn
       STRING FORNAVN IN KUNDEOPL DELIMITED BY SIZE
              " " DELIMITED BY SIZE
              EFTERNAVN IN KUNDEOPL DELIMITED BY SIZE
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

       SKRIV-KUNDE-ID-TIL-OUTPUT.
       MOVE SPACES TO NAVN-ADR.
       MOVE KUNDE-ID IN KUNDEOPL TO NAVN-ADR.
       WRITE KUNDE-ADR.
      
       SKRIV-NAVN-TIL-OUTPUT.
       MOVE SPACES TO NAVN-ADR.
       STRING
           FUNCTION TRIM(FORNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(EFTERNAVN IN KUNDEOPL)
           INTO NAVN-ADR.
       WRITE KUNDE-ADR.

       SKRIV-ADRESSE-TIL-OUTPUT.
       MOVE SPACES TO NAVN-ADR.
       STRING 
           FUNCTION TRIM(VEJNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(HUSNR IN KUNDEOPL) " "
           FUNCTION TRIM(ETAGE IN KUNDEOPL) " "
           FUNCTION TRIM(SIDE IN KUNDEOPL)
           INTO NAVN-ADR.
       WRITE KUNDE-ADR.

       SKRIV-POST-BY-LAND-TIL-OUTPUT.
       MOVE SPACES TO NAVN-ADR.
       STRING
           FUNCTION TRIM(POSTNR IN KUNDEOPL) " "
           FUNCTION TRIM(BYNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(LANDE-KODE IN KUNDEOPL)
           INTO NAVN-ADR.
       WRITE KUNDE-ADR.

       SKRIV-KONTAKTOPL-TIL-OUTPUT.
       MOVE SPACES TO NAVN-ADR.
       STRING
           FUNCTION TRIM(TELEFON IN KUNDEOPL) " "
           FUNCTION TRIM(EMAIL IN KUNDEOPL)
           INTO NAVN-ADR.
       WRITE KUNDE-ADR.

       SKRIV-BLANK-LINJE-TIL-OUTPUT.
       MOVE SPACES TO NAVN-ADR.
       WRITE KUNDE-ADR.

       PRINT-KUNDEINFO.
      * Print kundeinformation
       DISPLAY "-----------------------------".
       DISPLAY "Kunde ID   : " KUNDE-ID IN KUNDEOPL.
       DISPLAY "Navn       : " FULDT-NAVN.
       DISPLAY "Adresse    : " 
           FUNCTION TRIM(VEJNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(HUSNR IN KUNDEOPL) ", "
           FUNCTION TRIM(ETAGE IN KUNDEOPL) ", "
           FUNCTION TRIM(SIDE IN KUNDEOPL) ", "
           FUNCTION TRIM(POSTNR IN KUNDEOPL) " "
           FUNCTION TRIM(BYNAVN IN KUNDEOPL) ", "
           FUNCTION TRIM(LANDE-KODE IN KUNDEOPL).
       DISPLAY "Telefon    : " TELEFON IN KUNDEOPL.
       DISPLAY "Email      : " EMAIL IN KUNDEOPL.
       DISPLAY "-----------------------------".
