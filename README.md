# Migration guide 1.x.x -> 2.0.x
## API changes
### Instantiation
Before (1.1.x)
```
let bookingManager = CNIBookingManager(
    username: "<username>",
    password: "<password>",
    consumerKey: "<consumerKey>",
    environment: "staging")
```
After (2.0.x)
```
let bookingManager = CNIBookingManager(
    environment: .staging,
    apiToken: token,
    isTesting: true)
```
The `apiToken` for each environment will be provided separately.

### Get bookings

Before (1.1.x)
```
bookingManager.getBookingsFor(
      guestId: "1234",
      success: { (itineraries: [CNIBooking]) in

      },
      failure: { (error: Error) in  

      }
)
```

After (2.0.x)
```
let source = "CYTRIC_MOBILE"
let travelerId = "1234"
let partnerId = "5678"

bookingManager.getBookings(
      source: source,
      travelerID: travelerId,
      partnerPrimaryId: partnerId,
      partnerSecondaryIds: nil,
      success: {
        (response: CNIResponse<[CNIBooking]>) in

      },
      failure: {
        (response: CNIResponse<CNIStatus>) in

      }
)
```
(!) IMPORTANT: `source` argument tells the API where does the booking come from. This argument is present for cases such as when a library client sends us bookings from different sources.
<br/>For instance, Cytric should use `"CYTRIC_MOBILE"` for all their bookings as stated in the example above.

### Create a booking
Before (1.1.x)
```
let guest: CNIGuest = ...
let hotel: CNIHotel = ...
let stay: CNIStay = ...
let data = ["guest": guest.deserialize(),
            "hotel": hotel.deserialize(),
            "stay": stay.deserialize()]

bookingManager.postBookingWith(
      data: data,         
      success: { (result: Bool) in

      },
      failure: { (error: Error) in

      }
)
```
After (2.0.x)
```
let booking: CNIBooking = ...
let source = "CYTRIC_MOBILE"

bookingManager.postBooking(
      source: source,
      booking: booking,
      completion: { (response: CNIResponse<CNIStatus>) in

      }
)
```
(!) IMPORTANT: `source` argument tells the API where does the booking come from. This argument is present for cases such as when a library client sends us bookings from different sources.
<br/>For instance, Cytric should use `"CYTRIC_MOBILE"` for all their bookings as stated in the example above.

### Delete a booking
Before (1.1.x)
```
let guestId = "1234"
let reservationNumber = "EU-1337"

bookingManager.deleteBookingWith(
      guestId: guestId,
      reservationNumber: reservationNumber,
      success: { (result: Bool) in

      },
      failure: { (error: Error) in

      }
)
```
After (2.0.x)
```
let travelerId = "1234"
let partnerId = "5678"
let reservationNumber = "EU-1337"
let source = "CYTRIC_MOBILE"

bookingManager.cancelBooking(
      source: source,
      travelerId: travelerId,
      reservationNumber: reservationNumber,
      partnerPrimaryId: partnerId,
      partnerSecondaryIds: nil,
      completion: { (response: CNIResponse<CNIStatus>) in

      }
)
```
(!) IMPORTANT: `source` argument tells the API where does the booking come from. This argument is present for cases such as when a library client sends us bookings from different sources.
<br/>For instance, Cytric should use `"CYTRIC_MOBILE"` for all their bookings as stated in the example above.


## General info

### API response
Every request to Itineraries API returns `CNIResponse<CNIStatus>`.<br/>
You can check if the request was successful by checking ` CNIResponse.isSuccessful`.
It will return `false` in case if HTTP status code of the response is different from 2XX.

To obtain detailed information with the backend API response, you can use `CNIStatus`

```
let response: CNIResponse<CNIStatus> = ...
let status: CNIStatus = response.result
```

In case the request has failed (`CNIResponse.isSuccessful == false`) - check `CNIStatus.reason` for more detailed information.
