       IDENTIFICATION DIVISION.
       PROGRAM-ID. Opgave8.


       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE-KUNDEOPL 
               ASSIGN TO "files/Kundeoplysninger.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT INPUT-FILE-KONTOOPL 
               ASSIGN TO "files/KontoOpl.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT OUTPUT-FILE ASSIGN TO "files/KUNDEKONTO.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-FILE-KUNDEOPL.
       01  INPUT-RECORD.
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

       FD  INPUT-FILE-KONTOOPL.
       01  KONTO-RECORD.
           05 KUNDE-ID        PIC X(10).
           05 KONTO-ID        PIC X(10).
           05 KONTO-TYPE      PIC X(20).
           05 BALANCE         PIC Z(6)9V99.
           05 VALUTA-KD       PIC X(3).

       FD  OUTPUT-FILE.
       01  OUTPUT-RECORD.
           05 OUTPUT-TEXT        PIC X(100).

       WORKING-STORAGE SECTION.
       01  KUNDEOPL.
           COPY "copybooks/KUNDEOPL.cpy".

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

       01  FIRST-ENTRY     PIC X       VALUE "Y".
           88  IS-FIRST-ENTRY          VALUE "Y".
           88  IS-NOT-FIRST-ENTRY      VALUE "N".


       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
       OPEN INPUT INPUT-FILE-KUNDEOPL.
      * OPEN INPUT INPUT-FILE-KONTOOPL.
       OPEN OUTPUT OUTPUT-FILE.
       PERFORM UNTIL EOF-REACHED
           READ INPUT-FILE-KUNDEOPL INTO INPUT-RECORD
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
                   PERFORM SKRIV-KUNDE-KONTI-TIL-OUTPUT
      *            Skriv blank linje for at adskille kunder
                   PERFORM SKRIV-BLANK-LINJE-TIL-OUTPUT
           END-READ
       END-PERFORM.
       CLOSE INPUT-FILE-KUNDEOPL.
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
       MOVE SPACES TO OUTPUT-TEXT.
       MOVE KUNDE-ID IN KUNDEOPL TO OUTPUT-TEXT.
       WRITE OUTPUT-RECORD.
      
       SKRIV-NAVN-TIL-OUTPUT.
       MOVE SPACES TO OUTPUT-TEXT.
       STRING
           FUNCTION TRIM(FORNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(EFTERNAVN IN KUNDEOPL)
           INTO OUTPUT-TEXT.
       WRITE OUTPUT-RECORD.

       SKRIV-ADRESSE-TIL-OUTPUT.
       MOVE SPACES TO OUTPUT-TEXT.
       STRING 
           FUNCTION TRIM(VEJNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(HUSNR IN KUNDEOPL) " "
           FUNCTION TRIM(ETAGE IN KUNDEOPL) " "
           FUNCTION TRIM(SIDE IN KUNDEOPL)
           INTO OUTPUT-TEXT.
       WRITE OUTPUT-RECORD.

       SKRIV-POST-BY-LAND-TIL-OUTPUT.
       MOVE SPACES TO OUTPUT-TEXT.
       STRING
           FUNCTION TRIM(POSTNR IN KUNDEOPL) " "
           FUNCTION TRIM(BYNAVN IN KUNDEOPL) " "
           FUNCTION TRIM(LANDE-KODE IN KUNDEOPL)
           INTO OUTPUT-TEXT.
       WRITE OUTPUT-RECORD.

       SKRIV-KONTAKTOPL-TIL-OUTPUT.
       MOVE SPACES TO OUTPUT-TEXT.
       STRING
           FUNCTION TRIM(TELEFON IN KUNDEOPL) " "
           FUNCTION TRIM(EMAIL IN KUNDEOPL)
           INTO OUTPUT-TEXT.
       WRITE OUTPUT-RECORD.

       SKRIV-BLANK-LINJE-TIL-OUTPUT.
       MOVE SPACES TO OUTPUT-TEXT.
       WRITE OUTPUT-RECORD.

       SKRIV-KUNDE-KONTI-TIL-OUTPUT.
      * Skriv kundens kontooplysninger til output fil
       OPEN INPUT INPUT-FILE-KONTOOPL
       SET EOF-NOT-REACHED TO TRUE
       PERFORM UNTIL EOF-REACHED
           READ INPUT-FILE-KONTOOPL INTO KONTO-RECORD
               AT END
                   SET EOF-REACHED TO TRUE
               NOT AT END
                   IF KUNDE-ID IN 
                       KONTO-RECORD = KUNDE-ID IN KUNDEOPL
                       IF IS-FIRST-ENTRY
                           MOVE SPACES TO OUTPUT-TEXT
                           STRING 
                     "-------------------------------------------------"
                           INTO OUTPUT-TEXT
                           WRITE OUTPUT-RECORD
                           SET IS-NOT-FIRST-ENTRY TO TRUE
                       END-IF
                       MOVE SPACES TO OUTPUT-TEXT
                       STRING
                           KONTO-ID " | "
                           KONTO-TYPE " | "
                            BALANCE " " VALUTA-KD
                           INTO OUTPUT-TEXT
                       WRITE OUTPUT-RECORD
                   END-IF
           END-READ
       END-PERFORM
       SET EOF-NOT-REACHED TO TRUE
       SET IS-FIRST-ENTRY TO TRUE
       CLOSE INPUT-FILE-KONTOOPL.

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
