import { LightningElement, api, wire, track } from 'lwc';
import {getRecord} from "lightning/uiRecordApi";

import getCIS2RecordByCase from "@salesforce/apex/eWRTSApiHelper.CIS2SearchByCase";

import ID_FIELD from "@salesforce/schema/Case.Id";
import ANUMBER_FIELD from "@salesforce/schema/Case.A_Number__c";

const fields = [
    ID_FIELD,
    ANUMBER_FIELD
];

export default class CIS2RecordPageWidget extends LightningElement {
    @api recordId;
    @track apiRecord;
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
        getCIS2RecordByCase({recordId: this.recordId})
        .then((data) => {
            console.log(`CIS2RecordPageWidget.getCIS2RecordByCase Completed Successfully: ${data}`);
            let apiRecords = JSON.parse(data);  
            console.log(`apiRecords Size: ${apiRecords.length}`);

            this.apiCallCompletedFlag = true;
            if(apiRecords.length > 0){
                this.apiResultsFlag = true; 
                apiRecords[0].formatted_birthdate = Date.parse(apiRecords[0].birthdate);
                this.apiRecord = apiRecords[0];
                
            }    
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.log(`CIS2RecordPageWidget.getCIS2RecordByCase Failed: ${error}`);
        });
    }


// Sample Data
//
//  {
//    "birthdate": "1976-10-27T00:00:00",
//    "port_of_entry": "Genderfluid",
//    "gender": "Calexico East - Class A, California - 2507",
//    "country_of_origin": "Indonesia",
//    "last_name": "Hoofe",
//    "a_number": "100000003",
//    "first_name": "Emmey"
//  }



}
