import { LightningElement, api, wire, track } from 'lwc';
import {getRecord} from "lightning/uiRecordApi";

import getRailsRecordByCase from "@salesforce/apex/RailsRecordPageWidgetHelper.getMobileCase";

import ID_FIELD from "@salesforce/schema/Case.Id";
import ANUMBER_FIELD from "@salesforce/schema/Case.A_Number__c";

const fields = [
    ID_FIELD,
    ANUMBER_FIELD
];

export default class RAILSRecordPageWidget extends LightningElement {
    @api recordId;
    @track apiRecord = [];
    @track apiCallCompletedFlag = false;
    @track apiResultsFlag = false; 


    connectedCallback() {
        this.getRecord();
      }

    @wire(getRecord, {
        recordId: "$recordId",
        fields
      })
      case;


    getRecord(){
        getRailsRecordByCase({recordId: this.recordId})
        .then((data) => {
            console.log(`RAILSRecordPageWidget.getRailsRecordByCase Completed Successfully: ${JSON.stringify(data)}`);

            this.apiCallCompletedFlag = true;

            let newItem = data;

            this.apiResultsFlag = true; 
              
            switch(newItem.railsRecord.location_site) {
              case 'NRC':
                newItem.railsRecord.rpc = 'IL1111';
                newItem.custodianName = 'NRC Custodian';
                break;
              case 'ES1':
                newItem.railsRecord.rpc = 'IL8888';
                newItem.custodianName = 'ES1 Custodian';
                break;
              case 'ES2':
                newItem.railsRecord.rpc = 'IL9999';
                newItem.custodianName = 'ES2 Custodian';
                break; 
              case 'ES3':
                newItem.railsRecord.rpc = 'IL7777';
                newItem.custodianName = 'ES3 Custodian';
                break;
              case 'ES4':
                newItem.railsRecord.rpc = 'IL6666';
                newItem.custodianName = 'ES4 Custodian';
                break;                                                     
              default:
                newItem.railsRecord.rpc = 'IL1111';
                newItem.custodianName = 'NRC Custodian';
            }

            //eWRTS File Pulled from Shelf
            if(newItem.caseRecord.File_Pulled_from_Shelf__c == true && newItem.caseRecord.File_Delivered__c == false){
              newItem.custodianName = newItem.caseRecord.Owner.Name;
              newItem.railsRecord.rpc = 'IL1234';
              newItem.railsRecord.location_room = 'N/A'; 
              newItem.railsRecord.location_shelf = 'N/A';  
              newItem.railsRecord.status = 'In Transit'; 
              newItem.railsRecord.date_received_in_rpc = newItem.caseRecord.Date_File_Pulled_from_Shelf__c;    
              newItem.railsRecord.age_with_custodian = 0;         
            }


            //eWRTS File Delivered to Table
            if(newItem.caseRecord.File_Pulled_from_Shelf__c == true && newItem.caseRecord.File_Delivered__c == true){
              newItem.railsRecord.rpc = 'IL0300';
              newItem.custodianName = newItem.caseRecord.Owner.Name;
              newItem.railsRecord.location_site = 'NRC';
              newItem.railsRecord.location_room = 'N/A'; 
              newItem.railsRecord.location_shelf = 'N/A';  
              newItem.railsRecord.status = 'Received';    
              newItem.railsRecord.date_received_in_rpc = newItem.caseRecord.Date_File_Delivered__c;  
              newItem.railsRecord.age_with_custodian = 0;          
            }

            //eWRTS File Pulled for Processing
            if(newItem.caseRecord.File_Pulled_for_Processing__c == true && newItem.caseRecord.File_Processed__c == false){
              newItem.railsRecord.rpc = 'IL0087';
              newItem.custodianName = newItem.caseRecord.Owner.Name;
              newItem.railsRecord.location_site = 'NRC';
              newItem.railsRecord.location_room = 'ILMS 1234'; 
              newItem.railsRecord.location_shelf = 'Cube 2354';  
              newItem.railsRecord.status = 'Received';     
              newItem.railsRecord.date_received_in_rpc = newItem.caseRecord.Date_File_Delivered__c;   
              newItem.railsRecord.age_with_custodian = 0;         
            }


            if(newItem.railsRecord.status == 'Available'){
              newItem.railsRecord.badgeClass = 'slds-badge slds-theme_success';
            }else if(newItem.railsRecord.status == 'In Transit'){
              newItem.railsRecord.badgeClass = 'slds-badge slds-theme_warning';
            }else if(newItem.railsRecord.status == 'Missing'){
              newItem.railsRecord.badgeClass = 'slds-badge slds-theme_error';
            }else if(newItem.railsRecord.status == 'Received'){
              newItem.railsRecord.badgeClass = 'slds-badge slds-badge_inverse';
            }else{
              newItem.railsRecord.badgeClass = 'slds-badge';
            }      

            console.log(`Updated MobileRecord: ${JSON.stringify(newItem)}`);

            this.apiRecord = newItem;

            this.error = undefined;

        })
        .catch((error) => {
            this.error = error;
            console.log(`RAILSRecordPageWidget.getRailsRecordByCase Failed: ${error}`);
        });
    }

    get isAvailable(){
      
      if(this.apiResultsFlag){
        if(this.apiRecord.status == 'Available'){
          return true;
        }
      }
      return false;
    }

// Sample Data
//
//    {
//        "file_number": "100000003",
//        "age_with_custodian": 2,
//        "rpc": "161009711",
//        "location_notes": null,
//        "location_shelf": "595",
//        "location_site": "NRC",
//        "digitized_flag": false,
//        "date_received_in_rpc": "2015-08-14T00:00:00",
//        "location_room": "Stacking Room - Downstairs",
//        "status": "Available"
//    }




}
