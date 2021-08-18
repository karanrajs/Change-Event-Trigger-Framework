/**
 * @description       : Test class to cover code coverage for the Change event trigger factory class
 * @author            : Karanraj Sankaranarayanan
 * @last modified on  : 08-15-2021
 * @last modified by  : Karanraj Sankaranarayanan
**/
@isTest
public with sharing class AsyncTriggerFactory_Test {
  
    @isTest static void runAsyncTrigger(){

        Test.enableChangeDataCapture();
        
        Test.startTest();
        Case cs = new case(subject='Test1 case record');
        insert cs;
        Test.stopTest();
    }

}
