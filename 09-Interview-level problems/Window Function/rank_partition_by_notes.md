# SQL Notes: RANK() with PARTITION BY

## Question

Given the following data:

| col1 |
|---:|
| 100 |
| 100 |
| 200 |
| 200 |
| 300 |
| 400 |
| 400 |
| 400 |

Using `PARTITION BY col1`, how do you get the rank as shown below?

| col1 | rank |
|---:|---:|
| 100 | 1 |
| 100 | 1 |
| 200 | 1 |
| 200 | 1 |
| 300 | 1 |
| 400 | 1 |
| 400 | 1 |
| 400 | 1 |

---

## Key Concept

`PARTITION BY` divides the result set into separate groups.

Here, each distinct `col1` value becomes its own partition:

- `100` → one partition
- `200` → one partition
- `300` → one partition
- `400` → one partition

`RANK()` starts ranking separately inside each partition.

Because there is no `ORDER BY`, there is no ordering criterion inside each partition. The rows in each partition are tied, so each row receives rank `1`.

### Visual

```text
Original data
100
100
200
200
300
400
400
400

        ↓ PARTITION BY col1

100, 100  → rank starts at 1
200, 200  → rank starts at 1
300       → rank starts at 1
400, 400, 400 → rank starts at 1
```

## Important Note

Normally, `RANK()` is used with an `ORDER BY` inside the window:

```sql
RANK() OVER (
    PARTITION BY col1
    ORDER BY some_column
)
```

The `ORDER BY` determines how rows are ranked within each partition.

For this particular question, the expected result requires every row to have rank `1`, so `PARTITION BY col1` alone produces that result in SQL dialects that allow `RANK()` without an `ORDER BY`.

---

## Solution Query

```sql
SELECT col1,
       RANK() OVER(PARTITION BY col1) AS rnk_col
FROM rank_data;
```

## Expected Output

| col1 | rnk_col |
|---:|---:|
| 100 | 1 |
| 100 | 1 |
| 200 | 1 |
| 200 | 1 |
| 300 | 1 |
| 400 | 1 |
| 400 | 1 |
| 400 | 1 |
