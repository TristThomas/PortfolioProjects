--------------------------------------------------------------------------------------------------------------------------------

-- This project was inspired by Alex Freberg (https://www.linkedin.com/in/alex-freberg/) walkthroughs

Select *
from PortfolioProject..NashHousing

--------------------------------------------------------------------------------------------------------------------------------

-- Changing SaleDate format 

Select SaleDate, CONVERT(date, SaleDate) 
from PortfolioProject..NashHousing

Update PortfolioProject..NashHousing 
SET SaleDate = Convert(date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------------

-- Populating null PropertyAddress values

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashHousing a
Join PortfolioProject..NashHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Updating table

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashHousing a
Join PortfolioProject..NashHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------

-- Separating PropertyAddress 

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertyAddress_new,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertyCity_new
from PortfolioProject..NashHousing

-- Updating the table

ALTER TABLE NashHousing
Add PropertyAddress_new nvarchar(255);

Update PortfolioProject..NashHousing
Set PropertyAddress_new = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashHousing
Add PropertyCity_new nvarchar(255);

Update PortfolioProject..NashHousing
Set PropertyCity_new = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------------

-- Separating OwnerAddress  

Select OwnerAddress
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddress_new
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity_new
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState_new
from PortfolioProject..NashHousing

-- Updating table

ALTER TABLE NashHousing
Add OwnerAddress_new nvarchar(255);

Update PortfolioProject..NashHousing
Set OwnerAddress_new = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashHousing
Add OwnerCity_new nvarchar(255);

Update PortfolioProject..NashHousing
Set OwnerCity_new = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashHousing
Add OwnerState_new nvarchar(255);

Update PortfolioProject..NashHousing
Set OwnerState_new = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------------

-- Standardising SoldAsVacant data - currently contains Yes/No and Y/N data - proven by:

Select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortfolioProject..NashHousing
group by SoldAsVacant

-- Standardising to Yes and No

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		End
from PortfolioProject..NashHousing

-- Updating table

Update PortfolioProject..NashHousing
Set SoldAsVacant =  Case when SoldAsVacant = 'Y' then 'Yes'
					when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					End

--------------------------------------------------------------------------------------------------------------------------------

-- All remaining code was written and tested for practice purposes, but not used as it is not standard practice to delete data

With Duplicates_CTE as
(
Select *, 
	ROW_NUMBER() over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
from PortfolioProject..NashHousing
)
Delete
from Duplicates_CTE
where row_num > 1

-- Removing unwanted columns

Alter table PortFolioProject..NashHousing
Drop column SaleDate, PropertyAddress, OwnerAddress

