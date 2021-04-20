public with sharing class ExpressionInterpreter {

    
    //  TOKENIZED MAP
    public static Map<String, String> tokenMap = new Map<String, String>();
    
    // TOKEN TYPES
    private static final String STRING_TOKEN = 'String';
    private static final String NUMBER_TOKEN = 'Number';
    private static final String VARIABLE_TOKEN = 'Variable';
    private static final String LOGICAL_TOKEN = 'Logical';
    private static final String OPERATOR_TOKEN = 'Operator';

    // TOKEN VALUES
    private static final String STRINGS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"\'';
    private static final String NUMBERS = '0123456789';
    private static final String OPERATORS = '+-*/<>=!';
    private static final String LOGICALS = '&&||';
    // Treat special characters as their own token

    public static Map<String, String> tokenize(String formula){

    }
    
}
