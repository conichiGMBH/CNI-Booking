# How To
## Release

To make the library accessible to our partners we're using cocoapods.

In order for the Pod to be publicly accessible while keeping the sources private, we need to host the compiled framework on a public repository. (https://github.com/conichiGMBH/CNI-Booking.git)

### Steps

#### 1. Generate the framework

- Run `bundle exec pod install` to install the Pods if necessary

- Run `bundle exec fastlane build_frameworks`

This will generate `CNI_Itineraries.framework` in the `Carthage/Build/iOS/` folder

#### 2. Add framework to CNI-booking

- Clone CNI-Booking (https://github.com/conichiGMBH/CNI-Booking.git)

- Copy `CNI_Itineraries.framework` at the root

- Add the file with `git add CNI_Itineraries.framework`

- Commit & push to remote

#### 3. Update podspecs

- Open `CNI-Itineraries.podspec`

- Update `s.version` to `VERSION_NUMBER`

- Commit & push changes to remote

#### 4. Tag the version

- Tag the commit with `git tag VERSION_NUMBER`

- Push the tag to remote `git push origin VERSION_NUMBER`

#### 5. Push the specs to CocoaPods

Note: CNI-Booking doesn't have Bundler. You wil need to have a version of cocoapods installed on your machine. (install with `sudo gem install cocoapods`)

- Make sure you're registered on Trunk `pod trunk register dev@conichi.com`

- Run `pod lib lint` to verify the Pod configuration is correct

- Run `pod trunk push CNI-Itineraries.podspec`

#### You're done.
You can verify that the version was pushed to cocoapods with `pod trunk info CNI-Itineraries`

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
