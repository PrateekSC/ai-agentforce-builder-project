public with sharing class VerifyCustomerIdentityAction {
    public class Request {
        @InvocableVariable(required=true label='Booking Number' description='Customer-facing booking or reservation number. Never invent one.')
        public String bookingNumber;

        @InvocableVariable(required=true label='Customer Email' description='Email address the customer says is on the booking.')
        public String email;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True when booking number and email match a Contact-owned booking.')
        public Boolean success;

        @InvocableVariable(label='Verified Contact Id' description='Salesforce Contact Id to store in an agent variable and pass to every later action.')
        public String contactId;

        @InvocableVariable(label='Message' description='Say this to the customer. Do not expose internal IDs.')
        public String message;
    }

    @InvocableMethod(
        label='Verify Customer Identity'
        description='Verifies a customer using booking number plus email before any private booking action. Use this first in a conversation. Do not use this to cancel, amend, or rebook.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.verify(request.bookingNumber, request.email);
            Response response = new Response();
            response.success = domain.success;
            response.contactId = domain.contactId;
            response.message = domain.message;
            if (domain.success == true && domain.message != null && domain.message.contains('ContactId=')) {
                response.contactId = domain.message.substringAfter('ContactId=').substringBefore('.');
            }
            outputs.add(response);
        }
        return outputs;
    }
}