/**
 * @description       : Change Event Trigger for Case Object
 * @author            : Karanraj Sankaranarayanan
 * @group             : 
 * @last modified on  : 08-15-2021
 * @last modified by  : Karanraj Sankaranarayanan
**/
trigger CaseChangeEventTrigger on CaseChangeEvent (after insert) {
    AsyncTriggerFactory.CreateHandlerAndExecute(case.sObjectType);
}