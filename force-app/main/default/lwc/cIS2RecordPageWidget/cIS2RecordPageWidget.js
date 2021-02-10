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
    @track apiResultsFlag = false;
    
    connectedCallback() {
        console.log("Running doRefreshComponent");
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
            this.apiResultsFlag = true;
            let apiRecords = JSON.parse(data);
            this.apiRecord = apiRecords[0];
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
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
