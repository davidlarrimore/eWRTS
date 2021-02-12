public with sharing class RailsRecord {

    @AuraEnabled public String file_number {get;set;} 
    @AuraEnabled public String status {get;set;} 
    @AuraEnabled public String rpc {get;set;} 
    @AuraEnabled public String location_notes {get;set;} 
    @AuraEnabled public String location_shelf {get;set;} 
    @AuraEnabled public String location_site {get;set;} 
    @AuraEnabled public String location_room {get;set;} 

    @AuraEnabled public DateTime date_received_in_rpc {get;set;} 

    @AuraEnabled public Boolean digitized_flag {get;set;} 

    @AuraEnabled public Integer age_with_custodian;

    public RailsRecord() {

    }
}
