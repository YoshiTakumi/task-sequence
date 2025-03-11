@isTest
private class TaskSequenceServiceTest {

    @TestSetup
    static void makeData(){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Initial Task Opp';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = Date.today().addDays(15);
        testOpp.Process__c = 'Process 1';
        oppList.add(testOpp);

        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Task Progression Opp';
        testOpp1.StageName = 'Negotiation';
        testOpp1.CloseDate = Date.today().addDays(20);
        testOpp1.Process__c = 'Process 1';
        oppList.add(testOpp1);
        
        insert oppList;
    }
    
    @isTest
    static void testInitialTaskCreation() {
        Test.startTest();
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Initial Task Opp'];
        List<Opportunity_Task__c> taskList = [SELECT Id, Task_Name__c FROM Opportunity_Task__c WHERE Opportunity__c = :testOpp.Id];
        Test.stopTest();
        System.assertEquals(1, taskList.size(), 'Expected exactly 1 task created by the trigger');
        System.assertEquals('Send Proposal', taskList[0].Task_Name__c);
    }

    @isTest
    static void testNextTaskCreationAfterCompletion() {
        Test.startTest();
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Task Progression Opp'];

        Opportunity_Task__c firstTask = [SELECT Id, Task_Name__c, Status__c FROM Opportunity_Task__c WHERE Opportunity__c = :testOpp.Id LIMIT 1];
        System.assertEquals('Send Proposal', firstTask.Task_Name__c, 'Expected "Send Proposal" as the first task');
        
        firstTask.Status__c = 'Completed';
        update firstTask;
        List<Opportunity_Task__c> taskList = [SELECT Id, Task_Name__c,CreatedDate FROM Opportunity_Task__c WHERE Opportunity__c = :testOpp.Id ORDER BY Task_Name__c ASC];
        Test.stopTest();

        System.assertEquals(2, taskList.size(), 'Expected exactly 2 tasks (original + next in sequence)');
        System.assertEquals('Follow Up Call', taskList[0].Task_Name__c);
    }
}
