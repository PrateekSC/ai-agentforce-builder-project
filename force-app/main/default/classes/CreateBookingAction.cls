public without sharing class CreateBookingAction {
    public class Request {
        @InvocableVariable(required=true label='Verified Contact Id' description='Contact Id from Verify Customer Identity or Register Customer. Never omit.')
        public String contactId;
        @InvocableVariable(required=true label='Pickup Location' description='Pickup location stated by the customer.')
        public String pickupLocation;
        @InvocableVariable(required=true label='Drop-off Location' description='Drop-off location. If they only gave one place, confirm before reusing it.')
        public String dropoffLocation;
        @InvocableVariable(required=true label='Pickup Datetime' description='Pickup date and time.')
        public Datetime pickupDatetime;
        @InvocableVariable(required=true label='Drop-off Datetime' description='Drop-off date and time.')
        public Datetime dropoffDatetime;
        @InvocableVariable(required=true label='Vehicle Class' description='Requested class such as Compact, SUV, or Van.')
        public String vehicleClass;
        @InvocableVariable(label='Driver Email' description='Driver email if different from the registered email.')
        public String driverEmail;
        @InvocableVariable(label='Flight Number' description='Flight number if they provided one.')
        public String flightNumber;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True only when a Booking record was inserted.')
        public Boolean success;
        @InvocableVariable(label='Booking Number' description='New booking number to read back.')
        public String bookingNumber;
        @InvocableVariable(label='Message' description='Confirmation for chat. Do not invent a number if success is false.')
        public String message;
    }

    @InvocableMethod(
        label='Create Booking'
        description='Creates a new Booking record in Salesforce for a registered customer. Use after Register Customer or when Verify found a customer with no booking. Collect every trip field first and confirm values before calling. Do not use this if Verify succeeded on an existing booking. Do not use to register a customer, amend, cancel, or rebook.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.createBooking(
                request.contactId,
                request.pickupLocation,
                request.dropoffLocation,
                request.pickupDatetime,
                request.dropoffDatetime,
                request.vehicleClass,
                //request.driverEmail,
                request.flightNumber
            );
            Response response = new Response();
            response.success = domain.success;
            response.bookingNumber = domain.bookingNumber;
            response.message = domain.message;
            outputs.add(response);
        }
        return outputs;
    }
}