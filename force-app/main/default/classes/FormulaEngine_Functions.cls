public with sharing class FormulaEngine_Functions {

    // Supported methods
    private static final Set<String> METHOD_NAMES = new Set<String>{'AND', 
                                                                    'BEGINS', 
                                                                    'CONTAINS', 
                                                                    'ENDS', 
                                                                    'ISBLANK', 
                                                                    'LEN', 
                                                                    'LEFT', 
                                                                    'NOT', 
                                                                    'OR', 
                                                                    'RIGHT', 
                                                                    'TEXT', 
                                                                    'VALUE'};

    public static Boolean f_and(String LHS, String RHS){
        return (LHS && RHS);
    }

    public static String f_begins(String fieldValue, String beginningStr){
        return fieldValue.startsWith(beginningStr);
    }

    public static Boolean f_contains(String fieldValue, String valueInField){
        return fieldToCheck.contains(valueInField);
    }

    public static Boolean f_ends(String fieldValue, String endingStr){
        return fieldValue.endsWith(endingStr);
    }

    public static Boolean f_isblank(String fieldValue){
        return String.isBlank(fieldValue);
    }

    public static Integer f_len(String fieldValue){
        return fieldValue.length();
    }

    public static String f_left(String fieldValue, Integer i){
        return fieldValue.left(i);
    }

    public static Boolean f_not(Boolean expr){
        return !expr;
    }

    public static Boolean f_or(String LHS, String RHS){
        return (LHS || RHS);
    }

    public static String f_right(String fieldValue, Integer i){
        return fieldValue.right(i);
    }

    public static String f_text(Decimal numValue){
        return String.valueOf(numValue);
    }

    public static Decimal f_value(String fieldValue){
        
        return fieldValue.isNumeric() ? Decimal.valueOf(fieldValue) : null;
    }
}
