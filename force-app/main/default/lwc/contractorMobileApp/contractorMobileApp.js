import { LightningElement, track, wire} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';

import getMyMobileCases from "@salesforce/apex/ContractorMobileAppHelper.getMyMobileCases";
import processScannedFile from "@salesforce/apex/ContractorMobileAppHelper.processScannedFile";

export default class ContractorMobileApp extends LightningElement {
    appVersion = '1.34'; 
    @track apiRecords = [];
    @track apiCallCompletedFlag = false;
    @track apiResultsFlag = false; 
    activeSectionMessage = '';
    treeItems;

    myScanner;
    scanButtonDisabled = false;
    scannedBarcode = '';
    

    activeSections = [];
    activeSectionsMessage = '';



    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
        this.getMyMobileCases();
    }

    getMyMobileCases(){
        getMyMobileCases()
        .then((data) => {
            console.log('wiredgetMyMobileCases SUCCESS');
              console.log(`Data = ${JSON.stringify(data)}`);
      
              this.apiCallCompletedFlag = true;
      
              if(data.length > 0){
                  this.apiResultsFlag = true; 
                  this.apiRecords = data;
                  this.generateTreeItems();
              }    
      
              this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.log(`wiredgetMyMobileCases ERROR = ${JSON.stringify(error)}`);
    
            eWRTSUtils.showToast(
                this,
                `wiredgetMyMobileCases ERROR!`,
                `Error = ${JSON.stringify(error)}`,
                "error"
              );
        });
    }





    handleBeginScanClick(event) {
        // Inform the user we ran into something unexpected
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';

        // Make sure BarcodeScanner is available before trying to use it
        // Note: We _also_ disable the Scan button if there's no BarcodeScanner
        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR, this.myScanner.barcodeTypes.CODE_128]
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
                    console.log('#finally');

                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                });
        } else {
            // BarcodeScanner is not available
            // Not running on hardware with a camera, or some other context issue
            console.log(
                'Scan Barcode button should be disabled and unclickable.'
            );
            console.log('Somehow it got clicked: ');
            console.log(event);

            // Let user know they need to use a mobile phone with a camera
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Barcode Scanner Is Not Available',
                    message:
                        'Try again from the Salesforce app on a mobile device.',
                    variant: 'error'
                })
            );
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

	handleBarCode() {

        console.log(this.scannedBarcode);

        processScannedFile({'aNumber':this.scannedBarcode})
        .then((data) => {
            console.log('processScannedFile SUCCESS');
                console.log(`Data = ${JSON.stringify(data)}`);
        
                switch(data){
                    case 1:
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Case Updated',
                                message: `Completed Milestone "File Pulled from Shelf"`,
                                variant: 'success'
                            })
                        );

                        break;
                    case 2:

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Case Updated',
                                message: `Completed Milestone "File Delivered to Table"`,
                                variant: 'success'
                            })
                        );                        
                        break;
                    case 3:

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'No Action',
                                message: `File already marked as delivered, no action"`,
                                variant: 'info'
                            })
                        );    

                        break;
                    default:

                }
        
                this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.log(`wiredgetMyMobileCases ERROR = ${JSON.stringify(error)}`);
    
            eWRTSUtils.showToast(
                this,
                `wiredgetMyMobileCases ERROR!`,
                `Error = ${JSON.stringify(error)}`,
                "error"
                );
        });



        this.getMyMobileCases();

	}


    generateTreeItems(){
        console.log(`Processing generateTreeItems`);
        let newItems = [];
        let itemCounter = 1;
        console.log(`Found the following apiRecords ${JSON.stringify(this.apiRecords)}`);

        //Getting Rooms
        console.log(`Room Loop`);
        for(let i = 0; i < this.apiRecords.length; i ++){
            let thisApiRecord = this.apiRecords[i];
            console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with Room: ${thisApiRecord.railsRecord.location_room}`);

            if(newItems.length > 0){
                console.log(`New Items is Greater than 0`);
                let noExistingRoom = true;
                for(let j = 0; j < newItems.length; j ++){
                    if (thisApiRecord.railsRecord.location_room === newItems[j].label){
                        noExistingRoom = false;
                    }
                }   
                
                if (noExistingRoom){
                    let newItem = {};
                    newItem.label = thisApiRecord.railsRecord.location_room;
                    newItem.name = itemCounter;
                    newItem.expanded = false;
                    newItem.items = [];
                    itemCounter ++;
                    console.log(`Adding NewItem (Room): ${JSON.stringify(newItem)}`);
                    newItems.push(newItem);
                }
            }else{
                console.log(`New Items is not greater than 0..adding first Room`);    
                let newItem = {};
                newItem.label = thisApiRecord.railsRecord.location_room;
                newItem.name = itemCounter;
                newItem.expanded = true;
                newItem.items = [];
                itemCounter ++;
                console.log(`Adding NewItem (Room): ${JSON.stringify(newItem)}`);
                newItems.push(newItem);
            }
        }


        //Getting Racks
        console.log(`Shelf Loop`);
        for(let i = 0; i < this.apiRecords.length; i ++){
            let thisApiRecord = this.apiRecords[i];
            console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with Room: ${thisApiRecord.railsRecord.location_room}`);

            for(let j = 0;j < newItems.length; j ++){
                if(newItems[j].label == thisApiRecord.railsRecord.location_room){

                    if(newItems[j].items.length > 0){
                        for(let k = 0;k < newItems.length; k ++){
                            let noExistingShelf = true;

                            for(let l = 0; l < newItems[j].items.length; l ++){
                                if (`Shelf: ${thisApiRecord.railsRecord.location_shelf}` === newItems[j].items[l].label){
                                    noExistingShelf = false;
                                }
                            }   
                            
                            if (noExistingShelf){
                                let newItem = {};
                                newItem.label = `Shelf: ${thisApiRecord.railsRecord.location_shelf}`;
                                newItem.name = itemCounter;
                                newItem.expanded = false;
                                newItem.items = [];
                                itemCounter ++;
                                console.log(`Adding NewItem.item (Rack): ${JSON.stringify(newItem)}`);
                                newItems[j].items.push(newItem);
                            }
                        }   
                    }else{
                        console.log(`NewItems.items is not greater than 0..adding first Shelf`);    
                        let newItem = {};
                        newItem.label = `Shelf: ${thisApiRecord.railsRecord.location_shelf}`;
                        newItem.name = itemCounter;
                        newItem.expanded = false;
                        newItem.items = [];
                        itemCounter ++;
                        console.log(`Adding NewItem.item (Rack): ${JSON.stringify(newItem)}`);
                        newItems[j].items.push(newItem);
                    }
                }

            }

        }

        //TO DO Organize Shelfs to be numeric



        //Placing A Files
        console.log(`A File Loop`);
        for(let i = 0; i < this.apiRecords.length; i ++){
            let thisApiRecord = this.apiRecords[i];
            console.log(`Looping through apiRecord: ${JSON.stringify(thisApiRecord)} | with AFile: ${thisApiRecord.railsRecord.file_number}`);
            for(let j = 0;j < newItems.length; j ++){
                if(newItems[j].label == thisApiRecord.railsRecord.location_room){
                    for(let k = 0;k < newItems[j].items.length; k ++){
                        if (`Shelf: ${thisApiRecord.railsRecord.location_shelf}` === newItems[j].items[k].label){
                            console.log(`Adding AFile`);    
                            let newItem = {};
                            newItem.label = `File: ${thisApiRecord.railsRecord.file_number}`;
                            newItem.name = itemCounter;
                            newItem.expanded = false;
                                if(thisApiRecord.caseRecord.File_Pulled_from_Shelf__c){
                                    newItem.metatext = 'Pulled!';
                                }
                            newItem.items = [];
                            itemCounter ++;
                            console.log(`Adding NewItem.item (Rack): ${JSON.stringify(newItem)}`);
                            newItems[j].items[k].items.push(newItem);     
                        }             
                    } 
                }
            }
        }




        console.log(`newItems: ${newItems}`);
        this.treeItems = newItems;
    }


    get caseCountText(){
        let pulledCount = 0;
        for(let i = 0; i < this.apiRecords.length; i ++){
            if(this.apiRecords[i].caseRecord.File_Pulled_from_Shelf__c){
                pulledCount++;
            }
        }

        return `${pulledCount}/${this.apiRecords.length} Pulled`;
    }



    clickEventFilePullButton(event){
        event.target.variant = 'brand';
        let fileDeliverButton = this.template.querySelector(".file-deliver-button");
        fileDeliverButton.variant = 'neutral';
        let fileReturnButton = this.template.querySelector(".file-return-button");
        fileReturnButton.variant = 'neutral';
    }

    clickEventFileDeliverButton(event){
        event.target.variant = 'brand';
        let filePullButton = this.template.querySelector(".file-pull-button");
        filePullButton.variant = 'neutral';
        let fileReturnButton = this.template.querySelector(".file-return-button");
        fileReturnButton.variant = 'neutral';
    }    

    clickEventFileReturnButton(event){
        event.target.variant = 'brand';
        let fileDeliverButton = this.template.querySelector(".file-deliver-button");
        fileDeliverButton.variant = 'neutral';
        let filePullButton = this.template.querySelector(".file-pull-button");
        fileDeliverButton.variant = 'neutral';
    }    

}