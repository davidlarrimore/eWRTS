public with sharing class ContractorMobileAppHelper {

    @AuraEnabled(cacheable=true)
    public static List<MobileCase> getMyMobileCases(){
        List<Case> myCases = [Select Id, Status, ContactId, AccountId, OwnerId, A_Number__c, File_Pulled_for_Processing__c, File_Pulled_from_Shelf__c from Case WHERE Status = 'File_Retrieval' AND OwnerId = :UserInfo.getUserId() LIMIT 10];
        List<MobileCase> mobileCaseList = new List<MobileCase>();

        if(myCases.size() > 0){
            for(Case thisCase: myCases){
                MobileCase mobileCase = new mobileCase();
                List<RailsRecord> railsRecord = (List<RailsRecord>)System.JSON.deserialize(eWRTSApiHelper.RAILSSearch(thisCase.A_Number__c), List<RailsRecord>.class);

                mobileCase.railsRecord = railsRecord[0];
                mobileCase.caseRecord = thisCase;
                mobileCase.anumber = thisCase.A_Number__c;
                mobileCase.accordianTitle = thisCase.A_Number__c + ' - ' + railsRecord[0].location_room + ' - ' + railsRecord[0].location_shelf;
                mobileCaseList.add(mobileCase);
            }
        }
        System.debug(System.JSON.serialize(mobileCaseList));
        return mobileCaseList;
    }


    @AuraEnabled
    public static Integer processScannedFile(String aNumber){
        List<Case> myCases = [Select Id, Status, ContactId, AccountId, OwnerId, A_Number__c, File_Pulled_for_Processing__c, File_Delivered__c, File_Pulled_from_Shelf__c from Case WHERE Status != 'Closed' AND A_Number__c = :aNumber];
        Integer retVal = 0;

        if(myCases.size() > 0){
            Case thisCase = myCases[0];
            if (!thisCase.File_Pulled_from_Shelf__c){
                retVal = 1;
                thisCase.File_Pulled_from_Shelf__c = true;
            }

            if (thisCase.File_Pulled_from_Shelf__c){
                retVal = 2;
                thisCase.File_Delivered__c = true;
            }  

            if (thisCase.File_Delivered__c){
                retVal = 3;
            }  

            Update thisCase;
        }


        //TODO: Mulesoft API Call to update

        /*
        * 0 = Could not find Active Case for this AFile
        * 1 = File Marked as Pulled
        * 2 = File Marked as Delivered to Table
        * 3 = File Already Delivered, No Action
        */
         
        return retVal;
    }

}
