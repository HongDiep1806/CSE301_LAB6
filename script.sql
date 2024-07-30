use salemanagement;
-- 1. How to check constraint in a table?
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'salesman';
-- 2. Create a separate table name as “ProductCost” from “Product” table, which contains the information
-- about product name and its buying price. 
create table if not exists ProductCost as
select Product_Name,Sell_Price from product;
-- 3. Compute the profit percentage for all products. Note: profit = (sell-cost)/cost*100
select Product_Name, ((Sell_Price - Cost_Price)/Cost_Price)*100 as profit from product;
-- 4. If a salesman exceeded his sales target by more than equal to 75%, his remarks should be ‘Good’.
alter table salesman
add column remarks varchar(20);
update salesman
set remarks = 'Good'
where Target_Achieved >= Sales_Target*0.75;
-- 5. If a salesman does not reach more than 75% of his sales objective, he is labeled as 'Average'.
update salesman
set remarks = 'Average'
where Target_Achieved < Sales_Target*0.75;
-- 6. If a salesman does not meet more than half of his sales objective, he is considered 'Poor'.
update salesman
set remarks = 'Poor'
where Target_Achieved <= Sales_Target*0.55;
-- 7. Find the total quantity for each product. (Query)
select *, (Quantity_On_Hand+Quantity_Sell) as total_quantity from product;
-- 8. Add a new column and find the total quantity for each product.
alter table product
add column total_quantity int;
update product
set total_quantity = Quantity_On_Hand+Quantity_Sell;
-- 9. If the Quantity on hand for each product is more than 10, change the discount rate to 10 otherwise set to 5.
alter table product
add column discount_rate int;
UPDATE product
SET discount_rate = CASE
    WHEN Quantity_On_Hand > 10 THEN 10
    ELSE 5
END;
-- 10. If the Quantity on hand for each product is more than equal to 20, change the discount rate to 10, if it is 
-- between 10 and 20 then change to 5, if it is more than 5 then change to 3 otherwise set to 0.
UPDATE product
SET discount_rate = CASE
    WHEN Quantity_On_Hand >= 20 then 10
    when Quantity_On_Hand>=10 and Quantity_On_Hand < 20 then 5
    when Quantity_On_Hand> 5 and Quantity_On_Hand<10 then 3
    ELSE 5
END;
-- 11. The first number of pin code in the client table should be start with 7.
ALTER TABLE clients
ADD CONSTRAINT pincode_starts_with_7
CHECK (pincode LIKE '7%');
-- 12. Creates a view name as clients_view that shows all customers information from Thu Dau Mot.
create view clients_view as
select * from clients
where City = 'Thu Dau Mot';
-- 13. Drop the “client_view”.
drop view clients_view;
-- 14. Creates a view name as clients_order that shows all clients and their order details from Thu Dau Mot.
create view clients_order as 
select c.Client_Number,c.Client_Name,
c.Address,c.City,c.Pincode,
c.Province,c.Amount_Paid,
c.Amount_Due,sod.Order_Number,
sod.Order_Quality,sod.Product_Number
from clients c join salesorder so
on c.Client_Number = so.Client_Number 
join salesorderdetails sod on so.Order_Number = sod.Order_Number
 where c.City = 'Thu Dau Mot';
