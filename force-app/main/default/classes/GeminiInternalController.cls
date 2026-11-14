
public with sharing class GeminiInternalController {

    @AuraEnabled
    public static void createInternalRequest(
        Id contentDocumentId,
        //String base64Data,
        //String fileName,
        String documentType
    ) {
        String contactId = null;

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
                'Invalid document type.'
            );
        }

        /*if (contentDocumentId == null) {
            throw new AuraHandledException(
                'Document ID is required.'
            );
        }*/

        /*Blob fileBlob = EncodingUtil.base64Decode(base64Data);
        if (fileBlob==null || String.isEmpty(base64Data)) {
            throw new AuraHandledException(
                'Uploaded document not found.'
            );
        }*/
        // 2. Create ContentVersion (the actual file)
        /*ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName; // Extension here determines file type icon & preview in SF
        cv.VersionData = fileBlob;
        cv.IsMajorVersion = true;
        insert cv;*/

        // Get the file version.
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            AND IsLatest = true
            LIMIT 1
        ];
        /*Id contentDocumentId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id 
                LIMIT 1
            ].ContentDocumentId;*/

        

        // Verify Contact association through file links.
        List<ContentDocumentLink> links = [
            SELECT LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :contentDocumentId
            AND LinkedEntityId IN (
                SELECT Id FROM Contact WHERE Id = '003jV00000GNnA6QAL'
            )
            LIMIT 1
        ];
        if (links.isEmpty()) {
            //throw new AuraHandledException(
              //  'Document is not linked to a Contact.'
            //);
        //}
        String demoEmail =
            System.Label.OCR_Demo_Contact_Email;
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE Email = :demoEmail
            LIMIT 1
        ];
        /*if (contacts.isEmpty()) {
            throw new AuraHandledException(
                'Document is not linked to a Contact.'
            );
        }*/
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = contacts[0].Id;
        cdl.ShareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
        cdl.Visibility = 'AllUsers';
        insert cdl;

        contactId = cdl.LinkedEntityId;
        } else {
            contactId = links[0].LinkedEntityId;
        }
        // Verify current user's access.
        Contact authorizedContact = [
            SELECT Id
            FROM Contact
            WHERE Id = :contactId
            //WITH USER_MODE
            LIMIT 1
        ];

        // Ensure the document is associated with this Contact.
        String token = EncodingUtil.convertToHex(
            Crypto.generateAesKey(256)
        );

        Customer_Attachment__c doc =
            new Customer_Attachment__c();

        doc.Contact__c = authorizedContact.Id;
        doc.Upload_Token__c = token;
        doc.Document_Type__c = documentType;
        doc.OCR_Status__c = 'Pending';
        doc.ContentVersionId__c = String.valueOf(versions[0].Id);
        insert as user doc;

        ContentDocumentLink linksCA = new ContentDocumentLink();
        linksCA.ContentDocumentId = contentDocumentId;
        linksCA.LinkedEntityId = doc.Id;
        linksCA.ShareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
        linksCA.Visibility = 'AllUsers';
        insert linksCA;

        System.enqueueJob(
            new GeminiDocumentQueueable(versions[0].Id)
        );
    }
}
