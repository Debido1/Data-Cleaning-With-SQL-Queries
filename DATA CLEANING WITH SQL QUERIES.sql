/*
CLEANING OF DATA IN SQL QUERIES
*/

SELECT *
FROM NashvilleHousing$


--STANDARDIZE DATE FROMAT

ALTER TABLE NashvilleHousing$
ADD SaleDateConverted Date

UPDATE NashvilleHousing$
SET SaleDateConverted = CONVERT(Date,SaleDate)

--POPULATE PROPERTY ADDRESS DATA
SELECT *
FROM NashvilleHousing$
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing$ a
JOIN NashvilleHousing$ b
	ON a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing$ a
JOIN NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

---TO CHECK IF YOUR PROPERTY ADDRESS IS POPULATED
SELECT *
FROM NashvilleHousing$
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

---BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(Address, City ,State)

SELECT PropertyAddress
FROM NashvilleHousing$

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM NashvilleHousing$

ALTER TABLE NashvilleHousing$
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing$
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

SELECT *
FROM NashvilleHousing$

---BREAKING OUT  OWNERS ADDRESS INTO INDIVIDUAL COLUMNS(Address, City ,State)
--N.B THE PARSENAME FUNCTIONS RETURN THE SPECIFIED PART OF AN OBJECT NAME.THE PART OF OBJECT THAT CAN BE RETRIEVED ARE OBJECT NAME,OWNER NAME,
--SERVER NAME AND DATABASE NAME

SELECT OwnerAddress
FROM NashvilleHousing$

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3) AS Address
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,1) AS State
FROM NashvilleHousing$

ALTER TABLE NashvilleHousing$
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

SELECT *
FROM NashvilleHousing$

ALTER TABLE NashvilleHousing$
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

ALTER TABLE NashvilleHousing$
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)

SELECT *
FROM NashvilleHousing$

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT SoldAsVacant
FROM NashvilleHousing$
WHERE SoldAsVacant LIKE '%N'
ORDER BY SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant='y' THEN 'YES'
	WHEN SoldAsVacant= 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing$

UPDATE NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant='y' THEN 'YES'
	WHEN SoldAsVacant= 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

--REMOVE DUPLICATES
SELECT *
FROM NashvilleHousing$

WITH RowNumCTE AS (SELECT *,
			ROW_NUMBER()OVER(PARTITION BY ParcelID, PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) AS row_num
	FROM NashvilleHousing$)

SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

SELECT *
FROM NashvilleHousing$


--REMOVING UNUSED COLUMNS
SELECT *
FROM NashvilleHousing$

ALTER TABLE NashvilleHousing$
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

