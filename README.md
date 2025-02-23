# Oracle_PL-SQL-Oracle_Database-project

# Technologies Used:
- **RDBMS:** Oracle Database
- **Language:** Oracle PL/SQL

# Economic Theme
The chosen economic theme for the database is **EMPLOYEE MANAGEMENT IN A COMPANY**. The application handles:
- Managing employees' state contributions
- Managing the accountants assigned to each employee and their registered offices
- Keeping records of the employment book
- Tracking bank accounts

## Tables Involved in the Project
- **EMPLOYEE Table** - Contains details about employees.
- **ACCOUNTANTS Table** - Manages the accountants assigned to each employee and the hierarchical structure through the `id_sef_contabil` column.
- **HEADQUARTERS Table** - Contains the registered offices of all accountants in the ACCOUNTANTS table, as well as other unoccupied offices.
- **CONTRIBUTIONS Table** - Structures all employee contributions to the state, including social security contributions (CAS), health insurance contributions (CASS), and income tax (tax). It also includes information about contribution payments.
- **ACCOUNTS Table** - Efficiently manages employees' bank accounts, keeping track of balances, credit scores, and profit margins.
- **EMPLOYMENT_DETAILS Table** - Contains information also found in the individual employment contract, such as place of birth, order number, start date of employment, position, and work experience.
