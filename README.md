## Overview

This project is an end-to-end **NBFC Loan Portfolio Analysis** built using **MySQL** and **Power BI**.

The analysis focuses on understanding the quality and performance of an NBFC loan book by evaluating:
- total loan applications
- total funded amount
- total amount received
- average interest rate
- average debt-to-income ratio (DTI)
- good-loan vs bad-loan distribution
- portfolio trends and segment-level concentration

A major focus of this project is to assess how much of the portfolio is performing well, how much is exposed to risky loans, and which borrower or loan segments need closer monitoring.

## Project Objective

The objective of this project is to analyze an NBFC loan portfolio to evaluate **portfolio quality**, **repayment performance**, and **borrower risk indicators**.

This project was designed to:
- measure the size and performance of the loan book
- classify loans into good and bad segments using loan status
- evaluate portfolio health using funded amount, received amount, interest rate, and DTI
- identify concentration across states, terms, employment groups, purposes, and home ownership categories
- validate all business KPIs in SQL before presenting them through an interactive Power BI dashboard

## Business Problem

Financial institutions and NBFCs need to continuously monitor the quality of their loan portfolio to understand:
- how much of the portfolio is healthy
- how much is exposed to bad loans
- whether repayment trends are improving or weakening
- whether borrower characteristics indicate higher credit risk
- which segments contribute the most to portfolio concentration

This project addresses those questions using structured SQL analysis and dashboard reporting.

## Dataset and Schema

The analysis is based on a MySQL table named `bank_loans`.

### Main Fields Included

- Loan identifiers: `id`, `member_id`
- Borrower profile: `address_state`, `emp_length`, `emp_title`, `annual_income`, `home_ownership`, `verification_status`
- Loan attributes: `purpose`, `grade`, `sub_grade`, `term`, `loan_amount`, `installment`, `int_rate`
- Repayment and portfolio quality fields: `loan_status`, `dti`, `total_payment`
- Date fields: `issue_date`, `last_payment_date`, `next_payment_date`, `last_credit_pull_date`

### Why This Dataset Is Useful

This dataset supports:
- portfolio performance monitoring
- borrower risk analysis
- loan status analysis
- portfolio quality measurement
- state-wise and segment-wise loan concentration analysis
- trend-based lending analysis

## Tools and Technologies

### Tools Used

- **MySQL**
- **MySQL Workbench**
- **Power BI Desktop**
- **CSV Dataset**
- **MS Word** for SQL documentation and query outputs

### Skills Demonstrated

- SQL aggregations
- CTEs
- window functions
- grouped summaries
- date-based KPI analysis
- lending and portfolio analytics
- good-loan vs bad-loan classification
- Power BI dashboard development
- SQL-based KPI validation

## Project Workflow

This project follows a validation-first workflow:

1. Inspect and understand the loan dataset.
2. Create the `bank_loans` table in MySQL.
3. Solve lending and portfolio analysis questions using SQL.
4. Validate KPIs such as funded amount, collections, portfolio quality, and borrower risk indicators.
5. Build a Power BI dashboard using the same business logic.
6. Cross-check dashboard values with SQL outputs.

## KPI Snapshot

| KPI | Value |
|---|---:|
| Total Loan Applications | 38,576 |
| Total Funded Amount | $435.76M |
| Total Amount Received | $473.07M |
| Average Interest Rate | 12.05% |
| Average DTI | 13.33% |
| Good Loan Percentage | 86.2% |
| Bad Loan Percentage | 13.8% |

### Loan Quality Logic

- **Good Loans** = `Fully Paid` and `Current`
- **Bad Loans** = `Charged Off`

## Business Problems and SQL Solutions

### 1. Total Loan Applications

**Problem:** Find the total number of loan applications in the portfolio.

```sql
select count(id) as total_loan_application
from bank_loans;
```

**Output:** `38,576`

### 2. Month-to-Date (MTD) Loan Applications

**Problem:** Find the number of loan applications in December 2021.

```sql
select month(issue_date) as month, count(id) as total_loan_application
from bank_loans
where month(issue_date)=12 and year(issue_date)=2021
group by 1;
```

**Output:** `4,314`

### 3. Previous-Month-to-Date (PMTD) Loan Applications

**Problem:** Find the number of loan applications in November 2021.

```sql
select month(issue_date) as month, count(id) as total_loan_application
from bank_loans
where month(issue_date)=11 and year(issue_date)=2021
group by 1;
```

**Output:** `4,035`

### 4. MoM Change % for Loan Applications

**Problem:** Calculate month-over-month change in loan applications.

```sql
with cte1 as (
    select month(issue_date) as months, count(id) as total_loan_application
    from bank_loans
    where year(issue_date)=2021
    group by 1
),
cte2 as (
    select months,
           total_loan_application,
           lead(total_loan_application,1) over(order by months desc) as total_loan_application_lead
    from cte1
)
select round(((total_loan_application-total_loan_application_lead)/total_loan_application_lead)*100,2) as mom_change_percent
from cte2
where months=12;
```

**Output:** `6.91%`

### 5. Total Funded Amount

