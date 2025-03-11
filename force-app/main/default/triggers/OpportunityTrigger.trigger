trigger OpportunityTrigger on Opportunity (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.handleOpportunityInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.handleOpportunityUpdate(Trigger.oldMap, Trigger.newMap);
    }
}