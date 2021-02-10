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
        getRailsRecordByCase({recordId: this.recordId})
        .then((data) => {
            console.log(`RAILSRecordPageWidget.getRailsRecordByCase Completed Successfully: ${data}`);
            this.apiResultsFlag = true;
            let apiRecords = JSON.parse(data);
            this.apiRecord = apiRecords[0];
            console.log(`A Folder: ${this.apiRecord.file_number}`);
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
        });
    }

    get isAvailable(){
        if(this.apiRecord.status == 'Available'){
          return true;
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
