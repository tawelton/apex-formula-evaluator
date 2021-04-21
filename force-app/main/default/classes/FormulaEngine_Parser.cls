public with sharing class FormulaEngine_Parser {

    /*
    List<FormulaEngine_Lexer.Token> tokens = new List<FormulaEngine_Lexer.Token>();
    tokens.add(new FormulaEngine_Lexer.Token('string','and'));
tokens.add(new FormulaEngine_Lexer.Token('open-paren','('));
    tokens.add(new FormulaEngine_Lexer.Token('number','5'));
    tokens.add(new FormulaEngine_Lexer.Token('add','+'));
    tokens.add(new FormulaEngine_Lexer.Token('number','1'));
    tokens.add(new FormulaEngine_Lexer.Token('equals','='));
tokens.add(new FormulaEngine_Lexer.Token('number','6'));
tokens.add(new FormulaEngine_Lexer.Token('closed-paren',')'));

    FormulaEngine_Parser.SyntaxBranch syntaxTree = FormulaEngine_Parser.parseTokens(tokens);

    system.debug('HEAD');
    system.debug(syntaxTree.type + ' - ' + syntaxTree.value);
    system.debug(syntaxTree.subBranches);

    if (syntaxTree.subBranches != null) {
        system.debug('First Level');
        for (FormulaEngine_Parser.SyntaxBranch subBranch : syntaxTree.subBranches) {
            system.debug(subBranch.type + ' - ' + subBranch.value);
            if (subBranch.subBranches != null) {
                system.debug('Second Level');
                for (FormulaEngine_Parser.SyntaxBranch subSubBranch : subBranch.subBranches) {
                    system.debug(subSubBranch.type + ' - ' + subSubBranch.value);
                }
            }
        }
    }
    */

    // Token types
    private static List<String> binaryFunctions = new List<String>{'and','or','begins','ends','contains','left','right','text','value'};
    private static List<String> binaryOperators = new List<String>{'and','or','add','subtract','multiply','divide','equals','not-equals','less-than','le','greater-than','ge'};
    private static List<String> unaryFunctions = new List<String>{'isblank','not','len'};
    private static List<String> unaryOperators = new List<String>{'not'};

    // Token info
    private static FormulaEngine_Lexer.Token currentToken;
    private static Integer currentTokenIndex = -1;
    private static List<FormulaEngine_Lexer.Token> tokens;

    // Branch info
    private static SyntaxBranch previousBranch;


    public class SyntaxBranch {
        public String type;
        public String value;
        public List<SyntaxBranch> subBranches;
    }

    public static SyntaxBranch parseTokens(List<FormulaEngine_Lexer.Token> lexedTokens) {
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

    private static void nextToken() {
        currentTokenIndex += 1;
        currentToken = currentTokenIndex < tokens.size() ? tokens[currentTokenIndex] : null;
    }

    private static void prevToken() {
        currentTokenIndex -= 1;
        currentToken = currentTokenIndex < tokens.size() ? tokens[currentTokenIndex] : null;
    }

    private static SyntaxBranch routeToken() {
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

    private static SyntaxBranch parentheseBranch() {
        system.debug('Parenthese Branch');
        system.debug(currentToken);
        SyntaxBranch parentheseBranch = new SyntaxBranch();
        parentheseBranch.type = 'parenthese';
        parentheseBranch.value = currentToken.key;
        List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
        SyntaxBranch argBranch;
        // Step to token after open-paren token
        nextToken();
        // Watch for end of string OR closed-paren
        while (currentTokenIndex < tokens.size() &&
            currentToken.key != 'closed-paren'
        ) {
            // If not comma token
            if (currentToken.key != 'comma') {
                // Configure argument branch
                argBranch = routeToken();
                nextToken();
            } else {
                // Throw Error
            system.debug('Error line 173');
                // Expecting ')' but found ','
            }
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
        if (currentTokenIndex >= tokens.size()) {
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

    private static SyntaxBranch binaryOperatorBranch(){
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
            // Watch for end of string OR comma
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'comma' &&
                currentToken.key != 'closed-paren' &&
                !binaryOperators.contains(currentToken.key.toLowerCase())
            ) {
                // Configure right hand side branch
                rightSubBranch = routeToken();
                nextToken();
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

            // If not end of string, step back to comma or operator token
            if (currentTokenIndex < tokens.size()) {
                // system.debug(currentToken);
                prevToken();
                // system.debug(currentToken);
            }
        } else {
            // Throw Error
            system.debug('Error line 249');
        }

        return binaryOperatorBranch;
    }

    private static SyntaxBranch unaryOperatorBranch(){
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
            // Watch for end of string OR comma
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'comma'
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
                system.debug('Error line 282');
                // Missing argument
            }

            // Set unaryOperatorBranch subBranches
            unaryOperatorBranch.subBranches = subBranches;

            // Update previousBranch to be the completed unary operator branch
            previousBranch = unaryOperatorBranch;
        } else {
            // Throw Error
            system.debug('Error line 293');
        }

        return unaryOperatorBranch;
    }

    private static SyntaxBranch binaryFunctionBranch() {
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
            // Watch for end of string OR comma
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'comma'
            ) {
                // If not closed-paren token
                if (currentToken.key != 'closed-paren') {
                    // Configure argument branch
                    firstArgBranch = routeToken();
                    nextToken();
                } else {
                    // Throw Error
                    system.debug('Error line 325');
                    // Expecting ',' but found ')'
                }
            }
            // Branch created for argument
            if (firstArgBranch != null) {
                subBranches.add(firstArgBranch);
            } else {
                // Throw Error
            system.debug('Error line 334');
                // First argument missing
            }
            SyntaxBranch secondArgBranch;
            // Step to token after comma token
            nextToken();
            // system.debug('Second Binary Function Argument');
            // Watch for closed-paren token
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'closed-paren'
            ) {
                // system.debug(currentToken);
                // If not comma token
                if (currentToken.key != 'comma') {
                    // Configure argument branch
                    secondArgBranch = routeToken();
                    nextToken();
                } else {
                    // Throw Error
                    system.debug('Error line 351');
                    // Expecting ')' but found ','
                }
            }
            // Branch created for argument
            if (secondArgBranch != null) {
                subBranches.add(secondArgBranch);
            } else {
                // Throw Error
            system.debug('Error line 360');
                // Second argument missing
            }
            // system.debug('End of Binary Function');
            // system.debug(currentTokenIndex);
            // Ensure ending token is closed-paren (i.e. currentTokenIndex >= tokens.size())
            if (currentTokenIndex >= tokens.size()) {
                // Throw Error
                system.debug('Error line 366');
                // Missing ')'
            }
        
            // Set binaryFunctionBranch subBranches
            binaryFunctionBranch.subBranches = subBranches;

            // Update previousBranch to be the completed binary function branch
            previousBranch = binaryFunctionBranch;
        } else {
            // Throw error
            system.debug('Error line 377');
        }

        return binaryFunctionBranch;
    }

    private static SyntaxBranch unaryFunctionBranch() {
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
            // Watch for end of string OR closed-paren
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'closed-paren'
            ) {
                // If not comma token
                if (currentToken.key != 'comma') {
                    // Configure argument branch
                    firstArgBranch = routeToken();
                    nextToken();
                } else {
                    // Throw Error
                    system.debug('Error line 409');
                    // Expecting ')' but found ','
                }
            }
            // Branch created for argument
            if (firstArgBranch != null) {
                subBranches.add(firstArgBranch);
            } else {
                // Throw Error
                system.debug('Error line 418');
                // First argument missing
            }
            // Ensure ending token is closed-paren (i.e. currentTokenIndex >= tokens.size())
            if (currentTokenIndex >= tokens.size()) {
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

    private static SyntaxBranch fieldReferenceBranch() {
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

    private static SyntaxBranch literalStringBranch() {
        system.debug('Literal String Branch');
        system.debug(currentToken);
        SyntaxBranch literalStringBranch;
        // Step to token after double_quote token
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
        // Ensure ending token is double_quote
        if (currentTokenIndex >= tokens.size() ||
            currentToken.key != 'double_quote'
        ) {
            // Throw Error
            system.debug('Error line 516');
            // Missing '}'
        }

        return literalStringBranch;
    }

    private static SyntaxBranch numberBranch(){
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
