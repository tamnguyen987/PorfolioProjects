
/*
Cleaning Data in SQL Queries: pull up the data
*/

SELECT *
FROM PorfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- I/ Standardize Date Format: 

SELECT saleDateConverted, CONVERT(date,SaleDate)
FROM PorfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate) 

--- Note: if the 1st step does not work, try to use this: CREATE A NEW COLUMN in the table
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- II/ Populate Property Address data

Select *
From PorfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


-- When the original "a.PropertyAddress" is NULL, use information(data) from "b.PropertyAddress" column
--Use JOIN command for 2 columns: PropertyAddress and 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- "ISNULL" command: Check for empty values.
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------

-- III./ Breaking out Address into Individual Columns (Address, City, State)
--B/c the origin Column combined these information
-- Using SUBSTRING, CHARINDEX methods

Select PropertyAddress
From PorfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--Use "-1" to get rid of "," in the result
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM PorfolioProject.dbo.NashvilleHousing

-- CREATE and UPDATE 2 NEW Columns in the table: "PropertySplitAddress" and "PropertySplitCity"
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 



ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

--Now, check out the result from the Table: showing at the end of table
Select *
From PorfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- IV./ Breaking out OwnerAddress into Individual Columns (Address, City, State)
--B/c the origin Column combined these information
-- Using PARSENAME method: do not know why Parsename function returned reversed order if doing 1,2,3 => changed to 3,2,1

Select OwnerAddress
From PorfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PorfolioProject.dbo.NashvilleHousing


-- CREATE and UPDATE 3 NEW Columns in the table: "OwnerSplitAddress" ; "OwnerSplitCity"and "OwnerSplitState"
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Now, check out the result from the Table: showing at the end of table
Select *
From PorfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- V/ Change from "Y" and "N" to Yes and No in "Sold as Vacant" field: 
-- Using DISTICT to check if the original field mixed of 'Y', 'N', 'Yes', 'No'
-- Using COUNT to calculate how many of each

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
From PorfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Using CASE expression: (CASE...WHEN = (condition) THEN (value))

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant  
  END
From PorfolioProject.dbo.NashvilleHousing

-- Now, UPDATE the table with new result

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant  
  END

  -----------------------------------------------------------------------------------------------------------------------------------------------------------

-- VI/ REMOVE DUPLICATES
-- Deleting Duplicate Rows in SQL Using CTE, Row_Number, Partition, 

-- Notes: Using ROW_NUMBER to assign consecutive numbering of rows, it will return different number if Duplicate rows exits (Ex: 1,2 instead of 1)
	--		Using Partition By to group of certain Column that we want to check duplication

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
									   					 				  				  				 
From PorfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

--After Creating temp table (RowNumCTE), now we need to find Duplicate rows 
--						which have values greater than 1 (b/c ROW_NUM returns value of 1 if no duplication)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- NOW, we need to DELETE duplicated rows:
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- VII/ Delete Unused Columns (that we don not need): Ex:TaxDistrict

Select *
From PorfolioProject.dbo.NashvilleHousing

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN TaxDistrict