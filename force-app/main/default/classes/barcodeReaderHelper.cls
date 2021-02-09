public with sharing class barcodeReaderHelper {

    @AuraEnabled
    public static String getCaseId(String aNumber){
        List<Case> theCaseId = [Select Id, Status, File_Pulled_for_Processing__c from Case WHERE A_Number__c = :aNumber AND Status != 'Closed'];

        if(theCaseId.size() > 0){

            Case thisCase = theCaseId[0];
            //If Case is in File Processing, Mark it as pulled and re-assign owner.
            if (thisCase.Status == 'File_Processing'){
                //If not already marked as pulled, mark it

                if (thisCase.File_Pulled_for_Processing__c != true){
                    thisCase.File_Pulled_for_Processing__c = true;
                }

                if (thisCase.File_Pulled_for_Processing__c != true){
                    thisCase.File_Pulled_for_Processing__c = true;
                }

                thisCase.OwnerId = UserInfo.getUserId();
                update thisCase;
            }

            return (String)thisCase.Id;
        }

        return null;
    }
}
