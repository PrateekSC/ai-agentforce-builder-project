
import { LightningElement } from 'lwc';

import createInternalRequest
    from '@salesforce/apex/GeminiInternalController.createInternalRequest';

export default class InternalGovernmentUpload extends LightningElement {

    documentType = '';
    message = '';
    fileData = '';

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

    handleTypeChange(event) {
        this.documentType = event.detail.value;
    }

    async handleUploadFinished(event) {

        if (!this.documentType) {
            this.message = 'Select a document type first.';
            return;
        }

        const uploadedFiles = event.detail.files;

        try {

            for (const file of uploadedFiles) {
                if (file.size > 4000000) {
                    this.message = 'Error: '+ file.name + ' File size exceeds 4 MB limit.';
                    return;
                }
                console.log('file: ', JSON.stringify(file));
                /*const reader = new FileReader();
                reader.onload = () => {
                    // Extract pure Base64 string after the comma
                    const base64 = reader.result.split(',')[1];
                    this.fileData = {
                        filename: file.name,
                        base64: base64
                    };
                };
                reader.readAsDataURL(file);
                await createInternalRequest({
                    base64Data: this.fileData.base64,
                    fileName: this.fileData.filename,
                    //contentDocumentId: file.documentId,
                    documentType: this.documentType
                });*/
                await createInternalRequest({
                    //base64Data: this.fileData.base64,
                    //fileName: this.fileData.filename,
                    contentDocumentId: file.documentId,
                    documentType: this.documentType
                });
            }

            this.message =
                'Upload successful. AI extraction started.';

        } catch (error) {
console.error('Error during upload: ', error+' | '+error.body?.message);
            this.message =
                error.body?.message ||
                'Unable to start AI extraction.';
        }
    }
}
