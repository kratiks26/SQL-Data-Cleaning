create database nashville_data

select* from nashville_data..nashville_housing_data



--(1) Standardize Date Format

select cast(saledate as date) from nashville_data..nashville_housing_data
  --( for that we change column type  datetime to date)

alter table nashville_data..nashville_housing_data
alter column saledate date



--(2) Populate Property Address 

select propertyaddress from nashville_data..nashville_housing_data
where propertyaddress is null


select a.uniqueid, a.parcelid,a.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
from nashville_data..nashville_housing_data as a join nashville_data..nashville_housing_data as b
on a.parcelid=b.parcelid and a.uniqueid != b.uniqueid
where a.propertyaddress is null


update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from nashville_data..nashville_housing_data as a join nashville_data..nashville_housing_data as b
on a.parcelid=b.parcelid and a.uniqueid != b.uniqueid
where a.propertyaddress is null




--(3) Breaking out Property Address into Individual Columns (Address, City, State)

select * from nashville_data..nashville_housing_data

select propertyaddress, substring(propertyaddress,1, charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+2,len(propertyaddress)) as city
from nashville_data..nashville_housing_data


alter table nashville_data..nashville_housing_data
add propertyaddress_new nvarchar(225), city nvarchar(225)

update nashville_data..nashville_housing_data
set propertyaddress_new=substring(propertyaddress,1, charindex(',',propertyaddress)-1),
city = substring(propertyaddress,charindex(',',propertyaddress)+2,len(propertyaddress))


--(4) break out owner address

select *
from nashville_data..nashville_housing_data

select replace(owneraddress,',','.')
from nashville_data..nashville_housing_data

select PARSENAME(replace(owneraddress,',','.'),3) as owneraddress_new,
parsename(replace(owneraddress,',','.'),2) as owner_city,
parsename(replace(owneraddress,',','.'),1) as state
from nashville_data..nashville_housing_data

alter table nashville_data..nashville_housing_data
add owneraddress_new nvarchar(225),owner_city nvarchar(225),state nvarchar(225)

update nashville_data..nashville_housing_data
set owneraddress_new= PARSENAME(replace(owneraddress,',','.'),3),
owner_city = parsename(replace(owneraddress,',','.'),2),
state = parsename(replace(owneraddress,',','.'),1)

--(5) populate owneraddress_new

select propertyaddress_new,city, owneraddress_new, owner_city,state 
from nashville_data..nashville_housing_data

select propertyaddress_new, owneraddress_new, isnull( owneraddress_new, propertyaddress_new) as owneraddress_new2
from nashville_data..nashville_housing_data
where owneraddress_new is null

update nashville_data..nashville_housing_data
set owneraddress_new= isnull( owneraddress_new, propertyaddress_new)
from nashville_data..nashville_housing_data
where owneraddress_new is null

--(6) populate owner_city

update nashville_data..nashville_housing_data
set owner_city= isnull( owner_city, city)
from nashville_data..nashville_housing_data
where owner_city is null


--(7) populate state( these all cities are in Tennessee)
update nashville_data..nashville_housing_data
set state = 'TN'
where state is null

--(8) now let's change this 'TN' state name to 'Tennessee'

update nashville_data..nashville_housing_data
set state = 'TENNESSEE'
where state = 'TN'


--(9) Change Y and N to Yes and No in "SoldasVacant" field

select * from nashville_data..nashville_housing_data

update nashville_data..nashville_housing_data
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No' when SoldAsVacant = 'Y' then 'Yes' end


--(10) Remove Duplicates

select uniqueid, ROW_NUMBER() over ( partition by parcelid, propertyaddress,saledate, owneraddress_new order by uniqueid) 
from nashville_data..nashville_housing_data

with remove_dup( uniqueid, row_num)
 as
 (select uniqueid, ROW_NUMBER() over ( partition by parcelid, propertyaddress,saledate, owneraddress_new order by uniqueid) 
from nashville_data..nashville_housing_data
)

delete from remove_dup where row_num>1


--(11) Delete Unused Columns
select * from nashville_data..nashville_housing_data

alter table nashville_data..nashville_housing_data
drop column propertyaddress, owneraddress


select * from nashville_data..nashville_housing_data