**Problem:** Find the total funded amount across the portfolio.

```sql
select sum(loan_amount) as funded_amount
from bank_loans;
```

**Output:** `$435.76M`

### 6. MTD Total Funded Amount

**Problem:** Find the funded amount for December 2021.

```sql
select month(issue_date) as months, sum(loan_amount) as funded_amount
from bank_loans
where month(issue_date)=12 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `$53,981,425`

### 7. PMTD Total Funded Amount

**Problem:** Find the funded amount for November 2021.

```sql
select month(issue_date) as months, sum(loan_amount) as funded_amount
from bank_loans
where month(issue_date)=11 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `$47,754,825`

### 8. MoM Change % for Funded Amount

**Problem:** Calculate month-over-month change in funded amount.

```sql
with cte1 as (
    select month(issue_date) as months, sum(loan_amount) as funded_amount
    from bank_loans
    where year(issue_date)=2021
    group by month(issue_date)
),
cte2 as (
    select months,
           funded_amount,
           lead(funded_amount,1) over(order by months desc) as funded_amount_lead
    from cte1
)
select round(((funded_amount-funded_amount_lead)/funded_amount_lead)*100,2) as mom_change_percent
from cte2
where months=12;
```

**Output:** `13.04%`

### 9. Total Amount Received

**Problem:** Find the total amount received from borrowers.

```sql
select sum(total_payment) as received_amount
from bank_loans;
```

**Output:** `$473.07M`

### 10. MTD Total Amount Received

**Problem:** Find the amount received in December 2021.

```sql
select month(issue_date) as months, sum(total_payment) as received_amount
from bank_loans
where month(issue_date)=12 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `$58,074,380`

### 11. PMTD Total Amount Received

**Problem:** Find the amount received in November 2021.

```sql
select month(issue_date) as months, sum(total_payment) as received_amount
from bank_loans
where month(issue_date)=11 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `$50,132,030`

### 12. MoM Change % for Total Amount Received

**Problem:** Calculate month-over-month change in amount received.

```sql
select ((58074380 - 50132030) / 50132030) * 100 as mom_change_percent;
```

**Output:** `15.84%`

### 13. Average Interest Rate

**Problem:** Find the average interest rate across the portfolio.

```sql
select avg(int_rate) as avg_interest_rate
from bank_loans;
```

**Output:** `12.05%`

### 14. MTD Average Interest Rate

**Problem:** Find the average interest rate for December 2021.

```sql
select month(issue_date) as months, avg(int_rate) as avg_interest_rate
from bank_loans
where month(issue_date)=12 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `12.35%`

### 15. PMTD Average Interest Rate

**Problem:** Find the average interest rate for November 2021.

```sql
select month(issue_date) as months, avg(int_rate) as avg_interest_rate
from bank_loans
where month(issue_date)=11 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `11.94%`

### 16. MoM Change % for Average Interest Rate

**Problem:** Calculate month-over-month change in average interest rate.

```sql
select ((0.1235 - 0.1194) / 0.1194) * 100 as mom_change_percent;
```

**Output:** `3.43%`

### 17. Average Debt-to-Income Ratio (DTI)

**Problem:** Find the average DTI across the portfolio.

```sql
select avg(dti) as avg_dti
from bank_loans;
```

**Output:** `13.33%`

### 18. MTD Average DTI

**Problem:** Find the average DTI for December 2021.

```sql
select month(issue_date) as months, avg(dti) as avg_dti
from bank_loans
where month(issue_date)=12 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `13.66%`

### 19. PMTD Average DTI

**Problem:** Find the average DTI for November 2021.

```sql
select month(issue_date) as months, avg(dti) as avg_dti
from bank_loans
where month(issue_date)=11 and year(issue_date)=2021
group by month(issue_date);
```

**Output:** `13.30%`

### 20. MoM Change % for Average DTI

**Problem:** Calculate month-over-month change in average DTI.

```sql
select ((0.1366 - 0.1330) / 0.1330) * 100 as mom_change_percent;
```

**Output:** `2.70%`

### 21. Good Loan KPIs

**Problem:** Measure the healthy portion of the portfolio.

```sql
select loan_status,
       count(id) as good_loan_applications,
       (count(id)/(select count(id) from bank_loans))*100 as good_loan_applications_perc,
       sum(loan_amount) as good_loan_funded_amount,
       sum(total_payment) as good_loan_received_amount
from bank_loans
where loan_status in ("Fully Paid","Current")
group by loan_status;
```

**Output Focus:**
- Good loan applications
- Good loan percentage
- Good loan funded amount
- Good loan total received amount

### 22. Bad Loan KPIs

**Problem:** Measure the risky portion of the portfolio.

```sql
select loan_status,
       count(id) as bad_loan_applications,
       (count(id)/(select count(id) from bank_loans))*100 as bad_loan_applications_perc,
       sum(loan_amount) as bad_loan_funded_amount,
       sum(total_payment) as bad_loan_received_amount
