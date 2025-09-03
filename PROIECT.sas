* PROIECT PS;

*Crearea setului de date SAS;
data hoteluri;
 infile '/home/u64207962/HotelDataset_SAS.csv' dlm =',' dsd firstobs=2;
 length ID 8 Name $50 Type $20 Price 8 ReviewsCount 8 Rating 8 City $30 State $30;
 input ID Name $ Type $ Price ReviewsCount Rating City $ State $;
run;

* Vizualizarea informatiilor referitoare la setul de date;
title "Descrierea datelor:";
proc contents data=hoteluri;
run;

*Crearea si folosirea de etichete si formate;

proc format;
value ratingfmt 
     low -< 7     = "Slab"
     7   -< 8     = "Acceptabil"
     8   -< 9     = "Foarte bun"
     9   - high   = "Excelent";
value pricefmt
     low -< 150    = "Economie"
     150 -< 300    = "Standard"
     300 - high    = "Premium";
run;

data hoteluri_formatat;
    set hoteluri;
 label
        ID = "Cod Hotel"
        Name = "Numele Hotelului"
        Type = "Tip Cameră"
        Price = "Preț per Noapte (EUR)"
        ReviewsCount = "Număr Recenzii"
        Rating = "Scor Rating"
        City = "Cartier"
        State = "Oraș";
 format rating ratingfmt.
        price pricefmt.
run;

*Afisarea setului de date formatat;
proc print data=hoteluri_formatat(obs=10)LABEL;
run;

*Frecventa de aparitie pentru pret;
title "Frecventa de aparitie pentru pret";
proc FREQ data=hoteluri_formatat;
	TABLES Price /nocum nopercent;
       	FORMAT pret pricefmt.;
run;

*Frecventa de aparitie pentru rating;
title "Frecventa de aparitie pentru rating";
proc FREQ data=hoteluri_formatat;
	TABLES Rating /nocum nopercent;
       	FORMAT rating ratingfmt.;
run;

*Procesare conditionala;
* WHERE;
* Ex 1;
title "Hoteluri din Amsterdam Noord cu rating peste 8 sau pret peste 200 EUR";
proc print data=hoteluri;
    where City = 'Amsterdam Noord' and
          (Rating > 8 or Price > 200);
    var Name City Rating Price;
run;

*Ex 2 - crearea de subset si folosirea where;
data hoteluri_populare;
     set hoteluri;
     where (Type in ('Double Room', 'King Room')) and ReviewsCount ge 500;
run;

title "Camere Double sau King Room, cu minim 500 recenzii";
proc print data = hoteluri_populare;
    var Name City Price Rating;
run;

*Ex 3;
title "Hoteluri din Nijmegen cu pret mediu și rating foarte bun";
proc print data=hoteluri;
    where City = 'Nijmegen' and
          Price between 150 and 300 and Rating gt 8.5;
    var Name City Price Rating;
run;

* Clasificare preturi in grupe;
data hoteluri_clasificat;
length PriceCategory $10;
    set hoteluri;
    if Price < 100 and not missing(Price) then PriceCategory = "Mic";
    else if 100 <= Price < 200 then PriceCategory = "Mediu";
    else if Price >= 200 then PriceCategory = "Mare";
run;

title "Hoteluri cu categorii de pret";
proc print data=hoteluri_clasificat;
    var Name City Price PriceCategory;
run;

*Procesare iterativa;
*Determinarea scorului total pe baza mai multor variabile;
data scoruri_hoteluri;
    set hoteluri;
    
    length ScorTotal 8;
    ScorTotal = 0;

    if Rating >= 9 then ScorTotal + 3;
    else if Rating >= 8 then ScorTotal + 2;
    else if Rating >= 7 then ScorTotal + 1;

    if ReviewsCount >= 1000 then ScorTotal + 2;
    else if ReviewsCount >= 500 then ScorTotal + 1;

    if Price < 150 then ScorTotal + 1;
run;

proc print data=scoruri_hoteluri(obs=10);
    var Name Rating ReviewsCount Price ScorTotal;
run;

*Calcularea nr de zile pana la depasirea bugetului de 500 EUR;
data sejur;
    set hoteluri;
    length Sejur $ 20;
    buget = 500;
    Zile = 0;

    do while (buget >= Price and not missing(Price));
        buget = buget - Price;
        zile + 1;
    end;

    if zile >= 5 then Sejur = "Sejur lung";
    else if zile >= 3 then Sejur = "Sejur mediu";
    else if zile > 0 then Sejur = "Sejur scurt";
    else Sejur = "Buget insuficient";
run;

title "Număr de zile posibile la hoteluri din bugetul de 500 EUR";
proc print data=sejur;
    var Name City Price Zile Sejur;
run;

*Utilizarea functiilor SAS;

* Utilizarea functiilor text;
data hoteluri_text;
    set hoteluri;
    City_lower = lowcase(City);            
    Name_upper = upcase(Name);           
    First_word = scan(Name, 1);      
    Initials = substr(Name, 1, 3);      
    Length_Name = length(Name);         
run;

proc print data = hoteluri_text;
     var City Name City_lower Name_upper First_word Initials Length_Name;
run;

* Utilizarea de functii SAS intr-o procedura SQL;
proc sql;
    select City,
           count(*) as NrHoteluri,
           mean(Price) as PretMediu format=8.2,
           max(Rating) as MaxRating
    from hoteluri
    group by City;
quit;

* Combinarea seturilor de date prin proceduri specifice SAS şi SQL;

