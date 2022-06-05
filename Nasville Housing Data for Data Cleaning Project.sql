/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------
--How to Populate the Property Address

select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress ,b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.Parcelid
	AND a.[UniqueID] <> b. [UniqueID]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.Parcelid
	AND a.[UniqueID] <> b. [UniqueID]
Where a.PropertyAddress is null

------------------------------------------------------------------------------

---Breaking out Addresses into Individual Columns(Address,City,State)

select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

---Using substring

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

----To remove the comma-----
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX( ',' , PropertyAddress)+1 , LEN (PropertyAddress))as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Varchar(225);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Varchar(225);

Update NashvilleHousing
SET PropertySplitCity=  SUBSTRING(PropertyAddress, CHARINDEX( ',' , PropertyAddress)+1 , LEN (PropertyAddress))

select *
From PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-----Using PARSENAME-----
select 
PARSENAME(REPLACE(Owneraddress, ',' ,'.'),3)
,PARSENAME(REPLACE(Owneraddress, ',' ,'.'),2)
,PARSENAME(REPLACE(Owneraddress, ',' ,'.'),1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Varchar(225);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',' ,'.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Varchar(225);

Update NashvilleHousing
SET OwnerSplitCity=  PARSENAME(REPLACE(Owneraddress, ',' ,'.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Varchar(225);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',' ,'.'),1)

select *
From PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------------------------

---How to change Y/N to YES/NO in "SOLD AS VACANT' COLUMN---

---First find out how many distinct variables are in the colums and there count
SELECT DISTINCT(soldasvacant),COUNT(soldasvacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY soldasvacant
ORDER BY  2

---changing them--

select soldasvacant
, CASE when Soldasvacant = 'Y' THEN 'Yes'
       when soldasvacant = 'N' THEN 'No'   
	   else soldasvacant
	   end
From PortfolioProject.dbo.NashvilleHousing

-----update the database now---

Update NashvilleHousing
SET soldasvacant =  CASE when Soldasvacant = 'Y' THEN 'Yes'
       when soldasvacant = 'N' THEN 'No'   
	   else soldasvacant
	   end
----check it out again---
SELECT DISTINCT(soldasvacant),COUNT(soldasvacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY soldasvacant
ORDER BY  2
----DONE!!!---

-----------------------------------------------------------------------------------------------
---REMOVE DUPLICATE--

--1. WRITE THE QUERY AND THEN DO A CTE (Common Table Expression)
with cte as(
SELECT*,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
SELECT*
from cte
 where row_num  > 1
 --order by propertyAddress

select*
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------
--How to DELETE Unused Columns

select*
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column propertyaddress,TaxDistrict

alter table PortfolioProject.dbo.NashvilleHousing
drop column Saledate
