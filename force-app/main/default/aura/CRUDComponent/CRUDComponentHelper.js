({
    fetchRecords: function (component) {
        let action = component.get("c.getRecords");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let records = response.getReturnValue();
                console.log('Registros obtenidos:', records);
                component.set("v.records", records);
            } else {
                console.error('Error al obtener registros:', response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function (title, message) {
        $A.get("e.force:showToast").setParams({
            title: title,
            message: message,
            type: title === "Success" ? "success" : "error"
        }).fire();
    }
});
