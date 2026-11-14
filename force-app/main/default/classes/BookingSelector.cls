public without sharing class BookingSelector {
    public static Booking__c findForContact(String bookingNumber, Id contactId) {
        List<Booking__c> rows = [
            SELECT Id, Name, Booking_Number__c, Contact__c, Account__c, Status__c,
                   Pickup_Location__c, Dropoff_Location__c, Pickup_Datetime__c,
                   Dropoff_Datetime__c, Driver_Contact__c, Flight_Number__c,
                   Vehicle_Class__c, Cancellation_Rate__c, Total_Booking_Fees__c, 
                   Driver_Email__c, Commission_Rate__c, Discount_Rate__c
            FROM Booking__c
            WHERE Booking_Number__c = :bookingNumber
              AND Contact__c = :contactId
            //WITH USER_MODE
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public static List<Booking__c> findOpenForContact(Id contactId) {
        return [
            SELECT Id, Booking_Number__c, Status__c, Pickup_Location__c,
                   Pickup_Datetime__c, Vehicle_Class__c
            FROM Booking__c
            WHERE Contact__c = :contactId
              AND Status__c IN ('Confirmed', 'Amended')
            //WITH USER_MODE
            ORDER BY Pickup_Datetime__c DESC
            LIMIT 20
        ];
    }
}