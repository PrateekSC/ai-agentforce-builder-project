
public without sharing class GeminiDocumentController {

    @AuraEnabled
    public static String createUploadRequest(
        String documentType
    ) {
        Set<String> allowedTypes = new Set<String>{
            'AADHAAR',
            'PAN',
            'VOTER_ID',
            'PASSPORT',
            'DRIVING_LICENSE',
            'RATION_CARD'
        };

        if (!allowedTypes.contains(documentType)) {
            throw new AuraHandledException(
                'Unsupported document type.'
            );
        }

        String demoEmail =
            System.Label.OCR_Demo_Contact_Email;

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE Email = :demoEmail
            LIMIT 1
        ];

        if (contacts.isEmpty()) {
            throw new AuraHandledException(
                'Create the OCR Demo Contact first.'
            );
        }

        String token = EncodingUtil.convertToHex(
            Crypto.generateAesKey(256)
        );

        Customer_Attachment__c doc =
            new Customer_Attachment__c();

        doc.Contact__c = contacts[0].Id;
        doc.Upload_Token__c = token;
        doc.Document_Type__c = documentType;
        doc.OCR_Status__c = 'Pending';

        insert doc;

        return token;
    }
}
