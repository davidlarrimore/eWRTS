


echo "*** Pull Data from Dev..."
#sfdx sfdmu:run --sourceusername eWRTSScratch --targetusername csvfile -p data

echo "*** Push Data from Scratch CSV to Prod..."
#sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTS -p data

echo "*** Pull Data from Prod..."
#sfdx sfdmu:run --sourceusername eWRTS --targetusername csvfile -p data

echo "*** Push Data from Prod CSV to Scratch..."
#sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTSScratch -p data

echo "*** Push Data from Scratch to Prod..."
#sfdx sfdmu:run --sourceusername eWRTSScratch --targetusername eWRTS -p data

echo "*** Push Data from Prod to Scratch..."
#sfdx sfdmu:run --sourceusername eWRTS --targetusername eWRTSScratch -p data


