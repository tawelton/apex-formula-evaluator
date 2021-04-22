public class RoutingEngine {

    private Map<Id,List<Routing_Rule__c>> routingRuleMap = new Map<Id,List<Routing_Rule__c>>();
    private List<Routing_Rule__c> tierOneRules = new List<Routing_Rule__c>();

    public void runEngine(SObject record){
        getRoutingRules(record);
        Routing_Rule__c parentRule;
        for (Routing_Rule__c routingRule : tierOneRules) {
            // Lex and parse rule's formula
            FormulaEngine fEngine = new FormulaEngine(routingRule.Formula__c);
            // Run formula engine
            Object result = fEngine.runEngine(record);
            if (result == true) {
                
            }
        }
    }

    public void getRoutingRules(SObject record) {
        routingRuleMap = new Map<Id,List<Routing_Rule__c>>();
        tierOneRules = new List<Routing_Rule__c>();
        String objectName = recordId.getSObjectType().getDescribe().getName();
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


    // TO BE EXPANDED TO DO N-LEVEL QUERYING
    public SObject queryRecord(Id recordId) {
        String objectName = recordId.getSObjectType().getDescribe().getName();
        String fieldsString = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
         
        if (fieldMap != null){
            // Loop through all field tokens
            for (Schema.SObjectField fieldToken : fieldMap.values()){
                // Describe each field
                Schema.DescribeFieldResult field = fieldToken.getDescribe();
                // Compile field
                fieldsString += field.getName() + ',';
            }
        }
         
        // Remove trailing ','
        if (fieldsString.endsWith(',')){
            fieldsString = fieldsString.substring(0,fieldsString.lastIndexOf(','));
        }
         
        String queryString = 'SELECT ' + fieldsString + ' FROM ' + objectName + ' WHERE Id=\''+recordId+'\'';
        return Database.query(queryString);
    }
}
