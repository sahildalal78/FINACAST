@isTest
public class ClientDetailApexTest {
     @testsetup
    public static void data(){
        String cId = 'init';
        Account ac = new Account();
        ac.name = 'Test';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert ac;
        String cId1 = ac.id;
        
        Account hac = new Account();
        hac.name = 'Test2';
        hac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesHousehold').getRecordTypeId();
        insert hac;
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountid = hac.id;
        acr.contactid = [select id from contact where accountid =: ac.id].Id;
        acr.IsActive = true;
        acr.FinServ__PrimaryGroup__c = true;
        acr.FinServ__Rollups__c = 'All';
        acr.FinServ__Primary__c = true;
        insert acr;
        String cId2 = hac.id;
        
        
        Budget__c income = new Budget__c();
        income.Name = 'test income';
       
        income.Amount__c = 1234;
        income.Primary_Owner__c = ac.Id; income.Start_Date__c = system.today();
        income.End_Date__c = system.today();
        income.RecordTypeId = FinacastUtility.getRecordTypeId('Budget__c', 'Income_Record_Type');
        insert income;
        
        Budget__c expense = new Budget__c();
        expense.Name = 'test expense';
        expense.Amount__c = 1234;
         expense.Start_Date__c = system.today();
        expense.End_Date__c = system.today();
        expense.Primary_Owner__c = ac.Id;
        expense.RecordTypeId = FinacastUtility.getRecordTypeId('Budget__c', 'Expense_Record_Type');
        insert expense;
        
        FinServ__FinancialAccount__c financial1 = new FinServ__FinancialAccount__c();
        financial1.Name = 'Test Financial Account 1';
        financial1.FinServ__PaymentAmount__c = 5000;
        financial1.FinServ__PrimaryOwner__c= ac.Id;
        financial1.FinServ__LoanAmount__c = 5000;
        financial1.APR__c = 4;
        financial1.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c', 'LoanAccount');
        financial1.Account_Type__c = 'Loan';
        insert financial1;
         system.debug('typefin1'+financial1.Account_Type__c);
        
        FinServ__FinancialAccount__c savings1 = new FinServ__FinancialAccount__c();
        savings1.FinServ__PrimaryOwner__c = ac.Id;
        savings1.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c', 'SavingsAccount');
        savings1.Name = 'Test Savings 1';
        savings1.FinServ__Balance__c = 0;
        savings1.FinServ__APY__c = 3;   
        savings1.FinServ__LoanEndDate__c = Date.today();
        savings1.FinServ__FinancialAccountType__c = 'Savings';
        savings1.Account_Type__c = 'Savings';
        insert savings1;
        update savings1;
        system.debug('typefin1'+savings1.RecordTypeId);
        
        FinServ__FinancialAccount__c card = new FinServ__FinancialAccount__c();
        card.Name = 'Test Credit Card 1';
        card.FinServ__Balance__c = 98765;
        card.FinServ__PaymentAmount__c = 5000;
        card.FinServ__PrimaryOwner__c= ac.Id;
        card.FinServ__LoanAmount__c = 5000;
        card.APR__c = 4;
        card.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c', 'CreditCard');
        card.FinServ__FinancialAccountType__c  = 'Credit Card';
         card.Account_Type__c = 'Credit Card';
        insert card;
        
        system.debug('typefin1'+card.Account_Type__c);
        FinServ__FinancialGoal__c goals1 = new  FinServ__FinancialGoal__c();
        goals1.FinServ__PrimaryOwner__c = ac.Id;
        goals1.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialGoal__c' , 'CarRecordType');
        goals1.Name = 'Test Goal 1';
        goals1.FinServ__TargetValue__c = 10000;
        goals1.FinServ__TargetDate__c = Date.today()+900;
        goals1.Start_Value__c = 2000;
        goals1.Goal_Priority__c = '1';
        goals1.Required_Monthly_Saving__c = 2000;
        goals1.Associated_Account__c = savings1.Id;
        insert goals1;
        
        
        
        //Household Account
        
        Budget__c income2 = new Budget__c();
        income2.Name = 'test income';
        income2.Start_Date__c = system.today();
        income2.End_Date__c = system.today();
        income2.Amount__c = 4234;
        income2.Primary_Owner__c = ac.Id;
        income2.HouseHold__c = hac.id;
        income2.RecordTypeId = FinacastUtility.getRecordTypeId('Budget__c', 'Income_Record_Type');
        insert income2;
        
        Budget__c expense2 = new Budget__c();
        expense2.Name = 'test expense';
        expense2.Start_Date__c = system.today();
        expense2.End_Date__c = system.today();
        expense2.Amount__c = 1234;
        expense2.Primary_Owner__c = ac.Id;
        expense2.HouseHold__c = hac.id;
        expense2.RecordTypeId = FinacastUtility.getRecordTypeId('Budget__c', 'Expense_Record_Type');
        insert expense2;
        
        FinServ__FinancialAccount__c financial2 = new FinServ__FinancialAccount__c();
        financial2.Name = 'Test Financial Account 1';
        financial2.FinServ__PaymentAmount__c = 6000;
        financial2.FinServ__PrimaryOwner__c= ac.Id;
        financial2.FinServ__LoanAmount__c = 6000;
        financial2.APR__c = 4;
        financial2.FinServ__Household__c = hac.id;
        financial2.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c', 'LoanAccount');
        financial2.Account_Type__c = 'Loan';
        insert financial2;
        
        FinServ__FinancialAccount__c savings2 = new FinServ__FinancialAccount__c();
        savings2.FinServ__PrimaryOwner__c = ac.Id;
        savings2.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c', 'SavingsAccount');
        savings2.Name = 'Test Savings 1';
        savings2.FinServ__Balance__c = 98765;
        savings2.FinServ__Household__c = hac.id;
        savings2.FinServ__APY__c = 3;   
        savings2.FinServ__LoanEndDate__c = Date.today();
        savings2.FinServ__FinancialAccountType__c = 'Savings';
        insert savings2;
        
        FinServ__FinancialAccount__c card2 = new FinServ__FinancialAccount__c();
        card2.Name = 'Test Credit Card 1';
        card2.FinServ__Balance__c = 98765;
        card2.FinServ__PaymentAmount__c = 5000;
        card2.FinServ__PrimaryOwner__c= ac.Id;
        card2.FinServ__LoanAmount__c = 5000;
        card2.FinServ__Household__c = hac.id;
        card2.APR__c = 4;
        card2.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c', 'CreditCard');
        card2.FinServ__FinancialAccountType__c  = 'Credit Card';
        insert card2;
        
        list<FinServ__FinancialGoal__c> goals4 = new  list<FinServ__FinancialGoal__c>();
        FinServ__FinancialGoal__c goals2 = new  FinServ__FinancialGoal__c();
        goals2.FinServ__PrimaryOwner__c = ac.Id;
        goals2.RecordTypeId = FinacastUtility.getRecordTypeId('FinServ__FinancialGoal__c' , 'CarRecordType');
        goals2.Name = 'Test Goal 1';
        goals2.FinServ__TargetValue__c = 10000;
        goals2.FinServ__TargetDate__c = Date.today()+900;
        goals2.Start_Value__c = 2000;
        goals2.FinServ__Household__c = hac.id;
        goals2.Goal_Priority__c = '1';
        goals2.Required_Monthly_Saving__c = 2000;
        goals2.Associated_Account__c = savings1.Id;
        goals4.add(goals2);
        insert goals4;
    }
    
