@isTest
public class AssignToQueueTest {
    @isTest
    static void testAssignToQueue() {
        // Crear una cola para las pruebas
        Group queue = new Group();
        queue.Name = 'UserData Queue';
        queue.Type = 'Queue';
        insert queue;

        // Recuperar el ID de la cola creada
        Group insertedQueue = [SELECT Id FROM Group WHERE Name = 'UserData Queue' LIMIT 1];

        // Crear un registro de UserData__c
        UserData__c userData = new UserData__c(
            Name = 'John Doe',
            Username__c = 'johndoe',
            Email__c = 'johndoe@example.com',
            Street__c = '123 Main St',
            Suite__c = 'Apt 4',
            City__c = 'Springfield',
            Zipcode__c = '12345',
            Phone__c = '555-555-5555'
        );

        Test.startTest();
        insert userData; // Disparar el trigger
        Test.stopTest();

        // Verificar que el registro fue asignado a la cola
        UserData__c insertedUserData = [SELECT Id, OwnerId FROM UserData__c WHERE Id = :userData.Id];
        System.assertEquals(insertedQueue.Id, insertedUserData.OwnerId, 'El OwnerId debe ser el ID de la cola.');
    }
}
