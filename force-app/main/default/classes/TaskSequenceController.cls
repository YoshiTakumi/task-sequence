public with sharing class TaskSequenceController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity_Task__c> getOpportunityTasks(Id opportunityId) {
        if (String.isBlank(opportunityId)) {
            return new List<Opportunity_Task__c>();
        }
        return [
            SELECT Id, Task_Name__c, Status__c, Order__c, Due_Date__c,Assigned_To__r.Name
                FROM Opportunity_Task__c
                WHERE Opportunity__c = :opportunityId
                ORDER BY Order__c ASC
        ];
    }
    @AuraEnabled
    public static void updateTasks(List<Opportunity_Task__c> tasks) {
        if (tasks == null || tasks.isEmpty()) {
            throw new AuraHandledException('No valid data received.');
        }
        for (Opportunity_Task__c task : tasks) {
            if (task.Id == null) {
                throw new AuraHandledException('Each task must have an Id.');
            }
        }
        update tasks;
    }

}
