@isTest
private class ProcessChangeValidationTest {

    @TestSetup
    static void makeData(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Validation Rule Test Opp';
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.today().addDays(30);
        opp.Process__c = 'Process 1';
        insert opp;

        Opportunity_Task__c existingTask = new Opportunity_Task__c();
        existingTask.Opportunity__c = opp.Id;
        existingTask.Task_Name__c = 'Send Proposal';
        existingTask.Status__c = 'Not Started';
        insert existingTask;
    }


    @isTest
    static void testPreventProcessChangeWhenTasksExist() {
        Test.startTest();
        Opportunity opp = [SELECT Id,Process__c FROM Opportunity WHERE Name = 'Validation Rule Test Opp'];
        
        try {
            opp.Process__c = 'Process 2';
            update opp;
            System.assert(false, 'Expected an exception due to validation rule');
        } catch (DmlException e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage().contains('Do not change the current process while task(s) exist'), 
                'Validation rule should prevent changing the process');
        }
        Test.stopTest();
    }
}
