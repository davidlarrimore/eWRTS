echo "*** Creating scratch org ..."
sfdx force:org:create -f config/project-scratch-def.json --setdefaultusername --setalias eWRTSScratch -d 30

echo "*** Installing required packages ..."
echo "*** Installing Tableau LWC ..."
sfdx force:package:install --package 04t5w000005diA4AAI -w 1000 -u eWRTSScratch
echo "*** Installing Unofficial SF Flow Horizontal Rule  ..."
sfdx force:package:install --package 04tB00000006grz -w 1000 -u eWRTSScratch
echo "*** Barcode and QR Reader: https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FvIsgUAF..."
sfdx force:package:install --package 04t1U000007Y4i4QAC -w 1000 -u eWRTSScratch
echo "*** Activity Scorecard Component: https://appexchangejp.salesforce.com/appxListingDetail?listingId=a0N3u00000MBd62EAD&channel=recommended..."
sfdx force:package:install --package 04t4N000000omg3QAA -w 1000 -u eWRTSScratch
echo "*** Customisable Flow Header & Footer with Progress Indicator: https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000EczujUAB..."
sfdx force:package:install --package 04t1t0000034vZjAAI -w 1000 -u eWRTSScratch


echo "*** Pushing metadata to scratch org ..."
sfdx force:source:push

echo "*** Create Contactor User ..."
sfdx force:user:create -a eWRTSScratch_Contractor email=davidlarrimoresalesforce@gmail.com firstName=Chris lastName=Contractor -f config/contractor-user-def.json
sfdx force:user:create -a eWRTSScratch_Analyst email=davidlarrimoresalesforce@gmail.com firstName=Alice lastName=Analyst -f config/analyst-user-def.json
#sfdx force:user:create -a eWRTSScratch_Analyst2 email=davidlarrimoresalesforce@gmail.com firstName=Steve lastName=Service -f config/analyst-user-def.json
#sfdx force:user:create -a eWRTSScratch_Analyst3 email=davidlarrimoresalesforce@gmail.com firstName=Bob lastName=Hotchkins -f config/analyst-user-def.json

echo "*** Assigning permission set to your users ..."
sfdx force:user:permset:assign -n eWRTS_Demo_Admin -u eWRTSScratch


echo "*** Generating password for your users ..."
sfdx force:user:password:generate --targetusername eWRTSScratch
sfdx force:user:password:generate --targetusername eWRTSScratch_Contractor
sfdx force:user:password:generate --targetusername eWRTSScratch_Analyst

echo "*** Creating data"
sfdx sfdmu:run --sourceusername csvfile --targetusername eWRTSScratch -p data
#sfdx force:apex:execute -f scripts/apex/randomlyGenerateCases.apex
#sfdx force:apex:execute -f scripts/apex/randomlyGenerateCases.apex
#sfdx force:apex:execute -f scripts/apex/randomlyGenerateCases.apex

#echo "*** Creating User"
#sfdx force:user:create --setalias outlook-user --definitionfile data/user-def.json
#sfdx force:user:password:generate --targetusername outlook-user

echo "*** Setting up debug mode..."
sfdx force:apex:execute -f scripts/apex/setDebugMode.apex

echo "*** Setting up Remote Site Settings..."
#sfdx force:apex:execute -f scripts/apex/createRemoteSiteSettings.apex

echo "*** Opening Org"
#sfdx force:org:open
sfdx force:org:open -p /lightning/page/home
