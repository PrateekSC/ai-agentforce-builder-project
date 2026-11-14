public with sharing class GetBookingAlternativesAction {
    public class Request {
        @InvocableVariable(required=true label='Verified Contact Id' description='Contact Id from identity verification.')
        public String contactId;
        @InvocableVariable(required=true label='Booking Number' description='Booking the customer wants to change or cancel.')
        public String bookingNumber;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True when alternatives were returned.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Options to present: amend, rebook, then cancel.')
        public String message;
    }

    @InvocableMethod(
        label='Get Booking Alternatives'
        description='Returns amendment and rebooking options for a booking. Always call this when the customer asks to cancel, before Cancel Booking. Do not cancel with this action.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.getAlternatives(request.contactId, request.bookingNumber);
            Response response = new Response();
            response.success = domain.success;
            response.message = domain.message;
            outputs.add(response);
        }
        return outputs;
    }
}