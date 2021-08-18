/**
 * @description       : Base class for Async Trigger Handlder 
 * @author            : Karanraj Sankaranarayanan
 * @last modified on  : 08-14-2021
 * @last modified by  : Karanraj Sankaranarayanan
**/
public virtual class AbstractAsyncTriggerHandler {

    public String sObjectName;
    public string changeOrigin = '';
    public Map<string,Set<string>> recordTypeIdMap; // Contains set of recordId based on the RecordTypeID
    public Map<String,Map<string,set<String>>> recordsMapByContext;
    public Map<Id,EventBus.ChangeEventHeader> changeEventHeaderMap;
    public Map<String,set<String>> fieldsChangedMap; 
    
    public virtual void isInsert(Map<string,set<String>> newMap){
        system.debug('Override this method in the AsyncTriggerFacatory class');
    }

    public virtual void isUpdate(Map<string,set<String>> newMap){
        system.debug('Override this method in the AsyncTriggerFacatory class');
    }

    public virtual void isDelete(Map<string,set<String>> newMap){
        system.debug('Override this method in the AsyncTriggerFacatory class');
    }

    public virtual void isUnDelete(Map<string,set<String>> newMap){
        system.debug('Override this method in the AsyncTriggerFacatory class');
    }

    public void init(){
        setChangeEventHeaderMap();
        setFieldChangedMap();
        setRecordTypeIdMap();
        setRecordMapbyContext();
    }

    /**
    * @description : To populate the Change event header for the recordId 
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    **/
    private void setChangeEventHeaderMap(){
        changeEventHeaderMap = new Map<Id,Eventbus.ChangeEventHeader>();
        Eventbus.ChangeEventHeader changeHeader;

        for(sObject record:(List<sObject>)Trigger.new){
            changeHeader = (Eventbus.ChangeEventHeader)record.get('ChangeEventHeader');
            for(Id recordId:changeHeader.getRecordIds()){
                changeEventHeaderMap.put(recordId, changeHeader);
                //store the object name
                sObjectName = changeHeader.entityname;
                
            }
            //Capture the source of change and it will be empty if change not done by API or in Lightning Experience
            changeOrigin = changeHeader.getChangeOrigin();
        }
    }

    
    /**
    * @description : Method to capture the list of fields changed for the record
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    **/
    private void setFieldChangedMap(){
        fieldsChangedMap = new Map<String,Set<String>>();
        Eventbus.ChangeEventHeader changeEventHeader;

        for(sObject record:(List<sObject>)Trigger.new){
            changeEventHeader =  (Eventbus.ChangeEventHeader)record.get('ChangeEventHeader');
            for(string recordId : changeEventHeader.getRecordIds()){
                if(fieldsChangedMap.containsKey(recordId)){
                    fieldsChangedMap.get(recordId).addAll(changeEventHeader.changedFields);
                }else{
                    fieldsChangedMap.put(recordId, new set<String>(changeEventHeader.changedFields));
                }                

            }
        }
    }

    /**
    * @description : To Populate set of recordId based on the recordTypeID of the record
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    **/
    private void setRecordTypeIdMap(){
        recordTypeIdMap = new Map<String,set<string>>();
        set<String> recordIds = fieldsChangedMap.keySet();
        //Check recordTypeID field is exist for the object or not
        if(isAvailableField(sObjectName,'RecordTypeId')){
            for(sObject sobj : Database.query('Select Id,RecordTypeId from '+sObjectName+ ' WHERE Id IN:recordIds')){
                if(recordTypeIdMap.containsKey((string)sobj.get('RecordTypeId'))){
                    recordTypeIdMap.get((string)sobj.get('RecordTypeId')).add(sobj.Id);
                }else{
                    recordTypeIdMap.put((string)sobj.get('RecordTypeId'),new set<string>{sobj.Id});
                }
            }
        }else{
            recordTypeIdMap.put('None', recordIds);
        }

    }
    
    /**
    * @description : To populate set of the recordTypeIdMap based on the change event context
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    **/
    private void setRecordMapbyContext(){

        recordsMapByContext = new Map<String,Map<string,set<String>>>();
        for(String eventContext : new List<String>{'CREATE','UPDATE','DELETE','UNDELETE'}){
            recordsMapByContext.put(eventContext, new Map<string,set<String>>());
        }

        for(Eventbus.ChangeEventHeader ceh:changeEventHeaderMap.values()){
            for(String recordTypeId : recordTypeIdMap.keySet()){
                recordsMapByContext.get(ceh.changetype.replace('GAP_', '')).put(recordTypeId,recordTypeIdMap.get(recordTypeId));
            }
        }

    }

    /**
    * @description : To check specific field is avaiable in an object or not.
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    * @param String sObjectAPIName : API Name of the object
    * @param String fieldAPIName : API Name of the field
    * @return Boolean 
    **/
    public static Boolean isAvailableField(String sObjectAPIName, String fieldAPIName) {
        // call to get the appropriate object's describe
        Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objSObjectType = mapGlobalDescribe.get(sObjectAPIName);
    
        // field describe
        Schema.DescribeSObjectResult objectDescribe = objSObjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFieldDescribe = 
            objSObjectType.getDescribe().fields.getMap();
    
        // check if field exists in describe call
        return mapFieldDescribe.containsKey(fieldAPIName);
    }
}
