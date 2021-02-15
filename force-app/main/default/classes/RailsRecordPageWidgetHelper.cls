public inherited sharing class RailsRecordPageWidgetHelper {
    public RailsRecordPageWidgetHelper() {

    }


    @AuraEnabled
    public static MobileCase getMobileCase(String recordId){
        List<Case> myCases = [SELECT Id, Status, ContactId, AccountId, OwnerId, A_Number__c, Owner.Name, Owner.FirstName, Owner.LastName, File_Pulled_from_Shelf__c, Date_File_Pulled_from_Shelf__c,  File_Delivered__c, Date_File_Delivered__c, File_Pulled_for_Processing__c, Date_File_Pulled_for_Processing__c, File_Processed__c, Date_File_Processed__c FROM Case WHERE Id = :recordId];
        MobileCase mobileCase = new MobileCase();

        if(myCases.size() > 0){
                Case thisCase = myCases[0];
                List<RailsRecord> railsRecord = (List<RailsRecord>)System.JSON.deserialize(eWRTSApiHelper.RAILSSearch(thisCase.A_Number__c), List<RailsRecord>.class);

                mobileCase.railsRecord = railsRecord[0];
                mobileCase.caseRecord = thisCase;
                mobileCase.anumber = thisCase.A_Number__c;
                mobileCase.accordianTitle = thisCase.A_Number__c + ' - ' + railsRecord[0].location_room + ' - ' + railsRecord[0].location_shelf;
        }
        System.debug(System.JSON.serialize(mobileCase));
        return mobileCase;
    }


}
