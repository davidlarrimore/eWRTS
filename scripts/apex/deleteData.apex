List<A_File__c> aFileList = [SELECT Id from A_File__c WHERE Handcrafted_for_eWRTS_Demo_Scenario__c = true];
delete aFileList;

List<Case> caseList = [SELECT Id from Case WHERE Handcrafted_for_eWRTS_Demo_Scenario__c = true];
delete caseList;

List<Contact> contactList = [SELECT Id from Contact WHERE Handcrafted_for_eWRTS_Demo_Scenario__c = true];
delete contactList;

List<Account> newList = [SELECT Id from Account WHERE Handcrafted_for_eWRTS_Demo_Scenario__c = true];
delete newList;