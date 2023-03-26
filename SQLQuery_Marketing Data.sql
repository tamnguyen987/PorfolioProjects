
--SELECT *
--FROM TamPortfolioProject.dbo.Marketing_data


-- I/ CLEANING DATA:

---Remove Duplicate( if any)
---uses a common table expression (CTE) to delete duplicate rows:
--------- CTE uses the ROW_NUMBER() function to find the duplicate rows specified by values in columns: 
----------- PARTITION BY to group of certain Columns that we want to check duplication
----------DELETE statement deletes all the duplicate rows but keeps only one occurrence of each duplicate group.

WITH MyCTE as(
	Select *,
	ROW_NUMBER() OVER(
			PARTITION BY
				Year_Birth,
				Education,
				Marital_Status,
				Kidhome,
				Teenhome,
				Dt_Customer,
				Recency,
				MntWines,
				MntFruits,
				MntMeatProducts,
				MntFishProducts,
				MntSweetProducts,
				MntGoldProds,
				NumDealsPurchases,
				NumWebPurchases,
				NumCatalogPurchases,
				NumStorePurchases,
				NumWebVisitsMonth
			ORDER BY
				ID
				) AS row_num
	From TamPortfolioProject.dbo.Marketing_data	 
)

---NOTE: 
-- ---- > Step 1: when deleting DUPLICATE ROWS, REMEMBER TO COMMENT OUT these BELOW LINES, otherwise INVALID Ojectives Name
--Select *
--From MyCTE 
--Where row_num > 1
--Order by ID


-- ---- > Step 2: AFTER deleting DUPLICATE ROWS, REMEMBER TO COMMENT OUT these BELOW LINES, otherwise INVALID Ojectives Name
--Delete
--From MyCTE
--Where row_num > 1

-- ---- > Step 3: RECHECK the data. If OK, continue to COMMENT OUT these BELOW LINES to do Part II, otherwise INVALID Ojectives Name
--SELECT *
--FROM MyCTE
--Where row_num > 1

-- II/ FORMATING DATA:
Select 
	AcceptedCmp3,
	AcceptedCmp4,
	AcceptedCmp5,
	AcceptedCmp1,
	AcceptedCmp2,
	Response as AcceptedCampLast
From MyCTE






-- III/ Finding relationship b/w Education and Income
------- 'Income' column contain both numbers and NULL values, Don't count NULL data info

SELECT DISTINCT Education, [ Income ], Marital_Status
FROM TamPortfolioProject.dbo.Marketing_data
Where [ Income ] is not NULL