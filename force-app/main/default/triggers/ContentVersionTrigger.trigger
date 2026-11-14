trigger ContentVersionTrigger on ContentVersion (after insert) {

    for (ContentVersion cv : Trigger.new) {

        if (String.isNotBlank(
            cv.Guest_Upload_Token_fileupload__c
        )) {

            System.enqueueJob(
                new GeminiDocumentQueueable(cv.Id)
            );
        }
    }
}
