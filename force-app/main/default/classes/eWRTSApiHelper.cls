public with sharing class eWRTSApiHelper {
  public static String baseAPIUrl = 'http://uscis-api-v2.us-e2.cloudhub.io/api/';

  @AuraEnabled
  public static String CIS2SearchByCase(String recordId) {
    List<Case> caseList = [SELECT A_Number__c FROM Case WHERE Id = :recordId];
    System.debug('Running eWRTSApiHelper.CIS2SearchByCase');

    if (caseList.size() > 0) {
      return eWRTSApiHelper.CIS2Search(caseList[0].A_Number__c);
    }

    return eWRTSApiHelper.CIS2Search(null);
  }

  @AuraEnabled
  public static String CIS2Search(String anumber) {
    System.debug('Running eWRTSApiHelper.CIS2Search');

    String url = eWRTSApiHelper.baseAPIUrl + 'cis2';
    System.debug('API URL is: ' + url);

    if ((null != anumber)) {
      url = url + '/' + anumber;
    }
    system.debug('Search URL is ' + url);

    return eWRTSApiHelper.getRequest(url);
  }

  @AuraEnabled
  public static String CIS2Put(
    String anumber,
    String firstName,
    String lastName,
    String countryofOrigin,
    String portOfEntry
  ) {
    System.debug('Running eWRTSApiHelper.CIS2Put');

    String url = eWRTSApiHelper.baseAPIUrl + 'cis2';
    System.debug('API URL is: ' + url);

    if ((null != anumber)) {
      url = url + '/' + anumber;
    }
    system.debug('Search URL is ' + url);

    HttpRequest request = new HttpRequest();

    request.setTimeout(20000);
    request.setHeader('Content-Type', 'application/json');

    request.setEndpoint(url);
    request.setMethod('PUT');

    String jsonBody =
      '{"a_number":"' +
      anumber +
      '", "first_name":"' +
      firstName +
      '", "last_name":"' +
      lastName +
      '", "country_of_origin":"' +
      countryofOrigin +
      '", "port_of_entry":"' +
      portOfEntry +
      '"}';
    System.debug(jsonBody);

    request.setBody(jsonBody);

    try {
      Http http = new Http();
      HttpResponse response = http.send(request);

      if (response.getStatusCode() == 200) {
        // Deserialize the JSON string into collections of primitive data types.
        String responseData = response.getBody();
        system.debug('Data: ' + responseData);
        system.debug('doRestRequestJSON was a Success!');
        return responseData;
      } else {
        system.debug(
          'Request failed. Status Code: ' + response.getStatusCode()
        );
        return null;
      }
    } catch (Exception e) {
      system.debug('Error Running HTTP Request: ' + e);
      throw e;
    }
  }

  @AuraEnabled
  public static String RAILSSearchByCase(String recordId) {
    List<Case> caseList = [SELECT A_Number__c FROM Case WHERE Id = :recordId];
    System.debug('Running eWRTSApiHelper.RAILSSearchByCase');

    if (caseList.size() > 0) {
      return eWRTSApiHelper.RAILSSearch(caseList[0].A_Number__c);
    }

    return eWRTSApiHelper.RAILSSearch(null);
  }

  @AuraEnabled
  public static String RAILSSearch(String anumber) {
    System.debug('Running eWRTSApiHelper.RAILSSearch');

    String url = eWRTSApiHelper.baseAPIUrl + 'rails';
    System.debug('API URL is: ' + url);

    if ((null != anumber)) {
      url = url + '/' + anumber;
    }
    system.debug('Search URL is ' + url);

    return eWRTSApiHelper.getRequest(url);
  }

  public static String getRequest(String url) {
    system.debug('Search URL is ' + url);

    HttpRequest request = new HttpRequest();
    //request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

    request.setTimeout(20000);
    request.setHeader('Content-Type', 'application/json');

    request.setEndpoint(url);
    request.setMethod('GET');

    try {
      Http http = new Http();
      HttpResponse response = http.send(request);

      if (response.getStatusCode() == 200) {
        // Deserialize the JSON string into collections of primitive data types.
        String responseData = response.getBody();
        system.debug('Data: ' + responseData);
        system.debug('doRestRequestJSON was a Success!');
        return responseData;
      } else {
        system.debug(
          'Request failed. Status Code: ' + response.getStatusCode()
        );
        return null;
      }
    } catch (Exception e) {
      system.debug('Error Running HTTP Request: ' + e);
      throw e;
    }
  }
}
