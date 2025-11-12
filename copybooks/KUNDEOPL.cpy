      ******************************************************************
      * Copybook til kundeinformation                                  *
      ******************************************************************
       02  KUNDE-ID        PIC X(10).
       02  FORNAVN         PIC X(20).
       02  EFTERNAVN       PIC X(20).
       02  ADDRESSE.
           03 VEJNAVN      PIC X(30).
           03 HUSNR        PIC X(5).
           03 ETAGE        PIC X(5).
           03 SIDE         PIC X(5).
           03 BYNAVN       PIC X(20).
           03 POSTNR       PIC X(4).
           03 LANDE-KODE   PIC X(2).
       02  KONTAKTINFO.
           03 TELEFON      PIC X(8).
           03 EMAIL        PIC X(50).
