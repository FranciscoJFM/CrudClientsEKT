public with sharing class UserDataController {

    public class Address {
        public String street;
        public String suite;
        public String city;
        public String zipcode;
        public Geo geo;
    }
    
    public class Geo {
        public String lat;
        public String lng;
    }
    
    public class UserWrapper {
        public String name;
        public String username;
        public String email;
        public String phone;
        public Address address; 
    }
    
    @AuraEnabled
    public static string insertRecords() {
        try {
            if (!Schema.sObjectType.UserData__c.isCreateable()) {
                throw new AuraHandledException('El usuario no tiene permisos para crear registros en UserData__c.');
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://jsonplaceholder.typicode.com/users');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) {
                throw new AuraHandledException('Error al obtener datos de la API. Código de estado: ' + response.getStatusCode());
            }
            
            List<UserWrapper> users;
            try {
                users = (List<UserWrapper>) JSON.deserialize(response.getBody(), List<UserWrapper>.class);
            } catch (Exception e) {
                throw new AuraHandledException('Error al procesar los datos de la API: ' + e.getMessage());
            }
            
            List<UserData__c> userRecords = new List<UserData__c>();
            for (UserWrapper user : users) {
                if (user.name == null || user.username == null || user.email == null) {
                    System.debug('Registro ignorado debido a campos faltantes: ' + user);
                    continue; 
                }
                
                UserData__c newUser = new UserData__c();
                newUser.Name = user.name;
                newUser.Username__c = user.username;
                newUser.Email__c = user.email;
                newUser.Street__c = user.address != null ? user.address.street : null;
                newUser.Suite__c = user.address != null ? user.address.suite : null;
                newUser.City__c = user.address != null ? user.address.city : null;
                newUser.Zipcode__c = user.address != null ? user.address.zipcode : null;
                
                if (String.isNotBlank(user.phone)) {
                    newUser.Phone__c = user.phone.length() > 15 ? user.phone.substring(0, 15) : user.phone;
                }
                
                userRecords.add(newUser);
            }
            
            if (!userRecords.isEmpty()) {
                insert userRecords;
            }
            
            return 'Registros insertados exitosamente.';
        } catch (AuraHandledException e) {
            throw e; 
        } catch (Exception e) {
            System.debug('Error general: ' + e.getMessage());
            throw new AuraHandledException('Error al insertar registros: ' + e.getMessage());
        }
    }
    
    
    /**
     * Método para insertar o actualizar un registro de UserData__c.
     * @param userRecord Registro del objeto UserData__c a crear o actualizar.
     */
    @AuraEnabled
    public static void upsertRecord(UserData__c userRecord) {
        try {
            if (userRecord == null) {
                System.debug('El registro recibido es nulo.');
                throw new AuraHandledException('El registro proporcionado es nulo.');
            }
            System.debug('Registro recibido: ' + userRecord);
            
            if (!Schema.sObjectType.UserData__c.isCreateable() && String.isBlank(userRecord.Id)) {
                throw new AuraHandledException('El usuario no tiene permiso para crear registros en UserData__c.');
            }
            if (!Schema.sObjectType.UserData__c.isUpdateable() && !String.isBlank(userRecord.Id)) {
                throw new AuraHandledException('El usuario no tiene permiso para actualizar registros en UserData__c.');
            }
            
            upsert userRecord;
            System.debug('Registro guardado correctamente: ' + userRecord);
        } catch (Exception e) {
            System.debug('Error en upsertRecord: ' + e.getMessage());
            throw new AuraHandledException('Error al guardar el registro: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<UserData__c> getRecords() {
        try {
            List<UserData__c> records = [
            SELECT Id, Name, Username__c, Email__c, Street__c, Suite__c, City__c, Zipcode__c, Phone__c 
            FROM UserData__c
        ];
            System.debug('Registros obtenidos: ' + records);
            return records;
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener registros: ' + e.getMessage());
        }
    }
    
    /**
     * Método para eliminar un registro de UserData__c.
     * @param recordId ID del registro a eliminar.
     */
    @AuraEnabled
    public static void deleteUser(Id recordId) {
        if (!Schema.sObjectType.UserData__c.isDeletable()) {
            throw new AuraHandledException('El usuario no tiene permiso para eliminar registros en UserData__c.');
        }
        
        try {
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('El ID del registro no puede estar vacío.');
            }
            UserData__c recordToDelete = [SELECT Id FROM UserData__c WHERE Id = :recordId LIMIT 1];
            delete recordToDelete;
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el registro: ' + e.getMessage());
        }
    }
    
}