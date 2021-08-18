/**
 * @description       : CDE Hanlder class of the Case object 
 * @author            : Karanraj Sankaranarayanan
 * @last modified on  : 08-15-2021
 * @last modified by  : Karanraj Sankaranarayanan
**/
public with sharing class CaseAsyncTriggerHandler extends AbstractAsyncTriggerHandler{

    public override void isInsert(Map<String,Set<String>> newMap){
        system.debug('Insert'+ newMap.values());
        system.debug('Insert'+ newMap.keySet());
    }

    public override void isUpdate(Map<String,set<String>> newMap){
       
        Id rtId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('IHR').getRecordTypeId();
        system.debug('Update Value'+ newMap.values());
        system.debug('Update Keys'+ newMap.keySet());
        system.debug('IHR'+ newMap.get(rtId));
        system.debug('ChangeEventHeader'+changeEventHeaderMap);
        system.debug('FieldsChangedMap'+fieldsChangedMap);
        system.debug('ChangeOrigin'+changeOrigin);
    }
    
}
