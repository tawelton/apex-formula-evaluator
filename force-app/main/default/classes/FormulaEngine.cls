public with sharing class FormulaEngine {

    public static Object evaluate(String formula, SObject record){
        // tokenize the formula
        FormulaEngine_Lexer lexer = new FormulaEngine_Lexer();
        List<FormulaEngine_Lexer.Token> tokens = lexer.tokenize(formula);

        // parse the tokens to create a syntax tree
        FormulaEngine_Parser parser = new FormulaEngine_Parser();
        FormulaEngine_Parser.SyntaxBranch syntaxTree = parser.parseTokens(tokens);

        // evaluate the syntax
        return syntaxTree.evaluateSubBranches(record);
    }

    @AuraEnabled
    public static Object validate(String formula){
        // tokenize the formula
        FormulaEngine_Lexer lexer = new FormulaEngine_Lexer();
        List<FormulaEngine_Lexer.Token> tokens = lexer.tokenize(formula);

        // parse the tokens to create a syntax tree
        FormulaEngine_Parser parser = new FormulaEngine_Parser();
        FormulaEngine_Parser.SyntaxBranch syntaxTree = parser.parseTokens(tokens);
        return syntaxTree;
    }

    // public SObject queryRecord(Id recordId) {
    //     String objectName = recordId.getSObjectType().getDescribe().getName();
    //     String fieldsString = '';
    //     // Get a map of field name and field token
    //     Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
         
    //     if (fieldMap != null){
    //         // Loop through all field tokens
    //         for (Schema.SObjectField fieldToken : fieldMap.values()){
    //             // Describe each field
    //             Schema.DescribeFieldResult field = fieldToken.getDescribe();
    //             // Compile field
    //             fieldsString += field.getName() + ',';
    //         }
    //     }
         
    //     // Remove trailing ','
    //     if (fieldsString.endsWith(',')){
    //         fieldsString = fieldsString.substring(0,fieldsString.lastIndexOf(','));
    //     }
         
    //     String queryString = 'SELECT ' + fieldsString + ' FROM ' + objectName + ' WHERE Id=\''+recordId+'\'';
    //     return Database.query(queryString);
    // }
}