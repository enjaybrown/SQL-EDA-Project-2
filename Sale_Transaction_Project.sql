select * from Sales_Trans.dbo.Region_Manager
select * from Sales_Trans.dbo.Returned_Items
select * from Sales_Trans.dbo.Sales_Transactions

select *
from Sales_Trans.dbo.Returned_Items as ri
full outer join Sales_Trans.dbo.Sales_Transactions as st
on
	ri.[Order ID] = st.Order_id
	and ri.sales_id = st.sales_id
full outer join Sales_Trans.dbo.Region_Manager as rm
on st.Region = rm.Region





---The Organization is planning to gift the best performing manager who made the best sales and want to know the region which the manager belongs to?
select st.Region, rm.Manager, round(sum(st.Sales),1) as highestsales

from Sales_Trans.dbo.Returned_Items as ri
full outer join Sales_Trans.dbo.Sales_Transactions as st
on
	ri.[Order ID] = st.Order_id
	and ri.sales_id = st.sales_id
full outer join Sales_Trans.dbo.Region_Manager as rm
on st.Region = rm.Region
group by st.Region, rm.Manager
order by 3 desc

----how many times was delivery truck used as the ship mode?
select st.[Ship Mode], COUNT([Ship Mode]) as Usage

from Sales_Trans.dbo.Sales_Transactions as st
where st.[Ship Mode] = 'Delivery Truck'
group by st.[Ship Mode]
order by 2

----how many orders were returned, and which product category got rejected the most?

select st.[Product Category], count(ri.[Order status]) as Returned

from Sales_Trans.dbo.Returned_Items as ri
full outer join Sales_Trans.dbo.Sales_Transactions as st
on
	ri.[Order ID] = st.Order_id
	and ri.sales_id = st.sales_id
where ri.[Order status] = 'Returned'
group by st.[Product Category]
order by 2 desc


----Created a Temp table to house the date split in column REALORDERDATE
drop table if exists #datemanup
create  table #datemanup(
 Month int,
 Day nvarchar(255),
 Year int,
 Customer_Segment nvarchar(255),
 Shipping_cost float,
 sales float
)

insert into #datemanup
select DATEPART(month, REALORDERDATE), DATENAME(WEEKDAY, REALORDERDATE),
DATEPART(year, REALORDERDATE),[Customer Segment],[Shipping Cost],Sales
from Sales_Trans.dbo.Sales_Transactions

----which Year did the company incurred the least shipping cost?
select Year, round(SUM(Shipping_cost), 1) As Least_shipping_cost
from #datemanup
group by year
order by 2 asc

---display the day of the week in which customer segment has the most sales?
select Customer_Segment,day, round(SUM(sales), 1) As HighestSales
from #datemanup
group by Customer_Segment,day
order by 3 desc


--The company want to determine its profitability by knowing the actual orders that were delivered.
select count([Order status]) as Total_delivered, sum(Profit) As Total_profit

from Sales_Trans.dbo.Returned_Items as ri
full outer join Sales_Trans.dbo.Sales_Transactions as st
on
	ri.[Order ID] = st.Order_id
	and ri.sales_id = st.sales_id
where ri.[Order status] = 'Delivered'

----The Organization is eager to know the customer names and persons born in 2011?
select st.[First Name],st.[Last Name], st.Birth_Date
from Sales_Trans.dbo.Sales_Transactions as st
where st.Birth_Date like '%2011'
order by 3 desc

----what are the aggregate orders made by all the customers?
select sum(st.[Order Quantity]) as Total_orders, AVG(st.[Order Quantity]) as Average_orders, 
max(st.[Order Quantity]) as max_orders, min(st.[Order Quantity]) as min_orders
from Sales_Trans.dbo.Sales_Transactions as st


----The company intends to discontinue any product that brings in the least profit, you are required to help the organization to determine the product?
select st.[Product Sub-Category], round(SUM(Profit),1) as least_profit
from Sales_Trans.dbo.Sales_Transactions as st
group by st.[Product Sub-Category]
order by 2 asc

----what are the top 2 best selling items that the company should keep selling?
select top 2 st.[Product Sub-Category], round(SUM(Sales),1) as Best_sales
from Sales_Trans.dbo.Sales_Transactions as st
group by st.[Product Sub-Category]
order by 2 desc
