/* This class is used as Order Servie that can be called from anywhere
   Called from invocable class 'FulfilledOrderCallout' 
   takes Order Id as parameter
   Performs callout to NPS
   TODO : Store the respose from callout and return  
*/
public with sharing class OrderService {
    
    public static void performCallout(List<id> orderIds){
        try{
        // Get Order details
        // TODO : Use Selector Pattern to retrive Order List by Id
        List<order> orderlist = [select id,OrderNumber,BillToContactId,status from order where id in :orderIds];        
		
        // Contact Ids set
        set<id> contactIds = new set<id>();
        // get Bill to contact Ids from OrderList
   		for(order o : orderlist){
        	contactIds.add(o.BillToContactId);
  		}

        //Create a Map of Contact Id as key and contact record as value based on the contactIds from Order List

        Map<id,Contact> customerContact = new Map<id,Contact>([select id,email from contact where id in :contactIds]);        
        
        //Loop through the order List and create JSON body to be sent to NPS
        for(order o : orderlist){
            if(o.Status.equals('Fulfilled')){
                //Call Wrapper class 
                OrderWrapper wrap = new OrderWrapper();
                wrap.sfId = o.Id;
                wrap.orderNumber = o.OrderNumber;
                wrap.customerEmail = customerContact.get(o.BillToContactId).email;
                String jsonBody = json.serialize(wrap);
                //Call future method to perform callout and pass json body as parameter
                calloutToNPS(jsonBody);
            }
        }
        }catch (Exception e) {
            // Handle exceptions at this level 
            System.debug('Exception : ' + e);
        }
    }
    
    // Future method to perform actual callout
    @future(callout=true)
    public static void calloutToNPS(String jsonbody){
        String message = null;
        try{
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:nps/orders');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        // Send the request, and return a response
        HttpResponse res = h.send(req);
           
        //Processing response and checking response code
			switch on res.getStatusCode() 
            {
    			when 200 {		
        			message = 'SUCCESS';
    				}	
    			when 400 {		
        			message = 'BAD PAYLOAD';
    				}
    			when 500 {		
        			message = 'SERVER ERROR';
    				}
    			when else {		  
        			message = 'UNKNOWN ERROR';
    				}
			}
            System.debug('Status ==> ' + res.getStatus() +' , StatusCode ==> ' + res.getStatusCode() + ' , Message ==>' + message);
            
            } catch(System.CalloutException e)
            {
                System.debug('Exception ==> ' + e);
            }    	       	
    }
}