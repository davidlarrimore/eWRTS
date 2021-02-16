public with sharing class ContractorMobileAppHelper {
  @AuraEnabled
  public static List<MobileCase> getMyMobilePullCases() {
    List<Case> myCases = [
      SELECT
        Id,
        Status,
        ContactId,
        AccountId,
        OwnerId,
        A_Number__c,
        File_Pulled_for_Processing__c,
        File_Pulled_from_Shelf__c
      FROM Case
      WHERE
        Status = 'File_Retrieval'
        AND File_Pulled_from_Shelf__c = FALSE
        AND OwnerId = :UserInfo.getUserId()
      LIMIT 50
    ];
    List<MobileCase> mobileCaseList = new List<MobileCase>();

    if (myCases.size() > 0) {
      for (Case thisCase : myCases) {
        MobileCase mobileCase = new mobileCase();
        List<RailsRecord> railsRecord = (List<RailsRecord>) System.JSON.deserialize(
          eWRTSApiHelper.RAILSSearch(thisCase.A_Number__c),
          List<RailsRecord>.class
        );

        mobileCase.railsRecord = railsRecord[0];
        mobileCase.caseRecord = thisCase;
        mobileCase.anumber = thisCase.A_Number__c;
        mobileCase.accordianTitle =
          thisCase.A_Number__c +
          ' - ' +
          railsRecord[0].location_room +
          ' - ' +
          railsRecord[0].location_shelf;
        mobileCaseList.add(mobileCase);
      }
    }
    System.debug(System.JSON.serialize(mobileCaseList));
    return mobileCaseList;
  }

  @AuraEnabled
  public static List<MobileCase> getMyMobileDeliveryCases() {
    List<Case> myCases = [
      SELECT
        Id,
        Status,
        ContactId,
        AccountId,
        OwnerId,
        A_Number__c,
        File_Pulled_for_Processing__c,
        File_Pulled_from_Shelf__c
      FROM Case
      WHERE
        Status = 'File_Retrieval'
        AND File_Pulled_from_Shelf__c = TRUE
        AND OwnerId = :UserInfo.getUserId()
      ORDER BY Date_Opened__c DESC
      LIMIT 50
    ];
    List<MobileCase> mobileCaseList = new List<MobileCase>();

    if (myCases.size() > 0) {
      for (Case thisCase : myCases) {
        MobileCase mobileCase = new mobileCase();
        List<RailsRecord> railsRecord = (List<RailsRecord>) System.JSON.deserialize(
          eWRTSApiHelper.RAILSSearch(thisCase.A_Number__c),
          List<RailsRecord>.class
        );

        mobileCase.railsRecord = railsRecord[0];
        mobileCase.caseRecord = thisCase;
        mobileCase.anumber = thisCase.A_Number__c;
        mobileCase.accordianTitle =
          thisCase.A_Number__c +
          ' - ' +
          railsRecord[0].location_room +
          ' - ' +
          railsRecord[0].location_shelf;
        mobileCaseList.add(mobileCase);
      }
    }
    System.debug(System.JSON.serialize(mobileCaseList));
    return mobileCaseList;
  }

  @AuraEnabled
  public static Integer processScannedFile(String aNumber, String appMode) {
    List<Case> myCases = [
      SELECT
        Id,
        Status,
        ContactId,
        AccountId,
        OwnerId,
        A_Number__c,
        File_Pulled_for_Processing__c,
        File_Delivered__c,
        File_Pulled_from_Shelf__c
      FROM Case
      WHERE
        Status != 'Closed'
        AND A_Number__c = :aNumber
        AND OwnerId = :UserInfo.getUserId()
    ];
    Integer retVal = 0;

    if (myCases.size() > 0) {
      Case thisCase = myCases[0];

      if (thisCase.Status == 'File_Retrieval') {
        //If in Pull Mode, Will Mark File as Pulled
        if (appMode == 'Pull' && !thisCase.File_Pulled_from_Shelf__c) {
          retVal = 1;
          thisCase.File_Pulled_from_Shelf__c = true;
          update thisCase;
        } else if (appMode == 'Pull' && thisCase.File_Pulled_from_Shelf__c) {
          //Otherwise the file was already pulled
          retVal = 2;
        }

        //If in Deliver Mode, Will Mark File as Delivered
        if (appMode == 'Deliver' && thisCase.File_Pulled_from_Shelf__c) {
          retVal = 3;
          thisCase.File_Delivered__c = true;
          update thisCase;
        } else if (
          appMode == 'Deliver' && !thisCase.File_Pulled_from_Shelf__c
        ) {
          //Otherwise the file was already delivered
          retVal = 4;
        } else if (appMode == 'Deliver' && thisCase.File_Delivered__c) {
          //Otherwise the file was already delivered
          thisCase.File_Pulled_from_Shelf__c = true;
          thisCase.File_Delivered__c = true;
          retVal = 5;
        }
      }
    } else {
      return 0;
    }

    //TODO: Mulesoft API Call to update

    /*
     * 0 = Could not find Active Case for this AFile
     * 1 = File Marked as Pulled
     * 2 = File Already Pulled, No Action
     * 3 = File Marked as Delivered to Table
     * 4 = File Already Delivered, No Action
     * 5 = File was Not Marked as Pulled from Shelf, Updating Now
     */

    return retVal;
  }
}
