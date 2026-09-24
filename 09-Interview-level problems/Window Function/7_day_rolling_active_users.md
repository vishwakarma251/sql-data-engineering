# Rolling 7-day active users

**Type: Medium**

**Solving %: 33% solve it**

**Company: Amazon**

**Q:Return the number of distinct users active in each trailing 7-day window, one row per day.**

**Input schema:**

```python
  activity
  user_id    bigint
  active_at  timestamp
```

**Constraints:**

- The window is **7 days inclusive**: the row for day `D` counts activity from `D - 6` through `D`
- One row per day from the first day of activity to the last, with no gaps — a day with no activity in its window returns `0`, not a missing row
- A user active several times inside one window counts once
- day is formatted `YYYY-MM-DD`
- Order by day ascending

**Example 1: the window reaches back six days**

_Input · activity_

```python
user_id	active_at
1	2024-01-01 10:00:00
2	2024-01-03 10:00:00
```

_Output:_

```python
day	active_users
2024-01-01	1
2024-01-02	1
2024-01-03	2
```

**Example 2: a user active twice in a window counts once**

_Input · activity_

```python
user_id	active_at
5	2024-02-01 08:00:00
5	2024-02-01 20:00:00
5	2024-02-02 09:00:00
```

_Output:_

```python
day	active_users
2024-02-01	1
2024-02-02	1
```

## Problem

Given an `activity` table containing:

- `active_at` — timestamp when activity happened
- `user_id` — user who performed the activity

Calculate the **number of unique active users for every calendar day**, considering the current day plus the previous 6 days.

In other words, calculate **7-day rolling active users**.

---

## Query

```sql
WITH RECURSIVE min_max_dates AS (
    SELECT
        MIN(DATE(active_at)) AS start_date,
        MAX(DATE(active_at)) AS end_date
    FROM activity
),

calendar AS (
    SELECT start_date AS day
    FROM min_max_dates

    UNION ALL

    SELECT day + INTERVAL '1 day'
    FROM calendar, min_max_dates
    WHERE day < end_date
),

daily_activity AS (
    SELECT
        DATE(active_at) AS activity_date,
        user_id
    FROM activity
    GROUP BY 1, 2
)

SELECT
    TO_CHAR(c.day, 'YYYY-MM-DD') AS day,
    COUNT(DISTINCT d.user_id) AS active_users
FROM calendar c
LEFT JOIN daily_activity d
    ON d.activity_date BETWEEN c.day - INTERVAL '6 days' AND c.day
GROUP BY c.day
ORDER BY c.day ASC;
```

---

# CTE-by-CTE Summary

## 1. `min_max_dates`

### Purpose

Find the **first and last date** on which any activity occurred.

```sql
SELECT
    MIN(DATE(active_at)) AS start_date,
    MAX(DATE(active_at)) AS end_date
FROM activity
```

### Example

If activity exists from September 1 to September 10:

| start_date | end_date |
| ---------- | -------- |
| Sep 1      | Sep 10   |

### Why is it needed?

It tells the recursive calendar exactly where to start and where to stop.

### Easy analogy

Think of it as saying:

> "My calendar starts on Sep 1 and ends on Sep 10."

---

## 2. `calendar`

### Purpose

Generate **every single date** between `start_date` and `end_date`, including dates where nobody was active.

```sql
SELECT start_date AS day
FROM min_max_dates

UNION ALL

SELECT day + INTERVAL '1 day'
FROM calendar, min_max_dates
WHERE day < end_date
```

### Example

If activity happened only on:

```text
Sep 1
Sep 2
Sep 5
Sep 10
```

the `calendar` CTE produces:

```text
Sep 1
Sep 2
Sep 3
Sep 4
Sep 5
Sep 6
Sep 7
Sep 8
Sep 9
Sep 10
```

### Why `RECURSIVE`?

Because the CTE refers to itself:

```sql
FROM calendar
```

Each iteration adds one day:

```text
Sep 1
  ↓ + 1 day
Sep 2
  ↓ + 1 day
Sep 3
  ↓ + 1 day
...
```

It stops when `day < end_date` becomes false.

### Easy analogy

Like walking up a staircase one step at a time until you reach the last step.

---

## 3. `daily_activity`

### Purpose

Convert timestamps into dates and keep only **one record per user per day**.

```sql
SELECT
    DATE(active_at) AS activity_date,
    user_id
FROM activity
GROUP BY 1, 2
```

### Why?

Suppose the raw activity table contains:

| active_at   | user_id |
| ----------- | ------- |
| Sep 1 09:00 | A       |
| Sep 1 10:00 | A       |
| Sep 1 15:00 | A       |
| Sep 1 16:00 | B       |

After `daily_activity`:

| activity_date | user_id |
| ------------- | ------- |
| Sep 1         | A       |
| Sep 1         | B       |

