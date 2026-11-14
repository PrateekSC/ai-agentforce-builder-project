import { LightningElement, api } from 'lwc';

import generateAccountSummary
from '@salesforce/apex/AccountPromptController.generateAccountSummary';

export default class AccountSummaryGenerator extends LightningElement {

    @api recordId;

    summary;
    riskLevel;
    recommendation;
    error;

    async handleGenerate() {

        try {
console.log('this.recordId: ', this.recordId);

            const result =
                await generateAccountSummary({
                    accountId: this.recordId
                });
console.log('result: ', result);
            const parsed = JSON.parse(result);

            this.summary =
                parsed.summary;

            this.riskLevel =
                parsed.riskLevel;

            this.recommendation =
                parsed.recommendation;

            this.error = null;

        } catch(err) {

            this.error =
                err.body?.message ||
                err.message;
        }
    }
}