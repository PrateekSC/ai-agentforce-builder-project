public without sharing class RegisterCustomerAction {
    public class Request {
        @InvocableVariable(required=true label='First Name' description='Customer first name. Required. Do not invent.')
        public String firstName;
        @InvocableVariable(required=true label='Last Name' description='Customer last name. Required. Do not invent.')
        public String lastName;
        @InvocableVariable(required=true label='Email' description='Customer email. Required. Use the address they provided.')
        public String email;
        @InvocableVariable(label='Phone' description='Customer phone. Optional.')
        public String phone;
        @InvocableVariable(label='Company Name' description='B2B company or account name. Optional. If blank, a household account is created.')
        public String companyName;
    }

    public class Response {
        @InvocableVariable(label='Success' description='True when the Contact exists or was created.')
        public Boolean success;
        @InvocableVariable(label='Verified Contact Id' description='Store this in the agent variable. Required for Create Booking.')
        public String contactId;
        @InvocableVariable(label='Next Action' description='Always CREATE_BOOKING after a successful register.')
        public String nextAction;
        @InvocableVariable(label='Message' description='Say this to the customer. Do not expose Salesforce IDs.')
        public String message;
    }

    @InvocableMethod(
        label='Register Customer'
        description='Creates an Account and Contact in Salesforce when Verify Customer Identity returns CUSTOMER_NOT_FOUND. Use only after first name, last name, and email are collected. Do not use to amend, cancel, rebook, or create a booking. After success, collect trip details and call Create Booking. Do not start the booking before this action succeeds.'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> outputs = new List<Response>();
        for (Request request : requests) {
            BookingService.ActionResult domain = BookingService.registerCustomer(
                request.firstName,
                request.lastName,
                request.email,
                request.phone,
                request.companyName
            );
            Response response = new Response();
            response.success = domain.success;
            response.contactId = domain.contactId;
            response.nextAction = domain.nextAction;
            response.message = domain.message;
            outputs.add(response);
        }
        return outputs;
    }
}