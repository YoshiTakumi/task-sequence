public with sharing class OpportunityTaskTriggerHandler {
    public static void handleTaskCompletion(Map<Id, Opportunity_Task__c> oldMap, Map<Id, Opportunity_Task__c> newMap) {
        List<Opportunity_Task__c> completedTasks = new List<Opportunity_Task__c>();

        for (Opportunity_Task__c newTask : newMap.values()) {
            Opportunity_Task__c oldTask = oldMap.get(newTask.Id);
            if (oldTask.Status__c != 'Completed' && newTask.Status__c == 'Completed') {
                completedTasks.add(newTask);
            }
        }

        if (!completedTasks.isEmpty()) {
            TaskSequenceService.createNextTasks(completedTasks);
        }
    }
}
