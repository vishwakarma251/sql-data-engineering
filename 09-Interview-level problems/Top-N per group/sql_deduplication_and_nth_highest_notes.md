# SQL Practice Notes: Deduplication & 2nd Highest Salary

## Question 1

> Write a SQL query to find duplicate records in a table.

### Practice Data

```sql
CREATE TABLE employees (
    employee_id INTEGER,
    employee_name TEXT,
    department TEXT,
    salary INTEGER
);

INSERT INTO employees (employee_id, employee_name, department, salary) VALUES
(101, 'Rahul', 'Sales', 50000),
(102, 'Priya', 'HR', 55000),
(103, 'Amit', 'IT', 70000),
(104, 'Neha', 'Sales', 50000),
(101, 'Rahul', 'Sales', 50000),
(105, 'Vikas', 'Finance', 60000),
(103, 'Amit', 'IT', 70000),
(106, 'Sneha', 'HR', 55000),
(104, 'Neha', 'Sales', 50000),
(107, 'Karan', 'IT', 75000);
```

### Query Solution

```sql
WITH duplicate_records AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY employee_id
               ORDER BY salary
           ) AS rw_no
    FROM employees
)
SELECT employee_id,
       employee_name,
       department,
       salary
FROM duplicate_records
WHERE rw_no > 1;
```

### Category

**Deduplication / Data Quality**

The query identifies duplicate occurrences based on `employee_id`. `ROW_NUMBER()` numbers each record within the same employee, and `rw_no > 1` returns the additional occurrences.

---

## Question 2

> Write a SQL query to get the 2nd highest salary.

### Practice Data

```sql
CREATE TABLE employees (
    employee_id INTEGER,
    employee_name TEXT,
    department TEXT,
    salary INTEGER
);

INSERT INTO employees (employee_id, employee_name, department, salary) VALUES
(101, 'Rahul', 'Sales', 50000),
(102, 'Priya', 'HR', 75000),
(103, 'Amit', 'IT', 90000),
(104, 'Neha', 'Sales', 65000),
(105, 'Vikas', 'Finance', 85000),
(106, 'Sneha', 'HR', 90000),
(107, 'Karan', 'IT', 70000),
(108, 'Riya', 'Finance', 80000),
(109, 'Arjun', 'Sales', 75000),
(110, 'Meera', 'IT', 60000);
```

### Query Solution

```sql
WITH high_salary AS (
    SELECT *,
           DENSE_RANK() OVER (
               ORDER BY salary DESC
           ) AS rnk
    FROM employees
)
SELECT employee_id,
       employee_name,
       department,
       salary
FROM high_salary
WHERE rnk = 2;
```

### Category

**Top-N / Ranking / Nth Highest Value**

`DENSE_RANK()` ranks distinct salary values from highest to lowest. `rnk = 2` returns the employees having the 2nd highest distinct salary.

---

## Key Takeaways

### Deduplication

Think:

```text
What defines a duplicate?
        ↓
Choose the business key
        ↓
PARTITION BY
        ↓
ROW_NUMBER()
        ↓
Keep or remove duplicate occurrences
```

### Nth Highest Value

Think:

```text
Need the Nth highest value?
        ↓
Does the question care about distinct values?
        ↓
DENSE_RANK()
        ↓
ORDER BY value DESC
        ↓
Filter for rank = N
```

### Query Categories

| Question | Category | Main Technique |
|---|---|---|
| Find duplicate records | Deduplication / Data Quality | `ROW_NUMBER()` |
| Find 2nd highest salary | Top-N / Nth Highest / Ranking | `DENSE_RANK()` |
