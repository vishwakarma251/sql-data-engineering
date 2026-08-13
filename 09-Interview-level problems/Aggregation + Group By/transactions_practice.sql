CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id VARCHAR(10),
    transaction_date DATE,
    transaction_amount DECIMAL(10,2)
);

INSERT INTO transactions
(transaction_id, customer_id, transaction_date, transaction_amount)
VALUES
(1, 'C101', '2026-08-01', 500.00),
(2, 'C101', '2026-08-01', 300.00),
(3, 'C101', '2026-08-02', 800.00),
(4, 'C102', '2026-08-01', 200.00),
(5, 'C102', '2026-08-01', 600.00),
(6, 'C102', '2026-08-02', 400.00),
(7, 'C103', '2026-08-01', 1000.00),
(8, 'C103', '2026-08-02', 500.00),
(9, 'C103', '2026-08-02', 700.00),
(10, 'C104', '2026-08-01', 250.00),
(11, 'C104', '2026-08-03', 750.00),
(12, 'C104', '2026-08-03', 250.00);
