import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import codeflask from '@salesforce/resourceUrl/codeflask'
import validateFormula from '@salesforce/apex/FormulaEngine.validate';

const functions = [
    // logical
    {
        name: "AND",
        group: "Logical",
        value: "AND(#,#)"
    },
    {
        name: "OR",
        group: "Logical",
        value: "OR(#,#)"
    },
    {
        name: "ISBLANK",
        group: "Logical",
        value: "ISBLANK(#)"
    },
    {
        name: "NOT",
        group: "Logical",
        value: "NOT(#)"
    },
    // text manipulations
    {
        name: "BEGINS",
        group: "Text Manipulation",
        value: "BEGINS(#,#)"
    },
    {
        name: "ENDS",
        group: "Text Manipulation",
        value: "ENDS(#,#)"
    },
    {
        name: "CONTAINS",
        group: "Text Manipulation",
        value: "BEGINS(#,#)"
    },
    {
        name: "LEFT",
        group: "Text Manipulation",
        value: "LEFT(#,#)"
    },
    {
        name: "RIGHT",
        group: "Text Manipulation",
        value: "RIGHT(#,#)"
    },
    // value conversion
    {
        name: "TEXT",
        group: "Value Conversion",
        value: "TEXT(#)"
    },
    {
        name: "VALUE",
        group: "Value Conversion",
        value: "VALUE(#)"
    },
    // miscellaneous
    {
        name: "LEN",
        group: "Miscellaneous",
        value: "LEN(#)"
    }
]

export default class RoutingRulesEditor extends LightningElement {

    @api rule
    cursorPosition = null
    editor

    // Getters
    get groupedFunctions() {
        let groupings = functions.reduce((objectsByKeyValue, obj) => {
            const value = obj.group;
            objectsByKeyValue[value] = (objectsByKeyValue[value] || []).concat(obj);
            return objectsByKeyValue;
        }, {});

        return Object.entries(groupings).map(grouping => ({ name: grouping[0], functions: grouping[1]}))
    }

    handleInsertFunctionClick(event) {
        const functionString = functions.find(f => f.name === event.target.value)?.value
        
        if(functionString) {
            this.insertAtCursorHead(functionString)
        }
    }

    handleInsertFieldClick(event) {
        console.log(event.target.value)
        console.log(this.cursorPosition)
    }

    handleValidateClick() {
        let params = { formula: this.editor.getCode() }

        validateFormula(params)
            .then((result) => {
                const evt = new ShowToastEvent({
                    title: 'Validation Successful',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            })
            .catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Validation Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            })
    }

    handleSaveClick() {
        let updatedRule = JSON.parse(JSON.stringify(this.rule))
        updatedRule.Formula__c = this.editor.getCode()
        const saveEvent = new CustomEvent('save', {
            detail: {
              rule: updatedRule
            }
        })
        // Fire the custom event
        this.dispatchEvent(saveEvent)
        this.handleCloseClick()
    }

    handleCloseClick() {
        const closeEvent = new CustomEvent('close')
        // Fire the custom event
        this.dispatchEvent(closeEvent)
    }

    async insertAtCursorHead(string) {
        let cursorPosition = this.template.querySelector('.editor textarea').selectionStart

        // retrieve current editor content
        const oldEditorContent = this.editor.getCode()

        // add new text at cursor head
        let newEditorContent = oldEditorContent.slice(0,cursorPosition) + string + oldEditorContent.slice(cursorPosition)

        // update entire editor content
        await this.editor.updateCode(newEditorContent)

        // advance cursor position to end of new text
        cursorPosition += string.length

        // refocus editor and set cursor
        let editorElement = this.template.querySelector('.editor textarea')
        editorElement.focus();
        editorElement.setSelectionRange(cursorPosition, cursorPosition)
    }

    // Lifecycle Methods

    async connectedCallback() {
        await loadScript(this, codeflask)
        console.log(this.groupedFunctions)
        this.editor = new CodeFlask(this.template.querySelector('.editor'), { language: 'js', lineNumbers: true });
        this.editor.updateCode(this.rule?.Formula__c)
    }

}