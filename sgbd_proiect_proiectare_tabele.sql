select*from angajat;
select*from contabili;
select*from contributii;
select*from sediu;
select*from conturi;
select*from carte;

set serveroutput on
declare
v_nume angajat.nume%type;
begin
select nume into v_nume from angajat where id_angajat=1;
dbms_output.put_line('Numele extras:'||v_nume);
end;
/
select * from angajat;

--Sa se creeze tabela manageri prin intermediul unei variabile de tip varchar2.
--La creeare , in tabela manageri se va adauga o noua inregistrare

set serveroutput on
variable g_id_angajat number--variabila globala
declare
v_sir varchar2(200);
begin 
:g_id_angajat:=1;--initializare variabila globala
v_sir:='create table manageri as select * from angajat where id_angajat='||:g_id_angajat;
dbms_output.put_line(v_sir);
execute immediate v_sir;
end;
/
select*from manageri;
drop table manageri cascade constraints;

--Sa se adauge o noua coloana numar_angajati in tabela sediu
set serveroutput on
declare
v_sir_deexceutat varchar2(200);
begin
v_sir_deexceutat:='alter table sediu add(numar_angajati number(7))';
dbms_output.put_line(v_sir_deexceutat);
execute immediate v_sir_deexceutat;
end;
/
select*from sediu;

--Se adauga o noua inregistrare in tabela angajat
begin
insert into angajat values(8 , 3 , 'DRAGHICI' , 'ALIN' , 29 , 1600);
end;
/
select * from angajat;

--Sa se adauge o noua inregistrare in tabela contabili cu ajutorul variabilelor de substitutie
begin
insert into contabili values(&id_contabili , &id_sef_contabil , '&nume' , '&prenume' , &id_sediu);
end;
/
select * from contabili;

--Se mareste cu 10 procente salariul angajatilor din tabela 
--angajat care au in prezent salariul mai mic decat o 
--anumit  valoare:
declare
v_procent number:=0.1;
v_prag_salarial NUMBER:=2400;
begin
update angajat set salariul=salariul*(1+v_procent) where salariul<v_prag_salarial;
end;
/
select * from angajat;

--In functie salariul angajatului
--avand id-ul citit de la tastatura, 
--se va afisa modificat pe ecran noua valoare.
-- 	Daca salariul este mai mic de 3000, 
--acesta se va dubla
-- 	Daca salariul este intre 3000 si 5000,  
--acesta se va mari de 1.5 ori
-- 	Altfel, pretul se va mari de 1.25 ori.

set serveroutput on
declare
v_id angajat.id_angajat%type;
v_salariul angajat.salariul%type;
begin
v_id:=&id_angajat;
select salariul into v_salariul from angajat where id_angajat=v_id;
dbms_output.put_line('Vechiul salariu : '||v_salariul);
if v_salariul <3000 then
    v_salariul:=2*v_salariul;
elsif v_salariul between 3000 and 5000 then
    v_salariul:=1.5*v_salariul;
else
    v_salariul:=1.25*v_salariul;
end if;
dbms_output.put_line('Noul salariu : '||v_salariul);
end;
/

--Se afi eaz   n ordine angaja ii cu codurile  n intervalul 
--3-7 at t timp c t salariul acestora este mai mic 
--dec t media:
set serveroutput on
declare
v_salmediu angajat.salariul%type;
v_sal angajat.salariul%type;
v_id angajat.id_angajat%type;
begin
select avg(salariul) into v_salmediu from angajat;
dbms_output.put_line('Salariul mediu : '||v_salmediu);
for v_id in 3..8 loop
select salariul into v_sal from angajat where id_angajat=v_id;
dbms_output.put_line('Angajatul cu id-ul '||v_id||' are salariul '||v_sal);
exit when v_sal<v_salmediu;
end loop;
end;
/

--IF
--IN fucntie de id-ul angajatului introdus de la tastatura , se va mari salariul acestuia cu 1.25 , daca are vechime mai mica de 20 de ani
-- , cu 1.5 daca are vechime intre 20 si 30 de ani , si cu 2 daca are vechime de peste 30 de ani.Sa se afiseze salariul initial si salariul final
set serveroutput on
accept g_id prompt 'Introduceti id-ul(intre 1 si 10) : '
declare
v_vechime carte.vechime%type;
v_id angajat.id_angajat%type;
v_salariul angajat.salariul%type;
begin
v_id:=&g_id;
select a.salariul , c.vechime into v_salariul,v_vechime from angajat a , carte c where a.id_angajat=c.id_angajat and a.id_angajat=v_id;
dbms_output.put_line('Salariul initial al angajatului este : '||v_salariul);
if v_vechime<20 then
    v_salariul:=v_salariul*1.25;