-- 15. Creates a view that selects every product in the "Products" table with a sell price higher than the average 
-- sell price.
create view newProducts as
select * from product
where Sell_Price > (select avg(Sell_Price) from product);
-- 16. Creates a view name as salesman_view that show all salesman information and products (product names, 
-- product price, quantity order) were sold by them.
create view salesman_view as
select ss.Salesman_Number,ss.Salesman_Name,
ss.Address,ss.City,ss.Pincode,
ss.Province,ss.Salary,ss.Sales_Target,
ss.Target_Achieved,ss.Phone, p.Product_Number,
p.Product_Name,p.Cost_Price,
p.Quantity_On_Hand,p.Quantity_Sell,
p.Sell_Price,p.Cost_Price as productCostPrice,p.total_quantity
from salesman ss join salesorder so
on ss.Salesman_Number = so.Salesman_Number
join salesorderdetails sod
on so.Order_Number = sod.Order_Number
join product p
on p.Product_Number = sod.Product_Number;
-- 17. Creates a view name as sale_view that show all salesman information and product (product names, 
-- product price, quantity order) were sold by them with order_status = 'Successful'.
create view sale_view as
select ss.Salesman_Number,ss.Salesman_Name,
ss.Address,ss.City,ss.Pincode,
ss.Province,ss.Salary,ss.Sales_Target,
ss.Target_Achieved,ss.Phone, p.Product_Number,
p.Product_Name,p.Cost_Price,
p.Quantity_On_Hand,p.Quantity_Sell,
p.Sell_Price,p.Cost_Price as productCostPrice,p.total_quantity
from salesman ss join salesorder so
on ss.Salesman_Number = so.Salesman_Number
join salesorderdetails sod
on so.Order_Number = sod.Order_Number
join product p
on p.Product_Number = sod.Product_Number
where so.Order_Status = 'Successful';
-- 18. Creates a view name as sale_amount_view that show all salesman information and sum order quantity 
-- of product greater than and equal 20 pieces were sold by them with order_status = 'Successful'.
create view sale_amount as
select ss.Salesman_Number,ss.Salesman_Name,
ss.Address,ss.City,ss.Pincode,ss.Province,
ss.Salary,ss.Sales_Target,ss.Target_Achieved,
ss.Phone, sum(sod.Order_Quality) as total_QuantitySold
from salesman ss join salesorder so
on ss.Salesman_Number = so.Salesman_Number
join salesorderdetails sod
on sod.Order_Number = so.Order_Number
where so.Order_Status = 'Successful'
group by ss.Salesman_Number,ss.Salesman_Name
having sum(sod.Order_Quality) >= 20;
-- 19. Amount paid and amounted due should not be negative when you are inserting the data.
ALTER TABLE clients
ADD CONSTRAINT check_amounts_non_negative
CHECK (amount_paid >= 0 AND amount_due >= 0);
-- 20. Remove the constraint from pincode;
alter table clients
drop constraint pincode_starts_with_7;
-- 21. The sell price and cost price should be unique.
ALTER TABLE product
ADD CONSTRAINT unique_price_combination UNIQUE (sell_price, cost_price);
-- 23. Remove unique constraint from product name.
SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'product'
AND COLUMN_NAME = 'product_name'
AND CONSTRAINT_SCHEMA = 'salemanagement';
ALTER TABLE product
DROP constraint product_name;
-- 24. Update the delivery status to “Delivered” for the product number P1007.
update salesorder so inner join salesorderdetails sod
on so.Order_Number = sod.Order_Number
set so.Delivery_Status = 'Delivered'
where sod.Product_Number = 'P1007';
-- 25. Change address and city to ‘Phu Hoa’ and ‘Thu Dau Mot’ where client number is C104.
UPDATE clients
SET Address = 'Phu Hoa', City = 'Thu Dau Mot'
WHERE Client_Number = 'C104';
-- 26. Add a new column to “Product” table named as “Exp_Date”, data type is Date.
alter table product
add column Exp_Date Date;
-- 27. Add a new column to “Clients” table named as “Phone”, data type is varchar and size is 15.
alter table clients
add column Phone varchar(15);
-- 28. Update remarks as “Good” for all salesman.
update salesman
set remarks = 'Good';
-- 29. Change remarks to "bad" whose salesman number is "S004".
update salesman
set remarks = 'bad'
where Salesman_Number = 'S004';
-- 30. Modify the data type of “Phone” in “Clients” table with varchar from size 15 to size is 10.
alter table clients
modify phone varchar(10);
-- 31. Delete the “Phone” column from “Clients” table.
alter table clients
drop column phone;
-- 33. Change the sell price of Mouse to 120.
update product
set Sell_Price = 120
where Product_Name = 'Mouse';
-- 34. Change the city of client number C104 to “Ben Cat”.
update clients
set City = 'Ben Cat'
where Client_Number = 'C104';
-- 35. If On_Hand_Quantity greater than 5, then 10% discount. If On_Hand_Quantity greater than 10, then 15% 
-- discount. Othrwise, no discount.
update product
set discount_rate = case
when Quantity_On_Hand > 5 and Quantity_On_Hand <= 10 then 10
when Quantity_On_Hand > 10 then 15
else 0
end;
