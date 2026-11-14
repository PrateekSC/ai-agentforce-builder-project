public with sharing class CancelBookingAction {
    public class Request {
        @InvocableVariable(required=true label='Verified Contact Id' description='Contact Id from identity verification.')
        public String contactId;
        @InvocableVariable(required=true label='Booking Number' description='Booking to cancel.')
        public String bookingNumber;
        @InvocableVariable(label='Cancellation Reason' description='Reason the customer gave, in their words.')
        public String reason;
        @InvocableVariable(required=true label='Customer Confirmed Cancellation' description='True only after the customer explicitly confirms they want to cancel after hearing fee and alternatives.')
        public Boolean customerConfirmed;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True only when the booking system cancelled the reservation.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Cancellation result to show in chat.')
        public String message;
    }

    @InvocableMethod(
        label='Cancel Booking'
        description='Cancels a verified customer booking in the booking API. Use only after Get Booking Alternatives was offered and the customer confirmed cancel. Do not use this to amend dates or create a new booking.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.cancel(
                request.contactId,
                request.bookingNumber,
                request.reason,
                request.customerConfirmed
            );
            Response response = new Response();
            response.success = domain.success;
            response.message = domain.message;
            outputs.add(response);
        }
        return outputs;
    }
}