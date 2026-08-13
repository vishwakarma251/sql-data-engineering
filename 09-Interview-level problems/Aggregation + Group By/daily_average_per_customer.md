# SQL Question Breakdown: Daily Average Transaction Amount per Customer

## Original Question

> Calculate daily average transaction amount per customer.

---

## 1. The Main Skill: Translate English into SQL

Before writing SQL, do not immediately think about syntax.

First break the question into:

1. **WHAT are we calculating?**
2. **PER WHAT?**
3. **PER WHAT ELSE?**

This helps identify the aggregate function and the grouping columns.

---

## 2. Break Down the Question

### WHAT are we calculating?

The word **average** tells us to use:

```sql
AVG(transaction_amount)
```

### PER WHAT?

The phrase **per customer** tells us to calculate separately for each customer.

Column:

```sql
customer_id
```

### PER WHAT ELSE?

The word **daily** tells us that the calculation must also be separated by day.

Column:

```sql
transaction_date
```

So the translation is:

```text
WHAT        → AVG(transaction_amount)
PER WHAT    → customer
PER WHAT    → day
```

Therefore:

```text
customer_id + transaction_date
```

---

## 3. The "Per" Trick

Whenever you see **"per"** in a SQL question, ask:

> **Per what?**

Examples:

| English Question | WHAT | PER WHAT |
|---|---|---|
| Total sales per customer | SUM(sales) | customer |
| Average salary per department | AVG(salary) | department |
| Maximum transaction amount per customer | MAX(transaction_amount) | customer |
| Total order amount per customer per day | SUM(order_amount) | customer + day |
| Average transaction amount per customer per day | AVG(transaction_amount) | customer + day |

**Memory rule:** "Per" usually tells you the dimension/group you need to calculate separately.

---

## 4. Aggregate Function Vocabulary

| Question Word | SQL Function |
|---|---|
| Total | `SUM()` |
| Average | `AVG()` |
| Maximum / Highest | `MAX()` |
| Minimum / Lowest | `MIN()` |
| Count / Number of | `COUNT()` |

---

## 5. Example: Total Order Amount per Customer

Question:

> Calculate the total order amount per customer.

Breakdown:

```text
WHAT       → SUM(order_amount)
PER WHAT   → customer
```

SQL thinking:

```text
SUM(order_amount)
        +
customer_id
```

Therefore:

```sql
GROUP BY customer_id
```

---

## 6. Example: Maximum Transaction Amount per Customer

Question:

> Find the maximum transaction amount for each customer.

Breakdown:

```text
WHAT       → MAX(transaction_amount)
PER WHAT   → customer
```

Therefore:

```sql
GROUP BY customer_id
```

---

## 7. Example: Total Transaction Amount per Customer per Day

Question:

> Find the total transaction amount for each customer on each day.

Breakdown:

```text
WHAT        → SUM(transaction_amount)
PER WHAT    → customer
PER WHAT    → day
```

Therefore:

```sql
GROUP BY customer_id, transaction_date
```

---

## 8. GROUP BY vs Window Function

After identifying WHAT and PER WHAT, ask:

> **Do I want one row per group, or do I want to keep all the original rows?**

### GROUP BY

Use `GROUP BY` when you want **one result row per group**.

For this question:

```text
one row per customer + date
```

### Window Function

Use a Window Function when you want to **keep the original rows** and also show a calculated value alongside them.

This distinction is important when learning SQL Window Functions.

---

## 9. Mental Model

Imagine a teacher sorting transaction slips into boxes.

```text
C101
 ├── Aug 1 → 500, 300
 └── Aug 2 → 800

C102
 ├── Aug 1 → 200, 600
 └── Aug 2 → 400
```

Each box represents:

```text
customer + day
```

Then calculate the average inside each box.

For C101 on Aug 1:

```text
(500 + 300) / 2 = 400
```

So the result is:

```text
C101 | Aug 1 | 400
```

Conceptually, this is what:

```sql
GROUP BY customer_id, transaction_date
```

does.

---

## 10. Step-by-Step SQL Construction

### Step 1: Choose what to display

```sql
SELECT customer_id, transaction_date
```

### Step 2: Add the calculation

```sql
SELECT
    customer_id,
    transaction_date,
    AVG(transaction_amount) AS avg_daily_trans_amt
```

### Step 3: Choose the source table

```sql
FROM transactions
```

### Step 4: Group by the dimensions identified from the question

```sql
GROUP BY customer_id, transaction_date
```

---

## 11. Quick Question-Reading Checklist

Before writing SQL:

```text
1. What am I calculating?
   ↓
   SUM / AVG / MAX / MIN / COUNT

2. Per what?
   ↓
   First grouping dimension

3. Per what else?
   ↓
   Second grouping dimension, date, product, etc.

4. Do I want one row per group?
   ↓
   GROUP BY

5. Do I need to keep every original row?
   ↓
   Consider a Window Function
```

---

## 12. Key Takeaway

The most important habit is:

> **English → WHAT + PER WHAT + PER WHAT ELSE → SQL**

For this question:

```text
Calculate daily average transaction amount per customer.
```

Think:

```text
WHAT        → AVG(transaction_amount)
PER WHAT    → customer
PER WHAT    → day
```

Then:

```sql
GROUP BY customer_id, transaction_date
```

Do this translation **before** writing SQL syntax.

---

# Query Solution

```sql
SELECT
    customer_id,
    transaction_date,
    AVG(transaction_amount) AS avg_daily_trans_amt
FROM transactions
GROUP BY customer_id, transaction_date;
```
