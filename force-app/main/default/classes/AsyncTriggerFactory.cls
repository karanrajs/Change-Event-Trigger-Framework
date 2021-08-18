/**
 * @description       : Change Event Trigger Factory class
 * @author            : Karanraj Sankaranarayanan
 * @last modified on  : 08-15-2021
 * @last modified by  : Karanraj Sankaranarayanan
**/
public with sharing class AsyncTriggerFactory {

    public static Map<Schema.sObjectType,AsyncTriggerConfig__mdt[]> configurations { //All the Async Trigger Configuration from the custom metadata
        get{
            if(configurations == null){
                configurations = new Map<Schema.sObjectType,AsyncTriggerConfig__mdt[]>();
                for(AsyncTriggerConfig__mdt cfg : [SELECT Active__c,Handler_Name__c,sObject__c,DeveloperName,Id,MasterLabel,Order__c FROM AsyncTriggerConfig__mdt order by Order__c asc]){
                    sObjectType objType = Schema.getGlobalDescribe().get(cfg.sObject__c);
                    if(configurations.containsKey(objType)){
                        configurations.get(objType).add(cfg);
                    }else{
                        configurations.put(objType,new List<AsyncTriggerConfig__mdt>{cfg});
                    }
                }
            }
            return configurations;
        }
        public set;
    }
    
    /**
    * @description Create Async Trigger Handler and Execute
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    * @param Schema.sObjectType soType 
    **/
    public static void CreateHandlerAndExecute(Schema.sObjectType soType){

        AbstractAsyncTriggerHandler[] handlers = getHandlers(soType);
        if(handlers == null || handlers.size() == 0){
            system.debug('Warring - No Trigger handler registered for Object Type:');
            return;
        }

        for(AbstractAsyncTriggerHandler handler: handlers){
            execute(handler);
        }
    }

    /**
    * @description : to get the list of Async Trigger Handler class from the custom metadata
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    * @param Schema.sObjectType soType 
    * @return List<AbstractAsyncTriggerHandler> 
    **/
    @testVisible
    private static List<AbstractAsyncTriggerHandler> getHandlers(Schema.sObjectType soType){
        if(configurations.containsKey(soType)){
            AsyncTriggerConfig__mdt[] configs = configurations.get(soType);
            List<AbstractAsyncTriggerHandler> ret = new List<AbstractAsyncTriggerHandler>();
            for(AsyncTriggerConfig__mdt setting : configs){
                if(setting.Active__c){
                    AbstractAsyncTriggerHandler hdlr = (AbstractAsyncTriggerHandler)Type.forName(setting.Handler_Name__c).newInstance();
                    ret.add(hdlr);
                }
            }
            return ret;
        }
        return null;
    }

    /**
    * @description Execute the trigger handler
    * @author Karanraj Sankaranarayanan | 08-14-2021 
    * @param AbstractAsyncTriggerHandler handler 
    **/
    private static void execute(AbstractAsyncTriggerHandler handler){
        
        handler.init();
        //run the trigger logic only if the changeOrigin is not empty
        if(!handler.recordsMapByContext.get('CREATE').isEmpty() && handler.changeOrigin != ''){
            handler.isInsert(handler.recordsMapByContext.get('CREATE'));
        }
        if(!handler.recordsMapByContext.get('UPDATE').isEmpty() && handler.changeOrigin != ''){
            handler.isUpdate(handler.recordsMapByContext.get('UPDATE'));
        }
        if(!handler.recordsMapByContext.get('DELETE').isEmpty() && handler.changeOrigin != ''){
            handler.isDelete(handler.recordsMapByContext.get('DELETE'));
        }
        if(!handler.recordsMapByContext.get('UNDELETE').isEmpty() && handler.changeOrigin != ''){
            handler.isUnDelete(handler.recordsMapByContext.get('UNDELETE'));
        }

    }
}