elsif v_vechime between 20 and 30 then
    v_salariul:=v_salariul*1.5;
else
        v_salariul:=v_salariul*2;
end if;  
dbms_output.put_line('Salariul final al angajatului este : '||v_salariul);
update angajat set salariul=v_salariul where id_angajat=v_id;
end;
/
rollback;

--CASE..WHEN..THEN
--Sa se modifice cas-ul angajatului cu numele introdus de la tastatura astfel:
--daca are varsta cuprinsa intre 20-35 de ani , se micsoreaza cas-ul cu 5%
---daca are varsta cuprinsa intre 35-50 de ani , se micsoreaza cas-ul cu 10%
----daca are varsta cuprinsa intre 50-69 de ani , se micsoreaza cas-ul cu 20%
--sa se afiseze cas-ul inainte si dupa modificare
set serveroutput on
accept g_nume prompt 'Introduceti numele angajatului : '
declare
v_nume angajat.nume%type;
v_cas contributii.cas%type;
v_varsta angajat.varsta%type;
begin
v_nume:='&g_nume';
select c.cas , a.varsta into v_cas , v_varsta from contributii c, angajat a where a.id_angajat=c.id_angajat and a.nume=v_nume;
dbms_output.put_line('cas inainte de modificare : '||v_cas);
case when v_varsta between 20 and 35 then v_cas:=v_cas*0.95;
when v_varsta between 35 and 50 then v_cas:=v_cas*0.9;
else  v_cas:=v_cas*0.8;
end case;
dbms_output.put_line('cas dupa modificare : '||v_cas);
update contributii set cas=v_cas where id_angajat=(select id_angajat from angajat where nume=v_nume);
exception when no_data_found then dbms_output.put_line('Nu exista angajatul cu numele respectiv');
end;
/
rollback;


--LOOP..END LOOP
--Sa se afiseze prenumele fiecarui angajat folosind structura repetitiva LOOP...END LOOP
set serveroutput on
declare
v_nume angajat.nume%type;
i number;
begin
i:=1;
loop
select nume into v_nume from angajat where id_angajat=i;
dbms_output.put_line('Nume angajat : '||v_nume);
i:=i+1;
exit when i>10;
end loop;
end;
/


--FOR..LOOP..END LOOP
--Sa se afiseze suma totala a soldurilor(din fiecare cont) fiecarui angajat cu id-ul cuprins intre 1 si 5 folosind
--structura repetitiva FOR...LOOP..END LOOP
set serveroutput on
declare
v_suma number(7);
begin
for v_id in 1..5 loop
v_suma:=0;
for v_record in (select sold sal from conturi where id_angajat=v_id)loop
v_suma:=v_suma+v_record.sal;
exit when sql%notfound;
end loop;    
dbms_output.put_line('Angajatul cu id_ul '||v_id||' are suma conturilor : '||v_suma);
exit when v_id=5;    
end loop;
end;
/

--Sa se afiseze locul nasterii angajatului cu prenumele introdus de la tastatura
--S? se trateze eroarea ap?rut? în cazul în care nu exist? nici un angajat cu acest prenume.
set serveroutput on
accept g_nume prompt 'Introduceti prenumele angajatului :'
declare
v_nastere carte.loc_nastere%type;
begin
select c.loc_nastere into v_nastere from angajat a , carte c where a.id_angajat=c.id_angajat and a.prenume='&g_nume';
dbms_output.put_line('Loc nastere :'||v_nastere);
exception when no_data_found then dbms_output.put_line('Nu exista niciun angajat cu numele respectiv !');
end;
/

--Sa se afiseze numele si prenumele angajatului din sediul cu id_sediu=4
--In cazul in care exista mai multi angajati la sediul cu id 4 , sa se arunce o exceptie
set serveroutput on
declare
v_nume contabili.nume%type;
v_prenume contabili.prenume%type;
begin
select nume , prenume into v_nume , v_prenume from contabili where id_sediu=4;
exception when too_many_rows then dbms_output.put_line('Exista mai multi angajati la sediul cu id 4');
end;
/

--Sa se schimbae id-ul angajatului introdus de la tastatura cu null.
--Sa se arunce eroare in cazul este incalcata vreo restrictie de integritate
set serveroutput on
accept g_id prompt 'Introduceti id :'
declare
v_exceptie exception;
pragma exception_init(v_exceptie , -01407);
begin
update angajat set id_angajat=null where id_angajat=&g_id;
exception when v_exceptie then dbms_output.put_line('Restrictia de integritate NOT NULL incalcata');
end;
/


