public with sharing class FormulaEngine_Parser {

    // Token types
    private List<String> binaryFunctions = new List<String>{'and','or','begins','ends','contains','left','right'};
    private List<String> binaryOperators = new List<String>{'and','or','add','subtract','multiply','divide','equals','not-equals','less-than','le','greater-than','ge'};
    private List<String> comboBinaryOperators = new List<String>{'and','or'};
    private List<String> unaryFunctions = new List<String>{'isblank','not','len','text','value'};
    private List<String> unaryOperators = new List<String>{'not'};

    // Token info
    private FormulaEngine_Lexer.Token currentToken;
    private Integer currentTokenIndex = -1;
    private List<FormulaEngine_Lexer.Token> tokens;

    // Branch info
    private SyntaxBranch previousBranch;


    public class SyntaxBranch {
        public String type;
        public String value;
        public List<SyntaxBranch> subBranches;

        // public Object evaluateSubBranches(){
        //     List<Object> evaluatedResults = new List<Object>();
        //     if (this.subBranches != null) {
        //         for (SyntaxBranch subBranch : this.subBranches) {
        //             evaluatedResults.add(subBranch.evaluateSubBranches());
        //         }
        //         return FormulaEngine_Evaluator.evaluateBranch(this,evaluatedResults);
        //     } else {
        //         return FormulaEngine_Evaluator.evaluateBranch(this);
        //     }
        // }

        public void readSubBranches(){
            if (this.subBranches != null) {
                for (SyntaxBranch subBranch : this.subBranches) {
                    if (subBranch.subBranches != null) {
                        system.debug(subBranch.type + ' - ' + subBranch.value);
                    }
                    subBranch.readSubBranches();
                }
            } else {
                system.debug(this.type + ' - ' + this.value);
            }
        }
    }

    public SyntaxBranch parseTokens(List<FormulaEngine_Lexer.Token> lexedTokens) {
        tokens = lexedTokens;
        nextToken();

        SyntaxBranch syntaxTree = new SyntaxBranch();

        // Evaluate each token created from lexer
        while (currentTokenIndex < tokens.size()) {

            syntaxTree = routeToken();
            system.debug(syntaxTree);

            nextToken();
        }

        return syntaxTree;
    }

    private void nextToken() {
        currentTokenIndex += 1;
        currentToken = currentTokenIndex < tokens.size() ? tokens[currentTokenIndex] : null;
    }

    private SyntaxBranch routeToken() {
        // Opening parenthese
        if (currentToken.key == 'open-paren') {
            return parentheseBranch();
        } 
        // Functions
        else if (currentToken.key == 'string') {
            // Binary Functions
            if (binaryFunctions.contains(currentToken.value.toLowerCase())) {
                return binaryFunctionBranch();
            }
             // Unary Functions
            else if (unaryFunctions.contains(currentToken.value.toLowerCase())) {
                return unaryFunctionBranch();
            } 
            // Invalid
            else {
                // Throw Error
                system.debug('Error line 134');
                // Inavlid syntax
            }
        } 
        // Binary Operators
        else if (binaryOperators.contains(currentToken.key.toLowerCase())) {
            return binaryOperatorBranch();
        } 
        // Unary Operators
        else if (unaryOperators.contains(currentToken.key.toLowerCase())) {
            return unaryOperatorBranch();
        }
        // Open Curly
        else if (currentToken.key == 'open-curly') {
            return fieldReferenceBranch();
        }
        // Open Quotes
        else if (currentToken.key == 'double-quote') {
            return literalStringBranch();
        } 
        // Numbers
        else if (currentToken.key == 'number') {
            return numberBranch();
        }
        // Invalid
        else {
            // Throw Error
            system.debug(currentToken);
            system.debug('Error line 148');
            // Inavlid syntax
        }
        return null;
    }

    private SyntaxBranch parentheseBranch() {
        system.debug('Parenthese Branch');
        system.debug(currentToken);
        SyntaxBranch parentheseBranch = new SyntaxBranch();
        parentheseBranch.type = 'parenthese';
        parentheseBranch.value = currentToken.key;
        List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
        SyntaxBranch argBranch;
        // Step to token after open-paren token
        nextToken();
        // Compile tokens until closed-paren
        while (currentTokenIndex < tokens.size() &&
            currentToken.key != 'closed-paren'
        ) {
            // Configure argument branch
            argBranch = routeToken();
            nextToken();
        }
        // Branch created for argument
        if (argBranch != null) {
            subBranches.add(argBranch);
        } else {
            // Throw Error
            system.debug('Error line 182');
            // First argument missing
        }
        // Ensure ending token is closed-paren (i.e. currentTokenIndex >= tokens.size())
        if (currentTokenIndex >= tokens.size() ||
            currentToken.key != 'closed=paren'
        ) {
            // Throw Error
            system.debug('Error line 188');
            // Missing ')'
        }
    
        // Set parentheseBranch subBranches
        parentheseBranch.subBranches = subBranches;

        // Update previousBranch to be the completed parenthese branch
        previousBranch = parentheseBranch;

        return parentheseBranch;
    }

    private SyntaxBranch binaryOperatorBranch(){
        system.debug('Binary Operator Branch');
        system.debug(currentToken);
        SyntaxBranch binaryOperatorBranch = new SyntaxBranch();
        binaryOperatorBranch.type = 'binaryOperator';
        binaryOperatorBranch.value = currentToken.key;

        // Ensure previousBranch and next token exist
        if (previousBranch != null &&
            (currentTokenIndex + 1) < tokens.size()
        ) {
            // subBranches for binary operator (2 branches)
            List<SyntaxBranch> subBranches = new List<SyntaxBranch>();

            // Save previousBranch info to place as subBranch on binary operator branch
            SyntaxBranch leftSubBranch = new SyntaxBranch();
            leftSubBranch.type = previousBranch.type;
            leftSubBranch.value = previousBranch.value;
            leftSubBranch.subBranches = previousBranch.subBranches;
            subBranches.add(leftSubBranch);

            // Configure rightSubBranch
            SyntaxBranch rightSubBranch;
            // Step to token after operator
            nextToken();
            // If valid token exists next
            if (currentTokenIndex < tokens.size()) {
                // Configure right hand side branch
                rightSubBranch = routeToken();
                // system.debug('currentToken');
                // system.debug(currentToken);
                // nextToken();
                // system.debug('currentToken');
                // system.debug(currentToken);
                FormulaEngine_Lexer.Token nextToken = (currentTokenIndex + 1) < tokens.size() ? tokens[currentTokenIndex+1] : null;
                if ((currentTokenIndex + 1) < tokens.size() &&
                    !comboBinaryOperators.contains(tokens[currentTokenIndex+1].key) &&
                    binaryOperators.contains(tokens[currentTokenIndex+1].key)
                ) {
                    nextToken();
                    rightSubBranch = routeToken();
                }
            }
            // Branch created for right hand side
            if (rightSubBranch != null) {
                subBranches.add(rightSubBranch);
            } else {
                // Throw Error
                system.debug('Error line 238');
                // Missing right hand side
            }

            // Set binaryOperatorBranch subBranches
            binaryOperatorBranch.subBranches = subBranches;

            // Update previousBranch to be the completed binary operator branch
            previousBranch = binaryOperatorBranch;

            // If not end of string, step back to comma or closed-paren
            // if (currentTokenIndex < tokens.size()) {
            //     prevToken();
            // }
        } else {
            // Throw Error
            system.debug('Error line 249');
        }

        return binaryOperatorBranch;
    }

    private SyntaxBranch unaryOperatorBranch(){
        system.debug('Unary Operator Branch');
        system.debug(currentToken);
        SyntaxBranch unaryOperatorBranch = new SyntaxBranch();
        unaryOperatorBranch.type = 'unaryOperator';
        unaryOperatorBranch.value = currentToken.key;

        // Ensure next token exists
        if ((currentTokenIndex + 1) < tokens.size()) {
            // subBranches for binary operator (1 branch)
            List<SyntaxBranch> subBranches = new List<SyntaxBranch>();

            // Configure argBranch
            SyntaxBranch argBranch;
            // Step to token after operator
            nextToken();
            // If valid token exists next
            if (currentTokenIndex < tokens.size()) {
                // Configure argument branch
                argBranch = routeToken();
                // nextToken();
            }
            // Branch created for argument
            if (argBranch != null) {
                subBranches.add(argBranch);
            } else {
                // Throw Error
                system.debug('Error line 282');
                // Missing argument
            }

            // Set unaryOperatorBranch subBranches
            unaryOperatorBranch.subBranches = subBranches;

            // Update previousBranch to be the completed unary operator branch
            previousBranch = unaryOperatorBranch;

            // If not end of string, step back to comma, closed-paren or operator/function token
            // if (currentTokenIndex < tokens.size()) {
            //     prevToken();
            // }
        } else {
            // Throw Error
            system.debug('Error line 293');
        }

        return unaryOperatorBranch;
    }

    private SyntaxBranch binaryFunctionBranch() {
        system.debug('Binary Function Branch');
        system.debug(currentToken);
        SyntaxBranch binaryFunctionBranch = new SyntaxBranch();
        binaryFunctionBranch.type = 'binaryFunction';
        binaryFunctionBranch.value = currentToken.value;

        // Ensure next token is an opening parenthese
        if ((currentTokenIndex + 1) < tokens.size() &&
            tokens[currentTokenIndex + 1].key == 'open-paren'
        ) {
            // Step to open-paren token
            nextToken();
            List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
            SyntaxBranch firstArgBranch;
            // Step to token after open-paren token
            nextToken();
            // If valid token exists next
            if (currentTokenIndex < tokens.size()) {
                // Configure argument branch
                firstArgBranch = routeToken();
                nextToken();
            }
            // Branch created for argument
            if (firstArgBranch != null) {
                subBranches.add(firstArgBranch);
            } else {
                // Throw Error
                system.debug('Error line 334');
                // First argument missing
            }
            // Ensure next token is a comma
            if (currentTokenIndex >= tokens.size() ||
                currentToken.key != 'comma'
            ) {
               // Throw Error
               system.debug('Error line 322: '+currentToken.key);
               // Missing ','
            }
            SyntaxBranch secondArgBranch;
            // Step to token after comma token
            nextToken();
            // If valid token exists next
            if (currentTokenIndex < tokens.size()) {
                // Configure argument branch
                secondArgBranch = routeToken();
                nextToken();
            }
            // Branch created for argument
            if (secondArgBranch != null) {
                subBranches.add(secondArgBranch);
            } else {
                // Throw Error
            system.debug('Error line 360');
                // Second argument missing
            }
            // Ensure next token is closed-paren
            if (currentTokenIndex >= tokens.size() ||
                currentToken.key != 'closed-paren'
            ) {
                // Throw Error
                system.debug('Error line 366');
                // Missing ')'
            }
        
            // Set binaryFunctionBranch subBranches
            binaryFunctionBranch.subBranches = subBranches;

            // Update previousBranch to be the completed binary function branch
            previousBranch = binaryFunctionBranch;
            system.debug('END OF BINARY FUNCTION');
            system.debug(currentToken);
        } else {
            // Throw error
            system.debug('Error line 377');
        }

        return binaryFunctionBranch;
    }

    private SyntaxBranch unaryFunctionBranch() {
        system.debug('Unary Function Branch');
        system.debug(currentToken);
        SyntaxBranch unaryFunctionBranch = new SyntaxBranch();
        unaryFunctionBranch.type = 'unaryFunction';
        unaryFunctionBranch.value = currentToken.value;

        // Ensure next token is an opening parenthese
        if ((currentTokenIndex + 1) < tokens.size() &&
            tokens[currentTokenIndex + 1].key == 'open-paren'
        ) {
            // Step to open-paren token
            nextToken();
            List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
            SyntaxBranch firstArgBranch;
            // Step to token after open-paren token
            nextToken();
            // If valid token exists next
            if (currentTokenIndex < tokens.size()) {
                // Configure argument branch
                firstArgBranch = routeToken();
                nextToken();
            }
            // Branch created for argument
            if (firstArgBranch != null) {
                subBranches.add(firstArgBranch);
            } else {
                // Throw Error
                system.debug('Error line 418');
                // First argument missing
            }
            // Ensure next token is closed-paren
            if (currentTokenIndex >= tokens.size() ||
                currentToken.key != 'closed-paren'
            ) {
                // Throw Error
                system.debug('Error line 424');
                // Missing ')'
            }
        
            // Set unaryFunctionBranch subBranches
            unaryFunctionBranch.subBranches = subBranches;

            // Update previousBranch to be the completed unary function branch
            previousBranch = unaryFunctionBranch;
        } else {
            // Throw error
            system.debug('Error line 435');
        }

        return unaryFunctionBranch;
    }

    private SyntaxBranch fieldReferenceBranch() {
        system.debug('Field Reference Branch');
        system.debug(currentToken);
        SyntaxBranch fieldReferenceBranch;
        // Step to token after open-curly token
        nextToken();
        // Check for string token
        if (currentTokenIndex < tokens.size() &&
            currentToken.key == 'string'
        ) {
            // Set fieldReferenceBranch details
            fieldReferenceBranch = new SyntaxBranch();
            fieldReferenceBranch.type = 'fieldReference';
            fieldReferenceBranch.value = currentToken.value;

            // Update previousBranch to be the completed field reference branch
            previousBranch = fieldReferenceBranch;
        } else {
            // Throw Error
            system.debug('Error line 458');
            // Expecting string
        }
        // Branch NOT created for reference
        if (fieldReferenceBranch == null) {
            // Throw Error
            system.debug('Error line 464');
            // Reference missing
        }

        // Step to token after string token
        nextToken();
        // Ensure ending token is closed-curly
        if (currentTokenIndex >= tokens.size() ||
            currentToken.key != 'closed-curly'
        ) {
            // Throw Error
            system.debug('Error line 475');
            // Missing '}'
        }

        return fieldReferenceBranch;
    }

    private SyntaxBranch literalStringBranch() {
        system.debug('Literal String Branch');
        system.debug(currentToken);
        SyntaxBranch literalStringBranch;
        // Step to token after double-quote token
        nextToken();
        // Check for string token
        if (currentTokenIndex < tokens.size() &&
            currentToken.key == 'string'
        ) {
            // Set literalStringBranch details
            literalStringBranch = new SyntaxBranch();
            literalStringBranch.type = 'literalString';
            literalStringBranch.value = currentToken.value;

            // Update previousBranch to be the completed literal string branch
            previousBranch = literalStringBranch;
        } else {
            // Throw Error
            system.debug('Error line 498');
            // Expecting string
        }
        // Branch NOT created for literal string
        if (literalStringBranch == null) {
            // Throw Error
            system.debug('Error line 505');
            // Literal string missing
        }

        // Step to token after string token
        nextToken();
        // Ensure ending token is double-quote
        if (currentTokenIndex >= tokens.size() ||
            currentToken.key != 'double-quote'
        ) {
            // Throw Error
            system.debug('Error line 516');
            // Missing '}'
        }

        return literalStringBranch;
    }

    private SyntaxBranch numberBranch(){
        system.debug('Number Branch');
        system.debug(currentToken);
        SyntaxBranch numberBranch = new SyntaxBranch();
        numberBranch.type = 'number';
        numberBranch.value = currentToken.value;

        // Update previousBranch to be the completed number branch
        previousBranch = numberBranch;

        return numberBranch;
    }
}
