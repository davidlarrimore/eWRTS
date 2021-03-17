import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getCIS2RecordByCase from "@salesforce/apex/eWRTSApiHelper.CIS2SearchByCase";
import getCIS2Put from "@salesforce/apex/eWRTSApiHelper.CIS2Put";

import ID_FIELD from "@salesforce/schema/Case.Id";
import ANUMBER_FIELD from "@salesforce/schema/Case.A_Number__c";

const fields = [ID_FIELD, ANUMBER_FIELD];

export default class CIS2RecordPageWidget extends LightningElement {
  @api recordId;
  @track apiRecord;
  @track editFormFlag = false;
  @track apiCallCompletedFlag = false;
  @track apiResultsFlag = false;
  nameInputFields = ["firstName", "lastName"];

  connectedCallback() {
    this.getRecord();
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields
  })
  case;

  updateCountryOfOrigin;

  getRecord() {
    getCIS2RecordByCase({ recordId: this.recordId })
      .then((data) => {
        console.log(
          `CIS2RecordPageWidget.getCIS2RecordByCase Completed Successfully: ${data}`
        );
        let apiRecords = JSON.parse(data);
        console.log(`apiRecords Size: ${apiRecords.length}`);

        this.apiCallCompletedFlag = true;
        if (apiRecords.length > 0) {
          this.apiResultsFlag = true;
          apiRecords[0].formatted_birthdate = Date.parse(
            apiRecords[0].birthdate
          );
          this.apiRecord = apiRecords[0];
        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log(
          `CIS2RecordPageWidget.getCIS2RecordByCase Failed: ${error}`
        );
      });
  }

  handleFormEditClick() {
    this.editFormFlag = true;
  }

  handleFormCancelClick() {
    this.editFormFlag = false;
  }

  handleFormSaveClick() {
    this.editFormFlag = false;
    console.log(`running handleFormSaveClick`);

    let newCountryOfOrigin = this.template.querySelector(
      '[data-id="fieldCountryOfOrigin"]'
    ).value;
    let newFirstName = this.template.querySelector('[data-id="fieldName"]')
      .firstName;
    let newLastName = this.template.querySelector('[data-id="fieldName"]')
      .lastName;
    let newPortOfEntry = this.template.querySelector(
      '[data-id="fieldPortOfEntry"]'
    ).value;

    console.log(`New Country of Origin: ${newCountryOfOrigin}`);
    console.log(`New First Name: ${newFirstName}`);
    console.log(`New Last Name: ${newLastName}`);
    console.log(`New Port of Entry: ${newPortOfEntry}`);

    //let endPoint = "http://uscis-api-v2.us-e2.cloudhub.io/api/cis2/100114778";

    getCIS2Put({
      anumber: this.apiRecord.a_number,
      firstName: newFirstName,
      lastName: newLastName,
      countryofOrigin: newCountryOfOrigin,
      portOfEntry: newPortOfEntry
    })
      .then((data) => {
        console.log(
          `CIS2RecordPageWidget.getCIS2Put Completed Successfully: ${data}`
        );

        this.error = undefined;

        let newAPIRecord = this.apiRecord;
        newAPIRecord.first_name = newFirstName;
        newAPIRecord.last_name = newLastName;
        newAPIRecord.country_of_origin = newCountryOfOrigin;
        newAPIRecord.port_of_entry = newPortOfEntry;

        this.apiRecord = newAPIRecord;

        this.dispatchEvent(
          new ShowToastEvent({
            title: `CIS2 Record Updated!`,
            message: `We have updated the record`,
            variant: "success"
          })
        );
      })
      .catch((error) => {
        this.error = error;
        console.log(`CIS2RecordPageWidget.getCIS2Put Failed: ${error}`);
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
