
USE `order-directory`;

/* Display the total number of customers based on gender who have placed orders of worth at least Rs.3000. */

SELECT A.CUS_GENDER AS CUSTOMERS_GENDER, COUNT(B.CUS_ID) AS CUSTOMERS_COUNT FROM CUSTOMER AS A
INNER JOIN
	(
    SELECT CUS_ID FROM `ORDER`
	GROUP BY CUS_ID HAVING SUM(ORD_AMOUNT)>=3000
    ) AS B ON A.CUS_ID = B.CUS_ID
GROUP BY A.CUS_GENDER;


/* Display all the orders along with product name ordered by a customer having Customer_Id=2 */

SELECT A.ORD_ID, A.ORD_DATE, A.CUS_ID, C.PRO_NAME AS PRODUCT_NAME, A.PRICING_ID, A.ORD_AMOUNT FROM `ORDER` AS A
INNER JOIN SUPPLIER_PRICING AS B ON A.PRICING_ID = B.PRICING_ID
INNER JOIN PRODUCT AS C ON B.PRO_ID = C.PRO_ID
WHERE A.CUS_ID=2;


/* Display the Supplier details who can supply more than one product. */

SELECT A.* FROM SUPPLIER AS A 
INNER JOIN 
	(
    SELECT SUPP_ID FROM SUPPLIER_PRICING 
    GROUP BY SUPP_ID HAVING COUNT(DISTINCT(PRO_ID))>1
    ) AS B ON A.SUPP_ID=B.SUPP_ID ;


/* Find the least expensive product from each category and print the table with category id, name, product name and price of the product */

SELECT A.CAT_ID AS CATEGORY_ID, A.CAT_NAME CATEGORY_NAME, A.PRO_NAME AS PRODUCT_NAME, A.SUPP_PRICE FROM
	(
    SELECT A.CAT_ID, A.CAT_NAME, B.PRO_NAME, C.SUPP_PRICE, ROW_NUMBER() OVER (PARTITION BY A.CAT_ID ORDER BY C.SUPP_PRICE) SRNO FROM CATEGORY AS A
    INNER JOIN PRODUCT AS B ON A.CAT_ID=B.CAT_ID
	INNER JOIN SUPPLIER_PRICING C ON B.PRO_ID=C.PRO_ID 
    ) AS A
WHERE A.SRNO = 1 ;


/* Display the Id and Name of the Product ordered after “2021-10-05”. */

SELECT A.PRO_ID, A.PRO_NAME FROM PRODUCT AS A
INNER JOIN SUPPLIER_PRICING B ON A.PRO_ID = B.PRO_ID
INNER JOIN `ORDER` AS C ON B.PRICING_ID = C.PRICING_ID
WHERE C.ORD_DATE > '2021-10-05'
GROUP BY A.PRO_ID, A.PRO_NAME ;


/* Display customer name and gender whose names start or end with character 'A'. */

SELECT CUS_NAME AS CUSTOMER_NAME, CUS_GENDER AS CUSTOMER_GENDER FROM CUSTOMER
WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';


/* Create a stored procedure to display supplier id, name, rating and Type_of_Service. For Type_of_Service, 
If rating =5, print “Excellent Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” 
else print “Poor Service”. */

DELIMITER //
CREATE PROCEDURE PRC_SUPPLIER_RATINGS()
BEGIN
	SELECT A.SUPP_ID, A.SUPP_NAME, ROUND(AVG(RAT_RATSTARS),0) RATING,  
		CASE
			WHEN AVG(RAT_RATSTARS)=5 THEN "EXCELLENT SERVICE"
			WHEN AVG(RAT_RATSTARS)>=4 AND AVG(RAT_RATSTARS)<5 THEN "GOOD SERVICE"
			WHEN AVG(RAT_RATSTARS)>=2 AND AVG(RAT_RATSTARS)<4 THEN "AVERAGE SERVICE"
		ELSE "POOR SERVICE" END 
	AS TYPE_OF_SERVICE
	FROM SUPPLIER AS A
	INNER JOIN SUPPLIER_PRICING AS B ON A.SUPP_ID = B.SUPP_ID
	INNER JOIN `ORDER` AS C ON B.PRICING_ID = C.PRICING_ID
	INNER JOIN RATING AS D ON C.ORD_ID = D.ORD_ID
	GROUP BY A.SUPP_ID, A.SUPP_NAME ;
END //
DELIMITER ;
