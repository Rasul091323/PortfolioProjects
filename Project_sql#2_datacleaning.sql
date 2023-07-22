
select * from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------

--Standardize Date Format 

select convert(date, saleDate) as SaleDate, saledate  from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing 
set saledate = cast(saledate as date)

Alter table PortfolioProject.dbo.NashvilleHousing
add saledateConverted date

update PortfolioProject.dbo.NashvilleHousing
set saledateConverted  = convert(date, saledate)

--------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

select * from PortfolioProject.dbo.NashvilleHousing
--where propertyAddress  is not null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
isnull(a.propertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing  b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set propertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.propertyAddress is null 
 
  --------------------------------------------------------------------------------------------------------------------

  --Breaking out adress Individual columns (Adress, City, State)

select propertyAddress, 
       substring(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1) as Address, 
       /* CHARINDEX(',', propertyAddress)*/
	   substring(propertyAddress, CHARINDEX(',', propertyAddress)+1, len(propertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing 

alter table NashvilleHousing
add PropertysplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1) 

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertysplitCity = substring(propertyAddress, CHARINDEX(',', propertyAddress)+1, len(propertyAddress))

select owneraddress from nashvillehousing

select  PARSENAME(replace(owneraddress, ',', '.'),  3),  
        PARSENAME(replace(owneraddress, ',', '.'),  2), 
	    PARSENAME(replace(owneraddress, ',', '.'),  1)
from PortfolioProject.dbo.nashvillehousing


Alter table NashvilleHousing
add Owner_Address nvarchar(255)

update NashvilleHousing
set Owner_Address = PARSENAME(replace(owneraddress, ',', '.'),  3)

Alter table nashvilleHousing
add Owner_City nvarchar(255)

update nashvillehousing
set Owner_city = PARSENAME(replace(owneraddress, ',', '.'),  2)

Alter table nashvilleHousing
add Owner_state nvarchar(255)

update nashvillehousing
set Owner_state = PARSENAME(replace(owneraddress, ',', '.'),  1)

select * from nashvillehousing

--------------------------------------------------------------------------------------------------------------------

--Change Y and N to yes and No in Sold as Vacant field

select distinct(soldasvacant), 
       count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2

select soldasvacant, 
      case when soldasvacant = 'Y' then 'Yes'
	       when soldasvacant = 'N' then 'No'
		   else soldasvacant
		   end
from nashvillehousing


update nashvillehousing 
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	       when soldasvacant = 'N' then 'No'
		   else soldasvacant
		   end

--------------------------------------------------------------------------------------------------------------------

--Remove Dublicates

with rwm_cte as (
select a.*, 
       Row_number() over(partition by a.parcelID, 
	                                  a.PropertyAddress, 
									  a.Saleprice, 
									  a.saledate, 
									  a.legalreference
						 order by 	  a.uniqueID	) row_num

from nashvillehousing a
--order by a.parcelID
)
select * from rwm_cte
where row_num > 1
order by Propertyaddress


--------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select * from nashvillehousing

alter table nashvillehousing
drop column ownerAddress, taxdistrict, PropertyAddress

alter table nashvillehousing
drop column saledate







