public with sharing class FormulaEngine_Functions {

    public Object f_and(Boolean LHS, Boolean RHS){
        return (Object)(LHS && RHS);
    }

    public Object f_begins(String fieldValue, String beginningStr){
        return (Object)fieldValue.startsWith(beginningStr);
    }

    public Object f_contains(String fieldValue, String valueInField){
        return (Object)fieldValue.contains(valueInField);
    }

    public Object f_ends(String fieldValue, String endingStr){
        return (Object)fieldValue.endsWith(endingStr);
    }

    public Object f_isblank(String fieldValue){
        return (Object)String.isBlank(fieldValue);
    }

    public Object f_len(String fieldValue){
        return (Object)fieldValue.length();
    }

    public Object f_left(String fieldValue, Integer i){
        return (Object)fieldValue.left(i);
    }

    public Object f_not(Boolean expr){
        return (Object)(!expr);
    }

    public Object f_or(Boolean LHS, Boolean RHS){
        return (Object)(LHS || RHS);
    }

    public Object f_right(String fieldValue, Integer i){
        return (Object)fieldValue.right(i);
    }

    public Object f_text(Decimal numValue){
        return (Object)String.valueOf(numValue);
    }

    public Object f_value(String fieldValue){
        return fieldValue.isNumeric() ? (Object)Decimal.valueOf(fieldValue) : 
                                        (Object)null;
    }

    public Object f_add(String LHS, String RHS){
        Boolean isDecimal = (LHS.isNumeric() && RHS.isNumeric());
        return isDecimal ? (Object)(Decimal.valueOf(LHS) + Decimal.valueOf(RHS)) : 
                           (Object)(LHS + RHS);
    }

    public Object f_sub(Decimal LHS, Decimal RHS){
        return (Object)(LHS - RHS);
    }

    public Object f_mult(Decimal LHS, Decimal RHS){
        return (Object)(LHS * RHS);
    }

    public Object f_div(Decimal LHS, Decimal RHS){
        return (Object)(LHS / RHS);
    }

    public Object f_equals(String LHS, String RHS){
        return (Object)(LHS == RHS);
    }

    public Object f_not_equals(String LHS, String RHS){
        return (Object)(LHS != RHS);
    }

    public Object f_less_than(Decimal LHS, Decimal RHS){
        return (Object)(LHS < RHS);
    }

    public Object f_le(Decimal LHS, Decimal RHS){
        return (Object)(LHS <= RHS);
    }

    public Object f_greater_than(Decimal LHS, Decimal RHS){
        return (Object)(LHS > RHS);
    }

    public Object f_ge(Decimal LHS, Decimal RHS){
        return (Object)(LHS >= RHS);
    }

}
