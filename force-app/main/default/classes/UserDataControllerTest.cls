@isTest
public class UserDataControllerTest {
    
    @isTest
    static void testInsertRecords() {
        // Configurar el mock de la API
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        String result = UserDataController.insertRecords();
        Test.stopTest();
        
        // Verificar resultados
        System.assertEquals('Registros insertados exitosamente.', result);
        
        List<UserData__c> userDataRecords = [
            SELECT Id, Name, Username__c, Email__c, Street__c, Suite__c, City__c, Zipcode__c, Phone__c 
            FROM UserData__c
        ];
        System.assertEquals(2, userDataRecords.size(), 'Se esperaba que se insertaran 2 registros.');
    }
    
    @isTest
    static void testGetRecords() {
        // Crear registros de prueba
        UserData__c user1 = new UserData__c(
            Name = 'Evan Flores',
        Username__c = 'Flores',
        Email__c = 'evan@example.com',
        Street__c = '123 Test St',
        City__c = 'Test City',
        Zipcode__c = '12345',
        Phone__c = '123-456-7890'
            );
        UserData__c user2 = new UserData__c(
            Name = 'matt flores',
        Username__c = 'Flores',
        Email__c = 'matt@example.com',
        Street__c = '456 Example Rd',
        City__c = 'Example City',
        Zipcode__c = '67890',
        Phone__c = '987-654-3210'
            );
        insert new List<UserData__c>{user1, user2};
        
        // Llamar al método getRecords
        Test.startTest();
        List<UserData__c> records = UserDataController.getRecords();
        Test.stopTest();
        
        // Verificar los resultados
        System.assert(records.size() >= 2, 'Se esperaba obtener al menos 2 registros.');
    }
    
    
    @isTest
    static void testUpsertRecordInsert() {
        // Crear un nuevo registro
        UserData__c newUser = new UserData__c(Name='Test User', Username__c='testuser', Email__c='testuser@example.com', Street__c='123 Test St', City__c='Test City', Zipcode__c='12345', Phone__c='123-456-7890');
        
        Test.startTest();
        UserDataController.upsertRecord(newUser);
        Test.stopTest();
        
        // Verificar que el registro fue insertado
        UserData__c insertedRecord = [SELECT Id, Name FROM UserData__c WHERE Name='Test User' LIMIT 1];
        System.assertNotEquals(null, insertedRecord, 'El registro debería haberse insertado.');
    }
    
    @isTest
    static void testUpsertRecordUpdate() {
        // Crear un registro existente
        UserData__c existingUser = new UserData__c(Name='Update User', Username__c='updateuser', Email__c='updateuser@example.com', Street__c='123 Update St', City__c='Update City', Zipcode__c='12345', Phone__c='123-456-7890');
        insert existingUser;
        
        // Actualizar el registro
        existingUser.Name = 'Updated User';
        
        Test.startTest();
        UserDataController.upsertRecord(existingUser);
        Test.stopTest();
        
        // Verificar que el registro fue actualizado
        UserData__c updatedRecord = [SELECT Id, Name FROM UserData__c WHERE Id = :existingUser.Id];
        System.assertEquals('Updated User', updatedRecord.Name, 'El registro debería haberse actualizado.');
    }
    
    @isTest
    static void testDeleteUser() {
        // Crear un registro para eliminar
        UserData__c userToDelete = new UserData__c(Name='Delete User', Username__c='deleteuser', Email__c='deleteuser@example.com', Street__c='123 Delete St', City__c='Delete City', Zipcode__c='12345', Phone__c='123-456-7890');
        insert userToDelete;
        
        // Eliminar el registro
        Test.startTest();
        UserDataController.deleteUser(userToDelete.Id);
        Test.stopTest();
        
        // Verificar que el registro fue eliminado
        Integer count = [SELECT COUNT() FROM UserData__c WHERE Id = :userToDelete.Id];
        System.assertEquals(0, count, 'El registro debería haberse eliminado.');
    }
    
    @isTest
    static void testInsertRecordsNoPermissions() {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        System.runAs(testUser) {
            try {
                Test.startTest();
                UserDataController.insertRecords();
                Test.stopTest();
                System.assert(false, 'Se esperaba que fallara debido a permisos insuficientes.');
            } catch (AuraHandledException e) {
                System.assertEquals(
                    'El usuario no tiene permisos para crear registros en UserData__c.',
                e.getMessage(),
                'El mensaje de error debe indicar falta de permisos.'
                    );
            }
        }
    }
}