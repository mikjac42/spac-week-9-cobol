       IDENTIFICATION DIVISION.
       PROGRAM-ID. Opgave3.
       

       DATA DIVISION.
       

       WORKING-STORAGE SECTION.
      * Variabler til kundeinformation
       01  kunde-id        PIC X(10)   VALUE SPACES.
       01  fornavn         PIC X(20)   VALUE SPACES.
       01  efternavn       PIC X(20)   VALUE SPACES.
       01  kontonummer     PIC X(20)   VALUE SPACES.
       01  balance         PIC 9(7)V99 VALUE 0.
       01  valutakode      PIC X(3)    VALUE SPACES.

      * Komposit variabel til fuldt navn
       01  fuldt-navn      PIC X(41)   VALUE SPACES.

      * Indekser og midlertidige variabler til strengbehandling
       01  read-index      PIC 9(2)    VALUE 0.
       01  write-index     PIC 9(2)    VALUE 0.
       01  current-char    PIC X       VALUE SPACE.
       01  previous-char   PIC X       VALUE SPACE.
       01  output-buffer   PIC X(100)  VALUE SPACES.
       
      * Tildel værdier til kundeinformations variabler
       PROCEDURE DIVISION.
       MOVE "1234567890"         TO kunde-id
       MOVE "Lars"               TO fornavn
       MOVE "Hansen"             TO efternavn
       MOVE "DK12345678912345"   TO kontonummer
       MOVE 2500.75              TO balance
       MOVE "DKK"                TO valutakode

      * Sammensæt fornavn og efternavn til fuldt-navn
       STRING fornavn DELIMITED BY SIZE
              " " DELIMITED BY SIZE
              efternavn DELIMITED BY SIZE
              INTO fuldt-navn

      * Fjern dobbelte mellemrum i fuldt-navn
       PERFORM VARYING read-index FROM 1 BY 1
        UNTIL read-index > LENGTH OF fuldt-navn
       
           MOVE fuldt-navn(read-index:1) TO current-char
           IF current-char = " " AND previous-char = " "
               CONTINUE
           ELSE
               ADD 1 TO write-index
               MOVE current-char TO output-buffer(write-index:1)
               
           END-IF
           MOVE current-char TO previous-char
       END-PERFORM

       MOVE output-buffer TO fuldt-navn

      * Print kundeinformation
       DISPLAY "-----------------------------"
       DISPLAY "Kunde ID   : "       kunde-id
       DISPLAY "Navn       : "         fuldt-navn
       DISPLAY "Kontonummer: "   kontonummer
       DISPLAY "Balance    : "      balance " " valutakode
       DISPLAY "-----------------------------"

       STOP RUN.
