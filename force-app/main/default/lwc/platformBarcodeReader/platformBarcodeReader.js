import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaseId from "@salesforce/apex/barcodeReaderHelper.getCaseId";
import eWRTSUtils from "c/eWRTSUtils";

export default class PlatformBarcodeReader extends NavigationMixin(LightningElement){

    handleInputChange() {
        var inputCmp = this.template.querySelector(".inputCmp");
        var value = inputCmp.value;
        if (value.length == 9){
            console.log(`Reached 9 Digits, Attempting to find Case with A Number ${value}.`);


            getCaseId({aNumber: value})
            .then((data) => {
                console.log(`barcodeReaderHelper.getCaseId Completed Successfully. Data: ${data}`);
                this.error = undefined;

                if(null !== data){
                    let caseId = data;

                    eWRTSUtils.showToast(
                        this,
                        `Success!`,
                        `We are assigning the case to you and opening it for you.`,
                        "success"
                      );

                    this.template.querySelector(".inputCmp").value = '';

                    console.log(`Opening Case Page ${caseId}`);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: caseId,
                            objectApiName: 'Case',
                            actionName: 'view',
                        },
                    });


                }


            })
            .catch((error) => {
            this.error = error;
            });


        }
    }
}