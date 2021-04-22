public with sharing class FormulaEngine {

    FormulaEngine_Parser.SyntaxBranch syntaxTree = new FormulaEngine_Parser.SyntaxBranch();

    public FormulaEngine(String formula) {
        FormulaEngine_Lexer lexer = new FormulaEngine_Lexer();
        FormulaEngine_Parser parser = new FormulaEngine_Parser();
        // tokenize the formula
        List<FormulaEngine_Lexer.Token> tokens = lexer.tokenize(formula);
        // parse the tokens to create a syntax tree
        syntaxTree = parser.parseTokens(tokens);
        // evaluate the syntax
    }

    public Object runEngine(){
        return syntaxTree.evaluateSubBranches();
    }
}
