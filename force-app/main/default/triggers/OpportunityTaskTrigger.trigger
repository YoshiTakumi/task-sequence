trigger OpportunityTaskTrigger on Opportunity_Task__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTaskTriggerHandler.handleTaskCompletion(Trigger.oldMap, Trigger.newMap);
    }
}
