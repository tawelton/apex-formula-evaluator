public with sharing class FormulaEngine_Lexer {
    
    // TOKEN TYPES
    private final String STRING_TOKEN = 'string';
    private final String NUMBER_TOKEN = 'number';
    private final String AND_TOKEN = 'and';
    private final String OR_TOKEN = 'or';
    private final String ADD_TOKEN = 'add';
    private final String SUBTRACT_TOKEN = 'subtract';
    private final String MULTIPLY_TOKEN = 'multiply';
    private final String DIVIDE_TOKEN = 'divide';
    private final String CURLY_OPEN_TOKEN = 'open-curly';
    private final String CURLY_CLOSED_TOKEN = 'closed-curly';
    private final String PAREN_OPEN_TOKEN = 'open-paren';
    private final String PAREN_CLOSED_TOKEN = 'closed-paren';
    private final String QUOTE_DOUBLE_TOKEN = 'double-quote';
    private final String COMMA_TOKEN = 'comma';
    private final String EQUALS_TOKEN = 'equals';
    private final String NOT_EQUALS_TOKEN = 'not-equals';
    private final String NOT_TOKEN = 'not';
    private final String LESS_THAN_TOKEN = 'less-than';
    private final String LE_TOKEN = 'le';
    private final String GREATER_THAN_TOKEN = 'greater-than';
    private final String GE_TOKEN = 'ge';
    private final String SPECIAL_CHAR_TOKEN = 'special';
    private final String INVALID_TOKEN = 'invalid';

    /** Functions Engine (contains list of supported functions)
     *  Evaluation Engine
     * 
     *  Define:
     *  - Full Strings
     *  - Full Numbers
     *  - Change for-loop to Integer iterator
     *  - Ignore whitespace UNLESS inside quote
     *  - Define functions
     */

    // Treat special characters as their own token

    // TOKEN VALUES
    private final Set<String> STRINGS = new Set<String>('_.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    private final Set<String> NUMBERS = new Set<String>('.0123456789'.split(''));
    private final Set<String> SYMBOLS = new Set<String>('_.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ '.split(''));
    private final Set<String> SPECIAL_HOLDS = new Set<String>('&|<>=!'.split('')); // special characters that require a second character in order to be a valid operator
    private final Map<String, String> SPECIAL_HOLDS_MAP = new Map<String, String> {'&' => SPECIAL_CHAR_TOKEN,
                                                                                          '|' => SPECIAL_CHAR_TOKEN,
                                                                                          '<' => SPECIAL_CHAR_TOKEN,
                                                                                          '>' => SPECIAL_CHAR_TOKEN,
                                                                                          '=' => SPECIAL_CHAR_TOKEN,
                                                                                          '!' => SPECIAL_CHAR_TOKEN};

    private final Map<String, String> SPECIAL_CHAR_MAP = new Map<String, String> {'&&' => AND_TOKEN,
                                                                                         '||' => OR_TOKEN,
                                                                                         '+' => ADD_TOKEN,
                                                                                         '-' => SUBTRACT_TOKEN,
                                                                                         '*' => MULTIPLY_TOKEN,
                                                                                         '/' => DIVIDE_TOKEN,
                                                                                         '==' => EQUALS_TOKEN,
                                                                                         '!=' => NOT_EQUALS_TOKEN,
                                                                                         '!' => NOT_TOKEN,
                                                                                         '>' => GREATER_THAN_TOKEN,
                                                                                         '>=' => GE_TOKEN,
                                                                                         '<' => LESS_THAN_TOKEN,
                                                                                         '<=' => LE_TOKEN,
                                                                                         '(' => PAREN_OPEN_TOKEN,
                                                                                         ')' => PAREN_CLOSED_TOKEN,
                                                                                         '{' => CURLY_OPEN_TOKEN,
                                                                                         '}' => CURLY_CLOSED_TOKEN,
                                                                                         '"' => QUOTE_DOUBLE_TOKEN,
                                                                                         ',' => COMMA_TOKEN};

    public class Token {
        public String key;
        public String value;

        public Token(String key, String value){
            this.key = key;
            this.value = value;
        }
    }

    public List<Token> tokenize(String formula){
        // create list of characters from formula
        List<String> characters = formula.split('');
        //  TOKENIZED MAP
        List<Token> tokenMap = new List<Token>();
        // save previous token for some specific token determinations
        String currentToken;
        String previousToken;
        Boolean invalid = false;
        Boolean openString = false;
        Boolean openHold = false;
        // remove whitespace and loop through each character in formula string
        Boolean endOfToken = false;
        for(Integer i = 0; i < characters.size(); i++){
            String currChar = characters[i];
            // if we hit whitespace and are not currently in a string literal, ignore
            if(currChar == ' ' && previousToken != STRING_TOKEN){
                continue;
            }
            // character is part of a binary operator
            else if(SPECIAL_HOLDS.contains(currChar)){
                Map<String, Integer> scanResult = scan(characters, i, SPECIAL_CHAR_TOKEN, SPECIAL_HOLDS_MAP);
                String currentTokenValue = new List<String>(scanResult.keySet())[0];
                i = scanResult.get(currentTokenValue);
                previousToken = SPECIAL_CHAR_TOKEN;
                if(SPECIAL_CHAR_MAP.get(currentTokenValue) != null){
                    previousToken = SPECIAL_CHAR_MAP.get(currentTokenValue);
                    // assign token's key-value pairing and add to list
                    Token token = new Token(SPECIAL_CHAR_MAP.get(currentTokenValue), currentTokenValue);
                    System.debug('Token: '+token);
                    tokenMap.add(token);
                    // end the open special character hold
                    openHold = false;
                    // signal for end of current token
                    endOfToken = true;
                    continue;
                }
                else{
                    // TO-DO: Error Handler for invalid sequence
                    break;
                }
            }
            // any special character outside of a special hold
            else if(SPECIAL_CHAR_MAP.get(currChar) != null){
                previousToken = SPECIAL_CHAR_MAP.get(currChar);
                Token token = new Token(SPECIAL_CHAR_MAP.get(currChar), currChar);
                System.debug('Token: '+token);
                tokenMap.add(token);
                if(previousToken == QUOTE_DOUBLE_TOKEN){
                    openString = !openString;
                }
                continue;
            }
            // any alpha-numeric character found INSIDE a string literal
            else if(previousToken == QUOTE_DOUBLE_TOKEN && openString){
                Map<String, Integer> scanResult = scan(characters, i, SYMBOLS);
                Token token = new Token(STRING_TOKEN, new List<String>(scanResult.keySet())[0]);
                System.debug('Token: '+token);
                tokenMap.add(token);
                i = scanResult.get(token.value);
                previousToken = STRING_TOKEN;
                continue;
            }
            // any string found OUTSIDE a string literal
            else if(STRINGS.contains(currChar)){
                Map<String, Integer> scanResult = scan(characters, i, STRINGS);
                Token token = new Token(STRING_TOKEN, new List<String>(scanResult.keySet())[0]);
                System.debug('Token: '+token);
                tokenMap.add(token);
                i = scanResult.get(token.value);
                previousToken = STRING_TOKEN;
                continue;
            }
            // any number found OUTSIDE a string literal
            else if(NUMBERS.contains(currChar)){
                Map<String, Integer> scanResult = scan(characters, i, NUMBERS);
                Token token = new Token(NUMBER_TOKEN, new List<String>(scanResult.keySet())[0]);
                System.debug('Token: '+token);
                tokenMap.add(token);
                i = scanResult.get(token.value);
                previousToken = NUMBER_TOKEN;
                continue;
            }
            else{
                // TO-DO: Error handler for invalid sequence
            }
        }
        return tokenMap;
    }

    public Map<String, Integer> scan(List<String> characters, Integer i, String endingToken, Map<String, String> tokenMap){
        String currToken = endingToken;
        String currValue = characters[i];
        // token value we'll return
        String returnValue = '';
        while(currToken == endingToken) {
            // if the current value was the same token type, add it to the overall string
            returnValue += currValue;
            // interate to the next character
            i += 1;
            currValue = i < characters.size() ? characters[i] : null;
            // find the token for the next 
            currToken = i < characters.size() ? tokenMap.get(currValue) : null;
        }
        return new Map<String, Integer>{returnValue => (i-1)};
    }

    public Map<String, Integer> scan(List<String> characters, Integer i, Set<String> tokenSet){
        String currValue = characters[i];
        // token value we'll return
        String returnValue = '';
        while(tokenSet.contains(currValue)){
            returnValue += currValue;
            i += 1;
            currValue = i < characters.size() ? characters[i] : null;
        }
        return new Map<String, Integer>{returnValue => (i-1)};
    }
}
