public with sharing class AmendBookingAction {
    public class Request {
        @InvocableVariable(required=true label='Verified Contact Id' description='Contact Id from identity verification.')
        public String contactId;
        @InvocableVariable(required=true label='Booking Number' description='Booking to amend.')
        public String bookingNumber;
        @InvocableVariable(label='Driver Contact' description='New driver contact if the customer wants to change it. Leave blank if unchanged.')
        public String driverContact;
        @InvocableVariable(label='Flight Number' description='New flight number if the customer wants to change it. Leave blank if unchanged.')
        public String flightNumber;
        @InvocableVariable(label='Pickup Location' description='New pickup location. Leave blank if unchanged.')
        public String pickupLocation;
        @InvocableVariable(label='Drop-off Location' description='New drop-off location. Leave blank if unchanged.')
        public String dropoffLocation;
        @InvocableVariable(label='Pickup Datetime' description='New pickup date and time in ISO format. Leave blank if unchanged.')
        public Datetime pickupDatetime;
        @InvocableVariable(label='Drop-off Datetime' description='New drop-off date and time. Leave blank if unchanged.')
        public Datetime dropoffDatetime;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True only when the booking API accepted the amendment.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Confirmation or follow-up question for the customer.')
        public String message;
    }

    @InvocableMethod(
        label='Amend Booking'
        description='Updates email, flight, pickup/drop-off date, time, or location on an existing booking via the booking API. Use when the customer wants to change details, not cancel. Collect only changed fields. Require the customer to confirm the new values before calling.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.amend(
                request.contactId,
                request.bookingNumber,
                request.driverContact,
                request.flightNumber,
                request.pickupLocation,
                request.dropoffLocation,
                request.pickupDatetime,
                request.dropoffDatetime
            );
            Response response = new Response();
            response.success = domain.success;
            response.message = domain.message;
            outputs.add(response);
        }
        return outputs;
    }
}