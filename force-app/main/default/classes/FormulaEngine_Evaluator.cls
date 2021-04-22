public with sharing class FormulaEngine_Evaluator {
    // Function and Operator node types
    private Set<String> unaryTypes = new Set<String>{'unaryFunction', 'unaryOperator'};
    private Set<String> binaryTypes = new Set<String>{'binaryFunction', 'binaryOperator'};

    // SObject queried record
    public SObject record;

    public Object evaluate(FormulaEngine_Parser.SyntaxBranch branch){
        if(branch.value == 'and' || branch.value == 'or'){
            Boolean LHS = (Boolean)evaluateBranch(branch.subBranches[0]);
            Boolean RHS = (Boolean)evaluateBranch(branch.subBranches[1]);
            return (Object)(branch.value == 'and' ? (LHS && RHS) : (LHS || RHS));
        }
        else{
            // TO-DO: Error Handler
            return null;
        }
    }

    public Object evaluateBranch(FormulaEngine_Parser.SyntaxBranch branch){
        FormulaEngine_Functions formulaEng = new FormulaEngine_Functions();
        if(branch.type.contains('binary')){
            Object LHS = evaluateBranch(branch.subBranches[0]);
            Object RHS = evaluateBranch(branch.subBranches[1]);
            // call function class methods
            if(branch.value == 'and'){
                return formulaEng.f_and((Boolean)LHS, (Boolean)RHS);
            }
            else if(branch.value == 'or'){
                return formulaEng.f_or((Boolean)LHS, (Boolean)RHS);
            }
            else if(branch.value == 'begin'){
                return formulaEng.f_begins((String)LHS, (String)RHS);
            }
            else if(branch.value == 'ends'){
                return formulaEng.f_ends((String)LHS, (String)RHS);
            }
            else if(branch.value == 'contains'){
                return formulaEng.f_contains((String)LHS, (String)RHS);
            }
            else if(branch.value == 'left'){
                return formulaEng.f_left((String)LHS, (String)RHS);
            }
            else if(branch.value == 'right'){
                return formulaEng.f_right((String)LHS, (String)RHS);
            }
            else if(branch.value == 'add'){
                return formulaEng.f_add((String)LHS, (String)RHS);
            }
            else if(branch.value == 'subtract'){
                return formulaEng.f_sub((String)LHS, (String)RHS);
            }
            else if(branch.value == 'multiply'){
                return formulaEng.f_mult((String)LHS, (String)RHS);
            }
            else if(branch.value == 'divide'){
                return formulaEng.f_div((String)LHS, (String)RHS);
            }
            else if(branch.value == 'equals'){
                return formulaEng.f_equals((String)LHS, (String)RHS);
            }
            else if(branch.value == 'not-equals'){
                return formulaEng.f_not_equals((String)LHS, (String)RHS);
            }
            else if(branch.value == 'less-than'){
                return formulaEng.f_less_than((String)LHS, (String)RHS);
            }
            else if(branch.value == 'le'){
                return formulaEng.f_le((String)LHS, (String)RHS);
            }
            else if(branch.value == 'greater-than'){
                return formulaEng.f_greater_than((String)LHS, (String)RHS);
            }
            else if(branch.value == 'ge'){
                return formulaEng.f_ge((String)LHS, (String)RHS);
            }
            else{
                // TO-DO: Error Handler
                return null;
            }

        }
        else if(branch.type.contains('unary')){
            Object LHS = evaluateBranch(branch.subBranches[0]);
            // call function class methods
            if(branch.value == 'isblank'){
                return formulaEng.f_isblank((String)LHS);
            }
            else if(branch.value == 'len'){
                return formulaEng.f_len((String)LHS);
            }
            else if(branch.value == 'not'){
                return formulaEng.f_not((Boolean)LHS);
            }
            else if(branch.value == 'text'){
                return formulaEng.f_text((Decimal)LHS);
            }
            else if(branch.value == 'value'){
                return formulaEng.f_value((String)LHS);
            }
            else{
                // TO-DO: Error Handler
                return null;
            }
        }
        else if (branch.type == 'fieldReference') {
            return getFieldReference(branch);
        }
        else{
            return evaluateEndNode(branch);
        }
    }

    public Object evaluateEndNode(FormulaEngine_Parser.SyntaxBranch branch){
        return (Object)branch.value;
    }

    public Object getFieldReference(FormulaEngine_Parser.SyntaxBranch branch){
        return (Object)record.get(branch.value);
    }
}