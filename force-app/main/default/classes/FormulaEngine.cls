public with sharing class FormulaEngine {
    /**
     * Used to evaluate Routing_Rule__r.Formula__c
    */    

    /**
     * Limitations:
     *  - Fires on trigger. Limited to 1st-level field data without querying
     */
    public static void evaluateFormula(String formula, Id recordId){
        // get name of SObject
        String objectName = recordId.getSObjectType().getDescribe().getName();
        // build record
        String query = createDynamicQuery(objectName, 'Id =: recordId');
        List<Object> records = Database.query(query);

        for(String letter : formula.replaceAll('\\s+', '').split('')){
            
        }
    }

    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static String createDynamicQuery(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ 
            return null; 
        }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause; 
    }

     /**
      * Class attributes:
      */
}
