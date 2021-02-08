//  Flow component to complete a given case milestone.
//  
//  The code checks to make sure that only one case is entered at a time.  To provide updates to multiple
//  cases, place this component inside a loop in flow builder.
//  
//  Returns a status string of either 'SUCCESS' or 'FAILURE'.  In case of FAILURE, a more detailed message
//  detailing the reason for failure is provided.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com


global without sharing class CompleteCaseMilestone {
    
    private static final String SUCCESS = 'SUCCESS';
    private static final String FAILURE = 'FAILURE';
    
    global class Requests {
        @InvocableVariable(required=true)
        global Id caseId;					// The record ID of the case
        
        @InvocableVariable(required=true)
        global String milestoneName;		// The name of the milestone to complete
    }
    
    global class Results {
        @InvocableVariable
        global String status;				// Either 'SUCCESS' or 'FAILURE'
        
        @InvocableVariable
        global String message;				// In the case of FAILURE, a more detailed message
    }
        
    @InvocableMethod(label='Complete Case Milestone' description='Completes the given milestone on a supplied case record.')
    
    public static List<Results> completeCaseMilestone (List<Requests> cases) {
        
        List<Results> resultList = new List<Results>();
        Results result = new Results();
        
        if (cases.size() != 1) {
            result.status = FAILURE;
            result.message = 'You must supply exactly one case to use this action.';
            System.debug(result.message);
        } else {          
            List<CaseMilestone> milestonesFound =
                [SELECT completionDate FROM	CaseMilestone
                 WHERE	caseId = :cases[0].caseId AND MilestoneType.Name = :cases[0].milestoneName AND completionDate = null
                 LIMIT 	1];
            if (milestonesFound.size() != 1) {
                result.status = FAILURE;
                result.message = 'No uncompleted milestones named "' + cases[0].milestoneName + '" were found on case ' + cases[0].caseId;
                System.debug(result.message);
            } else
                try {
                    milestonesFound[0].completionDate = DateTime.now();
                    update milestonesFound[0];
                    result.status = SUCCESS;
                    result.message = '';
                } catch (DMLException e) {
                    result.status = FAILURE;
                    result.message = 'Could not update milestone "' + cases[0].milestoneName + '" on case ' + cases[0].caseId + ': ' + e.getMessage();
                    System.debug(result.message);
                }            
        }
        
        resultList.add(result);
        return resultList;
    }
}