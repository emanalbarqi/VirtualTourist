# FINAL PROJECT: Virtual Tourist 
Virtual Tourist is IOS application that allows users to visit virtual places around the world by dropping pin on the map and generate collections of photo for selected place. All application info will be stored in core data.

the contains two view controller:
## Map Locations view:
allow users to add pins on the map around the world. When the app starts it will open to map view. All stored pin in core data should appear. the user will be able to long press to drop a new pin in the map, zoom and scroll around the map using standard pinch and drag gestures. The map should return to the same state when it is turned on again. when select pin the app will navigate to pin album.


## Pin Album View:
allow users to see photos for selected pin, delete any photo, and generate new collection of photos.
Pin Album. When user select a pin that already has a photos then the pin album view should display the photos stored for this pin. if pin does not have photos, the app will download Flickr images associated with the latitude and longitude of the pin. If no images are found a “No Images” label will be displayed.  The app will display a placeholder image for retrived image until downloading. when tapping a photo will be removed from collection and thel changes to the pin album should be automatically made persistent. Tapping the back button should return the user to the Map view. The user will be able to generate new collecition of photos by tapping generate new collections that will empty the pin photos and fetch a new set of images. Note that in locations that have a fairly static set of Flickr images, “new” images might overlap with previous collections of images.


## Prerequisites

It was built using Xcode Version Version 10.1 (10B61) along with Swift 4.2.1.

Installation CocoaPods
1- CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command: $ gem install cocoapods
2- In the destination of project create pod file with following command: pod init

3- To integrate Kingfisher into your Xcode project using CocoaPods, specify it to a target in your Podfile:

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.1'
use_frameworks!

target 'MyApp' do
#your other pod
#...
pod 'Kingfisher', '~> 5.0'
end

4- Then, run the following command: $ pod install

5- You should open the {Project}.xcworkspace instead of the {Project}.xcodeproj after you installed anything from CocoaPods.
