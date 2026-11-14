public with sharing class RebookVehicleAction {
    public class Request {
        @InvocableVariable(required=true label='Verified Contact Id' description='Contact Id from identity verification.')
        public String contactId;
        @InvocableVariable(required=true label='Original Booking Number' description='Existing booking being replaced.')
        public String originalBookingNumber;
        @InvocableVariable(required=true label='Pickup Location' description='New pickup location stated by the customer.')
        public String pickupLocation;
        @InvocableVariable(required=true label='Drop-off Location' description='New drop-off location. If omitted by the customer, reuse pickup location only after asking.')
        public String dropoffLocation;
        @InvocableVariable(required=true label='Pickup Datetime' description='New pickup date and time.')
        public Datetime pickupDatetime;
        @InvocableVariable(required=true label='Drop-off Datetime' description='New drop-off date and time.')
        public Datetime dropoffDatetime;
        @InvocableVariable(required=true label='Vehicle Class' description='Requested class such as Compact, SUV, or Van.')
        public String vehicleClass;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True when a new booking number was issued.')
        public Boolean success;
        @InvocableVariable(label='New Booking Number' description='New reservation number to read back to the customer.')
        public String newBookingNumber;
        @InvocableVariable(label='Message' description='Rebooking confirmation for chat.')
        public String message;
    }

    @InvocableMethod(
        label='Rebook Vehicle'
        description='Creates a new booking from customer pickup/drop-off date, time, location, and vehicle class, and marks the original as rebooked. Use when the customer wants a different trip instead of cancelling. Collect every required field before calling. Do not cancel without a new booking unless the customer asks.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.rebook(
                request.contactId,
                request.originalBookingNumber,
                request.pickupLocation,
                request.dropoffLocation,
                request.pickupDatetime,
                request.dropoffDatetime,
                request.vehicleClass
            );
            Response response = new Response();
            response.success = domain.success;
            response.newBookingNumber = domain.newBookingNumber;
            response.message = domain.message;
            outputs.add(response);
        }
        return outputs;
    }
}