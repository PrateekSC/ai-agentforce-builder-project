@IsTest
private class BookingApiMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('/alternatives')) {
            res.setBody('{"options":["amend dates","rebook SUV"]}');
        } else if (req.getMethod() == 'POST' && req.getEndpoint().endsWith('/v1/bookings')) {
            res.setBody('{"bookingNumber":"BK-NEW-1","id":"ext-1"}');
        } else {
            res.setBody('{"driverEmail":"a@b.com","flightNumber":"AI101","status":"Confirmed"}');
        }
        return res;
    }
}