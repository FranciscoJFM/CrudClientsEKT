@RestResource(urlMapping='/UserDataAPI/v1/*')
global with sharing class UserDataAPI {
    
    private static Boolean bypassAccessCheck = false; // Para pruebas
    
    @HttpGet
    global static UserData__c getUserDataById() {
        RestRequest req = RestContext.request;
        String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        if (String.isBlank(recordId)) {
            throw new CustomException('El ID del registro es obligatorio.');
        }
        
        if (!bypassAccessCheck && !Schema.sObjectType.UserData__c.isAccessible()) {
            throw new CustomException('El usuario no tiene permiso para acceder al objeto UserData__c.');
        }
        
        try {
            UserData__c userData = [
                SELECT Id, Name, Username__c, Email__c, Street__c, Suite__c, City__c, Zipcode__c, Phone__c
                FROM UserData__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            validateFieldAccessibility(userData);
            return userData;
        } catch (QueryException e) {
            throw new CustomException('Error al obtener el registro: No se encontró el registro.');
        }
    }
    
    private static void validateFieldAccessibility(UserData__c userData) {
        String[] fieldsToCheck = new String[] { 'Name', 'Username__c', 'Email__c' };
        for (String fieldName : fieldsToCheck) {
            // Obtén el descriptor del campo y verifica el acceso
            Schema.DescribeFieldResult fieldDescribe = Schema.sObjectType.UserData__c.fields.getMap().get(fieldName).getDescribe();
            if (!bypassAccessCheck && !fieldDescribe.isAccessible()) {
                throw new CustomException('El usuario no tiene acceso al campo: ' + fieldName);
            }
        }
    }
    
    public class CustomException extends Exception {}
    
    @TestVisible
    static void setBypassAccessCheck(Boolean value) {
        bypassAccessCheck = value;
    }
}