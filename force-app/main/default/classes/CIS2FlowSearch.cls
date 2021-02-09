public with sharing class CIS2FlowSearch {

    @InvocableMethod
    public static List<String> search(List<String> anumber) {
        System.debug('Running CIS2FlowSearch.search');

        String url = 'http://uscis-api.us-e2.cloudhub.io/api/cis2';
        System.debug('API URL is: ' + url);
            
        if((anumber.size() > 0)){
            url = url + '/' + anumber[0];
        }
        system.debug('Search URL is ' + url);

        List<String> results = new List<String>{eWRTSApiHelper.getRequest(url)};
        return results;
    }

}
