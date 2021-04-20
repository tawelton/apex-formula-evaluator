public with sharing class FormulaEngine_Lexer {
    
    // TOKEN TYPES
    private static final String STRING_TOKEN = 'string';
    private static final String SYMBOL_TOKEN = 'symbol';
    private static final String NUMBER_TOKEN = 'number';
    private static final String COMPARISON_TOKEN = 'comparison';
    private static final String OPERATOR_TOKEN = 'operator';
    private static final String LOGICAL_TOKEN = 'logical';
    private static final String INVALID_TOKEN = 'invalid';

    // and
    // or
    // add
    // subtract
    // multiply
    // divide
    // open_paren
    // close_paren
    // open_curly
    // close_curly
    // single_quote
    // double_quote
    // LE
    // GE
    // equals
    // not equals
    /** Functions Engine (contains list of supported functions)
     *  Evaluation Engine
     * 
     *  Define:
     *  - Full Strings
     *  - Full Numbers
     *  - Change for-loop to Integer iterator
     *  - Ignore whitespace UNLESS inside quote
     */

    // Treat special characters as their own token

    // TOKEN VALUES
    private static final Set<String> STRINGS = new Set<String>('_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    private static final Set<String> NUMBERS = new Set<String>('.0123456789'.split(''));
    private static final Set<String> SYMBOLS = new Set<String>('_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    private static final Set<String> OPERATORS = new Set<String>('+-*/'.split(''));
    private static final Set<String> COMPARISONS = new Set<String>('<>=!'.split(''));
    private static final Set<String> LOGICALS = new Set<String>('&|'.split(''));
    private static final Set<String> SPECIALS = new Set<String>('(){}[],;'.split(''));

    public class Token {
        static String key;
        static String value;

        Token(String key, String value){
            this.key = key;
            this.value = value;
        }
    }

    public static List<Token> tokenize(String formula){
        //  TOKENIZED MAP
        List<Map<String, String>> tokenMap = new Map<String, String>();
        // save previous token for some specific token determinations
        String previousToken = null;
        String openString = false;
        // remove whitespace and loop through each character in formula string
        for(String char : formula.split('')){
            Token token = new Token();
            // check for arithmetic operator
            if(OPERATORS.contains(char)){ // ------> +-*/
                token.key = OPERATOR_TOKEN;
                token.value = char;
                tokenMap.add(token);
                previousToken = OPERATOR_TOKEN;
                continue;
            }
            // check for comparison operator
            else if(COMPARISONS.contains(char)){ // ------> <>=!
                cToken.put(COMPARISON_TOKEN, char);
                tokenMap.add(cToken);
                previousToken = COMPARISON_TOKEN;
                continue;
            }
            // check for logical operator
            else if(LOGICALS.contains(char)){ // ------> &|
                cToken.put(LOGICAL_TOKEN, char);
                tokenMap.add(cToken);
                previousToken = LOGICAL_TOKEN;
                continue;
            }
            // check for special characters
            else if(SPECIALS.contains(char)){ // ------> (){}[],;:
                tokecTokennMap.put(char, '');
                tokenMap.add(cToken);
                previousToken = 'special';
                continue;
            }
            // check for beginning/end of string
            else if(char == '"' || char == '\''){
                cToken.put(STRING_TOKEN, char);
                tokenMap.add(cToken);
                previousToken = STRING_TOKEN;
                // If beginning a new string, set to true. Otherwise set to false
                openString = !openString;
                continue;
            }

            /**
             * TO-DO:
             *  - do we need to check for special symbols while inside a string?
             */

            // currently inside a string
            if(openString){
                // check for a continuation of the string
                if(SYMBOLS.contains(char)){
                    cToken.put(SYMBOL_TOKEN, char);
                    tokenMap.add(cToken);
                    previousToken = SYMBOL_TOKEN;
                    continue;
                }
                // non-alphanumeric numbers (excluding _) found in open string
                else{
                    cToken.put(INVALID_TOKEN, char);
                    tokenMap.add(cToken);
                    previousToken = INVALID_TOKEN;
                    break;
                }
            }
            // not currently inside a string
            else{
                if(STRINGS.contains(char)){
                    cToken.put(STRING_TOKEN, char);
                    tokenMap.add(cToken);
                    previousToken = STRING_TOKEN;
                    continue;
                }
                else if(NUMBERS.contains(char)){
                    // if a number is coming right after a letter, treat it as a part of the string
                    // otherwise, treat is as a normal number.
                    String TOKEN = previousToken == STRING_TOKEN ? STRING_TOKEN : NUMBER_TOKEN;
                    cToken.put(TOKEN, char);
                    tokenMap.add(cToken);
                    previousToken = TOKEN;
                    continue;
                }
                // non-alphanumeric numbers (excluding _ and .) found in open string
                else{
                    cToken.put(INVALID_TOKEN, char);
                    tokenMap.add(cToken);
                    previousToken = INVALID_TOKEN;
                    break;
                }
            }
        }
        return tokenMap;
    }
}
