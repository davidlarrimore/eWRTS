public with sharing class MobileCase {
    
    @AuraEnabled public Case caseRecord {get;set;} 
    @AuraEnabled public railsRecord railsRecord {get;set;} 
    @AuraEnabled public String anumber {get;set;} 
    @AuraEnabled public String accordianTitle {get;set;} 

    public MobileCase() {

    }
}