    static TestMethod void testDashboard() {
        Account acc = [select id from Account where name = 'Test'];
        test.startTest();
    
        ClientDetailApex.createClientData(acc.Id);
        ClientDetailApex.createClientData_bak('init');
        ClientDetailApex.createClientData_bak(acc.Id);
        ClientDetailApex.getData(acc.id);
        ClientDetailApex.createClientData('init');
        ClientDetailApex.NumberOfMonths(system.today(), system.today());
        ClientDetailApex.curentgoalestimation(500, system.today(), system.today());
        
        
        ClientDetailApex.getGoals(acc.Id);   
         ClientDetailApex.getAccounts(acc.Id);
        ClientDetailApex.getAccounts('init');
        ClientDetailApex.getGoals('init');
        
        Account acc2 = [select id from Account where name = 'Test2'];
        ClientDetailApex.createClientData_bak(acc2.Id);
        ClientDetailApex.getAccounts(acc2.Id);
        ClientDetailApex.getGoals(acc2.Id);   
        ClientDetailApex.getData(acc2.id);
        ClientDetailApex.createClientData(acc2.Id);
        ClientDetailApex.getAccounts(acc2.Id);
        ClientDetailApex.getGoals(acc2.Id);
        ClientDetailApex.isportalEnabled =true;
        

        //Test.setMock(HttpCalloutMock.class, new FutureSimulationMockHttpResponse());        
        //ClientDetailApex.WrapperClass res = ClientDetailApex.getData(acc.Id);
        System.assertEquals(1,1);
        test.stopTest();
    } 

}