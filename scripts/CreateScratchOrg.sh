#!/bin/bash

echo "*** Creating scratch org ..."
sfdx force:org:create -f config/project-scratch-def.json --setdefaultusername --setalias eWRTSScratch -d 30

echo "*** Installing required packages ..."
sh scripts/installScratchOrgPackages.sh

echo "*** Pushing metadata to scratch org ..."
sfdx force:source:push

read -n1 -s -r -p $'Press [SPACE] to continue...\n' key

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
sfdx force:apex:execute -f scripts/apex/randomlyGenerateCases.apex

echo "*** Setting up debug mode..."
sfdx force:apex:execute -f scripts/apex/setDebugMode.apex

echo "*** Setting up Remote Site Settings..."
#sfdx force:apex:execute -f scripts/apex/createRemoteSiteSettings.apex

echo "*** Opening Org"
#sfdx force:org:open
sfdx force:org:open -p /lightning/page/home
