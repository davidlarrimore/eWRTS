echo "*** Pushing metadata to scratch org ..."
sfdx force:source:push

echo "*** Deploying metadata to target org ..."
sfdx force:source:deploy --targetusername eWRTS --sourcepath force-app

echo "*** Deleting Data ..."
sfdx force:apex:execute -f scripts/apex/deleteData.apex -u eWRTS

echo "*** Re-Importing Data ..."
sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTS -p data

echo "*** Setting up Remote Site Settings ..."
sfdx force:apex:execute -f scripts/apex/createRemoteSiteSettings.apex -u eWRTS