from bank_loans
where loan_status="Charged Off"
group by loan_status;
```

**Output Focus:**
- Bad loan applications
- Bad loan percentage
- Bad loan funded amount
- Bad loan total received amount

### 23. Loan Status Grid View

**Problem:** Compare portfolio metrics across each loan status.

```sql
select loan_status,
       count(id) as total_loan_applications,
       (count(id)/(select count(id) from bank_loans))*100 as total_loan_applications_perc,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount,
       round(avg(int_rate),3) as average_interest_rate,
       round(avg(dti),3) as average_dti
from bank_loans
group by loan_status;
```

**Output Focus:**
- total loan applications
- total application percentage
- funded amount
- received amount
- average interest rate
- average DTI by loan status

### 24. Loan Status MTD Grid View

**Problem:** Compare loan-status metrics for December 2021.

```sql
select loan_status,
       count(id) as total_loan_applications,
       (count(id)/(select count(id) from bank_loans))*100 as total_loan_applications_perc,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount,
       round(avg(int_rate),3) as average_interest_rate,
       round(avg(dti),3) as average_dti
from bank_loans
where month(issue_date)=12 and year(issue_date)=2021
group by loan_status;
```

**Output Focus:** Monthly loan-status quality view for the latest month.

### 25. Monthly Trends by Issue Date

**Problem:** Track applications, funded amount, and amount received month by month.

```sql
select month(issue_date) as month_no,
       monthname(issue_date) as months,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount
from bank_loans
where year(issue_date)=2021
group by month(issue_date), monthname(issue_date)
order by month_no;
```

**Output Summary:**
- January applications: `2,332`
- December applications: `4,314`
- December funded amount: `$53,981,425`
- December total received amount: `$58,074,380`

### 26. Regional Analysis by State

**Problem:** Measure state-wise portfolio concentration.

```sql
select address_state,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount
from bank_loans
where year(issue_date)=2021
group by address_state;
```

**Top States by Applications:**
- CA: `6,894`
- NY: `3,701`
- FL: `2,773`
- TX: `2,664`

### 27. Loan Term Analysis

**Problem:** Analyze the portfolio by term.

```sql
select term,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount
from bank_loans
where year(issue_date)=2021
group by 1;
```

**Output Insight:** The portfolio is dominated by `36-month` loans.

### 28. Employee Length Analysis

**Problem:** Analyze portfolio distribution by borrower employment length.

```sql
select emp_length,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount
from bank_loans
where year(issue_date)=2021
group by 1;
```

**Output Insight:** Borrowers with `10+ years` of employment form the largest group.

### 29. Loan Purpose Breakdown

**Problem:** Analyze why borrowers are taking loans.

```sql
select purpose,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount
from bank_loans
where year(issue_date)=2021
group by 1;
```

**Output Insight:** `Debt consolidation` is the largest loan purpose category.

### 30. Home Ownership Analysis

**Problem:** Analyze the portfolio by home ownership segment.

```sql
select home_ownership,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_received_amount
from bank_loans
where year(issue_date)=2021
group by 1;
```

**Output Insight:** `RENT` and `MORTGAGE` are the dominant borrower home ownership categories.

## Dashboard Pages

### 1. Summary Dashboard

![Summary Dashboard](Bank-Loan-Report-Summary.jpg)

This page presents the most important loan portfolio KPIs in one place.

It includes:
- total loan applications
- total funded amount
- total amount received
- average interest rate
- average DTI
- good loan percentage
- bad loan percentage
- loan status matrix

### 2. Overview Dashboard

![Overview Dashboard](Bank-Loan-Report-Overview.jpg)

This page focuses on trend and segment analysis across the loan portfolio.

It includes:
- monthly trends by issue date
- regional analysis by state
- loan term analysis
- employee length analysis
- loan purpose breakdown
- home ownership analysis

### 3. Details Dashboard

![Details Dashboard](Bank-Loan-Report-Details.jpg)

This page provides detailed loan-level visibility for deeper inspection.

It includes fields such as:
- loan ID
- purpose
- grade
- sub-grade
- home ownership
- issue date
- funded amount
- interest rate
- installment
- total amount received

## Business Value

This project demonstrates how SQL and Power BI can be used together to support practical NBFC lending analysis.

The project helps evaluate:
- portfolio quality
- repayment performance
- borrower risk indicators
- loan status distribution
- portfolio concentration by segment
- validated KPI reporting for business review

It reflects a strong mix of technical execution and business understanding in a lending analytics context.

## Repository Structure

```text
nbfc-loan-portfolio-analysis/
│
├── nbfc_loan_portfolio_data.csv.csv
├── SQL-Script-for-nbfc_loan_portfolio_analysis.sql
├── SQL-based-solution-for-Business-Problems.docx
├── Bank-Loan-Report-Summary.jpg
├── Bank-Loan-Report-Overview.jpg
├── Bank-Loan-Report-Details.jpg
└── README.md
```

## Author

**Surya Prakash Singh**  
Business Analyst | Aspiring Data Professional | SQL | Power BI | Data Analytics

This project demonstrates practical SQL analysis, portfolio KPI validation, loan book performance tracking, and business-focused dashboard reporting.
