List<Account> newList = [SELECT Id from Account where Type = ''];
delete newList;

List<Contact> contactList = [SELECT Id from Contact];
delete contactList;