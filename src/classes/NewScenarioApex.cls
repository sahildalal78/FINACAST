/********* Developer Name: Aditya Kaushal
* updated Date: July 5' 19
* provided new implementation *********/


public class NewScenarioApex {

    
    public static String requestEndpoint='https://mytafi.herokuapp.com/rest/service/getFutureSimulationsNew';
    
    //class variables come here
    public static Id incomeRecId = FinacastUtility.getRecordTypeId('Budget__c' , 'Scenario_Income_Record_Type');
    public static Id expenseRecId = FinacastUtility.getRecordTypeId('Budget__c' , 'Scenario_Expense_Record_Type');
    public static Id savingsRecId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c' , 'Scenario_Savings_Record_Type');
    public static Id goalsRecId = FinacastUtility.getRecordTypeId('FinServ__FinancialGoal__c' , 'Scenario_Goal_Record_Type');
    public static Id loansRecId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c' , 'Scenario_Loans_Record_Type');
    public static Id cardRecId = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c' , 'Scenario_Credit_Cards_Record_Type');
    public static Id recIdLoan = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c' , 'LoanAccount');
    public static Id recIdCard = FinacastUtility.getRecordTypeId('FinServ__FinancialAccount__c' , 'CreditCard');
    public static Id houseHoldRecId = FinacastUtility.getRecordTypeId('Account' , 'IndustriesHousehold');
    
    
    //Parent wrapper Class
    public class UserAndScenarios{
        @AuraEnabled public Account userNameId;                                     		 // id and name from account
        @AuraEnabled public List<Scenario_Income__c> userScenarioIncome;            					 // income of user for scenario income
        @AuraEnabled public List<Scenario_Expense__c> userScenarioExpense;            				 // expense of user 
        @AuraEnabled public List<Scenario_Goal__c> userScenarioGoal;                // goal og user for scenario goal
        @AuraEnabled public List<Scenario__c> userScenario;                         		 // scenario of user
        @AuraEnabled public List<Scenario_Savings__c> userSceneSave;                         // list of scenario saving
        @AuraEnabled public List<Scenario_Debt__c> userScenarioLoan;                         // list of scenario Loan
        @AuraEnabled public List<FinServ__FinancialAccount__c> userScenarioCard;             // list of scenario credit card
        @AuraEnabled public Decimal totalGoalAmount;                                		 // total target amount of all goals of user 
        @AuraEnabled public Decimal totalIncomeAmount;                              		 // total income of user 
        @AuraEnabled public Decimal totalExpenseAmount;                              		 // total expense of user
        @AuraEnabled public Decimal totalSaveAmount;                                		 // total current amount of all savings of user 
        @AuraEnabled public Decimal totalLoanAmount;                                		 // total payment amount of all loans of user 
        @AuraEnabled public Decimal totalCardAmount;                                		 // total current value (debt amount) of all credit card of user
        @AuraEnabled public String scenarioId;                                      		 // scenario id for user
        @AuraEnabled public String response;                                      			 // response from web service
        @AuraEnabled public String primaryOwner;											 //get primaryMember id in case of household, or account id in case it is not household
        @AuraEnabled public List<Scenario__c> scenarioList;
    }
    
