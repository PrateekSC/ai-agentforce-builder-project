public without sharing class GetBookingDetailsAction {
    public class Request {
        @InvocableVariable(required=true label='Verified Contact Id' description='Contact Id from Verify Customer Identity. Required. Never omit.')
        public String contactId;

        @InvocableVariable(required=true label='Booking Number' description='Booking number already verified for this customer.')
        public String bookingNumber;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True when the booking was found for this customer.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Human-readable booking summary to show in chat.')
        public String message;
        @InvocableVariable(label='Status' description='Current booking status from CRM after API sync.')
        public String status;
    }

    @InvocableMethod(
        label='Get Booking Details'
        description='Loads one verified customer booking and refreshes it from the booking API. Use when the customer asks about an existing reservation. Do not use to cancel, amend, or create a booking.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.getBooking(request.contactId, request.bookingNumber);
            Response response = new Response();
            response.success = domain.success;
            response.message = domain.message;
            response.status = domain.status;
            outputs.add(response);
        }
        return outputs;
    }
}