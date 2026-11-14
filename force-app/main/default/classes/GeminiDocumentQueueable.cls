
public without sharing class GeminiDocumentQueueable
    implements Queueable, Database.AllowsCallouts {

    private Id contentVersionId;

    private static final String MODEL = 'gemini-3.5-flash-lite';
        //'gemini-3.8-flash';

    public GeminiDocumentQueueable(Id fileId) {
        contentVersionId = fileId;
    }

    public void execute(QueueableContext context) {

        ContentVersion file = [
            SELECT Id, Title, FileExtension, VersionData,
                   Guest_Upload_Token_fileupload__c
            FROM ContentVersion
            WHERE Id = :contentVersionId
            LIMIT 1
        ];

        String token =
            file.Guest_Upload_Token_fileupload__c;

        List<Customer_Attachment__c> docs = [
            SELECT Id, Contact__c, Upload_Token__c,
                   OCR_Status__c
            FROM Customer_Attachment__c
            WHERE Upload_Token__c = :token
            OR ContentVersionId__c = :String.valueOf(contentVersionId)
            LIMIT 1
        ];

        if (docs.isEmpty() ||
            docs[0].Contact__c == null ||
            docs[0].OCR_Status__c != 'Pending') {
            return;
        }

        Customer_Attachment__c doc = docs[0];

        //doc.OCR_Status__c = 'Processing';
        //update doc;

        try {

            String extension =
                file.FileExtension.toLowerCase();

            String mimeType;

            if (extension == 'pdf') {
                mimeType = 'application/pdf';
            } else if (extension == 'png') {
                mimeType = 'image/png';
            } else if (
                extension == 'jpg' ||
                extension == 'jpeg'
            ) {
                mimeType = 'image/jpeg';
            } else {
                throw new CalloutException(
                    'Unsupported file format.'
                );
            }

            String base64File =
                EncodingUtil.base64Encode(file.VersionData);

            String prompt =
                'You are an Indian government identity ' +
                'document extraction assistant. Identify ' +
                'whether this is an Aadhaar, PAN, Voter ID, ' +
                'Passport, Driving Licence or Ration Card. ' +
                'Extract the government id number, full name, DOB, ' +
                'gender and address where explicitly present. ' +
                'Do not invent missing information. Do not confuse ' +
                'age, issue date, expiry date and DOB. ' +
                'Return a complete government ID number.' +
                'Return the extracted information in JSON format. ' +
                'Check, extract and return information which are provided in English language only. ' +
                'If only the year is present, return YEAR_ONLY. ' +
                'If only age is present, return AGE_ONLY. ' +
                'If uncertain, set needs_manual_review to true. ' +
                'Use ISO date format YYYY-MM-DD for full DOB.';

            Map<String, Object> inlineData =
                new Map<String, Object>{
                    'mime_type' => mimeType,
                    'data' => base64File
                };

            Map<String, Object> filePart =
                new Map<String, Object>{
                    'inline_data' => inlineData
                };

            Map<String, Object> textPart =
                new Map<String, Object>{
                    'text' => prompt
                };

            Map<String, Object> content =
                new Map<String, Object>{
                    'parts' => new List<Object>{
                        textPart,
                        filePart
                    }
                };

            Map<String, Object> generationConfig =
                new Map<String, Object>{
                    'responseMimeType' => 'application/json',
                    'responseSchema' => getSchema(),
                    'temperature' => 0
                };

            Map<String, Object> payload =
                new Map<String, Object>{
                    'contents' => new List<Object>{ content },
                    'generationConfig' => generationConfig
                };

            HttpRequest request = new HttpRequest();
            
            External_API_Key__mdt apiValue = [SELECT Id, Value__c FROM External_API_Key__mdt WHERE DeveloperName = 'Gemini_API_Key' LIMIT 1];

            request.setEndpoint(
                'callout:Gemini_API/v1beta/models/' +
                MODEL + ':generateContent' + '?key=' +
                apiValue.Value__c
            );

            request.setMethod('POST');

            request.setHeader(
                'Content-Type',
                'application/json'
            );
  
            request.setTimeout(120000);

            request.setBody(JSON.serialize(payload));

            HttpResponse response =
                new Http().send(request);

            if (response.getStatusCode() != 200) {
                throw new CalloutException(
                    'Gemini API returned HTTP ' +
                    response.getStatusCode()
                );
            }

            Map<String, Object> responseBody =
                (Map<String, Object>)
                JSON.deserializeUntyped(response.getBody());

            List<Object> candidates =
                (List<Object>) responseBody.get('candidates');

            if (candidates == null || candidates.isEmpty()) {
                throw new CalloutException(
                    'Gemini returned no candidates.'
                );
            }

            Map<String, Object> candidate =
                (Map<String, Object>) candidates[0];

            Map<String, Object> candidateContent =
                (Map<String, Object>) candidate.get('content');

            List<Object> parts =
                (List<Object>) candidateContent.get('parts');

            if (parts == null || parts.isEmpty()) {
                throw new CalloutException(
                    'Gemini returned empty content.'
                );
            }

            Map<String, Object> firstPart =
                (Map<String, Object>) parts[0];

            String extractedJson =
                (String) firstPart.get('text');

            Map<String, Object> extracted =
                (Map<String, Object>)
                JSON.deserializeUntyped(extractedJson);

            if (extracted.get('success') != true) {
                throw new CalloutException(
                    'Document extraction unsuccessful.'
                );
            }
            //doc.API_Request__c = JSON.serialize(payload);
            //doc.API_Response__c = JSON.serialize(responseBody);
            String formattedJsonAPIRequest =
                JSON.serializePretty(payload);
            String formattedJsonAPIResponse =
                JSON.serializePretty(responseBody);
            List<ContentVersion> apiRequestResponseVersions = new List<ContentVersion>();
            ContentVersion cvRequest = new ContentVersion();
            cvRequest.Title = 'API_Request_' + Datetime.now().getTime();
            cvRequest.PathOnClient = cvRequest.Title + '.json';
            cvRequest.VersionData = Blob.valueOf(formattedJsonAPIRequest);
            cvRequest.FirstPublishLocationId = doc.Id;
            apiRequestResponseVersions.add(cvRequest);
            //insert cvRequest;
            ContentVersion cvResponse = new ContentVersion();
            cvResponse.Title = 'API_Response_' + Datetime.now().getTime();
            cvResponse.PathOnClient = cvResponse.Title + '.json';
            cvResponse.VersionData = Blob.valueOf(formattedJsonAPIResponse);
            cvResponse.FirstPublishLocationId = doc.Id;
            apiRequestResponseVersions.add(cvResponse);
            insert apiRequestResponseVersions;
            //insert cvResponse, cvRequest;
            saveResults(doc, extracted, file.Id);

        } catch (Exception ex) {

            doc.OCR_Status__c = 'Failed';
            doc.OCR_Error__c =
                'Processing failed: ' + ex.getMessage();

            update doc;
        }
    }

    private static Map<String, Object> getSchema() {

        Map<String, Object> stringSchema =
            new Map<String, Object>{
                'type' => 'STRING'
            };

        Map<String, Object> properties =
            new Map<String, Object>{
                'success' => new Map<String, Object>{
                    'type' => 'BOOLEAN'
                },
                'document_type' => new Map<String, Object>{
                    'type' => 'STRING',
                    'enum' => new List<String>{
                        'AADHAAR',
                        'PAN',
                        'VOTER_ID',
                        'PASSPORT',
                        'DRIVING_LICENSE',
                        'RATION_CARD',
                        'UNKNOWN'
                    }
                },
                'full_name' => stringSchema,
                'date_of_birth' => stringSchema,
                'dob_precision' => new Map<String, Object>{
                    'type' => 'STRING',
                    'enum' => new List<String>{
                        'FULL_DATE',
                        'YEAR_ONLY',
                        'AGE_ONLY',
                        'UNKNOWN'
                    }
                },
                'government_id_number' => stringSchema,
                'gender' => stringSchema,
                'full_address' => stringSchema,
                'city' => stringSchema,
                'state' => stringSchema,
                'pincode' => stringSchema,
                'confidence' => new Map<String, Object>{
                    'type' => 'NUMBER'
                },
                'needs_manual_review' => new Map<String, Object>{
                    'type' => 'BOOLEAN'
                }
            };

        return new Map<String, Object>{
            'type' => 'OBJECT',
            'properties' => properties,
            'required' => new List<String>{
                'success',
                'document_type',
                'full_name',
                'date_of_birth',
                'dob_precision',
                'gender',
                'full_address',
                'city',
                'state',
                'pincode',
                'confidence',
                'government_id_number',
                'needs_manual_review'
            }
        };
    }

    private static void saveResults(
        Customer_Attachment__c doc,
        Map<String, Object> data,
        Id fileId
    ) {

        doc.Document_Type__c =
            (String)data.get('document_type');

        doc.Full_Name__c =
            (String)data.get('full_name');

        doc.DOB_Precision__c =
            (String)data.get('dob_precision');

        doc.Gender__c =
            (String)data.get('gender');

        doc.Full_Address__c =
            (String)data.get('full_address');

        doc.City__c =
            (String)data.get('city');

        doc.State__c =
            (String)data.get('state');

        doc.Pincode__c =
            (String)data.get('pincode');

        doc.ContentVersionId__c =
            String.valueOf(fileId);

        doc.OCR_Confidence__c =
            Decimal.valueOf(
                String.valueOf(data.get('confidence'))
            );

        doc.Government_Id_Number__c =
            (String)data.get('government_id_number');

        String dob = (String)data.get('date_of_birth');

        if (String.isNotBlank(dob) &&
            doc.DOB_Precision__c == 'FULL_DATE') {

            doc.Date_of_Birth__c = Date.valueOf(dob);
        }

        Boolean review =
            (Boolean)data.get('needs_manual_review');

        if (review == true ||
            doc.OCR_Confidence__c < 0.85 ||
            doc.Document_Type__c == 'UNKNOWN') {

            doc.OCR_Status__c = 'Needs Review';

            update doc;
            return;
        }

        doc.OCR_Status__c = 'Extracted';

        update doc;

        updateContact(doc);
    }

    private static void updateContact(
        Customer_Attachment__c doc
    ) {

        Contact con = [
            SELECT Id, FirstName, LastName, Birthdate,
                   MailingStreet, MailingCity,
                   MailingState, MailingPostalCode
            FROM Contact
            WHERE Id = :doc.Contact__c
            LIMIT 1
        ];

        // Only populate empty Contact fields.

        if (String.isBlank(con.LastName) &&
            String.isNotBlank(doc.Full_Name__c)) {

            List<String> names =
                doc.Full_Name__c.trim().split('\\s+');

            con.LastName = names[names.size() - 1];

            if (names.size() > 1) {
                List<String> firstNames =
                    new List<String>();

                for (Integer i = 0; i < names.size() - 1; i++) {
                    firstNames.add(names[i]);
                }

                con.FirstName =
                    String.join(firstNames, ' ');
            }
        }

        if (con.Birthdate == null &&
            doc.Date_of_Birth__c != null) {

            con.Birthdate = doc.Date_of_Birth__c;
        }

        if (String.isBlank(con.MailingStreet)) {
            con.MailingStreet = doc.Full_Address__c;
        }

        if (String.isBlank(con.MailingCity)) {
            con.MailingCity = doc.City__c;
        }

        /*if (String.isBlank(con.MailingState)) {
            con.MailingState = doc.State__c;
        }*/

        if (String.isBlank(con.MailingPostalCode)) {
            con.MailingPostalCode = doc.Pincode__c;
        }

        update con;
    }
}
