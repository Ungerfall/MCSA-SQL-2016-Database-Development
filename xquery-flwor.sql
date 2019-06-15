DECLARE @x AS XML = N'
<CustomersOrders>
<Customer custid="1">
<!-- Comment 111 -->
<companyname>Customer NRZBB</companyname>
<Order orderid="10692">
<orderdate>2015-10-03T00:00:00</orderdate>
</Order>
<Order orderid="10702">
<orderdate>2015-10-13T00:00:00</orderdate>
</Order>
<Order orderid="10952">
<orderdate>2016-03-16T00:00:00</orderdate>
</Order>
</Customer>
<Customer custid="2">
<!-- Comment 222 -->
<companyname>Customer MLTDN</companyname>
<Order orderid="10308">
<orderdate>2014-09-18T00:00:00</orderdate>
</Order>
<Order orderid="10952">
<orderdate>2016-03-04T00:00:00</orderdate>
</Order>
</CustomersOrders>';

SELECT @x.query('for $i in CustomersOrders/Customer/Order
let $j := $i/orderdate
where $i/@orderid < 10900
order by ($j)[1]
return
<Order-orderid-element>
<orderid>{data($i/@orderid)}</orderid>
{$j}
</Order-orderid-element>')
AS [Filtered, sorted and reformatted orders with let clause]
