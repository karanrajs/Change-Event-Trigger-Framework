# Change Event Trigger Framework

In general, saving a record in salesforce cause a series of transactions(Triggers and Order of Execution) takes place so when the business processes are more then automatically apex transaction can start taking a while. With the help of the Change Data Capture events, we can add the new complex /integration business logic without impacting the existing transaction. The change event triggers to run asynchronously after the database transaction is completed. Perform resource-intensive business logic asynchronously in the change event trigger, and implement transaction-based logic in the Apex object trigger. By decoupling the processing of changes, change event triggers can help reduce transaction processing time. The change events are based on the platform events.

<br/>
<center>
<img src="https://github.com/karanrajs/Change-Event-Trigger-Framework/blob/main/asset/ChangeDataCapture.png">
</center>
<br/>

This framework allows developers to write their business logic without much worrying about the anatomy of a change event. This framework allows developers to get the list of recordId based on the change event context(insert, update, delete, undelete) which is segregated based on the recordType ID, so for a developer, it's easy to grab a recordId based on the specific recordtypeId for a specific event (insert, update, delete, undelete) with a single line of code. Like our existing trigger framework, activate or deactivate their AysncTriggers through custom metadata.

Below is the sample code

Invoking AsyncTriggerFactory class from the Change Event Trigger
```java
trigger CaseChangeEventTrigger on CaseChangeEvent (after insert) {
    AsyncTriggerFactory.CreateHandlerAndExecute(case.sObjectType);
}
```

Structure of the Handler class

```java
public with sharing class caseAsyncTriggerHandler extends AbstractAsyncTriggerHandler{
    public override void isInsert(Map<String,Set<String>> newMap){
        system.debug('Insert'+ newMap.values());
        system.debug('Insert'+ newMap.keySet());
    }
    public override void isUpdate(Map<String,set<String>> newMap){
        Id rtId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('test').getRecordTypeId();
        system.debug('Values contains set of recordId from the change Event'+ newMap.values());
        system.debug('Keys contains the recordTypeId of the change Event'+ newMap.keySet());
        system.debug('It returns the set of records for the specific recordTypeId from the change event'+ newMap.get(rtId));
        system.debug('ChangeEventHeader'+changeEventHeaderMap);
        system.debug('FieldsChangedMap'+fieldsChangedMap);
        system.debug('ChangeOrigin'+changeOrigin);
    }
}
```

## References
* [Event Driven Architectures Developer Blog Post]()
* [Change Data Capture Documentation](https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_intro.htm)
* [Change Event Message Structure](https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_message_structure.htm)
* [Async Triggers Developer Blog Post](https://developer.salesforce.com/blogs/2019/06/get-buildspiration-with-asynchronous-apex-triggers-in-summer-19.html)

