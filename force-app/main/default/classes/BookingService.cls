public without sharing class BookingService {

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

    /*public static ActionResult verify(String bookingNumber, String email) {
        ActionResult result = new ActionResult();
        if (String.isBlank(bookingNumber) || String.isBlank(email)) {
            return fail(result, 'MISSING_INPUT', 'I need the booking number and the email on the reservation.');
        }

        List<Contact> contacts = [
            SELECT Id, AccountId, Email
            FROM Contact
            WHERE Email = :email
            //WITH USER_MODE
            LIMIT 1
        ];
        if (contacts.isEmpty()) {
            return fail(result, 'NOT_FOUND', 'I could not match that email to a customer record.');
        }

        Booking__c booking = BookingSelector.findForContact(bookingNumber, contacts[0].Id);
        if (booking == null) {
            return fail(result, 'NOT_FOUND', 'That booking number is not linked to this email.');
        }

        result.success = true;
        result.contactId = contacts[0].Id;
        result.bookingNumber = booking.Booking_Number__c;
        result.status = booking.Status__c;
        result.message = 'Identity verified. ' + summarize(booking);
        return result;
    }*/
    public static ActionResult verify(String bookingNumber, String email) {
        ActionResult result = new ActionResult();

        if (String.isBlank(email) && String.isBlank(bookingNumber)) {
            return needRegistration(result, 'I do not have a customer record yet.');
        }

        if (!String.isBlank(email)) {
            List<Contact> contacts = [
                SELECT Id, AccountId, Email
                FROM Contact
                WHERE Email = :email
                //WITH USER_MODE
                LIMIT 1
            ];

            if (contacts.isEmpty()) {
                return needRegistration(
                    result,
                    'No customer was found for that email.'
                );
            }

            result.contactId = contacts[0].Id;
            result.accountId = contacts[0].AccountId;

            if (String.isBlank(bookingNumber)) {
                result.success = true;
                result.nextAction = 'CREATE_BOOKING';
                result.message =
                    'Customer found. There is no booking number yet. Collect pickup location, drop-off location, pickup datetime, drop-off datetime, and vehicle class, then call Create Booking. Do not call Amend, Cancel, or Rebook.';
                return result;
            }

            Booking__c booking = BookingSelector.findForContact(bookingNumber, contacts[0].Id);
            if (booking == null) {
                result.success = true;
                result.nextAction = 'CREATE_BOOKING';
                result.message =
                    'Customer found, but that booking number is not on file. Collect trip details and call Create Booking. Do not amend or cancel a booking that does not exist.';
                return result;
            }

            result.success = true;
            result.nextAction = 'CONTINUE_BOOKING_CHANGES';
            result.bookingNumber = booking.Booking_Number__c;
            result.status = booking.Status__c;
            result.message = 'Identity verified. ' + summarize(booking);
            return result;
        }

        return needRegistration(result, 'Email is required to find or create a customer.');
    }

    private static ActionResult needRegistration(ActionResult result, String reason) {
        result.success = false;
        result.errorCode = 'CUSTOMER_NOT_FOUND';
        result.nextAction = 'REGISTER_CUSTOMER';
        result.message =
            reason +
            ' Do not start a booking yet. Ask for first name, last name, email, phone, and company name. ' +
            'Then call Register Customer. After that succeeds, collect trip details and call Create Booking.';
        return result;
    }

    public static ActionResult registerCustomer(
        String firstName,
        String lastName,
        String email,
        String phone,
        String companyName
    ) {
        ActionResult result = new ActionResult();

        if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(email)) {
            return fail(
                result,
                'MISSING_INPUT',
                'Ask for first name, last name, and email before registering. Phone and company name are optional but preferred for B2B.'
            );
        }

        List<Contact> existing = [
            SELECT Id, AccountId, Email
            FROM Contact
            WHERE Email = :email
            //WITH USER_MODE
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            result.success = true;
            result.contactId = existing[0].Id;
            result.accountId = existing[0].AccountId;
            result.nextAction = 'CREATE_BOOKING';
            result.message =
                'A customer with that email already exists. Store Verified Contact Id. Collect pickup/drop-off location, date, time, and vehicle class, then call Create Booking. Do not ask them to register again.';
            return result;
        }

        try {
            Id accountId = findOrCreateAccount(companyName, lastName);

            Contact c = new Contact();
            c.FirstName = firstName;
            c.LastName = lastName;
            c.Email = email;
            c.Phone = phone;
            c.AccountId = accountId;
            //Database.insert(c, AccessLevel.USER_MODE);
            Database.insert(c, false);

            result.success = true;
            result.contactId = c.Id;
            result.accountId = accountId;
            result.nextAction = 'CREATE_BOOKING';
            result.message =
                'Customer registered in Salesforce. Store Verified Contact Id. ' +
                'Now collect pickup location, drop-off location, pickup datetime, drop-off datetime, and vehicle class. ' +
                'Then call Create Booking. Do not call Amend, Cancel, or Rebook yet.';
            return result;
        } catch (Exception e) {
            return fail(result, 'REGISTER_FAILED', safeMessage(e));
        }
    }

    private static Id findOrCreateAccount(String companyName, String lastName) {
        String accountName = String.isBlank(companyName) ? lastName + ' Household' : companyName;

        List<Account> matches = [
            SELECT Id
            FROM Account
            WHERE Name = :accountName
            //WITH USER_MODE
            LIMIT 1
        ];
        if (!matches.isEmpty()) {
            return matches[0].Id;
        }

        Account a = new Account();
        a.Name = accountName;
        //Database.insert(a, AccessLevel.USER_MODE);
        Database.insert(a, false);
        return a.Id;
    }

    public static ActionResult getBooking(Id contactId, String bookingNumber) {
        ActionResult result = new ActionResult();
        try {
            BookingIdentityService.Identity identity = BookingIdentityService.requireVerified(contactId);
            Booking__c booking = requireBooking(bookingNumber, identity.contactId);
            result.success = true;
            result.bookingNumber = booking.Booking_Number__c;
            result.status = booking.Status__c;
            result.message = summarize(booking);
            return result;
        } catch (Exception e) {
            return fail(result, 'LOOKUP_FAILED', safeMessage(e));
        }
    }

    public static ActionResult getAlternatives(Id contactId, String bookingNumber) {
        ActionResult result = new ActionResult();
        try {
            BookingIdentityService.Identity identity = BookingIdentityService.requireVerified(contactId);
            Booking__c booking = requireBooking(bookingNumber, identity.contactId);

            if (booking.Status__c == 'Cancelled') {
                return fail(result, 'INVALID_STATE', 'This booking is already cancelled. Offer a new booking instead.');
            }

            result.success = true;
            result.bookingNumber = booking.Booking_Number__c;
            result.status = booking.Status__c;
            result.message =
                'Offer these options before any cancellation: ' +
                '(1) Amend this booking — change email, flight, pickup/drop-off date, time, or location. ' +
                '(2) Rebook — create a new reservation and close this one. ' +
                '(3) Cancel this booking. Cancellation fee: ' +
                String.valueOf(booking.Cancellation_Rate__c) + '. ' +
                'Current trip: ' + summarize(booking);
            return result;
        } catch (Exception e) {
            return fail(result, 'ALTERNATIVES_FAILED', safeMessage(e));
        }
    }

    public static ActionResult amend(
        Id contactId,
        String bookingNumber,
        String driverEmail,
        String flightNumber,
        String pickupLocation,
        String dropoffLocation,
        Datetime pickupDatetime,
        Datetime dropoffDatetime
    ) {
        ActionResult result = new ActionResult();
        try {
            BookingIdentityService.Identity identity = BookingIdentityService.requireVerified(contactId);
            Booking__c booking = requireBooking(bookingNumber, identity.contactId);

            if (booking.Status__c == 'Cancelled' || booking.Status__c == 'Rebooked') {
                return fail(result, 'INVALID_STATE', 'This booking cannot be amended. Offer a new booking instead.');
            }

            Boolean changed = false;
            if (!String.isBlank(driverEmail)) {
                booking.Driver_Email__c = driverEmail;
                changed = true;
            }
            if (!String.isBlank(flightNumber)) {
                booking.Flight_Number__c = flightNumber;
                changed = true;
            }
            if (!String.isBlank(pickupLocation)) {
                booking.Pickup_Location__c = pickupLocation;
                changed = true;
            }
            if (!String.isBlank(dropoffLocation)) {
                booking.Dropoff_Location__c = dropoffLocation;
                changed = true;
            }
            if (pickupDatetime != null) {
                booking.Pickup_Datetime__c = pickupDatetime;
                changed = true;
            }
            if (dropoffDatetime != null) {
                booking.Dropoff_Datetime__c = dropoffDatetime;
                changed = true;
            }

            if (!changed) {
                return fail(result, 'NO_CHANGES', 'Ask which field to change: email, flight, pickup/drop-off date, time, or location.');
            }

            booking.Status__c = 'Amended';
            Database.update(booking, AccessLevel.USER_MODE);
            createCase(identity, booking, 'Amendment', summarize(booking));

            result.success = true;
            result.bookingNumber = booking.Booking_Number__c;
            result.status = booking.Status__c;
            result.message = 'Amendment saved in Salesforce. Updated booking: ' + summarize(booking);
            return result;
        } catch (Exception e) {
            return fail(result, 'AMEND_FAILED', safeMessage(e));
        }
    }

    public static ActionResult cancel(Id contactId, String bookingNumber, String reason, Boolean customerConfirmed) {
        ActionResult result = new ActionResult();
        try {
            if (customerConfirmed != true) {
                return fail(result, 'CONFIRMATION_REQUIRED', 'Do not cancel yet. Restate the fee and ask the customer to confirm cancellation.');
            }

            BookingIdentityService.Identity identity = BookingIdentityService.requireVerified(contactId);
            Booking__c booking = requireBooking(bookingNumber, identity.contactId);

            if (booking.Status__c == 'Cancelled') {
                return fail(result, 'INVALID_STATE', 'This booking is already cancelled.');
            }

            booking.Status__c = 'Cancelled';
            //Database.update(booking, AccessLevel.USER_MODE);
            Database.update(booking, false);
            createCase(identity, booking, 'Cancellation', reason);

            result.success = true;
            result.bookingNumber = booking.Booking_Number__c;
            result.status = 'Cancelled';
            result.message =
                'Booking ' + booking.Booking_Number__c +
                ' is cancelled in Salesforce. Fee: ' +
                String.valueOf(booking.Cancellation_Rate__c) +
                '. Offer to create a new booking if they still need a vehicle.';
            return result;
        } catch (Exception e) {
            return fail(result, 'CANCEL_FAILED', safeMessage(e));
        }
    }

    public static ActionResult rebook(
        Id contactId,
        String originalBookingNumber,
        String pickupLocation,
        String dropoffLocation,
        Datetime pickupDatetime,
        Datetime dropoffDatetime,
        String vehicleClass
    ) {
        ActionResult result = new ActionResult();
        try {
            BookingIdentityService.Identity identity = BookingIdentityService.requireVerified(contactId);
            Booking__c original = requireBooking(originalBookingNumber, identity.contactId);

            if (String.isBlank(pickupLocation) || String.isBlank(dropoffLocation) ||
                pickupDatetime == null || dropoffDatetime == null || String.isBlank(vehicleClass)) {
                return fail(result, 'MISSING_INPUT', 'Collect pickup location, drop-off location, pickup datetime, drop-off datetime, and vehicle class before rebooking.');
            }

            Booking__c created = new Booking__c();
            created.Contact__c = identity.contactId;
            created.Account__c = identity.accountId;
            created.Status__c = 'Confirmed';
            created.Pickup_Location__c = pickupLocation;
            created.Dropoff_Location__c = dropoffLocation;
            created.Pickup_Datetime__c = pickupDatetime;
            created.Dropoff_Datetime__c = dropoffDatetime;
            created.Vehicle_Class__c = vehicleClass;
            created.Driver_Email__c = original.Driver_Email__c;
            created.Booking_Date__c = System.today();
            created.Previous_Booking__c = original.Id;
            created.Booking_Number__c = String.valueOf(Integer.valueOf([SELECT Booking_Number__c FROM Booking__c WHERE Booking_Number__c != null ORDER BY CreatedDate DESC LIMIT 1].Booking_Number__c)+1).leftPad(5, '0');
            Database.insert(created, AccessLevel.USER_MODE);
            //Database.insert(created, false);

            Booking__c inserted = [
                SELECT Id, Booking_Number__c, Status__c, Pickup_Location__c, Dropoff_Location__c,
                       Pickup_Datetime__c, Dropoff_Datetime__c, Vehicle_Class__c, Driver_Email__c,
                       Flight_Number__c, Cancellation_Rate__c, Contact__c, Account__c
                FROM Booking__c
                WHERE Id = :created.Id
                //WITH USER_MODE
                LIMIT 1
            ];

            original.Status__c = 'Rebooked';
            Database.update(original, AccessLevel.USER_MODE);
            createCase(identity, inserted, 'Rebooking', 'Replaced ' + originalBookingNumber);

            result.success = true;
            result.bookingNumber = originalBookingNumber;
            result.newBookingNumber = inserted.Booking_Number__c;
            result.status = inserted.Status__c;
            result.message =
                'New booking ' + inserted.Booking_Number__c +
                ' is confirmed in Salesforce. Original ' + originalBookingNumber +
                ' is marked Rebooked. ' + summarize(inserted);
            return result;
        } catch (Exception e) {
            return fail(result, 'REBOOK_FAILED', safeMessage(e));
        }
    }

    public static ActionResult createBooking(
        String customerId,
        String pickupLocation,
        String dropoffLocation,
        Datetime pickupDatetime,
        Datetime dropoffDatetime,
        String vehicleClass,
        String flightNumber
    ) {
        ActionResult result = new ActionResult();
        try {
            BookingIdentityService.Identity identity = BookingIdentityService.requireVerified(customerId);

            if (String.isBlank(pickupLocation) || String.isBlank(dropoffLocation) ||
                pickupDatetime == null || dropoffDatetime == null || String.isBlank(vehicleClass)) {
                return fail(result, 'MISSING_INPUT', 'Collect pickup location, drop-off location, pickup datetime, drop-off datetime, and vehicle class before rebooking.');
            }

            Booking__c created = new Booking__c();
            created.Contact__c = identity.contactId;
            created.Account__c = identity.accountId;
            created.Status__c = 'Confirmed';
            created.Pickup_Location__c = pickupLocation;
            created.Dropoff_Location__c = dropoffLocation;
            created.Pickup_Datetime__c = pickupDatetime;
            created.Dropoff_Datetime__c = dropoffDatetime;
            created.Vehicle_Class__c = vehicleClass;
            created.Flight_Number__c = flightNumber;
            //created.Driver_Email__c = original.Driver_Email__c;
            created.Booking_Date__c = System.today();
            created.Booking_Number__c = String.valueOf(Integer.valueOf([SELECT Booking_Number__c FROM Booking__c WHERE Booking_Number__c != null ORDER BY Booking_Number__c DESC LIMIT 1].Booking_Number__c)+1).leftPad(5, '0');
            Database.insert(created, AccessLevel.USER_MODE);
            //Database.insert(created, false);

            Booking__c inserted = [
                SELECT Id, Booking_Number__c, Status__c, Pickup_Location__c, Dropoff_Location__c,
                       Pickup_Datetime__c, Dropoff_Datetime__c, Vehicle_Class__c, Driver_Email__c,
                       Flight_Number__c, Cancellation_Rate__c, Contact__c, Account__c
                FROM Booking__c
                WHERE Id = :created.Id
                //WITH USER_MODE
                LIMIT 1
            ];

            createCase(identity, inserted, 'New Booking', 'New Booking ' + inserted.Booking_Number__c);

            result.success = true;
            result.contactId = identity.contactId;
            result.bookingNumber = inserted.Booking_Number__c;
            result.status = inserted.Status__c;
            result.nextAction = 'CONTINUE_BOOKING_CHANGES';
            result.message =
                'Booking created in Salesforce. Read back booking number ' +
                inserted.Booking_Number__c + '. ' + summarize(inserted);
            return result;
        } catch (Exception e) {
            return fail(result, 'REBOOK_FAILED', safeMessage(e));
        }
    }

    private static Booking__c requireBooking(String bookingNumber, Id contactId) {
        Booking__c booking = BookingSelector.findForContact(bookingNumber, contactId);
        if (booking == null) {
            throw new BookingException('No booking with that number exists for this customer. Do not guess another customer\'s booking.');
        }
        return booking;
    }

    private static void createCase(BookingIdentityService.Identity identity, Booking__c booking, String typeName, String detail) {
        Case c = new Case();
        c.Subject = typeName + ' for ' + booking.Booking_Number__c;
        c.Description = detail;
        c.Origin = 'Chat';
        c.ContactId = identity.contactId;
        c.AccountId = identity.accountId;
        c.Booking__c = booking.Id;
        //Database.insert(c, AccessLevel.USER_MODE);
        Database.insert(c, false);
    }

    private static String summarize(Booking__c booking) {
        return 'Booking ' + booking?.Booking_Number__c +
            ' status ' + booking?.Status__c +
            ', pickup ' + booking?.Pickup_Location__c +
            ' at ' + String.valueOf(booking?.Pickup_Datetime__c) +
            ', drop-off ' + booking?.Dropoff_Location__c +
            ' at ' + String.valueOf(booking?.Dropoff_Datetime__c) +
            ', vehicle ' + booking?.Vehicle_Class__c +
            ', email ' + booking?.Driver_Email__c +
            ', flight ' + booking?.Flight_Number__c +
            ', cancellation rate ' + String.valueOf(booking?.Cancellation_Rate__c) +
            ', ContactId=' + String.valueOf(booking?.Contact__c) + '.';
    }

    private static ActionResult fail(ActionResult result, String code, String message) {
        result.success = false;
        result.errorCode = code;
        result.message = message;
        return result;
    }

    private static String safeMessage(Exception e) {
        if (e instanceof BookingException) {
            return e.getMessage();
        }
        return 'Something went wrong updating the booking in Salesforce. Escalate to a human agent.';
    }
}
