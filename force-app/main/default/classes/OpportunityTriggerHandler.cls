public with sharing class OpportunityTriggerHandler {
    public static void handleOpportunityInsert(List<Opportunity> newOpps) {
        TaskSequenceService.createInitialTasks(newOpps);
    }

    public static void handleOpportunityUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> changedOpps = new List<Opportunity>();

        for (Opportunity opp : newMap.values()) {
            Opportunity oldOpp = oldMap.get(opp.Id);
            if (oldOpp.Process__c == null && opp.Process__c != null) {
                changedOpps.add(opp);
            }
        }

        if (!changedOpps.isEmpty()) {
            TaskSequenceService.createInitialTasks(changedOpps);
        }
    }
}
