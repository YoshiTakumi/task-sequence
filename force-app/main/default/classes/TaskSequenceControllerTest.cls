@isTest
private class TaskSequenceControllerTest {
    
    @testSetup
    static void setupTestData() {
        List<Opportunity_Task__c> oppTasks = new List<Opportunity_Task__c>();

        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = Date.today().addDays(10);
        insert testOpp;

        Opportunity_Task__c task1 = new Opportunity_Task__c();
        task1.Opportunity__c = testOpp.Id;
        task1.Task_Name__c = 'Task 1';
        task1.Status__c = 'Not Started';
        task1.Order__c = 1;
        oppTasks.add(task1);
        
        Opportunity_Task__c task2 = new Opportunity_Task__c();
        task2.Opportunity__c = testOpp.Id;
        task2.Task_Name__c = 'Task 2';
        task2.Status__c = 'Completed';
        task2.Order__c = 2;
        
        oppTasks.add(task2);
        insert oppTasks;
    }

    @isTest
    static void testGetOpportunityTasks() {
        Test.startTest();
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Opportunity_Task__c> tasks = TaskSequenceController.getOpportunityTasks(testOpp.Id);
        Test.stopTest();

        System.assertNotEquals(0, tasks.size(), 'Expected tasks to be returned for the Opportunity');
        System.assertEquals(2, tasks.size(), 'Expected exactly 2 tasks for the Opportunity');
        System.assertEquals('Task 1', tasks[0].Task_Name__c, 'First task name should match');
        System.assertEquals('Task 2', tasks[1].Task_Name__c, 'Second task name should match');
    }

    @isTest
    static void testGetOpportunityTasksWithNoTasks() {
        Test.startTest();
        Opportunity emptyOpp = new Opportunity();
        emptyOpp.Name = 'No Task Opp';
        emptyOpp.StageName = 'Prospecting';
        emptyOpp.CloseDate = Date.today().addDays(10);
    
        insert emptyOpp;

        List<Opportunity_Task__c> tasks = TaskSequenceController.getOpportunityTasks(emptyOpp.Id);
        Test.stopTest();

        System.assertEquals(0, tasks.size(), 'Expected no tasks for an Opportunity with no associated tasks');
    }

    @isTest
    static void testUpdateTasks_Success() {
        Test.startTest();
        Opportunity_Task__c taskToUpdate = [SELECT Id, Status__c FROM Opportunity_Task__c LIMIT 1];
        taskToUpdate.Status__c = 'Completed';

        TaskSequenceController.updateTasks(new List<Opportunity_Task__c>{taskToUpdate});
        Test.stopTest();

        Opportunity_Task__c updatedTask = [SELECT Id, Status__c FROM Opportunity_Task__c WHERE Id = :taskToUpdate.Id];
        System.assertEquals('Completed', updatedTask.Status__c, 'Task status should be updated to Completed');
    }

}