* Subset 1: hoteluri cu pret sub 200 EUR;
data hoteluri_ieftine;
    set hoteluri;
    where Price < 200;
run;

* Subset 2: hoteluri cu rating foarte bun (>= 8.5);
data hoteluri_bune;
    set hoteluri;
    where Rating >= 8.5;
run;

proc sort data=hoteluri_ieftine; by ID; run;
proc sort data=hoteluri_bune; by ID; run;

* Varianta 1 utilizand MERGE;
data hoteluri_combinate;
    merge hoteluri_ieftine(in=a) hoteluri_bune(in=b);
    by ID;
    if a and b; * păstrează doar hotelurile care au pret sub 200 și rating >= 8.5;
run;

proc print data=hoteluri_combinate(obs=10);
    var ID Name Price Rating City State;
    title "Hoteluri cu pret sub 200 si rating >= 8.5 ";
run;

* Varianta 2 utilizand PROC SQL;
proc sql;
    create table hoteluri_intersectie_sql as
    select a.*
    from hoteluri_ieftine as a
    inner join hoteluri_bune as b
    on a.ID = b.ID;
quit;

proc print data=hoteluri_intersectie_sql(obs=10);
    var ID Name Price Rating City State;
    title "Hoteluri cu pret sub 200 si rating >= 8.5 ";
run;

* Utilizarea masivelor;

data hoteluri_scor_simple;
    set hoteluri;
    array conditii[3];
    conditii[1] = (Rating >= 8);
    conditii[2] = (ReviewsCount >= 500);
    conditii[3] = (Price < 200);
    ScorSimplu = sum(of conditii[*]);
run;

proc print data=hoteluri_scor_simple (obs=10);
    var Name Rating ReviewsCount Price ScorSimplu;
    title "Scor simplu: număr de condiții îndeplinite de fiecare hotel";
run;

* Utilizarea de proceduri pentru raportare, proceduri statistice si reprezentari grafice;

* Procedura PRINT;

* EX 1;
proc sort data=hoteluri;
    by City;
run;

proc print data=hoteluri noobs label;
    by City;                  
    id Name;                  
    sum Price ReviewsCount;   
    var Type Price ReviewsCount Rating State; 
    label
        Name = "Numele Hotelului"
        Type = "Tip Cameră"
        Price = "Preț (EUR)"
        ReviewsCount = "Număr Recenzii"
        Rating = "Rating"
        City = "Oraș"
        State = "Regiune";
    title "Raport detaliat hoteluri pe orașe";
run;

* EX 2;
*Raport privind hotelurile din fiecare oras;
proc sort data=hoteluri_formatat;
    by State;
run;

proc print data=hoteluri_formatat noobs label;
    by State;
    id Name;
    var Price Rating;
    label Name = "Hotel"
          State = "Oraș"
          Price = "Preț pe noapte"
          Rating = "Scor rating";
    title "Raport simplu: Hoteluri grupate pe oraș";
run;

* Procedura UNIVARIATE;

*Analiza univariată a prețurilor hotelurilor;
proc univariate data=hoteluri_formatat nextrval=5 nextrobs=0;
    var Price;
    id Name;
    histogram Price / normal;
    title "Analiza univariată a prețurilor hotelurilor";
run;

* Procedura MEANS;

proc means data=hoteluri max min mean n nmiss sum;
    class City;
    var Price Rating ReviewsCount;
    title "Indicatori statistici pentru hoteluri, grupați pe orașe";
run;

* Realizarea de grafice;

* GCHART:
* Numarul hotelurilor pe orase;
proc gchart data=hoteluri;
    vbar3d City / 
        discrete 
        type=freq 
        sumvar=Price 
        maxis=axis1 
        raxis=axis2 
        width=10 
        coutline=black;
    title "Numărul de hoteluri pe orase";
run;
quit;

*GPLOT;
* Corelatia dintre nr de recenzii si pret;
symbol value=dot;
title "Corelatia dintre numarul de recenzii si pret - Grafic cu puncte";
proc gplot data=hoteluri;
    plot Price * ReviewsCount;
run;
quit;

*Corelatia dintre Rating si Pret;
proc sgplot data=hoteluri;
    scatter x=Rating y=Price;
    title "Corelatia dintre Rating si Pret";
run;

*Procedura CORR;
title "Corelația dintre Rating, Preț și Numărul de Recenzii";
proc corr data=hoteluri;
    var Rating Price ReviewsCount;
run;

*Procedura REG;

*Influenta numarului de recenzii asupra pretului;
title "Regresie: Influenta numarului de recenzii asupra pretului";
proc reg data=hoteluri;
    model Price = ReviewsCount;
    plot Price * ReviewsCount;
run;
quit;

*Analiza hoteluri;
PROC PRINT DATA=hoteluri;
    TITLE "Vizualizare date hoteluri";
RUN;

PROC CORR DATA=hoteluri;
    VAR Rating;
    WITH Price;
    TITLE "Corelatia dintre Rating si Pretul hotelurilor";
RUN;

PROC REG DATA=hoteluri;
    MODEL Price = Rating;
    PLOT Price*Rating;
    TITLE "Analiza de regresie: influenta Rating-ului asupra Pretului";
RUN;

* ANOVA;
PROC ANOVA DATA=hoteluri;
    CLASS City;
    MODEL Price = City;
    MEANS City / TUKEY;
    TITLE "Analiza ANOVA: Diferenta preturilor intre orase";
RUN;
