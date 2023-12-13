/* This class is used as Apex invocation from flow 'FulfilledOrderCallout' 
   passes Order Id as parameter
   Calls OrderService method that fetches order details and makes callout to NPS
   TODO : Store the respose from callout and return    
*/
public with sharing class FulfilledOrderCallout {
    @invocablemethod(label='FulfilledOrderCallout')
    public static void CallCallout(List<Id> OrderIds){
        try {
             // Call an OrderService method that makes a callout
             OrderService.performCallout(OrderIds);
        } catch (Exception e) {
             // Handle exceptions at this level 
             System.debug('Exception : ' + e);        
        }
    }
}