    @AuraEnabled
    public static  UserAndScenarios getUserScenarios(String clientId, String sceneId) {
        system.debug('clientId: '+clientId);
        system.debug('sceneId: '+sceneId);
        
        List<sobject> emptyList = new List<sObject>();       
        Integer hhStatus = 0;
        UserAndScenarios wrapper = new UserAndScenarios();
        
        
        try{
            List<Scenario__c> sceneList = new List<Scenario__c>();
            List<Account> accList  = new List<Account>();   
            Account ac = [select id,RecordTypeId,name from account where id=: clientId];
            wrapper.userNameId = ac;           
            
            //give values to sceneId
            if(sceneId == 'init' || String.isEmpty(sceneId) || String.isBlank(sceneId)) {
                sceneList = [select Name, Id from Scenario__c where Client_Id__c = :clientId order by LastModifiedDate DESC]; 
                
                if(sceneList != null && sceneList.size()> 0) {
                    sceneId = sceneList.get(0).Id;  
                    wrapper.scenarioId = sceneId;
                }
                else {
                    sceneId = 'No Scenario';  
                    wrapper.scenarioId = '';
                }
            }
                      
            if(ac.RecordTypeId == houseHoldRecId) {
                list<AccountContactRelation> acr  = [Select id,ContactId, Account.Id from AccountContactRelation where AccountId = :ac.Id AND FinServ__Primary__c = true ]; 
                for(AccountContactRelation c :acr){
                    id acrCon = c.ContactId;
                    Account accPrimaryOwn = [select id from Account where FinServ__PrimaryContact__c = :acrCon];
                    wrapper.primaryOwner = accPrimaryOwn.Id;
                }
            }
            
            else {
                wrapper.primaryOwner = ac.Id;
            }
            
            
            //CAse1:   if a scenaroi exists
            if(sceneId != 'No Scenario' && sceneId != null) {
                Decimal totalAmount = 0;
                
                // 1. Create income list
                List<Scenario_Income__c> sceneIncomeList = [select Id, Name, Amount__c from Scenario_Income__c where Scenario_Id__c = :sceneId];  
                if(sceneIncomeList != null && sceneIncomeList.size() > 0) {
                    totalAmount = 0;
                    wrapper.userScenarioIncome = sceneIncomeList;
                    for(Scenario_Income__c incomeAmt : sceneIncomeList) {
                        if(incomeAmt.Amount__c != null) {
                            totalAmount += incomeAmt.Amount__c;    
                        }
                        else {
                            totalAmount += 0;
                        }
                    }
                    wrapper.totalIncomeAmount = totalAmount; 
                }
                else {
                    emptyList = new List<sObject>();
                    Scenario_Income__c sc = new Scenario_Income__c();
                    sc.amount__c = 0;
                    emptyList.add(sc);
                    wrapper.userScenarioIncome = (List<Scenario_Income__c>) emptyList;
                    wrapper.totalIncomeAmount = 0; 
                }
                
                // 2. search scenario expense and calculate total expense amount
                List<Scenario_Expense__c> sceneExpenseList = [select Id, Name, Amount__c from Scenario_Expense__c where Scenario_Id__c = :sceneId ];
                if(sceneExpenseList !=null && sceneExpenseList.size() > 0) {
                    totalAmount = 0;
                    wrapper.userScenarioExpense = sceneExpenseList;
                    for(Scenario_Expense__c expenseAmt : sceneExpenseList) {
                        if(expenseAmt.Amount__c != null) {
                            totalAmount += expenseAmt.Amount__c;             
                        }
                        else {
                            totalAmount += 0; 
                        }
                    }
                    wrapper.totalExpenseAmount = totalAmount;
                }
                else {
                    emptyList = new List<sObject>();
                    Scenario_Expense__c sc = new Scenario_Expense__c();
                    sc.Amount__c = 0;
                    emptyList.add(sc);
                    wrapper.userScenarioExpense = (List<Scenario_Expense__c>) emptyList;
                    wrapper.totalExpenseAmount = 0; 
                }
                
                // 3. search scenario goals and calculate total goal amount
                List <Scenario_Goal__c> sceneGoal = [select name, Scenario_Target_Amount__c from Scenario_Goal__c where Scenario__c = :sceneId];
                if(sceneGoal != null && sceneGoal.size() > 0)   {
                    totalAmount = 0;
                    wrapper.userScenarioGoal = sceneGoal; 
                    for(Scenario_Goal__c goalAmt : sceneGoal){
                        if(goalAmt.Scenario_Target_Amount__c != Null)  {
                            totalAmount += goalAmt.Scenario_Target_Amount__c;
                        }
                        else {
                            totalAmount += 0;  
                        }
                    }
                    wrapper.totalGoalAmount = totalAmount;
                }
                
                // 4. search scenario loans and calculate total loan amount
                List <Scenario_Debt__c> sceneLoan = [select Name, Current_Value__c, Payment_Amount__c, APR__c,Frequency__c from Scenario_Debt__c where Scenario_Id__c = :sceneId];
                if(sceneLoan != null && sceneLoan.size() > 0)   {
                    totalAmount = 0;
                    wrapper.userScenarioLoan = sceneLoan; 
                    for(Scenario_Debt__c loanAmt : sceneLoan){
                        if(loanAmt.Payment_Amount__c != Null) {
                            totalAmount += loanAmt.Payment_Amount__c;
                        }
                        else {
                            totalAmount += 0;
                        }
                    }
                    wrapper.totalLoanAmount = totalAmount;
                }
                
                // 5. search scenario credit card and calculate total credit card amount
                List <FinServ__FinancialAccount__c> sceneCard = [select Name, FinServ__LoanAmount__c, APR__c from FinServ__FinancialAccount__c where Scenario_Id__c = :sceneId];
                if(sceneCard != null && sceneCard.size() > 0 )   {
                    totalAmount = 0;
                    wrapper.userScenarioCard = sceneCard; 
                    for(FinServ__FinancialAccount__c cardAmt : sceneCard) {
                        if(cardAmt.FinServ__LoanAmount__c != null) {
                            totalAmount += cardAmt.FinServ__LoanAmount__c;
                        }
                        else {
                            totalAmount += 0;
                        }
                    }
                    wrapper.totalCardAmount = totalAmount;
                }
                
                // 6. search scenario savinngs and calculate total saving amount
                List<Scenario_Savings__c> sceneSaveList = [select name, Current_Value__c, APY__c from Scenario_Savings__c where Scenario__c = :sceneId];
                if(sceneSaveList != null && sceneSaveList.size() > 0) {
                    totalAmount = 0;
                    wrapper.userSceneSave = sceneSaveList;
                    for(Scenario_Savings__c saveAmt : sceneSaveList) {
                        if(saveAmt.Current_Value__c != Null) {
                            totalAmount += saveAmt.Current_Value__c;
                        }
                        else {
                            totalAmount += 0;
                        }
                    }
                    wrapper.totalSaveAmount = totalAmount;
                }
                
                
                // 7. List of iteration objects on the UI for name on select
                if(sceneList.size() > 0) {
                    wrapper.userScenario = sceneList;
                }
                else {
                    emptyList = new List<sObject>();
                    Scenario__c sc = new Scenario__c();
                    emptyList.add(sc);
                    wrapper.userScenario  = (List<Scenario__c>) emptyList;
                }
                
                // call to getRequestData for to send request data 
                List<Scenario_Income__c> incomeList = [Select Amount__c from Scenario_Income__c  where Scenario_Id__c = :sceneId ];
                List<Scenario_Expense__c> expenseList = [Select Amount__c from Scenario_Expense__c  where Scenario_Id__c = :sceneId ];
                List<Scenario_Savings__c> fAccList = [Select id, Name, Current_Value__c,APY__c from Scenario_Savings__c where Scenario__c = :sceneId];
                List<Scenario_Debt__c> debtAccList = [select Name, APR__c, Current_Value__c, Payment_Amount__c from Scenario_Debt__c where Scenario_Id__c = :sceneId ];
                
                List<Scenario_Goal__c> goalList = [select Scenario_Current_Amount__c, Name,  Scenario_Monthly_Contribution__c,Scenario_Goal_Priority__c, Scenario_Start_Date__c, 
                                                   Scenario_Target_Amount__c, Scenario_Target_Date__c, Associated_Account__c 
                                                   //Annual_Growth_Rate__c
                                                   from Scenario_Goal__c where Scenario__c = :sceneId ];
                
                /*List<Scenario_Goal__c> goalList = [select Start_Value__c, Name,  Required_Monthly_Saving__c,Goal_Priority__c, Start_Date__c, FinServ__TargetValue__c,
                                                            Annual_Growth_Rate__c, FinServ__TargetDate__c, Associated_Account__c from Scenario_Goal__c where Scenario_Id__c = :sceneId ];*/
                
                //call the build utility in Utility call to build scenario data
                String reqData = FinacastUtility.buildScenarioRequestData2(incomeList, expenseList, fAccList, debtAccList,  goalList, sceneId, ac.Id);
                System.debug('Server Request in Scenario: ' + reqData);
                
                //Make Callout 
                wrapper.response = FinacastUtility.getCalloutResponseContents(requestEndpoint, 'POST', reqData);
                System.debug('Scenario Exists Response Data: ' + wrapper.response);
                wrapper.scenarioList = [select Name, Id from Scenario__c where Client_Id__c = :ac.Id order by LastModifiedDate DESC]; 
            }
            
            //case 2. no scenario
            else {
                System.debug('No Scenarios yet');
                emptyList = new List<sObject>();
                //Budget__c sc = new Budget__c();
                //sc.amount__c = 0;
                //emptyList.add(sc);
                
                wrapper.userScenarioIncome = (List<Scenario_Income__c>) emptyList;
                wrapper.totalIncomeAmount = 0; 
                
                wrapper.userScenarioExpense = (List<Scenario_Expense__c>) emptyList;
                wrapper.totalExpenseAmount = 0; 
                
                wrapper.userSceneSave = (List<Scenario_Savings__c>) emptyList; 
                wrapper.totalSaveAmount = 0;
                
                wrapper.userScenarioLoan = (List<Scenario_Debt__c>) emptyList;
                wrapper.totalLoanAmount = 0;
                
                wrapper.userScenarioCard = (List<FinServ__FinancialAccount__c>) emptyList;
                wrapper.totalCardAmount = 0;
                
                /*emptyList = new List<sObject>();
                FinServ__FinancialAccount__c facc = new FinServ__FinancialAccount__c();
                facc.FinServ__Balance__c = 0;
                facc.FinServ__LoanAmount__c = 0;
                facc.FinServ__PaymentAmount__c = 0;
                emptyList.add(facc);
                */
                
                emptyList = new List<sObject>();
                Scenario_Goal__c fGoal = new Scenario_Goal__c();
                fGoal.Scenario_Target_Amount__c = 0;
                emptyList.add(fGoal);
                wrapper.userScenarioGoal = (List <Scenario_Goal__c>) emptyList;
                wrapper.totalGoalAmount = 0;
                
                emptyList = new List<sObject> ();
                Scenario__c s = new Scenario__c();
                s.Name = '';
                emptyList.add(s);
                wrapper.userScenario = (List<Scenario__c>) emptyList;
                
                system.debug('No Scenario response Wrappr: '+wrapper);
                wrapper.scenarioList = [select Name, Id from Scenario__c where Client_Id__c = :ac.Id order by LastModifiedDate DESC];
            }//end else
            
        }//end catch
        
        catch(Exception e){  FinacastUtility.ExceptionHandle(e.getLineNumber(), e.getMessage(), e.getStackTraceString()); }
        
        return wrapper;  
    }//end init
    
        
    
