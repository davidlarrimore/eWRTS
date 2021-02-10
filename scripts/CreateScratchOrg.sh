echo "*** Creating scratch org ..."
sfdx force:org:create -f config/project-scratch-def.json --setdefaultusername --setalias eWRTSScratch -d 30

echo "*** Installing required packages ..."
echo "*** Installing Tableau LWC ..."
sfdx force:package:install --package 04t5w000005diA4AAI -w 1000 -u eWRTSScratch
echo "*** Installing Unofficial SF Flow Horizontal Rule  ..."
sfdx force:package:install --package 04tB00000006grz -w 1000 -u eWRTSScratch

echo "*** Pushing metadata to scratch org ..."
sfdx force:source:push

echo "*** Create Contactor User ..."
sfdx force:user:create --setalias eWRTSScratch_Contractor email=davidlarrimoresalesforce@gmail.com firstName=Chris lastName=Contractor

echo "*** Assigning permission set to your users ..."
sfdx force:user:permset:assign -n eWRTS_Demo_Admin -u eWRTSScratch
sfdx force:user:permset:assign -n eWRTSScratch_Contractor -u eWRTSScratch_Contractor

echo "*** Generating password for your users ..."
sfdx force:user:password:generate --targetusername eWRTSScratch
sfdx force:user:password:generate --targetusername eWRTSScratch_Contractor

echo "*** Creating data"
sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTSScratch -p data/scratch
sfdx force:apex:execute -f scripts/apex/generateCases.apex
sfdx force:apex:execute -f scripts/apex/generateCases.apex
sfdx force:apex:execute -f scripts/apex/generateCases.apex

#echo "*** Creating User"
#sfdx force:user:create --setalias outlook-user --definitionfile data/user-def.json
#sfdx force:user:password:generate --targetusername outlook-user

echo "*** Setting up debug mode..."
sfdx force:apex:execute -f scripts/apex/setDebugMode.apex

echo "*** Setting up Remote Site Settings..."
sfdx force:apex:execute -f scripts/apex/createRemoteSiteSettings.apex

echo "*** Opening Org"
#sfdx force:org:open
sfdx force:org:open -p /lightning/page/home
