# CNI-Booking

[![Version](https://img.shields.io/cocoapods/v/CNI-Booking.svg?style=flat)](http://cocoapods.org/pods/CNI-Booking)
[![License](https://img.shields.io/cocoapods/l/CNI-Booking.svg?style=flat)](http://cocoapods.org/pods/CNI-Booking)
[![Platform](https://img.shields.io/cocoapods/p/CNI-Booking.svg?style=flat)](http://cocoapods.org/pods/CNI-Booking)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

CNI-Booking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CNI-Booking'
```

## Usage

## Usage
* CNIBookingManager init with username, password, consumer key, environment

* `import CNIBooking`
* Use those `CNIBookingManager` methods
```swift
public class func getBookingsWith(success: @escaping (_ results: [CNIBooking]) -> Void,
failure: @escaping (_ error: Error) -> Void)
```
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
public class func deleteBookingWith(data: [String: Any],
success: @escaping (_ result: Bool) -> Void,
failure: @escaping (_ error: Error) -> Void)
```


## Author

vincentjacquesson, vincent.jacquesson@conichi.com

## License

CNI-Booking is available under the MIT license. See the LICENSE file for more info.