    // get recordTypeId to create records for goals, loan, savings, credit card 
    @AuraEnabled
    public static String getRecordTypeId(String recName){
        String recId;
        
        if(recName == 'goal button') {
            recId = goalsRecId;
        }
        if(recName == 'loan button') {
            recId = loansRecId;
        }
        if(recName == 'saving button') {
            recId = savingsRecId;
        }
        if(recName == 'credit card button') {
            recId = cardRecId;
        }
        
        return recId;
    }
    
    
    //to save the scenario to  Scenario__c object -----> calling js function: onScenarioSaveIcon()
    @AuraEnabled
    public static List<sObject> saveRecord(String recName, String clientId, String recType, String sceneId, Decimal incomeAmount, Decimal expenseAmount, String recordId) {
        
        Boolean status = false;
        Boolean hhStatus = false;
        List<sObject> recordList = new List<sObject>();
        Account accPrimaryOwn;							
        String primaryOwner;
        
        //insert new scenario
        List<Id> client = new List<Id>();
        try{
            if(recType == 'scenario') {
                List<Scenario__c> sceneList = [select Name, Client_Id__c from Scenario__c];
                for(Scenario__c s : sceneList){
                    if(s.Name == recName && s.Client_Id__c ==  clientId) {
                        status = true;				// scenario exist with the same name for the client
                    }
                }
                
                // status = false i.e scenario doesn't exist, if scenario is saved, clone income -> amount , expense -> , savings, credit card, loan, goals of the user from budget__c
                if(status == false) {
                    Account acc = [select id, RecordTypeId from Account where id = :clientId];
                    if(acc.RecordTypeId == houseHoldRecId) {
                        AccountContactRelation acr  = [Select id,ContactId, Account.Id from AccountContactRelation where AccountId = :clientId AND FinServ__Primary__c = true ]; 
                        id acrCon = acr.ContactId;
                        accPrimaryOwn = [select id from Account where FinServ__PrimaryContact__c = :acrCon];
                        hhStatus = true;
                        system.debug('aa'+acrCon);
                    }
                    Decimal totalIncome = 0;
                    Scenario__c scene = new Scenario__c();
                    scene.Name = recName;
                    scene.Client_Id__c = clientId;
                    insert scene; 
                    if(sceneId == null) {
                        sceneId = scene.Id;
                    }
                    Account clientName = [select name from Account where id = :clientId];
                    Scenario__c sceneName = [select name from Scenario__c where id = :sceneId];
                    
                    //insert income
                    Id recIdIncome = FinacastUtility.getRecordTypeId('Budget__c' , 'Income_Record_Type');
                    List<Budget__c> scIncome;
                    if(hhStatus == false) {
                        scIncome = [select id, Amount__c from Budget__c where Primary_Owner__c = :clientId AND RecordTypeId = :recIdIncome AND Scenario_Id__c = null];
                        primaryOwner = clientId;
                    }
                    else {
                        scIncome = [select id, Amount__c from Budget__c where HouseHold__c = :clientId AND RecordTypeId = :recIdIncome AND Scenario_Id__c = null];
                        primaryOwner = accPrimaryOwn.Id;
                    }
                    if(scIncome.size() > 0) {
                        totalIncome = 0;
                        for(Budget__c b : scIncome) {
                            if(b.Amount__c != Null) {
                                totalIncome += b.Amount__c; 
                            }
                            else {
                                totalIncome += 0;
                            }
                        }
                        Budget__c income = new Budget__c();
                        income.Name = 'Income'+ clientName.Name + sceneName.Name ;
                        income.Primary_Owner__c = primaryOwner;
                        income.RecordTypeId = incomeRecId;
                        income.Scenario_Id__c = sceneId;
                        income.Amount__c = totalIncome;
                        //---> problem is here
                        insert income;
                    }
                    
                    //insert expense
                    Id recIdExpense = FinacastUtility.getRecordTypeId('Budget__c' , 'Expense_Record_Type');
                    List<Budget__c> scExpense;
                    if(hhStatus == false) {
                        scExpense = [select Amount__c from Budget__c where Primary_Owner__c = :clientId AND RecordTypeId = :recIdExpense AND Scenario_Id__c = null]; 
                        primaryOwner = clientId;
                    }
                    else {
                        scExpense = [select id, Amount__c from Budget__c where HouseHold__c = :clientId AND RecordTypeId = :recIdExpense AND Scenario_Id__c = null];
                        primaryOwner = accPrimaryOwn.Id;
                    }
                    if(scExpense.size() > 0) {
                        totalIncome = 0;
                        for(Budget__c b : scExpense) {
                            if(b.Amount__c != Null) {
                                totalIncome += b.Amount__c; 
                            }
                            else {
                                totalIncome += 0;
                            }
                        }
                        Budget__c expense = new Budget__c();
                        expense.Name = 'Expense' + clientName.Name + sceneName.Name;
                        expense.Primary_Owner__c = primaryOwner;
                        expense.Scenario_Id__c =sceneId;
                        expense.RecordTypeId = expenseRecId;
                        expense.Amount__c = totalIncome;
                        //problem is here--> no start or end date
                        insert expense;   
                    }                
                    
                    //insert loan
                    List<Scenario_Debt__c> scLoan;
                    List<Scenario_Debt__c> newLoanList = new  List<Scenario_Debt__c>();
                    if(hhStatus == false) {
                        scLoan = [select Name,Current_Value__c,Payment_Amount__c, APR__c,Frequency__c from Scenario_Debt__c where Client_Id__c = :clientId  AND Scenario_Id__c = null ];
                        primaryOwner = clientId;
                    }
                    else {
                        scLoan = [select Name,id,Current_Value__c,Payment_Amount__c, APR__c,Frequency__c from Scenario_Debt__c where Client_Id__c = :clientId  AND Scenario_Id__c = null ];    
                        primaryOwner = accPrimaryOwn.Id;
                    }
                    if(scLoan.size() > 0) {
                        for(Scenario_Debt__c sc : scLoan) {
                            Scenario_Debt__c loan = new Scenario_Debt__c();
                            loan.Client_Id__c = primaryOwner;
                            loan.Scenario_Id__c = sceneId;                 
                            loan.Name = sc.Name;
                            loan.APR__c = sc.APR__c;
                            loan.Current_Value__c = sc.Current_Value__c;
                            loan.Frequency__c = sc.Frequency__c;
                            loan.Payment_Amount__c = sc.Payment_Amount__c;
                            //loan.Account_Type__c = 'Loan';
                            newLoanList.add(loan);
                        }
                        insert newLoanList;
                    }
                    
                    //insert credit cards
                    List<FinServ__FinancialAccount__c> scCard;
                    List<FinServ__FinancialAccount__c> newCardList = new  List<FinServ__FinancialAccount__c> ();
                    
                    if(hhStatus == false) {
                        
                        scCard = [select Name, FinServ__LoanAmount__c, APR__c from FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c = :clientId AND RecordTypeId = :recIdCard AND Scenario_Id__c = null ];
                        primaryOwner = clientId;
                    }
                    else {
                        scCard = [select Name, FinServ__LoanAmount__c, APR__c from FinServ__FinancialAccount__c where FinServ__Household__c = :clientId AND RecordTypeId = :recIdCard AND Scenario_Id__c = null ];   
                        primaryOwner = accPrimaryOwn.Id;
                    }
                    if(scCard.size() > 0) {
                        for(FinServ__FinancialAccount__c sc : scCard) {
                            FinServ__FinancialAccount__c card = new FinServ__FinancialAccount__c();
                            card.FinServ__PrimaryOwner__c = primaryOwner;
                            card.Scenario_Id__c = sceneId;
                            card.RecordTypeId = cardRecId;
                            card.Name = sc.Name;
                            card.FinServ__LoanAmount__c = sc.FinServ__LoanAmount__c;
                            card.APR__c = sc.APR__c;
                            card.Account_Type__c = 'Credit Card';
                            newCardList.add(card);
                        }
                        insert newCardList;
                    }
                    
                    //insert savings
                    List<Scenario_Savings__c> scSaving;
                    Map <String, Scenario_Savings__c> bankAcc = new Map <String, Scenario_Savings__c>();			// to map scenario savings with scenario financial goals
                    
                    if(hhStatus == false) {
                        scSaving = [select name, Current_Value__c, APY__c, End_Date__c from Scenario_Savings__c where Client_Id__c = :clientId AND Scenario__c = null];
                        primaryOwner = clientId;
                    }
                    else {
                        scSaving = [select name, Current_Value__c, APY__c, End_Date__c from Scenario_Savings__c where Client_Id__c = :clientId AND Scenario__c = null];
                        primaryOwner = accPrimaryOwn.Id;
                    }
                    if(scSaving.size() > 0) {
                        for(Scenario_Savings__c sc : scSaving) {
                            Scenario_Savings__c savings = new Scenario_Savings__c();
                            savings.Client_Id__c = primaryOwner;
                            savings.Scenario__c = sceneId;
                            
                            savings.Name = sc.Name;
                            savings.Current_Value__c = sc.Current_Value__c;
                            savings.APY__c = sc.APY__c;
                            //savings.FinServ__FinancialAccountType__c = sc.FinServ__FinancialAccountType__c;    
                            savings.End_Date__c = sc.End_Date__c;
                            //savings.FinServ__FinancialAccountType__c = sc.FinServ__FinancialAccountType__c;
                            bankAcc.put(sc.Id,savings);
                        }
                        insert bankAcc.values();
                    }
                    
                    //insert goals
                    List<FinServ__FinancialGoal__c> scGoal;
                    List<FinServ__FinancialGoal__c> newgoalList = new List<FinServ__FinancialGoal__c>();
                    if(hhStatus == false) {
                        scGoal = [select Name, RecordType.DeveloperName, Start_Value__c,Goal_Priority__c,Required_Monthly_Saving__c, Associated_Account__c, FinServ__TargetValue__c, FinServ__TargetDate__c from FinServ__FinancialGoal__c where FinServ__PrimaryOwner__c = :clientId AND Scenario_Id__c = null AND RecordTypeId != :goalsRecId]; 
                        primaryOwner = clientId;
                    }
                    else {
                        scGoal = [select Name, RecordType.DeveloperName, Start_Value__c,Goal_Priority__c,Required_Monthly_Saving__c, Associated_Account__c, FinServ__TargetValue__c, FinServ__TargetDate__c from FinServ__FinancialGoal__c where FinServ__Household__c = :clientId AND Scenario_Id__c = null AND RecordTypeId != :goalsRecId]; 
                        primaryOwner = accPrimaryOwn.Id; 
                    }
                    if(scGoal.size() > 0) {
                        List<String> goalType = new List<String>();
                        for(FinServ__FinancialGoal__c g :scGoal) {
                            FinServ__FinancialGoal__c goals = new  FinServ__FinancialGoal__c();
                            goalType = g.RecordType.DeveloperName.split('RecordType');
                            goals.FinServ__PrimaryOwner__c = primaryOwner;
                            goals.Scenario_Id__c = sceneId;
                            goals.RecordTypeId = goalsRecId;
                            goals.Name = g.Name;
                            goals.FinServ__TargetValue__c = g.FinServ__TargetValue__c;
                            goals.FinServ__TargetDate__c = g.FinServ__TargetDate__c;
                            goals.Start_Value__c = g.Start_Value__c;
                            goals.Goal_Priority__c = g.Goal_Priority__c;
                            goals.Required_Monthly_Saving__c = g.Required_Monthly_Saving__c;
                            goals.Scenario_Goal_Type__c = goalType[0]; 
                            goals.Associated_Account__c = bankAcc.get(g.Associated_Account__c).Id;
                            newgoalList.add(goals);
                        }
                        insert newgoalList;
                    }    
                }
                
                List<Scenario__c> scList = [select id, name from Scenario__c where Client_Id__c = :clientId];
                recordList = scList;
            }
            
            //insert/update scenaro income
            if(recType == 'income save') {
                System.debug('inside inceome');
                if(recordId != 'init') {
                    Scenario_Income__c scIncome = [select Amount__c from Scenario_Income__c where id = :recordId];  
                    scIncome.Amount__c = incomeAmount;
                    System.debug('inceome init');
                    upsert scIncome;
                }
                else {   System.debug('new Income');
                    
                    Scenario_Income__c scIncome = new Scenario_Income__c ();
                    scIncome.Client_Id__c = clientId ;
                    scIncome.Scenario_Id__c = sceneId;
                    scIncome.Name= 'Income 1';
                    //scIncome.RecordTypeId = incomeRecId;
                    date startDate = date.today();
					date endDate = startDate.addYears(10);
                    scIncome.Start_Date__c = startDate;
                    scIncome.End_Date__c = endDate;
                    scIncome.Amount__c = incomeAmount;
                    insert scIncome;
                }
                List<Budget__c> sceneIncomeList = [select Id, Name, Amount__c from Budget__c where Scenario_Id__c = :sceneId];
                recordList = sceneIncomeList;
            }
            
            //insert/update scenario expense
            if(recType == 'expense save') {
                if(recordId != 'init') {
                    Scenario_Expense__c scExpense = [select Amount__c from Scenario_Expense__c where id = :recordId];
                    system.debug('expense: ' + expenseAmount);
                    scExpense.Amount__c = expenseAmount;
                    upsert scExpense;   
                }
                else {   
                    Scenario_Expense__c scExpense = new Scenario_Expense__c ();
                    scExpense.Name = 'Expense 1';
                    scExpense.Client_Id__c = clientId ;
                    scExpense.Scenario_Id__c = sceneId;
                    date startDate = date.today();
					date endDate = startDate.addYears(10);
                    scExpense.Start_Date__c = startDate;
                    scExpense.End_Date__c = endDate;
                    //scExpense.RecordTypeId  = expenseRecId;
                    scExpense.Amount__c = expenseAmount; 
                    insert scExpense;
                }
                List<Scenario_Expense__c> sceneExpenseList = [select Id, Name, Amount__c from Scenario_Expense__c where Scenario_Id__c = :sceneId];
                recordList = sceneExpenseList;
            }
        }
        catch(Exception e){
            FinacastUtility.ExceptionHandle(e.getLineNumber(), e.getMessage(), e.getStackTraceString());
        }
        return recordList;
    }
    
