/*
Cleaning Data in SQL 
Skills used : Alter Table, Update, Window Function,  Joins, Substring, 
		      Parsename, Case, CTE, Row_Num, Delete, etc.
*/


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format (YYYY-MM-DD)

SELECT   CONVERT(Date,SaleDate, 103) AS  DateOfSale
FROM PortfolioProject.dbo.NashvilleHousing

--OR 

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate =  (
SELECT   CONVERT(Date,SaleDate,103) as  dateofsale
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM PortfolioProject..NashvilleHousing

--OR

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing



 --------------------------------------------------------------------------------------------------------------------------
 
-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)

FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER ID  ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHousing

-- for address
ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- for city
ALTER TABLE NashvilleHousing
	ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- To check new fields PropertySplitAddress & PropertySplitCity at the end of table
SELECT *
FROM PortfolioProject..NashvilleHousing

--OR

--Using the PARSENAME function to split delimited data (here, 'OwnerAddress')


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM  PortfolioProject.dbo.NashvilleHousing


--Splitting to get only Address
ALTER TABLE PortfolioProject..NashvilleHousing
	ADD  OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- Splitting to get only  City
ALTER TABLE PortfolioProject..NashvilleHousing
	ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


--Splitting to get State
ALTER TABLE PortfolioProject..NashvilleHousing
	ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Splitted Owner's address fields at the end of table
Select *
FROM PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
		CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'NO'  
			ELSE SoldAsVacant
			END
FROM PortfolioProject.dbo.NashvilleHousing  

UPDATE PortfolioProject..NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
						    WHEN SoldAsVacant = 'N' THEN 'No'  
			                ELSE SoldAsVacant
		                 	END


-- Removing Duplicates
WITH RowNumCTE AS 
(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		ORDER BY  UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)
--Used DELETE to delete the duplicates
SELECT *

FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM  PortfolioProject..NashvilleHousing

-- Delete Unuseful Columns



SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





---to be continued