--Sa se incerce adaugarea unui nou sediu in tabela sediu
--cu aceiasi locatie cu cea a sediului cu id_sediu=7
set serveroutput on
declare
v_exceptie exception;
pragma exception_init(v_exceptie , -00001);
v_locatie sediu.locatie%type;
begin
select locatie into v_locatie from sediu where id_sediu=7;
insert into sediu values(11,'hugaf',v_locatie,31);
exception when v_exceptie then dbms_output.put_line('Restrictia de integritate UNIQUE incalcata');
end;
/

--Sa se afiseze numele si prenumele angajatului cu id-ul introdus de la tastatura
set serveroutput on
accept g_id prompt 'Introduceti id :'
declare
v_nume angajat.nume%type;
v_prenume angajat.prenume%type;
v_id angajat.id_angajat%type;
v_exceptie exception;
begin
v_id:=&g_id;
if v_id>10 then raise v_exceptie;end if;
select nume , prenume into v_nume , v_prenume from angajat where id_angajat=v_id;
dbms_output.put_line('Angajatul are numele : '||v_nume||' '||v_prenume);
exception when v_exceptie then dbms_output.put_line('ID invalid !');
end;
/

--CURSORUL IMPLICIT
--Sa se modifice numele contabilului cu id sediu = 2
set serveroutput on
declare
v_nume angajat.nume%type;
begin
update contabili set nume='&nume' where id_sediu=2;
dbms_output.put_line('Linii afectate : '||sql%rowcount);
end;
/
rollback;

--CURSORUL IMPLICIT
--Sa se modifice salariul angajatului cu id_angajat=12 , cu o valoare introdusa de la tastatura
set serveroutput on
begin
update angajat set salariul=&Salariul where id_angajat=12;
if sql%notfound then dbms_output.put_line('Nu s-a gasit angajatul cu id-ul respectiv!');end if;
end;
/
rollback;

--CURSORUL EXPLICIT CU PARAMETRU
--Sa se afiseze numele si prenumele contabililor angajatilor cu id_angajat mai mare decat o valoare introdusa de la tastatura
set serveroutput on
accept z_id prompt 'Introduceti id :'
declare
cursor contabili_cursor(g_id number) is select nume nume , prenume prenume from  contabili  where id_sediu=g_id;
v_id angajat.id_angajat%type;
rec_cont contabili_cursor%rowtype;
begin
v_id:=&z_id;
open contabili_cursor(v_id);
loop
fetch contabili_cursor into rec_cont;
exit when contabili_cursor%notfound;
dbms_output.put_line(rec_cont.nume||' '||rec_cont.prenume);
end loop;
close contabili_cursor;
end;
/

--CURSORUL EXPLICIT CU PARAMETRU
--sa se afiseze soldul al angajatilor cu scorul de credit peste 50 
set serveroutput on
accept gg_sc_credit prompt 'Introduceti scorul de credit :'
declare
cursor sold_cursor(g_sc_credit number)is select sold s , id_angajat i from conturi where scor_credit>=g_sc_credit;
rec_cursor sold_cursor%rowtype;
v_sc_credit number(7);
begin
v_sc_credit:=&gg_sc_credit;
open sold_cursor(v_sc_credit);
loop
fetch sold_cursor into rec_cursor;
exit when sold_cursor%notfound;
dbms_output.put_line('Angajatul cu id_ul '||rec_cursor.i||' are soldul : '||rec_cursor.s);
end loop;
close sold_cursor;
end;
/

--CURSORUL EXLICIT FARA PARAMETRU
--Sa se afiseze numele si id-ul contabililor din sediul cu id=4
set serveroutput on
declare 
cursor cursor_s is select id_contabil id , nume nume from contabili where id_sediu=4;
v_record cursor_s%rowtype;
begin
open cursor_s;
loop
fetch cursor_s into v_record;
exit when cursor_s%notfound;
dbms_output.put_line('Nume : '||v_record.nume||' id: '||v_record.id);
end loop;
close cursor_s;
end;
/

--CURSORUL EXLICIT FARA PARAMETRU
--Sa se afiseze totalul contributiilor penrtu fiecare angajat
set serveroutput on
declare
cursor nume_cursor is select cas cas, cass cass, impozit impozit from contributii ;
v_cas contributii.cas%type;
v_cass contributii.cass%type;
v_impozit contributii.impozit%type;
v_record nume_cursor%rowtype;
v_nume angajat.nume%type;
v_prenume angajat.prenume%type;
suma number(7);
begin
for v_record in nume_cursor loop
suma:=0;
if v_record.cas is not null then suma:=suma+v_record.cas;end if;
if v_record.cass is not null then suma:=suma+v_record.cass;end if;
if v_record.impozit is not null then suma:=suma+v_record.impozit;end if;
select nume , prenume into v_nume , v_prenume from angajat a , contributii c where a.id_angajat=c.id_angajat and c.cas=v_record.cas;
dbms_output.put_line('Angajatul '||v_nume ||' '||v_prenume||' are total contributii : '||suma);
end loop;
end;
/
--CURSORUL EXLICIT FARA PARAMETRU
--Sa se afiseze denumirea sediilor cu id-urile pare
set serveroutput on
declare
cursor nume_cursor is select denumire_sediu n , id_sediu id from sediu ;
i number;
v_rec nume_cursor%rowtype;
begin
open nume_cursor;
loop
fetch nume_cursor into v_rec;
exit when nume_cursor%notfound;
for i in 2..10 loop
if v_rec.id=i then dbms_output.put_line('Nume sediu : '||v_rec.n);end if;
end loop;
end loop;
end;
/

