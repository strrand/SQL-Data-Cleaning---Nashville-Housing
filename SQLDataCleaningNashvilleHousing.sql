-- SQL Data Cleaning - Nashville Housing dataset

-- Standardize Date Format

select SaleDateConverted, convert(date, saledate) from NashvilleHousing

UPDATE NashvilleHousing
SET Saledate = CONVERT(date, SaleDate)

ALTER TABLE nashvillehousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

---------------------------------------------------------

-- Populate Property Address Data	

select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
inner join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
inner join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------
 -- Breaking out Address into Individual columns (Address, City, State)

 select PropertyAddress from NashvilleHousing

 select substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1), 
 substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) 
 from NashvilleHousing

ALTER TABLE nashvillehousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

ALTER TABLE nashvillehousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity =  substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select * from NashvilleHousing



select OwnerAddress from NashvilleHousing

select PARSENAME(replace(owneraddress, ',', '.'), 3), PARSENAME(replace(owneraddress, ',', '.'), 2), 
PARSENAME(replace(owneraddress, ',', '.'), 1) from NashvilleHousing

ALTER TABLE nashvillehousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

ALTER TABLE nashvillehousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)

select * from NashvilleHousing


-------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' Field

Select Distinct(SoldAsVacant), count(soldasvacant) from NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant, case 
when SoldAsVacant = 'Y' then 'Yes' 
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant end
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'Yes' 
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant end



--------------------------------------------

-- Remove Duplicates (NOT standard practise to remove data from db)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
from nashvillehousing
)
DELETE --Select * --=> gave 104 rows 
from RowNumCTE
where row_num > 1
--order by propertyaddress

----------------------------------------------

-- Delete Unused Columns

select * from NashvilleHousing

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress