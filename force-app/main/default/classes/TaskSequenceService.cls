public with sharing class TaskSequenceService {
    
    /**
     * Creates the initial task(s) when a Process is selected on Opportunity.
     */
    public static void createInitialTasks(List<Opportunity> opportunities) {
        List<Opportunity_Task__c> tasksToInsert = new List<Opportunity_Task__c>();
        
        for (Opportunity opp : opportunities) {
            if (String.isNotBlank(opp.Process__c)) {
                Task_Sequence__mdt firstTask = getFirstTaskInSequence(opp.Process__c);
                
                if (firstTask != null) {
                    Integer existingTasks = [SELECT COUNT() FROM Opportunity_Task__c WHERE Opportunity__c = :opp.Id];
                    if (existingTasks > 0) {
                        continue;
                    }
    
                    Opportunity_Task__c newTask = new Opportunity_Task__c();
                    newTask.Opportunity__c = opp.Id;
                    newTask.Task_Name__c = firstTask.Task_Name__c;
                    newTask.Status__c = 'Not Started';
                    newTask.Order__c = firstTask.Order__c;
                    
                    if (firstTask.Auto_Assign_To_Owner__c) {
                        newTask.Assigned_To__c = opp.OwnerId;
                    }
    
                    tasksToInsert.add(newTask);
                }
            }
        }
    
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }    
    
    /**
     * Creates the next task when a task is marked as 'Completed'.
     */
    public static void createNextTasks(List<Opportunity_Task__c> completedTasks) {
        List<Opportunity_Task__c> tasksToInsert = new List<Opportunity_Task__c>();
    
        for (Opportunity_Task__c completedTask : completedTasks) {
            Opportunity opp = [SELECT Process__c, OwnerId FROM Opportunity WHERE Id = :completedTask.Opportunity__c LIMIT 1];
    
            if (opp.Process__c != null) {
                Task_Sequence__mdt nextTask = getNextTaskInSequence(opp.Process__c, completedTask.Task_Name__c);
    
                if (nextTask != null) {
                    Opportunity_Task__c newTask = new Opportunity_Task__c();
                    newTask.Opportunity__c = opp.Id;
                    newTask.Task_Name__c = nextTask.Task_Name__c;
                    newTask.Status__c = 'Not Started';
                    newTask.Order__c = nextTask.Order__c;
                    
                    if (nextTask.Auto_Assign_To_Owner__c) {
                        newTask.Assigned_To__c = opp.OwnerId;
                    }
    
                    tasksToInsert.add(newTask);
                }
            }
        }
    
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    /**
     * Retrieves the first task in the sequence for a given process.
     */
    private static Task_Sequence__mdt getFirstTaskInSequence(String processName) {
        List<Task_Sequence__mdt> tasks = [
            SELECT Task_Name__c, Order__c, Auto_Assign_To_Owner__c 
                FROM Task_Sequence__mdt 
                WHERE Process_Name__c = :processName 
                ORDER BY Order__c ASC
                LIMIT 1
        ];

        return tasks.isEmpty() ? null : tasks[0];
    }

    /**
     * Retrieves the next task in the sequence based on the last completed task.
     */
    private static Task_Sequence__mdt getNextTaskInSequence(String processName, String lastTaskName) {
        List<Task_Sequence__mdt> orderedTasks = [
            SELECT Task_Name__c, Order__c, Auto_Assign_To_Owner__c 
                FROM Task_Sequence__mdt 
                WHERE Process_Name__c = :processName 
                ORDER BY Order__c ASC
        ];

        for (Integer i = 0; i < orderedTasks.size() - 1; i++) {
            if (orderedTasks[i].Task_Name__c == lastTaskName) {
                return orderedTasks[i + 1];
            }
        }
        return null;
    }
}
