public class FormulaEngine_Error {
    public class CustomException extends Exception {}

    // Throw custom exception to alert user of failed formula evaluation
    public void thowError(String displayMessage){
        thowError(displayMessage,null);
    }

    // Throw custom exception to alert user of failed formula evaluation
    public void thowError(String displayMessage, Exception e){
        String errorMessage = '';
        if(displayMessage != null){
            errorMessage += '***** ' + displayMessage + ' ***** ';
        }
        if(e != null){
            errorMessage += '(Runtime Error: ' + e.getMessage() + ')';
        }

        if(errorMessage == ''){
            errorMessage = 'An unknown formula error has occurred.';
        }

        throw new CustomException(errorMessage);
    }
}
    
