trigger AssignToQueue on UserData__c (before insert) {
    AssignToQueueHandler.assignToQueue(Trigger.new);
}
