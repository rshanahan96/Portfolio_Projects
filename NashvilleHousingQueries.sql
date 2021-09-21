--Cleaning data with SQL queries

Select *
From NashvilleHousing

--Standardize Date Format so that it is a date instead of datetime

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(date, SaleDate)

Select SaleDateConverted, SaleDate
From NashvilleHousing

--Populate Property Address Data

Select *
From NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State) using substrings

Select PropertyAddress
From NashvilleHousing

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	Substring(PropertyAddress, CharIndex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CharIndex(',', PropertyAddress)+1, len(PropertyAddress))

-- Separating Address Columns with PARSENAME
Select 
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldasVacant,
	Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldasVacant
	End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldasVacant
	End

--Remove Duplicates with CTE

With RowNumCTE as(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) as RowNum
From NashvilleHousing
)
Delete
From RowNumCTE
Where RowNum > 1

--Delete Unused Columns

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate