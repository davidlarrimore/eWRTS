import { LightningElement, track } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getBarcodeScanner } from "lightning/mobileCapabilities";

import getMyMobilePullCases from "@salesforce/apex/ContractorMobileAppHelper.getMyMobilePullCases";
import getMyMobileDeliverCases from "@salesforce/apex/ContractorMobileAppHelper.getMyMobileDeliveryCases";
import processScannedFile from "@salesforce/apex/ContractorMobileAppHelper.processScannedFile";

export default class ContractorMobileApp extends LightningElement {
  appVersion = "1.47";
  @track apiCallCompletedFlag = false;

  @track pullApiResultsFlag = false;
  @track deliverApiResultsFlag = false;

  activeSectionMessage = "";
  @track pullCases = [];
  @track pullCasesTree = [];
  @track deliverCases = [];
  @track deliverCasesTree = [];
  @track appModePullFlag = true;
  @track appModeDeliverFlag = false;
  @track appModeReturnFlag = false;

  myScanner;
  scanButtonDisabled = false;
  scannedBarcode = "";

  activeSections = [];
  activeSectionsMessage = "";

  connectedCallback() {
    this.myScanner = getBarcodeScanner();
    if (this.myScanner == null || !this.myScanner.isAvailable()) {
      this.scanButtonDisabled = true;
    }
    this.getCaseData();
  }

  getCaseData() {
    this.apiCallCompletedFlag = false;
    getMyMobilePullCases()
      .then((data) => {
        console.log("getMyMobilePullCases SUCCESS");
        console.log(`Data = ${JSON.stringify(data)}`);
        this.apiCallCompletedFlag = true;

        if (data.length > 0) {
          this.pullApiResultsFlag = true;
          this.pullCases = data;
          this.pullCasesTree = this.generatePullTreeItems(this.pullCases);
        }

        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log(`getMyMobilePullCases ERROR = ${JSON.stringify(error)}`);

        this.dispatchEvent(
          new ShowToastEvent({
            title: `getMyMobilePullCases ERROR!`,
            message: `Error = ${JSON.stringify(error)}`,
            variant: "error"
          })
        );
      });

    getMyMobileDeliverCases()
      .then((data) => {
        console.log("getMyMobileDeliverCases SUCCESS");
        console.log(`Data = ${JSON.stringify(data)}`);
        this.apiCallCompletedFlag = true;

        if (data.length > 0) {
          this.deliverApiResultsFlag = true;
          this.deliverCases = data;
          this.deliverCasesTree = this.generateDeliverTreeItems(
            this.deliverCases
          );
        }

        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log(`getMyMobileDeliverCases ERROR = ${JSON.stringify(error)}`);

        this.dispatchEvent(
          new ShowToastEvent({
            title: `getMyMobileDeliverCases ERROR!`,
            message: `Error = ${JSON.stringify(error)}`,
            variant: "error"
          })
        );
      });
  }

  handleBeginScanClick(event) {
    // Inform the user we ran into something unexpected
    // Reset scannedBarcode to empty string before starting new scan
    this.scannedBarcode = "";

    // Make sure BarcodeScanner is available before trying to use it
    // Note: We _also_ disable the Scan button if there's no BarcodeScanner
    if (this.myScanner != null && this.myScanner.isAvailable()) {
      const scanningOptions = {
        barcodeTypes: [
          this.myScanner.barcodeTypes.QR,
          this.myScanner.barcodeTypes.CODE_128
        ]
      };
      this.myScanner
        .beginCapture(scanningOptions)
        .then((result) => {
          console.log(result);

          // Do something with the barcode scan value:
          // - look up a record
          // - create or update a record
          // - parse data and put values into a form
          // - and so on; this is YOUR code
          // Here, we just display the scanned value in the UI
          this.scannedBarcode = result.value;
          this.handleBarCode();
        })
        .catch((error) => {
          // Handle cancellation and unexpected errors here
          console.error(error);
        })
        .finally(() => {
          console.log("#finally");

          // Clean up by ending capture,
          // whether we completed successfully or had an error
          this.myScanner.endCapture();
          this.getCaseData();
        });
    } else {
      // BarcodeScanner is not available
      // Not running on hardware with a camera, or some other context issue
      console.log("Scan Barcode button should be disabled and unclickable.");
      console.log("Somehow it got clicked: ");
      console.log(event);

      // Let user know they need to use a mobile phone with a camera
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Barcode Scanner Is Not Available",
          message: "Try again from the Salesforce app on a mobile device.",
          variant: "error"
        })
      );
    }
  }

  handleBarCode() {
    console.log(this.scannedBarcode);
    let appMode = "";

    if (this.appModePullFlag) {
      appMode = "Pull";
    } else if (this.appModeDeliverFlag) {
      appMode = "Deliver";
    } else if (this.appModeReturnFlag) {
      appMode = "Return";
    } else {
      appMode = "Pull";
    }

    processScannedFile({ aNumber: this.scannedBarcode, appMode: appMode })
      .then((data) => {
        console.log("processScannedFile SUCCESS");
        console.log(`Data = ${JSON.stringify(data)}`);

        switch (data) {
          case 1:
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Case Updated",
                message: `Completed Milestone "File Pulled from Shelf"`,
                variant: "success"
              })
            );

            break;
          case 2:
            this.dispatchEvent(
              new ShowToastEvent({
                title: "No Action",
                message: `File has already been marked as pulled`,
                variant: "info"
              })
            );
            break;
          case 3:
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Case Updated",
                message: `Completed Milestone "File Delivered to Table"`,
                variant: "success"
              })
            );
            break;
          case 4:
            this.dispatchEvent(
              new ShowToastEvent({
                title: "No Action",
                message: `File already marked as delivered, no action"`,
                variant: "info"
              })
            );

            break;
          case 5:
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Step Missed",
                message: `File was not previously marked pulled, updating..."`,
                variant: "warning"
              })
            );

            break;
          default:
            this.dispatchEvent(
              new ShowToastEvent({
                title: "No Action",
                message: `Could not find an active case for this file"`,
                variant: "info"
              })
            );

            break;
        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log(`processScannedFile ERROR = ${JSON.stringify(error)}`);

        this.dispatchEvent(
          new ShowToastEvent({
            title: "processScannedFile Error",
            message: `${JSON.stringify(error)}`,
            variant: "error"
          })
        );
      });

    this.getMyMobileCases();
  }

  generatePullTreeItems(recordsToProcess) {
    console.log(`Processing generatePullTreeItems`);
    let newItems = [];
    let itemCounter = 1;
    //console.log(`Found the following apiRecords ${JSON.stringify(recordsToProcess)}`);

    //Getting Rooms
    console.log(`Room Loop`);
    for (let i = 0; i < recordsToProcess.length; i++) {
      let thisApiRecord = recordsToProcess[i];
      //console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with Room: ${thisApiRecord.railsRecord.location_room}`);

      if (newItems.length > 0) {
        console.log(`New Items is Greater than 0`);
        let noExistingRoom = true;
        for (let j = 0; j < newItems.length; j++) {
          if (thisApiRecord.railsRecord.location_room === newItems[j].label) {
            noExistingRoom = false;
          }
        }

        if (noExistingRoom) {
          let newItem = {};
          newItem.label = thisApiRecord.railsRecord.location_room;
          newItem.name = itemCounter;
          newItem.expanded = false;
          newItem.items = [];
          itemCounter++;
          console.log(`Adding NewItem (Room): ${JSON.stringify(newItem)}`);
          newItems.push(newItem);
        }
      } else {
        console.log(`New Items is not greater than 0..adding first Room`);
        let newItem = {};
        newItem.label = thisApiRecord.railsRecord.location_room;
        newItem.name = itemCounter;
        newItem.expanded = true;
        newItem.items = [];
        itemCounter++;
        console.log(`Adding NewItem (Room): ${JSON.stringify(newItem)}`);
        newItems.push(newItem);
      }
    }

    //Getting Racks
    console.log(`Shelf Loop`);
    for (let i = 0; i < recordsToProcess.length; i++) {
      let thisApiRecord = recordsToProcess[i];
      //console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with Room: ${thisApiRecord.railsRecord.location_room}`);

      for (let j = 0; j < newItems.length; j++) {
        if (newItems[j].label === thisApiRecord.railsRecord.location_room) {
          if (newItems[j].items.length > 0) {
            for (let k = 0; k < newItems.length; k++) {
              let noExistingShelf = true;

              for (let l = 0; l < newItems[j].items.length; l++) {
                if (
                  `Shelf: ${thisApiRecord.railsRecord.location_shelf}` ===
                  newItems[j].items[l].label
                ) {
                  noExistingShelf = false;
                }
              }

              if (noExistingShelf) {
                let newItem = {};
                newItem.label = `Shelf: ${thisApiRecord.railsRecord.location_shelf}`;
                newItem.name = itemCounter;
                newItem.expanded = false;
                newItem.items = [];
                itemCounter++;
                console.log(
                  `Adding NewItem.item (Rack): ${JSON.stringify(newItem)}`
                );
                newItems[j].items.push(newItem);
              }
            }
          } else {
            console.log(
              `NewItems.items is not greater than 0..adding first Shelf`
            );
            let newItem = {};
            newItem.label = `Shelf: ${thisApiRecord.railsRecord.location_shelf}`;
            newItem.name = itemCounter;
            newItem.expanded = false;
            newItem.items = [];
            itemCounter++;
            console.log(
              `Adding NewItem.item (Rack): ${JSON.stringify(newItem)}`
            );
            newItems[j].items.push(newItem);
          }
        }
      }
    }

    //Placing A Files
    console.log(`A File Loop`);
    for (let i = 0; i < recordsToProcess.length; i++) {
      let thisApiRecord = recordsToProcess[i];
      //console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with AFile: ${thisApiRecord.railsRecord.file_number}`);
      for (let j = 0; j < newItems.length; j++) {
        if (newItems[j].label === thisApiRecord.railsRecord.location_room) {
          for (let k = 0; k < newItems[j].items.length; k++) {
            if (
              `Shelf: ${thisApiRecord.railsRecord.location_shelf}` ===
              newItems[j].items[k].label
            ) {
              console.log(`Adding AFile`);
              let newItem = {};
              newItem.label = `File: ${thisApiRecord.railsRecord.file_number}`;
              newItem.name = itemCounter;
              newItem.expanded = false;
              newItem.items = [];
              itemCounter++;
              console.log(
                `Adding NewItem.item (File): ${JSON.stringify(newItem)}`
              );
              newItems[j].items[k].items.push(newItem);
            }
          }
        }
      }
    }

    console.log(`newPullItems: ${JSON.stringify(newItems)}`);
    return newItems;
  }

  generateDeliverTreeItems(recordsToProcess) {
    console.log(`Processing generateDeliverTreeItems`);
    let newItems = [];
    let itemCounter = 1;
    //console.log(`Found the following apiRecords ${JSON.stringify(recordsToProcess)}`);

    //Getting Rooms
    console.log(`Defaulting RPC to IL0300`);
    //Default RPC to IL0300
    for (let i = 0; i < recordsToProcess.length; i++) {
      recordsToProcess[i].railsRecord.rpc = "IL0300";
    }

    console.log(`RPC Loop`);
    for (let i = 0; i < recordsToProcess.length; i++) {
      let thisApiRecord = recordsToProcess[i];
      //console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with Room: ${thisApiRecord.railsRecord.location_room}`);

      if (newItems.length > 0) {
        console.log(`New Items is Greater than 0`);
        let noExistingRoom = true;
        for (let j = 0; j < newItems.length; j++) {
          if (`Table: ${thisApiRecord.railsRecord.rpc}` === newItems[j].label) {
            console.log(
              `${thisApiRecord.railsRecord.rpc} matches loop, no new RPC needs to be created`
            );
            noExistingRoom = false;
          }
        }
        if (noExistingRoom) {
          let newItem = {};
          newItem.label = `Table: ${thisApiRecord.railsRecord.rpc}`;
          newItem.name = itemCounter;
          newItem.expanded = false;
          newItem.items = [];
          itemCounter++;
          console.log(`Adding NewItem (RPC): ${JSON.stringify(newItem)}`);
          newItems.push(newItem);
        }
      } else {
        console.log(`New Items is not greater than 0..adding first RPC`);
        let newItem = {};
        newItem.label = `Table: ${thisApiRecord.railsRecord.rpc}`;
        newItem.name = itemCounter;
        newItem.expanded = true;
        newItem.items = [];
        itemCounter++;
        console.log(`Adding NewItem (RPC): ${JSON.stringify(newItem)}`);
        newItems.push(newItem);
      }
    }

    //Placing A Files
    console.log(`A File Loop`);
    for (let i = 0; i < recordsToProcess.length; i++) {
      let thisApiRecord = recordsToProcess[i];
      //console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with AFile: ${thisApiRecord.railsRecord.file_number}`);
      for (let j = 0; j < newItems.length; j++) {
        if (`Table: ${thisApiRecord.railsRecord.rpc}` === newItems[j].label) {
          console.log(`Adding AFile`);
          let newItem = {};
          newItem.label = `File: ${thisApiRecord.railsRecord.file_number}`;
          newItem.name = itemCounter;
          newItem.expanded = false;
          newItem.items = [];
          itemCounter++;
          console.log(`Adding NewItem.item (File): ${JSON.stringify(newItem)}`);
          newItems[j].items.push(newItem);
        }
      }
    }

    console.log(`newDeliverItems: ${JSON.stringify(newItems)}`);
    return newItems;
  }

  get pullCaseCountText() {
    return `${this.deliverCases.length}/${
      this.deliverCases.length + this.pullCases.length
    } Pulled`;
  }

  get deliverCaseCountText() {
    return `${this.deliverCases.length} Left to Deliver`;
  }

  clickEventFilePullButton(event) {
    event.target.variant = "brand";
    let fileDeliverButton = this.template.querySelector(".file-deliver-button");
    fileDeliverButton.variant = "neutral";
    let fileReturnButton = this.template.querySelector(".file-return-button");
    fileReturnButton.variant = "neutral";

    this.appModePullFlag = true;
    this.appModeDeliverFlag = false;
    this.appModeReturnFlag = false;
  }

  clickEventFileDeliverButton(event) {
    event.target.variant = "brand";
    let filePullButton = this.template.querySelector(".file-pull-button");
    filePullButton.variant = "neutral";
    let fileReturnButton = this.template.querySelector(".file-return-button");
    fileReturnButton.variant = "neutral";

    this.appModePullFlag = false;
    this.appModeDeliverFlag = true;
    this.appModeReturnFlag = false;
  }

  clickEventFileReturnButton(event) {
    event.target.variant = "brand";
    let fileDeliverButton = this.template.querySelector(".file-deliver-button");
    fileDeliverButton.variant = "neutral";
    let filePullButton = this.template.querySelector(".file-pull-button");
    filePullButton.variant = "neutral";

    this.appModePullFlag = false;
    this.appModeDeliverFlag = false;
    this.appModeReturnFlag = true;
  }
}
