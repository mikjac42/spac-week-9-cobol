       IDENTIFICATION DIVISION.
       PROGRAM-ID. MOVIE-LOOKUP.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MOVIES-FILE 
               ASSIGN TO "movies_dataset.csv"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
           
           SELECT ID-FILE
               ASSIGN TO "movie_id.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-ID-STATUS.
           
           SELECT OUTPUT-FILE
               ASSIGN TO "movie_result.json"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-OUT-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD  MOVIES-FILE.
       01  MOVIE-RECORD            PIC X(2000).
       
       FD  ID-FILE.
       01  ID-RECORD               PIC X(10).
       
       FD  OUTPUT-FILE.
       01  OUTPUT-RECORD           PIC X(2000).
       
       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC XX.
       01  WS-ID-STATUS            PIC XX.
       01  WS-OUT-STATUS           PIC XX.
       01  WS-EOF                  PIC X VALUE 'N'.
       01  WS-HEADER-READ          PIC X VALUE 'N'.
       
       01  WS-SEARCH-ID            PIC 9(5).
       01  WS-CURRENT-ID           PIC 9(5).
       01  WS-FOUND                PIC X VALUE 'N'.
       
       01  CSV-FIELD-POINTERS.
           02  CSV-ID-START        PIC 9(4).
           02  CSV-ID-END          PIC 9(4).
           02  CSV-TITLE-START     PIC 9(4).
           02  CSV-TITLE-END       PIC 9(4).
           02  CSV-DATE-START      PIC 9(4).
           02  CSV-DATE-END        PIC 9(4).
           02  CSV-LANG-START      PIC 9(4).
           02  CSV-LANG-END        PIC 9(4).
           02  CSV-POP-START       PIC 9(4).
           02  CSV-POP-END         PIC 9(4).
           02  CSV-VOTE-CNT-START  PIC 9(4).
           02  CSV-VOTE-CNT-END    PIC 9(4).
           02  CSV-VOTE-AVG-START  PIC 9(4).
           02  CSV-VOTE-AVG-END    PIC 9(4).
           02  CSV-OVER-START      PIC 9(4).
           02  CSV-OVER-END        PIC 9(4).
       
       01  MOVIE-DATA.
           02  MOVIE-ID            PIC X(10).
           02  MOVIE-TITLE         PIC X(500).
           02  MOVIE-DATE          PIC X(20).
           02  MOVIE-LANG          PIC X(10).
           02  MOVIE-POP           PIC X(20).
           02  MOVIE-VOTE-CNT      PIC X(20).
           02  MOVIE-VOTE-AVG      PIC X(20).
           02  MOVIE-OVERVIEW      PIC X(1000).
       
       01  JSON-OUTPUT             PIC X(2000).
       01  WS-LENGTH               PIC 9(4).
       01  WS-POS                  PIC 9(4).
       
       PROCEDURE DIVISION.
       *> Main program logic, get request ID from input file, 
       *> lookup movie in CSV file, and write JSON result to output file
       MAIN-PROCEDURE.
           PERFORM READ-INPUT-ID
           IF WS-ID-STATUS = '00'
               PERFORM OPEN-FILE
               PERFORM SEARCH-MOVIE
               PERFORM CLOSE-FILE
               IF WS-FOUND = 'Y'
                   PERFORM BUILD-JSON-RESPONSE
                   PERFORM WRITE-OUTPUT
               END-IF
           END-IF
           STOP RUN.
       
       *> Read requested movie ID from input file
       READ-INPUT-ID.
           OPEN INPUT ID-FILE
           IF WS-ID-STATUS = '00'
               READ ID-FILE INTO ID-RECORD
               MOVE FUNCTION NUMVAL(ID-RECORD) TO WS-SEARCH-ID
               CLOSE ID-FILE
           END-IF.
       
       *> Open movies CSV file for reading
       OPEN-FILE.
           OPEN INPUT MOVIES-FILE
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'Y' TO WS-EOF
           END-IF.
       
       *> Close movies CSV file
       CLOSE-FILE.
           CLOSE MOVIES-FILE.
       
       *> Search for movie by ID in CSV file
       SEARCH-MOVIE.
           PERFORM UNTIL WS-EOF = 'Y' OR WS-FOUND = 'Y'
               READ MOVIES-FILE INTO MOVIE-RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF WS-HEADER-READ = 'N'
                           MOVE 'Y' TO WS-HEADER-READ
                       ELSE
                           PERFORM PARSE-CSV-LINE
                           IF WS-CURRENT-ID = WS-SEARCH-ID
                               MOVE 'Y' TO WS-FOUND
                           END-IF
                       END-IF
               END-READ
           END-PERFORM.
       
       *> Parse next CSV line into movie data fields
       PARSE-CSV-LINE.
           INITIALIZE CSV-FIELD-POINTERS
           INITIALIZE MOVIE-DATA
           MOVE 1 TO WS-POS
           
           PERFORM EXTRACT-ID
           PERFORM EXTRACT-TITLE
           PERFORM EXTRACT-DATE
           PERFORM EXTRACT-LANG
           PERFORM EXTRACT-POP
           PERFORM EXTRACT-VOTE-CNT
           PERFORM EXTRACT-VOTE-AVG
           PERFORM EXTRACT-OVERVIEW.
       
       *> Extract ID field
       EXTRACT-ID.
           MOVE WS-POS TO CSV-ID-START
           PERFORM FIND-NEXT-COMMA
           MOVE WS-POS TO CSV-ID-END
           COMPUTE WS-LENGTH = CSV-ID-END - CSV-ID-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 11
               MOVE MOVIE-RECORD(CSV-ID-START:WS-LENGTH) 
                   TO MOVIE-ID
               MOVE FUNCTION NUMVAL(MOVIE-ID) TO WS-CURRENT-ID
           END-IF
           ADD 1 TO WS-POS.
       
       *> Extract title field,
       *> with handling for quoted text containing commas
       EXTRACT-TITLE.
           MOVE WS-POS TO CSV-TITLE-START
           IF MOVIE-RECORD(WS-POS:1) = '"'
               ADD 1 TO WS-POS
               ADD 1 TO CSV-TITLE-START
               PERFORM FIND-QUOTE-END
           ELSE
               PERFORM FIND-NEXT-COMMA
           END-IF
           MOVE WS-POS TO CSV-TITLE-END
           COMPUTE WS-LENGTH = CSV-TITLE-END - CSV-TITLE-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 501
               MOVE MOVIE-RECORD(CSV-TITLE-START:WS-LENGTH) 
                   TO MOVIE-TITLE
           END-IF
           ADD 1 TO WS-POS.
       
       *> Extract release date field
       EXTRACT-DATE.
           MOVE WS-POS TO CSV-DATE-START
           PERFORM FIND-NEXT-COMMA
           MOVE WS-POS TO CSV-DATE-END
           COMPUTE WS-LENGTH = CSV-DATE-END - CSV-DATE-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 21
               MOVE MOVIE-RECORD(CSV-DATE-START:WS-LENGTH) 
                   TO MOVIE-DATE
           END-IF
           ADD 1 TO WS-POS.
       
       *> Extract original language field
       EXTRACT-LANG.
           MOVE WS-POS TO CSV-LANG-START
           PERFORM FIND-NEXT-COMMA
           MOVE WS-POS TO CSV-LANG-END
           COMPUTE WS-LENGTH = CSV-LANG-END - CSV-LANG-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 11
               MOVE MOVIE-RECORD(CSV-LANG-START:WS-LENGTH) 
                   TO MOVIE-LANG
           END-IF
           ADD 1 TO WS-POS.

       *> Extract popularity field
       EXTRACT-POP.
           MOVE WS-POS TO CSV-POP-START
           PERFORM FIND-NEXT-COMMA
           MOVE WS-POS TO CSV-POP-END
           COMPUTE WS-LENGTH = CSV-POP-END - CSV-POP-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 21
               MOVE MOVIE-RECORD(CSV-POP-START:WS-LENGTH) 
                   TO MOVIE-POP
           END-IF
           ADD 1 TO WS-POS.
       
       *> Extract vote count field
       EXTRACT-VOTE-CNT.
           MOVE WS-POS TO CSV-VOTE-CNT-START
           PERFORM FIND-NEXT-COMMA
           MOVE WS-POS TO CSV-VOTE-CNT-END
           COMPUTE WS-LENGTH = CSV-VOTE-CNT-END - CSV-VOTE-CNT-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 21
               MOVE MOVIE-RECORD(CSV-VOTE-CNT-START:WS-LENGTH) 
                   TO MOVIE-VOTE-CNT
           END-IF
           ADD 1 TO WS-POS.
       
       *> Extract vote average field
       EXTRACT-VOTE-AVG.
           MOVE WS-POS TO CSV-VOTE-AVG-START
           PERFORM FIND-NEXT-COMMA
           MOVE WS-POS TO CSV-VOTE-AVG-END
           COMPUTE WS-LENGTH = CSV-VOTE-AVG-END - CSV-VOTE-AVG-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 21
               MOVE MOVIE-RECORD(CSV-VOTE-AVG-START:WS-LENGTH) 
                   TO MOVIE-VOTE-AVG
           END-IF
           ADD 1 TO WS-POS.
       
       *> Extract overview field, 
       *> with handling for quoted text containing commas
       EXTRACT-OVERVIEW.
           MOVE WS-POS TO CSV-OVER-START
           IF MOVIE-RECORD(WS-POS:1) = '"'
               ADD 1 TO WS-POS
               ADD 1 TO CSV-OVER-START
               PERFORM FIND-QUOTE-END
               MOVE WS-POS TO CSV-OVER-END
           ELSE
               MOVE FUNCTION LENGTH(
                   FUNCTION TRIM(MOVIE-RECORD)) TO WS-POS
               MOVE WS-POS TO CSV-OVER-END
           END-IF
           COMPUTE WS-LENGTH = CSV-OVER-END - CSV-OVER-START
           IF WS-LENGTH > 0 AND WS-LENGTH < 1001
               MOVE MOVIE-RECORD(CSV-OVER-START:WS-LENGTH) 
                   TO MOVIE-OVERVIEW
           END-IF.
       
       *> Find next comma in CSV line
       FIND-NEXT-COMMA.
           PERFORM UNTIL WS-POS > FUNCTION LENGTH(MOVIE-RECORD) 
                      OR MOVIE-RECORD(WS-POS:1) = ','
               ADD 1 TO WS-POS
           END-PERFORM.

       *> Find the ending quote for quoted fields
       FIND-QUOTE-END.
           PERFORM UNTIL WS-POS > FUNCTION LENGTH(MOVIE-RECORD)
               IF MOVIE-RECORD(WS-POS:1) = '"'
                   EXIT PERFORM
               END-IF
               ADD 1 TO WS-POS
           END-PERFORM.
       
       *> Build JSON formatted output string
       BUILD-JSON-RESPONSE.
           INITIALIZE JSON-OUTPUT
           
           STRING '{"id":' 
                  FUNCTION TRIM(MOVIE-ID)
                  ',"title":"' 
                  FUNCTION TRIM(MOVIE-TITLE)
                  '","release_date":"' 
                  FUNCTION TRIM(MOVIE-DATE)
                  '","original_language":"' 
                  FUNCTION TRIM(MOVIE-LANG)
                  '","popularity":' 
                  FUNCTION TRIM(MOVIE-POP)
                  ',"vote_count":' 
                  FUNCTION TRIM(MOVIE-VOTE-CNT)
                  ',"vote_average":' 
                  FUNCTION TRIM(MOVIE-VOTE-AVG)
                  ',"overview":"' 
                  FUNCTION TRIM(MOVIE-OVERVIEW)
                  '"}'
               DELIMITED BY SIZE
               INTO JSON-OUTPUT
           END-STRING.
      
       *> Write JSON formatted output to output file
       WRITE-OUTPUT.
           OPEN OUTPUT OUTPUT-FILE
           IF WS-OUT-STATUS = '00'
               MOVE JSON-OUTPUT TO OUTPUT-RECORD
               WRITE OUTPUT-RECORD
               CLOSE OUTPUT-FILE
           END-IF.
