({
    doInit: function (component, event, helper) {
        console.log("Inicializando componente...");
        helper.fetchRecords(component);
    },
    handleRowSelection: function (component, event, helper) {
        const selectedRows = event.getParam("selectedRows");
        if (selectedRows && selectedRows.length > 0) {
            console.log("Registro seleccionado: ", selectedRows[0]);
            component.set("v.selectedRecord", selectedRows[0]);
            component.set("v.isEditMode", false); 
        } else {
            console.log("No se seleccionó ningún registro.");
            component.set("v.selectedRecord", null);
            component.set("v.isEditMode", false); 
        }
    },    
    handleSuccess: function (component, event, helper) {
        const payload = event.getParam("response");
        console.log("Registro creado/actualizado exitosamente: ", JSON.stringify(payload));
        helper.showToast("Success", "Registro guardado correctamente.");
        helper.fetchRecords(component);
        component.set("v.newUser", { sobjectType: "UserData__c" });
        component.set("v.selectedRecord", null);
        component.set("v.isEditMode", false);
    },
    handleError: function (component, event, helper) {
        const error = event.getParam("error");
        console.error("Error al crear/actualizar el registro: ", JSON.stringify(error));
        helper.showToast("Error", "No se pudo guardar el registro. Revisa los campos obligatorios.");
    },
    clearForm: function (component, event, helper) {
        console.log("Limpiando formulario para nuevo registro...");
        component.set("v.newUser", {
            sobjectType: "UserData__c",
            Name: "",
            Username__c: "",
            Email__c: "",
            Street__c: "",
            Suite__c: "",
            City__c: "",
            Zipcode__c: "",
            Phone__c: ""
        });
        component.set("v.selectedRecord", null);
        component.set("v.isEditMode", false);
    },
    editRecord: function (component, event, helper) {
        const selectedRecord = component.get("v.selectedRecord");
        if (!selectedRecord) {
            helper.showToast("Error", "Por favor selecciona un registro para editar.");
            return;
        }
        console.log("Editando registro: ", selectedRecord);
        component.set("v.newUser", JSON.parse(JSON.stringify(selectedRecord)));
        component.set("v.isEditMode", true);
    },
    deleteRecord: function (component, event, helper) {
        const selectedRecord = component.get("v.selectedRecord");
        if (!selectedRecord) {
            helper.showToast("Error", "Por favor selecciona un registro para eliminar.");
            return;
        }
        console.log("Eliminando registro: ", selectedRecord);
        const action = component.get("c.deleteUser");
        action.setParams({ recordId: selectedRecord.Id });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                helper.showToast("Success", "Registro eliminado correctamente.");
                helper.fetchRecords(component);
                    component.set("v.selectedRecord", null);
                component.set("v.newUser", { sobjectType: "UserData__c" });
                component.set("v.isEditMode", false);
            } else {
                console.error("Error al eliminar el registro: ", response.getError());
                helper.showToast("Error", "No se pudo eliminar el registro.");
            }
        });
        $A.enqueueAction(action);
    }
});
