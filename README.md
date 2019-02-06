# CNI-Itineraries

[![Version](https://img.shields.io/cocoapods/v/CNI-Itineraries.svg?style=flat)](http://cocoapods.org/pods/CNI-Itineraries )
[![License](https://img.shields.io/cocoapods/l/CNI-Itineraries.svg?style=flat)](http://cocoapods.org/pods/CNI-Itineraries )
[![Platform](https://img.shields.io/cocoapods/p/CNI-Itineraries.svg?style=flat)](http://cocoapods.org/pods/CNI-Itineraries)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

CNI-Itineraries is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CNI-Itineraries'
```

## Usage
* CNIBookingManager init with username, password, consumer key, environment

* `import CNI_Itineraries`
* Use those `CNIBookingManager` methods

```swift
public class func getBookingsFor(guestId: String,
success: @escaping (_ results: [CNIBooking]) -> Void,
failure: @escaping (_ error: Error) -> Void)
```
```swift
public class func postBookingWith(data: [String: Any],
success: @escaping (_ result: Bool) -> Void,
failure: @escaping (_ error: Error) -> Void)
```
```swift
public class func deleteBookingWith(
guestId: String,
reservationNumber: String,
success: @escaping (_ result: Bool) -> Void,
failure: @escaping (_ error: Error) -> Void)
```


## Author

Joseph Tseng, joseph.tseng@conichi.com

## License

CNI-Itineraries is available under the MIT license. See the LICENSE file for more info.
