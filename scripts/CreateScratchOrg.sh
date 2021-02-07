echo "*** Creating scratch org ..."
sfdx force:org:create -f config/project-scratch-def.json --setdefaultusername --setalias eWRTSScratch -d 30

echo "*** Installing required package ..."
sfdx force:package:install --package 04t5w000005diA4AAI -w 1000 -u eWRTSScratch

echo "*** Pushing metadata to scratch org ..."
sfdx force:source:push

echo "*** Assigning permission set to your user ..."
sfdx force:user:permset:assign --permsetname eWRTS_Demo_Admin --targetusername eWRTSScratch

echo "*** Generating password for your user ..."
sfdx force:user:password:generate --targetusername eWRTSScratch

echo "*** Creating data"
sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTSScratch -p data/scratch

#echo "*** Creating User"
#sfdx force:user:create --setalias outlook-user --definitionfile data/user-def.json
#sfdx force:user:password:generate --targetusername outlook-user

echo "*** Setting up debug mode..."
sfdx force:apex:execute -f scripts/apex/setDebugMode.apex

echo "*** Setting up Remote Site Settings..."
sfdx force:apex:execute -f scripts/apex/createRemoteSiteSettings.apex

echo "*** Opening Org"
sfdx force:org:open
#sfdx force:org:open -p /lightning/n/EWRTS