--PACHET
--zona de specificatii a pachetului
create or replace package pachet_contributii is
function returnare_cas(v_id angajat.id_angajat%type) return number;
function returnare_cass(v_id angajat.id_angajat%type) return number;
function returnare_impozit(v_id angajat.id_angajat%type) return number;
procedure marire_cas(v_id contributii.id_angajat%type , procent number);
procedure marire_cass(v_id contributii.id_angajat%type , procent number);
procedure marire_impozit(v_id contributii.id_angajat%type , procent number);
end;
/
--corpul pachetului
create or replace package body pachet_contributii is
-------------
function returnare_cas(v_id in angajat.id_angajat%type) return number is
v_cas number;
begin
select cas into v_cas from contributii where id_angajat=v_id;
return v_cas;
end;
-------------
function returnare_cass(v_id in angajat.id_angajat%type) return number is
v_cass number;
begin
select cass into v_cass from contributii where id_angajat=v_id;
return v_cass;
end;
-------------
function returnare_impozit(v_id in angajat.id_angajat%type) return number is
v_impozit number;
begin
select impozit into v_impozit from contributii where id_angajat=v_id;
return v_impozit;
end;
-------------
procedure marire_cas(v_id contributii.id_angajat%type , procent number)is
v_cas number;
begin
select cas into v_cas from contributii where id_angajat=v_id;
dbms_output.put_line('cas inainte de modificare : '||v_cas);
update contributii set cas=cas*(1+procent) where id_angajat=v_id;
select cas into v_cas from contributii where id_angajat=v_id;
dbms_output.put_line('cas dupa modificare : '||v_cas);
end;
-------------
procedure marire_cass(v_id contributii.id_angajat%type , procent number)is
v_cass number;
begin
select cass into v_cass from contributii where id_angajat=v_id;
dbms_output.put_line('cass inainte de modificare : '||v_cass);
update contributii set cass=cass*(1+procent) where id_angajat=v_id;
select cass into v_cass from contributii where id_angajat=v_id;
dbms_output.put_line('cass dupa modificare : '||v_cass);
end;
-------------
procedure marire_impozit(v_id contributii.id_angajat%type , procent number)is
v_impozit number;
begin
select impozit into v_impozit from contributii where id_angajat=v_id;
dbms_output.put_line('impozit inainte de modificare : '||v_impozit);
update contributii set impozit=impozit*(1+procent) where id_angajat=v_id;
select impozit into v_impozit from contributii where id_angajat=v_id;
dbms_output.put_line('impozit dupa modificare : '||v_impozit);
end;
end;
/

--stergere pachet
drop package pachet_contributii;
drop package body pachet_contributii;

set serveroutput on;
begin
dbms_output.put_line(pachet_contributii.returnare_cas(1));
dbms_output.put_line(pachet_contributii.returnare_cass(1));
dbms_output.put_line(pachet_contributii.returnare_impozit(1));
pachet_contributii.marire_cas(1,0.15);
pachet_contributii.marire_cass(1,0.15);
pachet_contributii.marire_impozit(1,0.15);
end;
/

--DECLANSATORI
----Se creeaza un trigger pentru a nu se permite depasirea limitei maxime a salariului unui angajat(max 10000)
create or replace trigger max_sal before insert or update on angajat
for each row
declare
v_max number;
begin
v_max:=10000;
if :new.salariul>v_max then
  	RAISE_APPLICATION_ERROR (-20202, 'Nu se poate depasi salariul maxim pentru functia data');end if;
end;
/
begin
update angajat set salariul=10500 where id_angajat=1;
end;
/
drop trigger max_sal;
rollback;

--DECLANSATORI
--Sa se creeze un trigger ce impiedica stergerea sediului cu id_sediu=1
create or replace trigger sediu_trigger before delete on sediu 
for each row
declare
v_id number;
begin
if :old.id_sediu=1 then RAISE_APPLICATION_ERROR (-20203, 'Nu se poate sterge sediul cu id_sediu=1');end if;
end;
/
begin
delete from sediu where id_sediu=1;
end;
/
drop trigger sediu_trigger;

