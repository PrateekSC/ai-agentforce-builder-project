public without sharing class BookingIdentityService {
    public class Identity {
        public Id contactId;
        public Id accountId;
        public String email;
        public Boolean verified;
    }

    /**
     * Verified identity from Experience Cloud user, or from a prior
     * verification action that stored Contact Id in an agent variable.
     */
    public static Identity requireVerified(Id contactId) {
        if (contactId == null) {
            throw new BookingException(
                'Customer is not verified. Collect booking number and registered email, then call Verify Customer Identity.'
            );
        }

        List<Contact> contacts = [
            SELECT Id, AccountId, Email
            FROM Contact
            WHERE Id = :contactId
            //WITH USER_MODE
            LIMIT 1
        ];
        if (contacts.isEmpty()) {
            throw new BookingException('Verified contact was not found or is not accessible.');
        }

        Identity identity = new Identity();
        identity.contactId = contacts[0].Id;
        identity.accountId = contacts[0].AccountId;
        identity.email = contacts[0].Email;
        identity.verified = true;
        return identity;
    }

}