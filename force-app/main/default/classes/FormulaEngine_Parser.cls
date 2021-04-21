public with sharing class FormulaEngine_Parser {

    /*
    List<FormulaEngine_Lexer.Token> tokens = new List<FormulaEngine_Lexer.Token>();
    tokens.add(new FormulaEngine_Lexer.Token('string','and'));
tokens.add(new FormulaEngine_Lexer.Token('open_paren','('));
    tokens.add(new FormulaEngine_Lexer.Token('number','5'));
    tokens.add(new FormulaEngine_Lexer.Token('add','+'));
    tokens.add(new FormulaEngine_Lexer.Token('number','1'));
    tokens.add(new FormulaEngine_Lexer.Token('equals','='));
tokens.add(new FormulaEngine_Lexer.Token('number','6'));
tokens.add(new FormulaEngine_Lexer.Token('close_paren',')'));

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
    
    /*
    private static final String STRING_TOKEN = 'string';
    private static final String NUMBER_TOKEN = 'number';
    private static final String AND_TOKEN = 'and';
    private static final String OR_TOKEN = 'or';
    private static final String ADD_TOKEN = 'add';
    private static final String SUBTRACT_TOKEN = 'subtract';
    private static final String MULTIPLY_TOKEN = 'multiply';
    private static final String DIVIDE_TOKEN = 'divide';
    private static final String CURLY_OPEN_TOKEN = 'open-curly';
    private static final String CURLY_CLOSED_TOKEN = 'closed-curly';
    private static final String PAREN_OPEN_TOKEN = 'open-paren';
    private static final String PAREN_CLOSED_TOKEN = 'closed-paren';
    private static final String QUOTE_DOUBLE_TOKEN = 'double-quote';
    private static final String COMMA_TOKEN = 'comma';
    private static final String EQUALS_TOKEN = 'equals';
    private static final String NOT_EQUALS_TOKEN = 'not-equals';
    private static final String NOT_TOKEN = 'not';
    private static final String LESS_THAN_TOKEN = 'less-than';
    private static final String LE_TOKEN = 'le';
    private static final String GREATER_THAN_TOKEN = 'greater-than';
    private static final String GE_TOKEN = 'ge';
    private static final String INVALID_TOKEN = 'invalid';
    */

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

    // Example strings
    // AND(4=4,5=5)
    // 5=2+3

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
        if (currentToken.key == 'open_paren') {
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
        SyntaxBranch parentheseBranch = new SyntaxBranch();
        parentheseBranch.type = 'parenthese';
        parentheseBranch.value = currentToken.key;
        List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
        SyntaxBranch argBranch;
        // Step to token after open_paren token
        nextToken();
        // Watch for end of string OR close_paren
        while (currentTokenIndex < tokens.size() &&
            currentToken.key != 'close_paren'
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
        // Ensure ending token is close_paren (i.e. currentTokenIndex >= tokens.size())
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
                prevToken();
            }
        } else {
            // Throw Error
            system.debug('Error line 249');
        }

        return binaryOperatorBranch;
    }

    private static SyntaxBranch unaryOperatorBranch(){
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
        SyntaxBranch binaryFunctionBranch = new SyntaxBranch();
        binaryFunctionBranch.type = 'binaryFunction';
        binaryFunctionBranch.value = currentToken.value;

        // Ensure next token is an opening parenthese
        if ((currentTokenIndex + 1) < tokens.size() &&
            tokens[currentTokenIndex + 1].key == 'open_paren'
        ) {
            // Step to open_paren token
            nextToken();
            List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
            SyntaxBranch firstArgBranch;
            // Step to token after open_paren token
            nextToken();
            // Watch for end of string OR comma
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'comma'
            ) {
                // If not close_paren token
                if (currentToken.key != 'close_paren') {
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
            // Watch for close_paren token
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'close_paren'
            ) {
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
            // Ensure ending token is close_paren (i.e. currentTokenIndex >= tokens.size())
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
        SyntaxBranch unaryFunctionBranch = new SyntaxBranch();
        unaryFunctionBranch.type = 'unaryFunction';
        unaryFunctionBranch.value = currentToken.value;

        // Ensure next token is an opening parenthese
        if ((currentTokenIndex + 1) < tokens.size() &&
            tokens[currentTokenIndex + 1].key == 'open_paren'
        ) {
            // Step to open_paren token
            nextToken();
            List<SyntaxBranch> subBranches = new List<SyntaxBranch>();
            SyntaxBranch firstArgBranch;
            // Step to token after open_paren token
            nextToken();
            // Watch for end of string OR close_paren
            while (currentTokenIndex < tokens.size() &&
                currentToken.key != 'close_paren'
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
            // Ensure ending token is close_paren (i.e. currentTokenIndex >= tokens.size())
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
        SyntaxBranch fieldReferenceBranch;
        // Step to token after open_curly token
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
        // Ensure ending token is close_curly
        if (currentTokenIndex >= tokens.size() ||
            currentToken.key != 'close_curly'
        ) {
            // Throw Error
            system.debug('Error line 475');
            // Missing '}'
        }

        return fieldReferenceBranch;
    }

    private static SyntaxBranch literalStringBranch() {
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
        SyntaxBranch numberBranch = new SyntaxBranch();
        numberBranch.type = 'number';
        numberBranch.value = currentToken.value;

        // Update previousBranch to be the completed number branch
        previousBranch = numberBranch;

        return numberBranch;
    }
}
