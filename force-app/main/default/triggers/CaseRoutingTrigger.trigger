trigger CaseRoutingTrigger on Case (before insert, before update) {

    for (Case updatedCase : Trigger.new) {
        Case oldCase = !Trigger.isInsert ? Trigger.oldMap.get(updatedCase.Id):new Case();
        
        if (
            (
                updatedCase.Execute_Assignment_Rules__c != oldCase.Execute_Assignment_Rules__c
                &&
                updatedCase.Execute_Assignment_Rules__c == true
            ) ||
            Trigger.isInsert
        ) {
            RoutingEngine rEngine = new RoutingEngine();
            rEngine.runEngine(updatedCase);
        }
    }
}