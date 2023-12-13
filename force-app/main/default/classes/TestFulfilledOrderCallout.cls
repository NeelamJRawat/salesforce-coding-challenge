@isTest
private class TestFulfilledOrderCallout {
    	@isTest
       private static void callFutureMethod() {        
        // Create an Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a Contact for Bill To Contact
		Contact testContact = new Contact(Lastname = 'testLastName',email = 'testlastname@yopmail.com');
        insert testContact;

        // Create Product
        Product2 product1 = new Product2(Name = 'Product 1', IsActive = true);
        insert product1;

        // Get standard Pricebook Id
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create Price Book Entries associated with standard pricebook
        PricebookEntry pricebookEntry1 = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product1.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
		insert pricebookEntry1;
        
        // Create a Custom Price Book
        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Pricebook', IsActive = true);
        insert customPricebook;
        
        // Create Price Book Entries associated with Custom pricebook
        PricebookEntry pricebookEntry2 = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = product1.Id,
            UnitPrice = 150.00,
            IsActive = true
        );
		insert pricebookEntry2;

        // Create a Contract
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            Status = 'Draft',
            ContractTerm = 12,  // Contract term in months
            StartDate = Date.today()
        );
        insert testContract;
        //Activate the contract
		testContract.status = 'Activated';
        update testContract;

        // Create an Order
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            ContractId = testContract.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id =  customPricebook.Id,
            BillToContactId = testContact.Id
        );
        insert testOrder;

        //Put the order Ids in List
        List<id> OrderIds = new List<id>();
        OrderIds.add(testOrder.Id);

        // Add Order Products (OrderItem)
        OrderItem orderItem1 = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry2.Id,
            Quantity = 2,
            UnitPrice = 100.00
            
        );
          
        OrderItem orderItem2 = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry2.Id,
            Quantity = 1,
           UnitPrice = 100.00
        );

        insert new List<OrderItem>{orderItem1,orderItem2};
        
        //Set order status to Fulfilled
        testOrder.Status = 'Fulfilled';
        update testOrder;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CalloutMockNPSHttp());
       
        FulfilledOrderCallout.CallCallout(OrderIds);

        Test.stopTest();
        
    }
    
    private class CalloutMockNPSHttp implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
        System.assertEquals('callout:nps/orders', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
        

    }
}
}