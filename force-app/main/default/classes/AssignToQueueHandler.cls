public with sharing class AssignToQueueHandler {
    public static void assignToQueue(List<UserData__c> newRecords) {
        try {
            // Verificar permisos de lectura para el objeto Group
            if (!Schema.sObjectType.Group.isAccessible()) {
                throw new AuraHandledException('El usuario no tiene permisos para acceder al objeto Group.');
            }

            // Recuperar el ID de la cola
            Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'UserData Queue' LIMIT 1];

            // Asignar el OwnerId a cada registro
            for (UserData__c userData : newRecords) {
                userData.OwnerId = queue.Id;
            }
        } catch (Exception e) {
            // Manejo de errores
            for (UserData__c userData : newRecords) {
                userData.addError('Error al asignar el registro a la cola: ' + e.getMessage());
            }
        }
    }
}
