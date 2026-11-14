public class ActionResult {
    public Boolean success;
    public String message;
    public String bookingNumber;
    public String status;
    public String newBookingNumber;
    public String errorCode;
    public Id contactId;
    public Id accountId;
    public String nextAction; // CONTINUE_BOOKING_CHANGES | REGISTER_CUSTOMER | CREATE_BOOKING
}