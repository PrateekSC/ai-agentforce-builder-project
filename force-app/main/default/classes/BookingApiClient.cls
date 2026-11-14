public with sharing class BookingApiClient {
    public class ApiResult {
        public Integer statusCode;
        public String body;
        public Boolean ok;
    }

    public static ApiResult getBooking(String bookingNumber) {
        return send('GET', '/v1/bookings/' + url(bookingNumber), null);
    }

    public static ApiResult patchBooking(String bookingNumber, Map<String, Object> payload) {
        return send('PATCH', '/v1/bookings/' + url(bookingNumber), JSON.serialize(payload));
    }

    public static ApiResult cancelBooking(String bookingNumber, String reason) {
        Map<String, Object> payload = new Map<String, Object>{ 'reason' => reason };
        return send('POST', '/v1/bookings/' + url(bookingNumber) + '/cancel', JSON.serialize(payload));
    }

    public static ApiResult rebook(Map<String, Object> payload) {
        return send('POST', '/v1/bookings', JSON.serialize(payload));
    }

    public static ApiResult alternatives(String bookingNumber) {
        return send('GET', '/v1/bookings/' + url(bookingNumber) + '/alternatives', null);
    }

    private static String url(String value) {
        return EncodingUtil.urlEncode(value, 'UTF-8');
    }

    private static ApiResult send(String method, String path, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Booking_API' + path);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(12000);
        if (body != null) {
            req.setBody(body);
        }

        HttpResponse res = new Http().send(req);
        ApiResult result = new ApiResult();
        result.statusCode = res.getStatusCode();
        result.body = res.getBody();
        result.ok = res.getStatusCode() >= 200 && res.getStatusCode() < 300;
        return result;
    }
}