


echo "*** Pull Data from Dev..."
#sfdx sfdmu:run --sourceusername eWRTSScratch --targetusername csvfile -p data

echo "*** Push Data from Scratch CSV to Prod..."
#sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTS -p data

echo "*** Push Data from Scratch to Prod..."
#sfdx sfdmu:run --sourceusername eWRTSScratch --targetusername eWRTS -p data

