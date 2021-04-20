public with sharing class ExpressionInterpreter {
    /**
     * TODO dates, nulls
     * 
     * Precedence implemented by method call ordering:
     * 
     * unary          +expr -expr !expr
     * multiplicative * /
     * additive       + -
     * relational     < > <= >=
     * equality       == !=
     * logical AND    &&
     * logical OR     ||
     * ternary        ? :
     */

    // Apex won't allow an infinite loop so set a high upper bound that should never be hit
    private static final Integer LOOP_LIMIT = 25;
    private static final String LOOP_LIMIT_MESSAGE = 'Loop limit of ' + LOOP_LIMIT + ' exceeded';
    

    private ExpressionLexer lexer;
    private ExpressionFunctions functions;

    public ExpressionInterpreter(String expression, ExpressionSymbols symbols, ExpressionFunctions functions) {
        this.lexer = new ExpressionLexer(expression, symbols);
        this.functions = functions;
    }

    private Object function(String functionName) {
        Integer functionPosition = lexer.getMatchPosition();
        Integer openPosition = lexer.getPosition() - 1;
        List<Object> arguments = new List<Object>();
        if (lexer.consumeOnMatch(')')) {
            return functions.evaluate(functionName, arguments, functionPosition);
        }
        arguments.add(expression());

        for (boolean isAnotherArgument = true; isAnotherArgument;) {
            if (lexer.consumeOnMatch(',')) {
                arguments.add(expression());
                isAnotherArgument = true;
            } else {
                isAnotherArgument = false;
            }
            if (lexer.consumeOnMatch(')')) {
                return functions.evaluate(functionName, arguments, functionPosition);
            }
        }
        throw ExpressionException.create(
                'No closing parenthesis found for function "' + functionName + '"',
                openPosition
                );
    }

    private Object atom() {

        // Unary
        boolean negativeOp = false;
        Integer negativePosition = -1;
        boolean notOp = false;
        Integer notPosition = -1;
        if (lexer.consumeOnMatch('-')) {
            negativeOp = true;
            negativePosition = lexer.getMatchPosition();
        } else if (lexer.consumeOnMatch('+')) {
            // Nothing to do in this case
        } else if (lexer.consumeOnMatch('!')) {
            notOp = true;
            notPosition = lexer.getMatchPosition();
        }

        Object result;
        String functionName;
        // Check if there is parenthesis
        if (lexer.consumeOnMatch('(')) {
            Integer openPosition = lexer.getMatchPosition();
            result = expression();
            if (lexer.consumeOnMatch(')')) {
                // Good - a match
            } else {
                throw ExpressionException.create('Mismatched parenthesis', openPosition);
            }
        } else if ((functionName = lexer.consumeFunctionOnMatch()) != null) {
            result = function(functionName);
        } else {
            result = lexer.consumeNextValue();
        }

        if (negativeOp) {
            if (result instanceof Double) {
                return -((Double) result);
            } else {
                throw ExpressionException.create('Type mismatch: cannot negate ' + result, negativePosition);
            }
        } else if (notOp) {
            if (result instanceof Boolean) {
                return !((Boolean) result);
            } else {
                throw ExpressionException.create('Type mismatch: cannot not ' + result, notPosition);
            }
        } else {
            return result;
        }
    }

    private Object factors() {
        Object result1 = atom();
        for (Integer i = 0; i < LOOP_LIMIT; i++) {
            Integer op = lexer.consumeOnMatch(new String[] {'/', '*'});
            if (op == -1) {
                return result1;
            }
            Integer opPosition = lexer.getMatchPosition();

            Object result2 = atom();
            if (result1 instanceof Double && result2 instanceof Double) {
                if (op == 0) {
                    if ((Double) result2 == 0.0) {
                        throw ExpressionException.create('Divide by zero', opPosition);
                    }
                    result1 = (Double) result1 / (Double) result2;
                }
                if (op == 1) {
                    result1 = (Double) result1 * (Double) result2;
                }
            } else {
                throw ExpressionException.create(
                        'Type mismatch: cannot apply * or / to ' + result1 + ' and ' + result2,
                        opPosition
                        );
            }
        }
        throw ExpressionException.create(LOOP_LIMIT_MESSAGE, lexer.getPosition());
    }

    private Object summands() {
        Object result1 = factors();
        for (Integer i = 0; i < LOOP_LIMIT; i++) {
            Integer op = lexer.consumeOnMatch(new String[] {'-', '+'});
            if (op == -1) {
                return result1;
            }
            Integer opPosition = lexer.getMatchPosition();

            Object result2 = factors();
            if (result1 instanceof Double && result2 instanceof Double) {
                if (op == 0) {
                    result1 = (Double) result1 - (Double) result2;
                } else {
                    result1 = (Double) result1 + (Double) result2;
                }
            } else {
                throw ExpressionException.create(
                        'Type mismatch: cannot apply + or - to ' + result1 + ' and ' + result2,
                        opPosition
                        );
            }
        }
        throw ExpressionException.create(LOOP_LIMIT_MESSAGE, lexer.getPosition());
    }

    private Object relational() {
        Object result1 = summands();
        for (Integer i = 0; i < LOOP_LIMIT; i++) {
            Integer op = lexer.consumeOnMatch(new String[] {'>=', '<=', '>', '<'});
            if (op == -1) {
                return result1;
            }
            Integer opPosition = lexer.getMatchPosition();

            Object result2 = summands();
            if (result1 instanceof Double && result2 instanceof Double) {
                Double d1 = (Double) result1;
                Double d2 = (Double) result2;
                if (op == 0) {
                    result1 = d1 >= d2;
                } else if (op == 1) {
                    result1 = d1 <= d2;
                } else if (op == 2) {
                    result1 = d1 > d2;
                } else if (op == 3) {
                    result1 = d1 < d2;
                }
            } else {
                throw ExpressionException.create(
                        'Type mismatch: cannot apply < or > or <= or >= to ' + result1 + ' and ' + result2,
                        opPosition
                        );
            }
        }
        throw ExpressionException.create(LOOP_LIMIT_MESSAGE, lexer.getPosition());
    }

    private Object equality() {
        Object result1 = relational();
        for (Integer i = 0; i < LOOP_LIMIT; i++) {
            Integer op = lexer.consumeOnMatch(new String[] {'==', '!='});
            if (op == -1) {
                return result1;
            }
            Integer opPosition = lexer.getMatchPosition();

            Object result2 = relational();
            if ((result1 instanceof Boolean && result2 instanceof Boolean)
                    || (result1 instanceof Double && result2 instanceof Double)
                    || (result1 == null || result2 == null)
                    ) {
                if (op == 0) {
                    result1 = result1 == result2;
                } else if (op == 1) {
                    result1 = result1 != result2;
                }
            } else {
                throw ExpressionException.create(
                        'Type mismatch: cannot apply == or != to ' + result1 + ' and ' + result2,
                        opPosition
                        );
            }
        }
        throw ExpressionException.create(LOOP_LIMIT_MESSAGE, lexer.getPosition());
    }

    private Object logical() {
        Object result1 = equality();
        for (Integer i = 0; i < LOOP_LIMIT; i++) {
            Integer op = lexer.consumeOnMatch(new String[] {'&&', '||'});
            if (op == -1) {
                return result1;
            }
            Integer opPosition = lexer.getMatchPosition();

            Object result2 = equality();
            if ((result1 instanceof Boolean && result2 instanceof Boolean)
                    || (result1 instanceof Double && result2 instanceof Double)) {
                Boolean b1 = (Boolean) result1;
                Boolean b2 = (Boolean) result2;
                if (op == 0) {
                    result1 = b1 && b2;
                }
                if (op == 1) {
                    result1 = b1 || b2;
                }
            } else {
                throw ExpressionException.create(
                        'Type mismatch: cannot apply && or || to ' + result1 + ' and ' + result2,
                        opPosition
                        );
            }
        }
        throw ExpressionException.create(LOOP_LIMIT_MESSAGE, lexer.getPosition());
    }

    private Object ternary() {
        Object result1 = logical();

        boolean questionOp = lexer.consumeOnMatch('?');
        if (!questionOp) {
            return result1;
        }
        Integer questionOpPosition = lexer.getMatchPosition();

        Object result2 = logical();

        boolean colonOp = lexer.consumeOnMatch(':');
        if (!colonOp) {
            return result2;
        }

        Object result3 = logical();
        if (result1 instanceof Boolean) {
            if ((Boolean) result1) {
                return result2;
            } else {
                return result3;
            }
        } else {
            throw ExpressionException.create(
                    'Type mismatch: value preceding ? must be a boolean but was ' + result1,
                    questionOpPosition
                    );
        }
    }

    private Object expression() {
        return ternary();
    }

    /**
     * Evaluate the expression.
     */
    public Object interpret() {
        return expression();
    }
}
