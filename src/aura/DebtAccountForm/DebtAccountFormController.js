({
    doInit: function(component, event, helper) {
        // console.log(JSON.stringify(component.get("v.financialAccount")))
        if(component.get("v.financialAccount.Id")!=null){
            var accountType=component.get("v.financialAccount.Account_Type__c")
            // alert(accountType)
            if (accountType=='Loan'){
                component.set("v.isFixedTerm",true)
                component.set("v.accountType", 'Loan')
            }
            else{
                component.set("v.isFixedTerm",false)
                component.set("v.accountType", 'Credit Card')
                
            }
            // alert(component.get("v.financialAccount.Do_you_get_tax_benefit_from_interest_pay__c"))
            if (component.get("v.financialAccount.Do_you_get_tax_benefit_from_interest_pay__c")){
                // alert('yes')
                component.set("v.isTaxBenefit",true);
                
            }
            else{
                //alert("no")
                component.set("v.isTaxBenefit",false);
                
            }
            if(component.get("v.financialAccount.Do_tax_benefits_realize_monthly__c")){
                component.set("v.isMonthly",true)
            }
            else{
                component.set("v.isMonthly",false)
                
            }
        }
    },
    onClickCancel: function(component, event, helper) {
        component.set("v.showInModal",false)
    },
    handleSubmit: function(component, event, helper){
        component.set("v.disabled",true)
        
        helper.validateInput(component, event, "accounts"); 
        /* if(!valid){
            component.set("v.disabled",false)
            
            helper.showAlertEmptyInvalidVal(event);
        }*/
        //  alert('submit')
    },
    handleSuccess: function(component, event, helper){
        //alert('success')
        var event = component.getEvent("submitDebtForm");
        event.fire();
        //alert("set"+component.set("v.showInModal",false))
        component.set("v.showInModal",false);
    },
    handleFixTerm: function(component,event,helper){
        var selected = event.getSource().get("v.name");
        if (selected=='FixTerm'){
            component.set("v.isFixedTerm",true)
            component.set("v.accountType", 'Loan')
            component.find('pymamt').set("v.value", "")
            component.find('payfreq').set("v.value","")
            
        }
        
        else{
            component.find('pymamt').set("v.value", "")
            component.find('payfreq').set("v.value","")
            component.set("v.isFixedTerm",false)
            component.set("v.accountType", 'Credit Card')
            
        }
        
    },
    handleTaxBenefit: function(component,event,helper){
        var selected = event.getSource().get("v.name");
        if (selected=='TaxBenefit')
        {        
            component.set("v.isTaxBenefit",true)
            component.find('taxbenfit').set("v.value", "")
            component.set("v.isMonthly",true)
            component.find('deducationtax').set("v.value","")
        }
        else{
            component.find('taxbenfit').set("v.value", "")
            component.set("v.isMonthly",false)
            component.find('deducationtax').set("v.value","")
            component.set("v.isTaxBenefit",false)
        }
        
        
        
    },
    handleMonthly: function(component,event,helper){
        var selected = event.getSource().get("v.name");
        if (selected=='Monthly')
            component.set("v.isMonthly",true)
            else
                component.set("v.isMonthly",false)
                
                },
    createDebtAccount : function(component,event,helper){
        
        helper.validateInput(component, event, "firstAccount"); 
        /* if(!valid){
            component.set("v.disabled",false)
            
            helper.showAlertEmptyInvalidVal(event);
        }
        else{
            component.find('form').submit();
            
        }*/
    }
})