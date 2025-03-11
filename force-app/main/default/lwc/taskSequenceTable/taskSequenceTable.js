import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOpportunityTasks from '@salesforce/apex/TaskSequenceController.getOpportunityTasks';
import updateTasks from '@salesforce/apex/TaskSequenceController.updateTasks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Task Name', fieldName: 'taskName', type: 'text' },
    { label: 'Order', fieldName: 'order', type: 'number', initialWidth: 80 },
    { label: 'Status', fieldName: 'status', type: 'text', editable: true },
    { label: 'Assigned To', fieldName: 'assignedTo', type: 'text'},
    { label: 'Due Date', fieldName: 'dueDate', type: 'date', editable: true }
];

export default class TaskSequenceTable extends LightningElement {
    @api recordId;
    @track taskData = [];
    draftValues = [];
    wiredTaskResult;
    columns = COLUMNS;

    @wire(getOpportunityTasks, { opportunityId: '$recordId' })
    wiredTasks(result) {
        this.wiredTaskResult = result;
        if (result.data) {
            this.taskData = result.data.map(task => ({
                id: task.Id,
                order: task.Order__c,
                taskName: task.Task_Name__c,
                status: task.Status__c,
                assignedTo: task.Assigned_To__r ? task.Assigned_To__r.Name : 'Unassigned',
                dueDate: task.Due_Date__c
            })).sort((a, b) => a.order - b.order);
            console.log('Task Data:', JSON.stringify(this.taskData));
        } else if (result.error) {
            console.error('Error fetching tasks:', result.error);
        }
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
    
        console.log('Draft xalues Before Processing:', JSON.stringify(updatedFields));
    
        if (!updatedFields || updatedFields.length === 0) {
            console.error('No data to update.');
            return;
        }
    
        const recordsToUpdate = updatedFields.map(task => {
            let matchedTask = this.taskData.find(t => t.id === task.id || t.Id === task.id);
            return {
                Id: matchedTask ? matchedTask.id : task.id,
                Status__c: task.status
            };
        }).filter(record => record.Id);
    
        if (recordsToUpdate.length === 0) {
            console.error('No valid records to update.');
            this.showToast('Error', 'Failed to update. No valid records found.', 'error');
            return;
        }
    
        updateTasks({ tasks: recordsToUpdate })
            .then(() => {
                this.showToast('Success', 'Task updates saved successfully!', 'success');
                this.draftValues = [];
                return refreshApex(this.wiredTaskResult);
            })
            .catch(error => {
                console.error('Error updating tasks:', JSON.stringify(error));
                this.showToast('Error', 'Failed to save changes. Please try again.', 'error');
            });
    }     
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}
