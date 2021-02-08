//  Flow component to assign an entitlement to a case.
//  
//  The code checks to make sure that only one case is entered at a time.  To provide updates to multiple
//  cases, place this component inside a loop in flow builder.
//  
//  Returns a status string of either 'SUCCESS' or 'FAILURE'.  In case of FAILURE, a more detailed message
//  detailing the reason for failure is provided.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com


global without sharing class AssignCaseEntitlement {
    
    private static final String SUCCESS = 'SUCCESS';
    private static final String FAILURE = 'FAILURE';
    
    global class Requests {
        @InvocableVariable(required=true)
        global Id caseId;					// The record ID of the case
        
        @InvocableVariable(required=true)
        global String entitlementName;		// The name of the entitlement to assign
    }
    
    global class Results {
        @InvocableVariable
        global String status;				// Either 'SUCCESS' or 'FAILURE'
        
        @InvocableVariable
        global String message;				// In the case of FAILURE, a more detailed message
    }    
    
    @InvocableMethod(label='Assign Case Entitlement' description='Assigns an entitlement to a given case.')
    
    public static List<Results> assignCaseEntitlement (List<Requests> cases) {
        
        List<Results> resultList = new List<Results>();
        Results result = new Results();
        
        if (cases.size() != 1) {
            result.status = FAILURE;
            result.message = 'You must supply exactly one case to use this action.';
            System.debug(result.message);
        } else {            
            List<Entitlement> entitlementsFound = [SELECT Id FROM Entitlement WHERE Name = :cases[0].entitlementName LIMIT 1];
            if (entitlementsFound.size() != 1) {
                result.status = FAILURE;
                result.message = 'No entitlements named "' + cases[0].entitlementName + '" were found.';
                System.debug(result.message);
            } else {
                List<Case> casesFound = [SELECT EntitlementId FROM Case WHERE Id = :cases[0].caseId LIMIT 1];
                if (casesFound.size() != 1) {
                    result.status = FAILURE;
                    result.message = 'Could not find case with Id = ' + cases[0].caseId;
                    System.debug(result.message);
                } else
                    try {
                        casesFound[0].EntitlementId = entitlementsFound[0].Id;
                        update casesFound[0];
                        result.status = SUCCESS;
                        result.message = '';
                    } catch (DMLException e) {
                        result.status = FAILURE;
                        result.message = 'Could not assign entitlement "' + cases[0].entitlementName + '" (' + entitlementsFound[0].Id + ') to case ' + cases[0].caseId + ': ' + e.getMessage();
                        System.debug(result.message);
                    }
            }
        }
        
        resultList.add(result);
        return resultList;
    }
}