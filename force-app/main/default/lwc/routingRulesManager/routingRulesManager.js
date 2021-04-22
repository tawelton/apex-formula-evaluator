import { LightningElement } from 'lwc';

export default class RoutingRulesManager extends LightningElement {

    currentTab = "rules/Case"
    currentTier = null
    rules
    selectedRule = null
    showEditor = false

    get filteredRules() {
        console.log('tier: ', this.currentTier)
        console.log('rules: ', this.rules)
        console.log(this.rules.filter(rule => rule.Object_Developer_Name__c === this.currentTab.replace('rules/','') && rule.Parent__c === this.currentTier?.Id))
        return this.rules.filter(rule => rule.Object_Developer_Name__c === this.currentTab.replace('rules/','') && rule.Parent__c === this.currentTier?.Id)
    }

    get actionTypeOptions() {
        return [
            { label: 'Field Assignment', value: 'Field Assignment' },
            { label: 'Evaluate Child Rules', value: 'Evaluate Child Rules' },
        ];
    }

    get parentRuleChain() {
        if(this.currentTier) {
            let currentRuleLevel = this.currentTier
            let ruleChain = []
            while (currentRuleLevel) {
                // add to front list
                ruleChain.unshift(currentRuleLevel)

                // set current level to parent for next loop iteration
                // find parent rule in list of all rules
                currentRuleLevel = this.rules.find(rule => rule.Id === currentRuleLevel.Parent__c)                
            }
            return ruleChain
        }
        return null
    }

    get evaluatesChildren() {
        return this.selectedRule.Action_Type__c === 'Evaluate Child Rules'
    }

    toggleEditor() {
        this.showEditor = !this.showEditor
    }

    saveFormula(event) {
        this.selectedRule = event?.detail?.rule
    }

    updateActionType(event) {
        this.selectedRule.Action_Type__c = event.detail.value
    }
    
    handleSelect(event) {
        this.currentTab = event.detail.name
    }

    handleSelectRule(event) {
        console.log(event.target.getAttribute('data-rule'))
        this.selectedRule = this.rules.find(rule => rule.Id === event.target.getAttribute('data-rule'))
        console.log(this.selectedRule)
    }

    handleShowChildrenClick() {
        this.currentTier = this.selectedRule
        this.selectedRule = null
        console.log(this.currentTier)
    }

    handleBackClick() {
        this.currentTier = this.rules.find(rule => rule.Id === this.currentTier.Parent__c)
    }

    connectedCallback() {
        this.rules = [
            {
                sobjectType: 'Routing_Rule__c',
                Id: '0',
                Name: 'All Finance Cases',
                Formula__c: '{RecordType.Name} == "Finance"',
                Action_Type__c: 'Field Assignment',
                Action_Field_Developer_Name__c: 'Owner',
                Action_Field_Value__c: '0052J000008I9DMQA0',
                Object_Developer_Name__c: 'Case'
            },
            {
                sobjectType: 'Routing_Rule__c',
                Id: '1',
                Name: 'All SFDC Support Cases',
                Formula__c: '{RecordType.Name} == "CPQ Admin Support"',
                Action_Type__c: 'Evaluate Child Rules',
                Action_Field_Developer_Name__c: '',
                Action_Field_Value__c: '',
                Object_Developer_Name__c: 'Case'
            },
            {
                sobjectType: 'Routing_Rule__c',
                Id: '2',
                Name: 'All Other Cases',
                Parent__c: '1',
                Formula__c: '{RecordType.Name} == "CPQ Admin Support"',
                Action_Type__c: 'Evaluate Child Rules',
                Action_Field_Developer_Name__c: '',
                Action_Field_Value__c: '',
                Object_Developer_Name__c: 'Case'
            }
        ]
    }
}