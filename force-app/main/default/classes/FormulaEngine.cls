public with sharing class FormulaEngine {

    public List<Object> FormulaEngine(String formula) {
        FormulaEngine_Lexer lexer = new FormulaEngine_Lexer();
        FormulaEngine_Parser parser = new FormulaEngine_Parser();
        // tokenize the formula
        List<FormulaEngine_Lexer.Token> tokens = lexer.tokenize(formula);
        // parse the tokens to create a syntax tree
        FormulaEngine_Parser.SyntaxBranch syntaxTree = FormulaEngine_Parser.parseTokens(tokens);
        // evaluate the syntax
        // return syntaxTree.evaluateSubBranches();
        return null;
    }
}
