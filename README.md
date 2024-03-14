# Oracle_PL-SQL-Oracle_Database-project

  # Tehnologii utilizate:
- **RDBMS:** Oracle Database
- **Limbaj :** Oracle PL/SQL
  
# Tema Economică
Tema economică aleasă pentru baza de date este **GESTIUNEA ANGAJATILOR UNEI FIRME**. Aplicația se ocupă de:
- Gestiunea contribuțiilor la stat ale angajaților
- Gestiunea contabililor fiecărui angajat și sediul juridic al contabililor respective
- Evidența cărții de muncă
- Evidența conturilor la bănci

## Tabele Implicate în Proiect
- **Tabela ANGAJAT** - Detalii despre angajați.
- **Tabela CONTABILI** - Gestionarea contabililor fiecărui angajat și structura ierarhică prin intermediul coloanei `id_sef_contabil`.
- **Tabela SEDIU** - Conține sediile tuturor contabililor din tabela CONTABILI, dar și alte sedii neocupate.
- **Tabela CONTRIBUTII** - Structurarea tuturor dărilor angajaților la stat, incluzând contribuții sociale (CAS), asigurări de sănătate (CASS), și impozitul pe venit (impozit). Include și date despre plățile contribuțiilor.
- **Tabela CONTURI** - Gestiunea eficientă a conturilor la bănci ale angajaților, ținând evidența soldului, scorului de credit și marjei de profit.
- **Tabela CARTE** - Conține informații care se regăsesc și în contractul individual de muncă, precum locul de naștere, numărul de ordine, data începerii activității, funcția și vechimea în câmpul muncii.
