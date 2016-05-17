# SireJSONModel

[![CI Status](http://img.shields.io/travis/Sire/SireJSONModel.svg?style=flat)](https://travis-ci.org/Sire/SireJSONModel)
[![Version](https://img.shields.io/cocoapods/v/SireJSONModel.svg?style=flat)](http://cocoapods.org/pods/SireJSONModel)
[![License](https://img.shields.io/cocoapods/l/SireJSONModel.svg?style=flat)](http://cocoapods.org/pods/SireJSONModel)
[![Platform](https://img.shields.io/cocoapods/p/SireJSONModel.svg?style=flat)](http://cocoapods.org/pods/SireJSONModel)
====
If you like SwiftAutoNSCoding and use it, could you please:

star this repo

send me some feedback. Thanks!
##Basic usage
####Json like this  in a file:   
  {
  "order_id": 104,
  "total_price": 103.45,
  "products" : [
    {
      "id": "123",
      "name": "Product #1",
      "price": 12.95
    },
    {
      "id": "137",
      "name": "Product #2",
      "price": 82.95
    }
  ]
 }

```Swift
  class Shop:NSObject{
    var order_id:String?
    var total_price:String?
    var products:[Product]?
  }
  class Product:NSObject{
    var id:Stirng?
    var name:String?
    var Price:Int = 0
  }
```
####turn json data to model
```Swift
  let path = NSBundle.mainBundle().pathForResource("data", ofType: "json")
		let data = NSData(contentsOfFile: path!)
		let jsonData = MallInfor(jsonNSData: data!)
		print("\(jsonData.toDictionary())")
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Attention
  * except `String` , `Object` and `Array` Type ,other type(like `Bool` ,`Int`, `Short`, `Char`, `Double`) in object model can not be optianl,because method in NSObject 'setVaue' does not support,they must be a determined type (like Int? must be set to Int)
  * do not write model class in anther class ,it will fail in create instance because can't find the class name
  * define app name use Bundle Name Display instead of Bundle Name
  

## Installation

SireJSONModel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SireJSONModel', :git => 'https://github.com/SireAI/SireJSONModel.git'
```

## Author
Sire, 1120523212@qq.com   
[Sire的博客](http://sireai.github.io/)
## My Other Projects
[SwiftAutoNSCoding](https://github.com/SireAI/SwiftAutoNSCoding)

## License

SireJSONModel is available under the MIT license. See the LICENSE file for more info.
