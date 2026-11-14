public with sharing class BookingDto {
    public String bookingNumber;
    public String status;
    public String pickupLocation;
    public String dropoffLocation;
    public Datetime pickupDatetime;
    public Datetime dropoffDatetime;
    public String driverEmail;
    public String flightNumber;
    public String vehicleClass;
    public Decimal cancellationFee;
    public String externalId;
    public String summaryForAgent;
}