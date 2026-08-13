# SQL: How to Break Down "Highest/Lowest for Each Group" Questions

## Original Question

> Write a query to get the customer with the highest total order value for each year and month. Order and Customer tables are separate, with Order_ID and Customer_ID as primary keys. The Customer table's Oid is a foreign key referencing the Orders table's Order_ID. In case of a tie, return the customer with the lower Customer_ID.

---

# 1. The Most Important Skill: Break the English Into SQL Tasks

For questions like this, **don't start writing SQL immediately**.

First translate the English question into smaller SQL tasks.

A useful method is to ask these 5 questions:

1. What am I calculating?
2. For whom am I calculating it?
3. Over what group/time period?
4. What does "highest" or "lowest" mean?
5. What happens in case of a tie?

Once these are answered, the SQL structure becomes much easier to see.

---

# 2. Question 1 — What Am I Calculating?

Look for words that tell you which aggregate function is needed.

| English word | SQL |
|---|---|
| total | `SUM()` |
| average | `AVG()` |
| maximum | `MAX()` |
| minimum | `MIN()` |
| count | `COUNT()` |

In our question:

> **highest total order value**

The word **total** tells us:

```sql
SUM(order_value)
```

So our first task is to calculate the total order value.

---

# 3. Question 2 — For Whom Am I Calculating It?

Now ask:

> Whose total are we calculating?

The question says:

> **customer**

Therefore we need:

```text
Customer_ID
```

So far:

```text
Customer
   ↓
SUM(Order_Value)
```

---

# 4. Question 3 — Over What Group or Time Period?

The question says:

> **for each year and month**

This is a very important clue.

We don't want one total for the entire customer history.

We want:

```text
Customer + Year + Month
```

So mentally write:

```text
Customer
   +
Year
   +
Month
   ↓
SUM(Order_Value)
```

This is the first major SQL step.

The result should look conceptually like:

| Customer_ID | Year | Month | Total_Order_Value |
|---:|---:|---:|---:|
| 1 | 2023 | 01 | 1200 |
| 2 | 2023 | 01 | 900 |
| 3 | 2023 | 01 | 300 |
| 2 | 2023 | 02 | 1000 |
| 3 | 2023 | 02 | 1000 |
| 4 | 2023 | 02 | 500 |

This is why the first CTE uses:

```sql
GROUP BY Customer_ID, year, month
```

---

# 5. Question 4 — What Does "Highest" Mean?

Now we already have:

```text
Customer | Year | Month | Total
```

But the question doesn't ask for **all** customers.

It asks for:

> the customer with the **highest** total

So now we need to **compare customers within the same year and month**.

Think of January 2023:

```text
2023 January

Customer 1 → 1200  ← Highest
Customer 2 →  900
Customer 3 →  300
```

Then February 2023:

```text
2023 February

Customer 2 → 1000
Customer 3 → 1000  ← Tie
Customer 4 →  500
```

This is where a **window ranking function** becomes useful.

We need to rank customers separately inside every:

```text
Year + Month
```

Therefore:

```sql
PARTITION BY year, month
```

And because we want the highest total first:

```sql
ORDER BY total_order_value DESC
```

The basic ranking idea becomes:

```sql
RANK() OVER (
    PARTITION BY year, month
    ORDER BY total_order_value DESC
)
```

---

# 6. Question 5 — What Happens in Case of a Tie?

Never ignore phrases such as:

> **In case of a tie...**

They are important SQL clues.

Our question says:

> return the customer with the **lower Customer_ID**

Suppose we have:

| Customer_ID | Total |
|---:|---:|
| 2 | 1000 |
| 3 | 1000 |

The totals are tied.

We want Customer 2 because:

```text
2 < 3
```

Therefore the ranking order needs another condition:

```sql
Customer_ID ASC
```

So the complete ranking expression becomes:

```sql
RANK() OVER (
    PARTITION BY year, month
    ORDER BY total_order_value DESC,
             customer_id ASC
)
```

Because `Customer_ID` is included in the ordering, the tied totals are broken by the lower Customer_ID.

The result becomes:

```text
Customer 2 → Rank 1
Customer 3 → Rank 2
```

Therefore:

```sql
WHERE rnk = 1
```

returns only Customer 2.

---

# 7. The Complete Mental Process

When you see this type of question, think:

```text
English Question
       ↓
What am I calculating?
       ↓
SUM / AVG / COUNT / etc.
       ↓
For whom?
       ↓
Customer / Employee / Product / etc.
       ↓
For what group or time period?
       ↓
Year + Month / Department / Category / etc.
       ↓
Calculate the metric
       ↓
Compare values within the group
       ↓
RANK / ROW_NUMBER / DENSE_RANK
       ↓
Handle tie-breaker
       ↓
Keep the winner
```

A shorter version to remember:

```text
GROUP → CALCULATE → RANK → PICK 1
```

---

# 8. English → SQL Mapping for This Question

| English | SQL Thinking |
|---|---|
| total order value | `SUM(order_value)` |
| customer | `Customer_ID` |
| each year | `year` |
| each month | `month` |
| highest | `ORDER BY total_order_value DESC` |
| for each year/month | `PARTITION BY year, month` |
| lower Customer_ID in a tie | `Customer_ID ASC` |
| return the winner | `WHERE rnk = 1` |

