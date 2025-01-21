@isTest
private class UserDataAPITest {
    
    @isTest
    static void testGetUserDataById_noAccess() {
        UserData__c testUser = new UserData__c(
            Name = 'Test User',
        Username__c = 'testuser',
        Email__c = 'testuser@example.com',
        Street__c = '123 Test St',
        Suite__c = 'Suite 100',
        City__c = 'Test City',
        Zipcode__c = '12345',
        Phone__c = '123-456-7890'
            );
        insert testUser;
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserDataAPI/v1/' + testUser.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        UserDataAPI.setBypassAccessCheck(false);
        
        Test.startTest();
        try {
            UserDataAPI.getUserDataById();
            System.assert(false, 'Se esperaba una excepción por falta de acceso.');
        } catch (UserDataAPI.CustomException e) {
            System.assertEquals(
                'El usuario no tiene permiso para acceder al objeto UserData__c.',
            e.getMessage(),
            'El mensaje de error debe indicar falta de permisos.'
                );
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserDataById_recordNotFound() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserDataAPI/v1/NonExistentId';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        UserDataAPI.setBypassAccessCheck(false);
        
        Test.startTest();
        try {
            UserDataAPI.getUserDataById();
            System.assert(false, 'Se esperaba una excepción para registro inexistente.');
        } catch (UserDataAPI.CustomException e) {
            System.assertEquals(
                'Error al obtener el registro: No se encontró el registro.',
            e.getMessage(),
            'El mensaje de error debe indicar que el registro no se encontró.'
                );
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserDataById_accessGranted() {
        UserData__c testUser = new UserData__c(
            Name = 'Test User',
        Username__c = 'testuser',
        Email__c = 'testuser@example.com',
        Street__c = '123 Test St',
        Suite__c = 'Suite 100',
        City__c = 'Test City',
        Zipcode__c = '12345',
        Phone__c = '123-456-7890'
            );
        insert testUser;
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserDataAPI/v1/' + testUser.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        UserDataAPI.setBypassAccessCheck(true);
        
        Test.startTest();
        UserData__c userData = UserDataAPI.getUserDataById();
        Test.stopTest();
        
        System.assertNotEquals(null, userData, 'Se esperaba que el registro fuera retornado correctamente.');
        System.assertEquals('Test User', userData.Name, 'El nombre del usuario debe coincidir.');
    }
    
    @isTest
    static void testGetUserDataById_fieldAccessDenied() {
        UserData__c testUser = new UserData__c(
            Name = 'Test User',
        Username__c = 'testuser',
        Email__c = 'testuser@example.com',
        Street__c = '123 Test St',
        Suite__c = 'Suite 100',
        City__c = 'Test City',
        Zipcode__c = '12345',
        Phone__c = '123-456-7890'
            );
        insert testUser;
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserDataAPI/v1/' + testUser.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        UserDataAPI.setBypassAccessCheck(false);
        
        Test.startTest();
        try {
            UserDataAPI.getUserDataById();
            System.assert(false, 'Se esperaba una excepción por falta de acceso a campos.');
        } catch (UserDataAPI.CustomException e) {
            System.assert(e.getMessage().contains('El usuario no tiene acceso al campo:'),
            'El mensaje de error debe indicar que un campo específico no es accesible.');
        }
        Test.stopTest();
    }
}