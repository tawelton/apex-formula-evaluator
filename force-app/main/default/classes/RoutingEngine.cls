public class RoutingEngine {

    private Map<Id,List<Routing_Rule__c>> routingRuleMap = new Map<Id,List<Routing_Rule__c>>();
    private List<Routing_Rule__c> tierOneRules = new List<Routing_Rule__c>();
    private SObject record;

    public void runEngine(SObject recordToBeRouted){
        record = recordToBeRouted;
        getRoutingRules();
        evaluateRules(tierOneRules);
    }

    public void evaluateRules(List<Routing_Rule__c> routingRules) {
        Boolean foundMatchInTier = false;
        for (Routing_Rule__c routingRule : tierOneRules) {
            if (foundMatchInTier != true) {
                evaluateRule(routingRule);
            } else {
                break;
            }
        }
    }

    public void evaluateRule(Routing_Rule__c routingRule) {
        // Run formula engine
        Object result = FormulaEngine.evaluate(routingRule.Formula__c,record);
        if (result == true) {
            if (routingRuleMap.get(routingRule.Id) != null) {
                evaluateRules(routingRuleMap.get(routingRule.Id));
            } else {
                performAction(routingRule);
            }
        }
    }

    public void performAction(Routing_Rule__c routingRule) {
        record.put(routingRule.Action_Field_Developer_Name__c,routingRule.Action_Field_Value__c);
        //update record;
    }

    public void getRoutingRules() {
        routingRuleMap = new Map<Id,List<Routing_Rule__c>>();
        tierOneRules = new List<Routing_Rule__c>();
        String objectName = record.getSObjectType().getDescribe().getName();
        String queryString = 'SELECT Id,Action_Field_Developer_Name__c,Action_Field_Value__c,Action_Type__c,Formula__c,Order__c,Parent__c FROM Routing_Rule__c WHERE Object_Developer_Name__c=\''+objectName+'\' ORDER BY Parent__c,Order__c';
        for (Routing_Rule__c routingRule : Database.query(queryString)) {
            if (routingRule.Parent__c != null) {
                // First rule under parent
                if (routingRuleMap.get(routingRule.Parent__c) == null) {
                    routingRuleMap.put(routingRule.Parent__c,new List<Routing_Rule__c>{routingRule});
                }
                // Rules already found under parent
                else {
                    routingRuleMap.get(routingRule.Parent__c).add(routingRule);
                }
            }
            // Tier 1
            else {
                tierOneRules.add(routingRule);
            }
        }
    }
}
