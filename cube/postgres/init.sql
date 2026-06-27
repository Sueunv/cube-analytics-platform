CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    city VARCHAR(50),
    quantity INT,
    price NUMERIC(10,2),
    sale_date DATE
);

INSERT INTO sales (product_name, category, city, quantity, price, sale_date)
VALUES
('Laptop','Electronics','Pune',2,65000,'2026-06-01'),
('Mouse','Electronics','Mumbai',5,800,'2026-06-02'),
('Keyboard','Electronics','Delhi',3,1500,'2026-06-03'),
('Monitor','Electronics','Bangalore',1,12000,'2026-06-04'),
('Headphones','Electronics','Hyderabad',4,2500,'2026-06-05');