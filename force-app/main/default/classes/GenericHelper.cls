public with sharing class GenericHelper {

    // ----------------------------------------------------------
    //               Generic Record Operations 
    //                  (mostly used by LWC)
    // ----------------------------------------------------------

    @AuraEnabled
    public static List<SObject> getRecords(String query){
        return Database.query(query);
    }

    @AuraEnabled
    public static void insertRecords(List<SObject> records){
        Database.insert(records);
    }

    @AuraEnabled
    public static void upsertRecords(List<SObject> records){
        Database.upsert(records);
    }

    @AuraEnabled
    public static void updateRecords(List<SObject> records){
        Database.update(records);
    }

    @AuraEnabled
    public static void deleteRecords(List<SObject> records){
        Database.delete(records);
    }

}
