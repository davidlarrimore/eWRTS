import { LightningElement, api, wire, track } from 'lwc';
import {getRecord} from "lightning/uiRecordApi";

import getRailsRecordByCase from "@salesforce/apex/eWRTSApiHelper.RAILSSearchByCase";

import ID_FIELD from "@salesforce/schema/Case.Id";
import ANUMBER_FIELD from "@salesforce/schema/Case.A_Number__c";

const fields = [
    ID_FIELD,
    ANUMBER_FIELD
];

export default class RAILSRecordPageWidget extends LightningElement {
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
        getRailsRecordByCase({recordId: this.recordId})
        .then((data) => {
            console.log(`RAILSRecordPageWidget.getRailsRecordByCase Completed Successfully: ${data}`);
            let apiRecords = JSON.parse(data);
            console.log(`apiRecords Size: ${apiRecords.length}`);

            this.apiCallCompletedFlag = true;

            if(apiRecords.length > 0){
                this.apiResultsFlag = true; 

                this.apiRecord = apiRecords[0];
                console.log(`A Folder: ${this.apiRecord.file_number}`);
            }  

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
