import { LightningElement } from 'lwc';
import createUploadRequest from '@salesforce/apex/GeminiDocumentController.createUploadRequest';

export default class GeminiGovernmentUpload extends LightningElement {

    documentType = '';
    uploadToken = '';
    message = '';

    acceptedFormats = [
        '.jpg',
        '.jpeg',
        '.png',
        '.pdf'
    ];

    documentOptions = [
        { label: 'Aadhaar Card', value: 'AADHAAR' },
        { label: 'PAN Card', value: 'PAN' },
        { label: 'Voter ID', value: 'VOTER_ID' },
        { label: 'Passport', value: 'PASSPORT' },
        { label: 'Driving Licence', value: 'DRIVING_LICENSE' },
        { label: 'Ration Card', value: 'RATION_CARD' }
    ];

    async handleDocumentType(event) {

        this.documentType = event.detail.value;
        this.uploadToken = '';
        this.message = 'Preparing upload...';

        try {

            this.uploadToken = await createUploadRequest({
                documentType: this.documentType
            });

            this.message = 'Please upload your document.';

        } catch (error) {

            this.message =
                error.body?.message ||
                'Unable to prepare document upload.';
        }
    }

    handleUploadFinished(event) {

        this.message =
            'Upload successful. Gemini AI processing has started.';

        // Guest users do not receive ContentDocumentId
        // from uploadfinished. Apex handles processing.
    }
}
