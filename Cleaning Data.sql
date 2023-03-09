Select *
From NashvilleHousing
--Standard Date
Select Sale_Date, CONVERT(date, SaleDate)
From NashvilleHousing

Alter table NashvilleHousing
Add Sale_Date Date;

Update NashvilleHousing
Set Sale_Date = CONVERT(date, SaleDate)


--Address cleaning
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking Address
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As City
From NashvilleHousing

Alter Table NashvilleHousing
Add Property_Address nvarchar(255);

Update NashvilleHousing
Set Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyAddress)-1) 

Alter Table NashvilleHousing
Add Property_city nvarchar(255);

Update NashvilleHousing
Set Property_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousing

--Owner Address
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add Owner_Address nvarchar(255);

Update NashvilleHousing
Set Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add Owner_City nvarchar(255);

Update NashvilleHousing
Set Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add Owner_State nvarchar(255);

Update NashvilleHousing
Set Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Changing 'Y' and 'N' to 'Yes' and 'No'
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicate
WITH RowNumCTE As(
Select*,
	ROW_NUMBER() Over(
		Partition By ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
		Order By UniqueID) row_num
From NashvilleHousing
)


Select *
From RowNumCTE
Where row_num >1
--Order By PropertyAddress

--Delete Unused Columns

Alter Table NashvilleHousing
Drop column PropertyAddress, SaleDate,OwnerAddress

Select *
From NashvilleHousing