public with sharing class ewrtsCaseGenerator {

    public static String CBPAccountName = 'US Customs and Border Protection';
    public static String ICEAccountName = 'US Immigration and Customs Enforcement';
    public static String USCISAccountName = 'US Citizenship and Immigration Services';
    public static String StatelocalAccountName = 'State/Local/Other';
    public static Integer minANumber = 100000004;
    public static Integer maxANumber = 100300000;
    public static Date beginningOfCases = date.parse('1/1/2018');

    public static String fileRetrievalStatus1 = 'File Retrieval Queue';
    public static String fileRetrievalStatus2 = 'Case assigned to Contractor';
    public static String fileRetrievalStatus3 = 'File Pulled from Shelf';


    public static String casePriority1 = 'Low';
    public static String casePriority2 = 'Medium';
    public static String casePriority3 = 'High';


    public static String fileProcessingStatus1 = 'File Processing Queue';
    public static String fileProcessingStatus2 = 'File Pulled for Processing';



    public static String NRCQueueFileProcessing = 'eWRTS File Processing Queue';
    public static String NRCQueueTriage = 'eWRTS NRC Triage Queue';   
    public static String NRCQueueNRCContractor = 'eWRTS NRC Contractor Queue';
    public static String NRCQueueES1Contractor = 'eWRTS Lees Summit Contractor Queue';
    public static String NRCQueueES2Contractor = 'eWRTS Lenexa Contractor Queue';
    public static String NRCQueueES3Contractor = 'eWRTS North KC Contractor Queue';
    public static String NRCQueueES4Contractor = 'eWRTS Iron Mountain Contractor Queue';


    public static void createRandomeWRTSCases(Integer numbertoCreate){
        Account CBPAccount;
        Account ICEAccount;
        Account USCISAccount;
        Account StatelocalAccount;
 
        String recordTypeId = [SELECT id FROM RecordType WHERE Name ='eWRTS CASE'].Id;

        Map<String,Id> queueMap = new Map<String, Id>();

        List<User> adminUsers = [SELECT Id, FirstName, LastName, Email, Username, Profile.name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];
        List<User> contractorUsers = [SELECT Id, FirstName, LastName, Email, Username, Profile.name FROM User WHERE IsActive = true AND Profile.Name IN ('eWRTS Contractor', 'Standard User')];

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Handcrafted_for_eWRTS_Demo_Scenario__c = true AND RecordType.DeveloperName = 'eWRTS_Customer_Account'];
       
        //Getting ID's of accounts
        for(Account account: accounts){
            if(account.name == ewrtsCaseGenerator.CBPAccountName){
                CBPAccount = account;
            }else if(account.name == ewrtsCaseGenerator.ICEAccountName){
                ICEAccount = account;
            }else if(account.name == ewrtsCaseGenerator.USCISAccountName){
                USCISAccount = account;
            }else{
                StatelocalAccount = account;
            }       
        }

        List<Contact>  CBPContacts = [SELECT Id, Email, Phone, MobilePhone FROM Contact where Handcrafted_for_eWRTS_Demo_Scenario__c = true AND RecordType.DeveloperName = 'eWRTS_Custom_Contact' AND Account.Name = 'US Customs and Border Protection'];
        List<Contact>  USCISContacts = [SELECT Id, Email, Phone, MobilePhone FROM Contact where Handcrafted_for_eWRTS_Demo_Scenario__c = true AND RecordType.DeveloperName = 'eWRTS_Custom_Contact' AND Account.Name = 'US Immigration and Customs Enforcement'];
        List<Contact>  ICEContacts = [SELECT Id, Email, Phone, MobilePhone FROM Contact where Handcrafted_for_eWRTS_Demo_Scenario__c = true AND RecordType.DeveloperName = 'eWRTS_Custom_Contact' AND Account.Name = 'US Citizenship and Immigration Services'];
        List<Contact>  statelocalContacts = [SELECT Id, Email, Phone, MobilePhone FROM Contact where Handcrafted_for_eWRTS_Demo_Scenario__c = true AND RecordType.DeveloperName = 'eWRTS_Custom_Contact' AND Account.Name = 'State/Local/Other'];
    

        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];

        for (Group queue : queues){
            if(queue.Name == ewrtsCaseGenerator.NRCQueueFileProcessing){
                queueMap.put(ewrtsCaseGenerator.NRCQueueFileProcessing,queue.Id);
            }else if(queue.Name == ewrtsCaseGenerator.NRCQueueTriage){
                queueMap.put(ewrtsCaseGenerator.NRCQueueTriage,queue.Id);        
            }else if(queue.Name == ewrtsCaseGenerator.NRCQueueNRCContractor){
                queueMap.put('NRC',queue.Id);
            }else if(queue.Name == ewrtsCaseGenerator.NRCQueueES1Contractor){
                queueMap.put('ES1',queue.Id);
            }else if(queue.Name == ewrtsCaseGenerator.NRCQueueES2Contractor){
                queueMap.put('ES2',queue.Id);
            }else if(queue.Name == ewrtsCaseGenerator.NRCQueueES3Contractor){
                queueMap.put('ES3',queue.Id);
            }else if(queue.Name == ewrtsCaseGenerator.NRCQueueES4Contractor){
                queueMap.put('ES4',queue.Id);
            }
        }


        List<Case> newCaseList = new List<Case>();
    
        for (Integer i = 0; i < numbertoCreate; i ++) {
            //System.debug('Creating Case #' + i);

            Case newCase = new Case();
            Account thisAccount;
            Contact thisContact;

            DateTime caseDateOpened = ewrtsCaseGenerator.randomDate(ewrtsCaseGenerator.beginningOfCases, Date.Today());
            DateTime caseDateInFileRetrieval = caseDateOpened.addMinutes(ewrtsCaseGenerator.randomNumberInbetween(10, 60));
            DateTime caseDateAssignedtoContractor =  caseDateInFileRetrieval.addMinutes(ewrtsCaseGenerator.randomNumberInbetween(10, 60));
            DateTime caseDateFilePulledfromShelf = caseDateAssignedtoContractor.addMinutes(ewrtsCaseGenerator.randomNumberInbetween(10, 60));
            DateTime caseDateFileDelivered = caseDateFilePulledfromShelf.addMinutes(ewrtsCaseGenerator.randomNumberInbetween(10, 60));
            DateTime caseDateFilePulledforProcessing = caseDateFileDelivered.addMinutes(ewrtsCaseGenerator.randomNumberInbetween(10, 60));
            DateTime caseDateFileProcessed = caseDateFilePulledforProcessing.addMinutes(ewrtsCaseGenerator.randomNumberInbetween(10, 60));
            

            String aNumber = String.ValueOf(ewrtsCaseGenerator.randomNumberInbetween(ewrtsCaseGenerator.minANumber, ewrtsCaseGenerator.maxANumber));
            String randomAccountName = ewrtsCaseGenerator.randomAccount();

            //Get Account
            if(randomAccountName == ewrtsCaseGenerator.CBPAccountName){
                thisAccount = CBPAccount;
            }else if(randomAccountName == ewrtsCaseGenerator.ICEAccountName){
                thisAccount = ICEAccount;
            }else if(randomAccountName == ewrtsCaseGenerator.USCISAccountName){
                thisAccount = USCISAccount;
            }else{
                thisAccount = StatelocalAccount;
            }  

            //Get Random Contact;
            if(randomAccountName == ewrtsCaseGenerator.CBPAccountName){
                thisContact = CBPContacts[ewrtsCaseGenerator.randomNumber(CBPContacts.size())];
            }else if(randomAccountName == ewrtsCaseGenerator.ICEAccountName){
                thisContact = ICEContacts[ewrtsCaseGenerator.randomNumber(ICEContacts.size())];
            }else if(randomAccountName == ewrtsCaseGenerator.USCISAccountName){
                thisContact = USCISContacts[ewrtsCaseGenerator.randomNumber(USCISContacts.size())];
            }else{
                thisContact = StatelocalContacts[ewrtsCaseGenerator.randomNumber(CBPContacts.size())];
            } 
            //TODO: If case is more than 10 days old, make it closed.....


            newCase.Handcrafted_for_eWRTS_Demo_Scenario__c = true;
            newCase.AccountId = thisAccount.Id;
            newCase.ContactId = thisContact.Id;
            newCase.RecordTypeId = recordTypeId;
            newCase.Date_Opened__c = caseDateOpened;
            newCase.Priority = ewrtsCaseGenerator.randomCasePriority();
            newCase.A_Number__C = aNumber;
            newCase.Location_Site__c = ewrtsCaseGenerator.randomSite();
            newCase.Origin = ewrtsCaseGenerator.randomCaseOrigin();
            newCase.Reason = ewrtsCaseGenerator.randomCaseReason();
            newCase.Subject = randomAccountName + ' - ' + newCase.Reason + ' - ' + newCase.A_Number__c;
    
            newCase.Status = ewrtsCaseGenerator.randomCaseStatus();

            //WHAT IS BEING REQUESTED
            newCase.REQ_Entire_File__c = ewrtsCaseGenerator.randomDocumentRequest();
            if(newCase.REQ_Entire_File__c){

                newCase.REQ_Alien_Status__c = true;
                newCase.REQ_All_Applications_and_Petitions__c = true;
                newCase.REQ_All_J_C_Forms__c = true;
                newCase.REQ_All_Removal_Documents__c = true;
                newCase.REQ_Application_Status__c = true;
                newCase.REQ_Biometric_Data__c = true;
                newCase.REQ_Charging_Documents__c = true;
                newCase.REQ_Fingerprints__c = true;
                newCase.REQ_IJO_Form__c = true;
                newCase.REQ_I_130_Form__c = true;
                newCase.REQ_I_213_Form__c = true;
                newCase.REQ_I_485_Form__c = true;     
                newCase.REQ_N_400_600_Forms__c = true;
                newCase.REQ_Photos__c = true;
                newCase.Other_Documents_Requested__c = 'ALL DOCUMENTS!';
            }else{

                newCase.REQ_Alien_Status__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_All_Applications_and_Petitions__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_All_J_C_Forms__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_All_Removal_Documents__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_Application_Status__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_Biometric_Data__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_Charging_Documents__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_Fingerprints__c = ewrtsCaseGenerator.randomDocumentRequest();  
                newCase.REQ_IJO_Form__c = ewrtsCaseGenerator.randomDocumentRequest();         
                newCase.REQ_I_130_Form__c = ewrtsCaseGenerator.randomDocumentRequest();   
                newCase.REQ_I_213_Form__c = ewrtsCaseGenerator.randomDocumentRequest();       
                newCase.REQ_I_485_Form__c = ewrtsCaseGenerator.randomDocumentRequest();          
                newCase.REQ_N_400_600_Forms__c = ewrtsCaseGenerator.randomDocumentRequest();   
                newCase.REQ_Photos__c = ewrtsCaseGenerator.randomDocumentRequest();
                newCase.REQ_Other_Documents__c = ewrtsCaseGenerator.randomDocumentRequest();
    
                if(newCase.REQ_Other_Documents__c){
                    newCase.Other_Documents_Requested__c = 'KQ7060 // CH1148 // DC0676';
                }
            }


            if(newCase.Status == 'New'){
                //We Push phone to File_Retrieval
                if(newCase.Origin == 'Phone'){
                    newCase.Status = 'File_Retrieval';
                    newCase.OwnerId = queueMap.get(newCase.Location_Site__c);
                    newCase.User_Contact_Info_Validated__c = true;
                    newCase.Case_in_File_Retrieval__c = true;

                    newCase.Date_Case_in_File_Retrieval__c = caseDateInFileRetrieval;
                }else{
                    newCase.OwnerId = queueMap.get(ewrtsCaseGenerator.NRCQueueTriage);
                }
            }else if(newCase.Status == 'File_Retrieval'){
                String fileRetrievalStatus = ewrtsCaseGenerator.randomFileRetrievalStatus();
                newCase.User_Contact_Info_Validated__c = true;
                newCase.Case_in_File_Retrieval__c = true;
                newCase.Date_Case_in_File_Retrieval__c = caseDateInFileRetrieval;


                if(fileRetrievalStatus == ewrtsCaseGenerator.fileRetrievalStatus1){
                    //Need to assign to Queue
                    newCase.OwnerId = queueMap.get(newCase.Location_Site__c);
                }
                
                if(fileRetrievalStatus == ewrtsCaseGenerator.fileRetrievalStatus2 || fileRetrievalStatus == ewrtsCaseGenerator.fileRetrievalStatus3){
                    newCase.OwnerId = contractorUsers[ewrtsCaseGenerator.randomNumber(contractorUsers.size())].Id;
                    newCase.Date_Case_Assigned_to_Contractor__c = caseDateAssignedtoContractor;
                    newCase.Case_assigned_to_Contractor__c = true;
                }    

                if(fileRetrievalStatus == ewrtsCaseGenerator.fileRetrievalStatus3){
                    newCase.Date_File_Pulled_from_Shelf__c = caseDateFilePulledfromShelf;
                    newCase.File_Pulled_from_Shelf__c = true;
                }

            }else if(newCase.Status == 'File_Processing'){
                newCase.User_Contact_Info_Validated__c = true;

                newCase.Date_Case_Assigned_to_Contractor__c = caseDateAssignedtoContractor;
                newCase.Case_in_File_Retrieval__c = true;

                newCase.Date_Case_in_File_Retrieval__c = caseDateInFileRetrieval;
                newCase.Case_assigned_to_Contractor__c = true;

                newCase.Date_File_Pulled_from_Shelf__c = caseDateFilePulledfromShelf;
                newCase.File_Pulled_from_Shelf__c = true;
              
                newCase.Date_File_Delivered__c = caseDateFileDelivered;
                newCase.File_Delivered__c = true;               

                String fileProcessingStatus = ewrtsCaseGenerator.randomFileProcessingStatus();

                if(fileProcessingStatus == ewrtsCaseGenerator.fileProcessingStatus1){
                    //Need to assign to Queue
                    newCase.OwnerId = queueMap.get(ewrtsCaseGenerator.NRCQueueFileProcessing);
                }


                if(fileProcessingStatus == ewrtsCaseGenerator.fileProcessingStatus2){
                    newCase.OwnerId = adminUsers[ewrtsCaseGenerator.randomNumber(adminUsers.size())].Id;

                    newCase.Date_File_Pulled_for_Processing__c = caseDateFilePulledforProcessing;
                    newCase.File_Pulled_for_Processing__c = true;
                }

            }else if(newCase.Status == 'Closed'){

                newCase.OwnerId = adminUsers[ewrtsCaseGenerator.randomNumber(adminUsers.size())].Id;

                newCase.User_Contact_Info_Validated__c = true;
                newCase.Date_Case_Assigned_to_Contractor__c = caseDateAssignedtoContractor;
                newCase.Case_in_File_Retrieval__c = true;

                newCase.Date_Case_in_File_Retrieval__c = caseDateInFileRetrieval;
                newCase.Case_assigned_to_Contractor__c = true;

                newCase.Date_File_Pulled_from_Shelf__c = caseDateFilePulledfromShelf;
                newCase.File_Pulled_from_Shelf__c = true;
              
                newCase.Date_File_Delivered__c = caseDateFileDelivered;
                newCase.File_Delivered__c = true;               

                newCase.Date_File_Pulled_for_Processing__c = caseDateFilePulledforProcessing;
                newCase.File_Pulled_for_Processing__c = true;

                newCase.Date_File_Processed__c = caseDateFileProcessed;
                newCase.File_Processed__c = true;
            }
            newCaseList.add(newCase);


            if(newCaseList.size() > 100){
                System.debug('Incremental Insert of newCaseList');
                Insert newCaseList;
                newCaseList = new List<Case>();
            }
        }
        System.debug('Final Insert of newCaseList');
        Insert newCaseList;
    }

    
    public static String randomAccount(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 31){
            return ewrtsCaseGenerator.CBPAccountName;
        }else if(randomNumber > 30 && randomNumber < 61){
            return ewrtsCaseGenerator.ICEAccountName;
        }else if(randomNumber > 60 && randomNumber < 91){
            return ewrtsCaseGenerator.USCISAccountName;
        }else{
            return ewrtsCaseGenerator.StatelocalAccountName;
        }
    }
    
    public static String randomCaseStatus(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 5){
            return 'New';
        }else if(randomNumber > 5 && randomNumber < 13){
            return 'File_Retrieval';
        }else if(randomNumber > 12 && randomNumber < 19){
            return 'File_Processing';
        }else{
            return 'Closed';
        }
    }
    
    public static String randomSite(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 80){
            return 'NRC';
        }else if(randomNumber > 79 && randomNumber < 85){
            return 'ES1';
        }else if(randomNumber > 84 && randomNumber < 90){
            return 'ES2';
        }else if(randomNumber > 89 && randomNumber < 95){
            return 'ES3';
        }else{
            return 'ES4';
        }
    }


    public static String randomCasePriority(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 59){
            return ewrtsCaseGenerator.casePriority1;
        }else if(randomNumber > 60 && randomNumber < 89){
            return ewrtsCaseGenerator.casePriority1;
        }else{
            return ewrtsCaseGenerator.casePriority3;
        }
    }   
    

    public static String randomCaseOrigin(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 59){
            return 'Phone';
        }else if(randomNumber > 60 && randomNumber < 84){
            return 'Email';
        }else{
            return 'Web';
        }
    }

    public static Boolean randomDocumentRequest(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 29){
            return true;
        }else{
            return false;
        }
    }

    public static String randomFileRetrievalStatus(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 29){
            return ewrtsCaseGenerator.fileRetrievalStatus1;
        }else if(randomNumber > 30 && randomNumber < 79){
            return ewrtsCaseGenerator.fileRetrievalStatus2;
        }else{
            return ewrtsCaseGenerator.fileRetrievalStatus3;            
        }
    }

    public static String randomFileProcessingStatus(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 69){
            return ewrtsCaseGenerator.fileProcessingStatus1;
        }
        return ewrtsCaseGenerator.fileProcessingStatus2;
    }


    public static String randomCaseReason(){
        Integer randomNumber = ewrtsCaseGenerator.randomD100Roll();
        if(randomNumber > 0 && randomNumber < 79){
            return 'Normal File Request';
        }else{
            return 'Subject in Custody';
        }
    }

    public static Date randomDate(Date min, Date max) {
        // Convert to DateTime values
        DateTime mint = min, maxt = max.addDays(1);
        // Then convert to milliseconds since Jan 1, 1970, and get difference in ms
        Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
        // Return a date between minms and maxms.
        return DateTime.newInstance(
            minms + Math.mod(Math.abs(Crypto.getRandomLong()), diff)
        ).date();
    }
    

    public static Integer randomD100Roll(){
        Integer randomNumber = Integer.valueof((Math.random() * 100)); 
        return randomNumber;
    }
    
    public static Integer randomD100Roll(Integer Size){
        Integer randomNumber = Integer.valueof((Math.random() * 100)); 
        return randomNumber;
    }

    //method to return random number between 0 and size-1
    public static Integer randomNumber(Integer size){
        Decimal d = math.random() * size;
        return d.intValue();
    }

    public static Integer randomNumberInbetween(integer startNum, integer endNum){
        Integer returnValue;
        //Logic- first we will generate random boolean value which will decide if we want to
        //add the random number from startNum or will subtract random number from endNum
        Integer randomNumber = Integer.valueof((math.random() * 10));
        boolean addSubFlag= math.mod(randomNumber,2) == 0 ? true : false;
        
        integer diffInRange = endNum-startNum;
        //Now find random number staring from 0 to diffInRange
        Integer randomNum = Math.mod(Math.round(Math.random()*diffInRange+1),diffInRange);
        
        //If addSubFlag is true, we will add random number generated between 0 and diffInRange from start number
        //else we will subtract random number from end number
                if(addSubFlag){
            if(diffInRange > 1)
                returnValue =startNum + randomNum;
            else
                returnValue =startNum;
        }else{
            if(diffInRange > 1)
                returnValue = endNum - randomNum;
            else
                returnValue =endNum;
        }
        //System.debug('found random number ' + returnValue + ' between ' + startNum + ' and ' + endNum);
        return returnValue;
    }

}