    public class AmtContriWrapper {
        @AuraEnabled public Decimal currentAmt;
        @AuraEnabled public Decimal monthlyContri;
    }
    
    @AuraEnabled
    public static AmtContriWrapper getAmtContri (String accId, Decimal currentAmt, String tarDate, Decimal tarAmt) {
        AmtContriWrapper wrapper = new AmtContriWrapper();
        Double iRate = 0;
        try{
            if (accId != null && accId != '')
            {
                FinServ__FinancialAccount__c savingAcc = [select FinServ__Balance__c, FinServ__APY__c, APR__c, id from FinServ__FinancialAccount__c where id = :accId];
                Double bal = savingAcc.FinServ__Balance__c; 
                if(savingAcc.FinServ__APY__c != null)
                {
                    iRate = savingAcc.FinServ__APY__c;
                }
                if(savingAcc.APR__c != null)
                {
                    iRate =  savingAcc.APR__c;
                }
                else 
                    iRate = 0; 
                
                list<FinServ__FinancialGoal__c> allAssocGoals = [select Associated_Account__c, Required_Monthly_Saving__c, Start_Date__c, FinServ__TargetValue__c from FinServ__FinancialGoal__c where Associated_Account__c = :accId];
                
                Double totalEstimated = 0;
                Decimal remainingAmount = 0;
                Decimal growth=0;
                
                for(FinServ__FinancialGoal__c relgoal : allAssocGoals ) {
                    totalEstimated = totalEstimated + ((Decimal)FinacastGoalProgressApex.curentgoalestimation((double)(relgoal.Required_Monthly_Saving__c), relgoal.Start_Date__c, date.today(),growth)).setScale(2,RoundingMode.HALF_UP)+ relgoal.FinServ__TargetValue__c;
                }
                
                remainingAmount = bal - totalEstimated;
                if(remainingAmount < 0)
                {
                    remainingAmount = 0;    
                }
                double curr = Math.ceil( remainingAmount);       
                wrapper.currentAmt = Math.ceil( remainingAmount);
                system.debug('current amt'+wrapper.currentAmt);
                
                if(tarDate != null && tarAmt != null) {
                    Date targetDate = Date.valueOf(tarDate);
                    Decimal currentAmount;
                    if(currentAmt == null) {
                        currentAmount = curr;
                    }
                    else {
                        currentAmount = Double.valueOf(currentAmt);
                    }
                    
                    wrapper.monthlyContri = Math.ceil(getMonthlyContribution(currentAmount, tarAmt, targetDate, iRate ));
                }
                else {
                    wrapper.monthlyContri = 0;
                }
            } 
        }
        catch(Exception e){
            FinacastUtility.ExceptionHandle(e.getLineNumber(), e.getMessage(), e.getStackTraceString());
        }
        return wrapper;
        
    }
    
    /* to monthlyContribution
* called from apex function getAmtContri 
* ***/
    public static Decimal getMonthlyContribution(Decimal currentAmount, Decimal tarAmt, Date targetDate, Double  iRate ) {
        Integer months = (((targetDate.year())*12)+targetDate.month()) - ((((date.today()).year())*12)+date.today().month());
        
        if(months < 0) {
            months = Math.abs(months);
        }
        Double installment = 0;
        Double growth = (Math.pow((1 + ( iRate / 100)), (1/12)))- 1;
        Decimal monContri;
        system.debug('tarAmt'+tarAmt);
        system.debug('currentAmount'+currentAmount);
        system.debug('months'+months);
        
        If (tarAmt > (currentAmount * (Math.pow((1 + growth),months))))
        { 
            If (growth > 0) {
                installment = ((tarAmt - currentAmount * (Math.pow((1 + growth), months))) * growth) / ((Math.pow((1 + growth), months)) - 1);
            } 
            Else {
                installment = (tarAmt - currentAmount) / months;
            }
            monContri = installment;
        }
        Else {
            monContri = installment;
        }
        
        return Math.ceil(monContri);   
    }
    
}