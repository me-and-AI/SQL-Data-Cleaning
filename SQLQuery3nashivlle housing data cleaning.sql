/*

Cleaning Data in SQL Queries

*/

Select*
From [Portfolio Project].dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- Standardize date format


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ALTER COLUMN SaleDate Date;


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select*
From [Portfolio Project].dbo.NashvilleHousing
order by ParcelID


Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



Select*
From [Portfolio Project]..NashvilleHousing
order by ParcelID

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))as City
From NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-- Alternate way to do the same thing except on owner address-



Select*
From [Portfolio Project].dbo.NashvilleHousing


Select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From [Portfolio Project]..NashvilleHousing	


UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
						End




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RownumberCTE AS(
Select*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueId) as Row_num
From [Portfolio Project]..NashvilleHousing
)
SELECT*
From RownumberCTE
Where Row_num > 1
--Order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