User A may have performed multiple activities, but for daily active-user analysis we only need to know:

> "Was A active on this day?"

### Easy analogy

A student may enter the school three times in one day, but the attendance register should still mark that student as **present once**.

### Important note

The final query also uses:

```sql
COUNT(DISTINCT d.user_id)
```

so the final result remains unique-user based. `daily_activity` additionally reduces duplicate user-day rows before the rolling join and makes the intent clearer.

---

# Final Query

The final section combines the generated calendar with daily user activity.

## 4. `LEFT JOIN`

```sql
FROM calendar c
LEFT JOIN daily_activity d
```

### Why `LEFT JOIN`?

We want **every calendar date** in the result.

Even if nobody was active on a particular date, that date should still appear.

If we used `INNER JOIN`, dates with no matching activity could disappear.

### Easy analogy

The calendar is the master attendance sheet:

> "Show me every school day, even if nobody attended that day."

---

# 5. The 7-Day Rolling Window

```sql
ON d.activity_date
   BETWEEN c.day - INTERVAL '6 days'
   AND c.day
```

This creates a **7-day window**:

```text
Current day - 6 days  →  Current day
```

### Example

For September 20:

```text
Sep 14
Sep 15
Sep 16
Sep 17
Sep 18
Sep 19
Sep 20
```

That's exactly **7 days**.

### Why subtract 6 and not 7?

Because `BETWEEN` is inclusive.

```text
Sep 14 ≤ activity_date ≤ Sep 20
```

includes both Sep 14 and Sep 20.

So:

```text
14, 15, 16, 17, 18, 19, 20
```

= 7 dates.

---

# 6. `COUNT(DISTINCT d.user_id)`

```sql
COUNT(DISTINCT d.user_id) AS active_users
```

This counts the **unique users** found inside the 7-day window.

### Example

Suppose the 7-day window contains:

| date   | user |
| ------ | ---- |
| Sep 14 | A    |
| Sep 15 | A    |
| Sep 16 | B    |
| Sep 17 | C    |
| Sep 18 | B    |
| Sep 19 | A    |
| Sep 20 | D    |

`COUNT(d.user_id)`:

```text
7
```

because there are 7 rows.

`COUNT(DISTINCT d.user_id)`:

```text
4
```

because the unique users are:

```text
A, B, C, D
```

### Easy rule to remember

```text
COUNT
→ How many entries/rows?

COUNT DISTINCT
→ How many different users?
```

---

# 7. `GROUP BY c.day`

```sql
GROUP BY c.day
```

We need one result for every calendar day.

Conceptually:

```text
Sep 1 → rolling active users
Sep 2 → rolling active users
Sep 3 → rolling active users
Sep 4 → rolling active users
...
```

---

# 8. `TO_CHAR`

```sql
TO_CHAR(c.day, 'YYYY-MM-DD') AS day
```

This is only for **display formatting**.

It converts the date into:

```text
2026-09-20
```

It does not perform the rolling calculation.

---

# Complete Flow

The entire query can be remembered as:

```text
ACTIVITY TABLE
      │
      ▼
1. min_max_dates
   Find first + last date
      │
      ▼
2. calendar
   Generate every date
      │
      │
      │
ACTIVITY ──────────────┐
                       ▼
3. daily_activity
   One user per day
                       │
                       ▼
4. LEFT JOIN
   Keep every calendar date
                       │
                       ▼
5. 7-day window
   current day + previous 6 days
                       │
                       ▼
6. COUNT(DISTINCT user_id)
   Count unique active users
                       │
                       ▼
                 FINAL RESULT
```

---

# Memory Trick

Remember the query as:

## **Boundary → Calendar → Clean → Window → Count**

### 1. Boundary

`min_max_dates`

> Where does the timeline start and end?

### 2. Calendar

`calendar`

> Generate every date without gaps.

### 3. Clean

`daily_activity`

> Keep user + day and remove repeated same-day activity.

### 4. Window

`BETWEEN c.day - INTERVAL '6 days' AND c.day`

> Look at today + previous 6 days.

### 5. Count

`COUNT(DISTINCT d.user_id)`

> Count unique users.

---

# Key Concepts Tested by This Query

This query combines several important SQL concepts:

- CTEs
- Recursive CTE
- Date manipulation
- `MIN()` / `MAX()`
- `UNION ALL`
- Deduplication with `GROUP BY`
- `LEFT JOIN`
- Range-based joins using `BETWEEN`
- Rolling time windows
- `COUNT(DISTINCT ...)`
- `GROUP BY`
- Date formatting with `TO_CHAR`

---

# One-Line Summary

> **Generate a gap-free calendar, clean activity into one user per day, join each calendar day to its current + previous 6 days, and count the distinct users active in that 7-day window.**
