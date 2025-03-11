SETUP INSTRUCTIONS: Test data have been created so no need for additional setup.Just go to an Opportunity record page where a related list and an LWC have been added.

1) Design Approach & Rationale

Custom Metadata Approach
The solution leverages Custom Metadata Types (CMDT) to store and manage task sequences instead of hardcoded values. This allows Salesforce Administrators to configure sequences without modifying Apex code, improving scalability, flexibility, and maintainability.

Why CMDT?
✅ Performance → CMDT is cached and does not consume SOQL queries.
✅ No Code Changes Required → Admins can add/edit task sequences via Salesforce Setup.
✅ Declarative Control → Configuration is managed entirely through the UI.

2) OBJECT MODELLING APPROACH
The solution introduces some custom objects to handle task tracking and sequence management, ensuring each Opportunity follows its assigned process correctly.

Task_Process__mdt
This metadata type allows administrators to define different processes (e.g., "Process 1", "Process 2") that dictate which task sequence should be executed when selected on an Opportunity.
Fields: DeveloperName, Label (name of the process like "contract signing"), Description__c

Task_Sequence__mdt
This metadata type allows admins to define the order of tasks for each process, ensuring sequential execution.
Fields: Process__c , Task_Name__c, Order__c, Auto_Assign_To_Owner__c

Opportunity_Task__c
Links task with opportunity through master details relationship.
Fields: Opportunity__c (Master-detail), Task_Name__c (stores the task name from cmdt), Status__c, Order__c (pulled from cmdt), Assigned_To__c

 How It All Works Together
1️⃣ Admin defines a process (Task_Process__mdt), e.g., "Contract Approval".
2️⃣ Admin configures tasks for that process (Task_Sequence__mdt), e.g.,

Step 1: "Send Proposal"
Step 2: "Follow-Up Call"
Step 3: "Finalize Agreement"
3️⃣ When a user selects a process on an Opportunity, the system retrieves the corresponding task sequence from metadata and creates the first task.
4️⃣ As each task is completed, the next one is automatically created, ensuring smooth workflow execution.


Why This Design?
✅ Metadata-Driven → No hardcoded logic; admins can configure sequences dynamically.
✅ Efficient & Scalable → Uses CMDT for performance and Master-Detail for data integrity.
✅ Enhances User Productivity → Automates task tracking and sequencing for streamlined workflows.

