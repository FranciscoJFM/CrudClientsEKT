@isTest
private class AssignToQueueHandlerTest {
    @isTest
    static void testAssignToQueue() {
        // Crear un grupo de tipo cola
        Group queue = new Group(Name = 'UserData Queue', Type = 'Queue');
        insert queue;

        // Recuperar el ID de la cola
        Group queueInserted = [SELECT Id FROM Group WHERE Name = 'UserData Queue' LIMIT 1];

        // Crear un registro de prueba
        UserData__c testUser = new UserData__c(
            Name = 'Test User',
            Username__c = 'testuser',
            Email__c = 'testuser@example.com'
        );

        // Llamar a la lógica de asignación
        Test.startTest();
        AssignToQueueHandler.assignToQueue(new List<UserData__c>{testUser});
        insert testUser;
        Test.stopTest();

        // Verificar que el OwnerId sea el de la cola
        UserData__c insertedUser = [SELECT OwnerId FROM UserData__c WHERE Id = :testUser.Id];
        System.assertEquals(queueInserted.Id, insertedUser.OwnerId, 'El OwnerId debería ser el ID de la cola.');
    }
}
