public with sharing class FormulaEngine_Lexer {

    public class Token {
        String key;
        String value;

        Token(String key, String value){
            this.key = key;
            this.value = value;
        }
    }
}