---

# 9. Reusable Pattern

A very common interview-question pattern is:

> Find the **highest/lowest X** for each **group**, with a **tie-breaker**.

Think:

```text
1. Calculate X
2. Group by the required dimensions
3. Rank within each group
4. Apply the tie-breaker
5. Keep rank = 1
```

For example:

### Highest salary in each department

```text
Department
    ↓
Compare employee salaries
    ↓
Highest salary
```

### Customer with highest sales each month

```text
Customer + Month
       ↓
SUM(Sales)
       ↓
Rank customers within Month
       ↓
Rank 1
```

### Product with lowest price in each category

```text
Product + Category
       ↓
Price
       ↓
Rank products within Category
       ↓
Rank 1
```

The story changes, but the underlying SQL thinking is often the same.

---

# 10. Important Distinction: GROUP BY vs PARTITION BY

This type of question often requires **both**.

## GROUP BY

Use `GROUP BY` when you need to **calculate one aggregate result for each combination of columns**.

Here:

```sql
GROUP BY Customer_ID, year, month
```

means:

> Give me one total for each Customer + Year + Month.

Result:

```text
Customer | Year | Month | Total
```

---

## PARTITION BY

Use `PARTITION BY` inside a window function when you need to **compare or rank rows within a group without collapsing those rows**.

Here:

```sql
PARTITION BY year, month
```

means:

> For each Year + Month, compare the customers against each other.

This distinction is extremely important:

```text
GROUP BY
→ creates the totals

PARTITION BY
→ creates the comparison groups for ranking
```

---

# 11. Why We Used Two CTEs

The problem naturally has two stages.

## Stage 1 — Calculate totals

```text
Customer + Year + Month
          ↓
      SUM(Order_Value)
```

## Stage 2 — Find the winner

```text
Year + Month
     ↓
Rank customers by Total
     ↓
Keep Rank 1
```

A CTE makes these stages easier to understand:

```sql
WITH total_order_value_customer AS (
    -- Stage 1
),
high_rank AS (
    -- Stage 2
)
SELECT ...
```

This is often easier to write and debug than trying to solve everything in one huge query.

---

# 12. A General Template to Memorize

For questions such as:

> "Find the highest/lowest [metric] for each [group], with [tie-breaker]."

Think:

```sql
WITH totals AS (
    SELECT
        entity,
        group_column,
        SUM(metric) AS total
    FROM table
    GROUP BY entity, group_column
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY group_column
            ORDER BY total DESC, entity ASC
        ) AS rnk
    FROM totals
)
SELECT *
FROM ranked
WHERE rnk = 1;
```

This is a **mental template**, not a rule that every question must use exactly.

The aggregate function, ranking function, ordering direction, and tie-breaker can change depending on the question.

---

# 13. Quick Checklist Before Writing SQL

When you get a similar SQL question, write these down first:

```text
1. Metric:
   What am I calculating?

2. Entity:
   For whom?

3. Group:
   For each what?

4. Ranking:
   Highest or lowest?

5. Tie:
   What should happen if values are equal?

6. Output:
   Which columns should I return?
```

For our question:

```text
1. Metric:
   SUM(order_value)

2. Entity:
   Customer

3. Group:
   Year + Month

4. Ranking:
   Highest total → DESC

5. Tie:
   Lower Customer_ID → ASC

6. Output:
   Customer_ID, Customer_Name,
   Total_Order_Value, Year, Month
```

---

# 14. Final Query Solution

```sql
WITH total_order_value_customer AS (
    SELECT
        o.Customer_ID,
        c.Customer_Name,
        SUM(o.order_value) AS total_order_value,
        strftime('%Y', o.order_date) AS year,
        strftime('%m', o.order_date) AS month
    FROM Orders o
    JOIN Customer c
        ON c.Customer_ID = o.Customer_ID
    GROUP BY o.Customer_ID, year, month
),
high_rank AS (
    SELECT
        customer_id,
        total_order_value,
        year,
        month,
        customer_name,
        RANK() OVER (
            PARTITION BY year, month
            ORDER BY total_order_value DESC,
                     customer_id ASC
        ) AS rnk
    FROM total_order_value_customer
)
SELECT
    customer_id,
    customer_name,
    total_order_value,
    year,
    month,
    rnk
FROM high_rank
WHERE rnk = 1;
```

---

# 15. Final Memory Trick

When you see:

> **"Find the highest/lowest [something] for each [group]"**

immediately think:

```text
           WHAT?
             ↓
        SUM / AVG / COUNT
             ↓
          FOR WHOM?
             ↓
           ENTITY
             ↓
          FOR EACH?
             ↓
           GROUP
             ↓
        CALCULATE TOTAL
             ↓
      COMPARE WITHIN GROUP
             ↓
           RANK
             ↓
       HANDLE THE TIE
             ↓
          PICK #1
```

## One-line memory rule

> **First calculate the number, then create the competition, then pick the winner.**
