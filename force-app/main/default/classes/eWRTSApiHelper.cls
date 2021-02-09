public with sharing class eWRTSApiHelper {


    @AuraEnabled
    public static String CIS2Search(String anumber){ 
        System.debug('Running eWRTSApiHelper.CIS2Search');

        String url = 'http://uscis-api.us-e2.cloudhub.io/api/cis2';
        System.debug('API URL is: ' + url);
            
        if((null != anumber)){
            url = url + '/' + anumber;
        }
        system.debug('Search URL is ' + url);

        return eWRTSApiHelper.getRequest(url);
    }

    @AuraEnabled
    public static String RAILSSearch(String anumber){ 
        System.debug('Running eWRTSApiHelper.RAILSSearch');

        String url = 'http://uscis-api.us-e2.cloudhub.io/api/rails';
        System.debug('API URL is: ' + url);
            
        if((null != anumber)){
            url = url + '/' + anumber;
        }
        system.debug('Search URL is ' + url);

        return eWRTSApiHelper.getRequest(url);
    }


    public static String getRequest(String url){ 
        system.debug('Search URL is ' + url);

        HttpRequest request = new HttpRequest();
        //request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            
        request.setTimeout(20000);
        request.setHeader('Content-Type', 'application/json');

        request.setEndpoint(url); 
        request.setMethod('GET');   

        try{

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                String responseData = response.getBody();
                system.debug('Data: '+ responseData);
                system.debug('doRestRequestJSON was a Success!');
                return responseData;
            }else{
                system.debug('Request failed. Status Code: ' + response.getStatusCode());
                return null;
            }

        }catch(Exception e){
            system.debug('Error Running HTTP Request: ' + e);
            throw e;
        }  
    }

}
