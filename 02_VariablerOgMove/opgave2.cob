       IDENTIFICATION DIVISION.
       PROGRAM-ID. opgave2.
       
       DATA DIVISION.
       
       WORKING-STORAGE SECTION.
       01  kunde-id        PIC X(10)   VALUE SPACES.
       01  fornavn         PIC X(20)   VALUE SPACES.
       01  efternavn       PIC X(20)   VALUE SPACES.
       01  kontonummer     PIC X(20)   VALUE SPACES.
       01  balance         PIC 9(7)V99 VALUE 0.
       01  valutakode      PIC X(3)    VALUE SPACES.

       PROCEDURE DIVISION.
       MOVE "1234567890"         TO kunde-id
       MOVE "Lars"               TO fornavn
       MOVE "Hansen"             TO efternavn
       MOVE "DK12345678912345"   TO kontonummer
       MOVE 2500.75              TO balance
       MOVE "DKK"                TO valutakode

       DISPLAY "Kunde ID: "       kunde-id
       DISPLAY "Navn: "         fornavn " " efternavn
       DISPLAY "Kontonummer: "   kontonummer
       DISPLAY "Balance: "      balance " " valutakode

       STOP RUN.
