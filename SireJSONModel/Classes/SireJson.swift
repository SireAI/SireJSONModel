//
//  SireJson.swift
//  YaApple
//
//  Created by Sire on 16/5/4.
//  Copyright © 2016年 sire. All rights reserved.
//

import Foundation

public extension NSObject {
	// - MARK: model entrance
	public convenience init(jsonDictionary: [String: AnyObject]) {
		self.init()
		self.fillDataWithDictionary(jsonDictionary)
	}
	public convenience init(jsonString: String?) {
		self.init()
		let jsonDictionary = dictionaryFromJson(jsonString)
		self.fillDataWithDictionary(jsonDictionary)
	}

	public convenience init(jsonNSData: NSData) {
		self.init()
		var jsonDictionary: [String: AnyObject] = [:]
		do {
			jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonNSData, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
		} catch {
			fatalError("NSJSONSerialization failed")
		}
		self.fillDataWithDictionary(jsonDictionary)
	}

	// - MARK: private function

	/**
	 Return a dictionary representation for the json string

	 :parameter: json The json string that will be converted

	 :returns: The dictionary representation of the json
	 */
	private func dictionaryFromJson(json: String?) -> Dictionary<String, AnyObject> {
		var result = Dictionary<String, AnyObject>()
		if json == nil {
			return result
		}
		if let jsonData = json!.dataUsingEncoding(NSUTF8StringEncoding) {
			do {
				if let jsonDic = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
					result = jsonDic
				}
			} catch _ as NSError {
				fatalError("NSJSONSerialization failed")
			}
		}
		return result
	}

	private func getObjectPropertiesCollection(mirror: Mirror) -> (Set<String>, [String: Any.Type]) {
		var classProperties = Set<String>()
		var keyvalueType = [String: Any.Type]()

		for property in mirror.children {
			classProperties.insert(property.label!)
			keyvalueType[property.label!] = Mirror(reflecting: property.value).subjectType
		}
		return (classProperties, keyvalueType)
	}

	private func getDictionaryKeysCollection(dictionary: [String: AnyObject]) -> Set<String> {
		var dictionaryKeys = Set<String>()
		for (key, _) in dictionary {
			dictionaryKeys.insert(key)
		}
		return dictionaryKeys
	}
	private func getTypeName(type: Any.Type) -> String {
		let objectString: String
		if let classTypeString = "\(type)".between("<", ">")?.between("<", ">") {
			objectString = classTypeString
		} else
		if let classTypeString = "\(type)".between("<", ">") {
			objectString = classTypeString
		} else {
			objectString = "\(type)".chompRight(".Type")
		}
		return objectString
	}
	private func createObjectByTypeName(type: Any.Type) -> NSObject {
		let objectString = getTypeName(type)
		let object = NSObject.newInstance(objectString) as! NSObject
		return object
	}

	/**
	 fill data with json dictionary to array

	 - parameter elementType: array element type
	 - parameter array:       json array

	 - returns: a array with pojo informaiton
	 */
	private func fillDataWithArray(elementType: String, array: [[String: AnyObject]]) -> [AnyObject] {
		var objectArray = [AnyObject]()
		for dictionary in array {
			let object = NSObject.newInstance(elementType) as! NSObject
			object.fillDataWithDictionary(dictionary)
			objectArray.append(object)
		}
		return objectArray
	}
	/**
	 fill data with json dictionary to an pojo which extends from NSObject

	 - parameter dictionary: json dictionary

	 - returns: current json value instance
	 */
	private func fillDataWithDictionary(dictionary: [String: AnyObject]) -> Self {
		let mirror = Mirror(reflecting: self)
		if mirror.children.count > 0 {
			let (classProperties, keyvalueType) = getObjectPropertiesCollection(mirror)
			let dictionaryKeys = getDictionaryKeysCollection(dictionary)

			// get the key witch both sets have
			let intersection = classProperties.intersect(dictionaryKeys)

			for key in intersection {
				let value = dictionary[key]
				let valueType = keyvalueType[key]
				switch value {
				case is [String: AnyObject]:
					let tempObject = createObjectByTypeName(valueType!)
					let jsonModel = tempObject.fillDataWithDictionary(value as! [String: AnyObject])
					self.setValue(jsonModel, forKey: key)
				case is [[String: AnyObject]]:
					let objectString = getTypeName(valueType!)
					let arrayModel = fillDataWithArray(objectString, array: value as! [[String: AnyObject]])
					self.setValue(arrayModel, forKey: key)
				default:
					checkClassPropertyType(valueType!)
					setPropertyValue(valueType!, value: value!, key: key)
				}
			}
		}
		return self
	}
	private func checkClassPropertyType(valueType: Any.Type) {
		if noPermissionTypes.contains("\(valueType)") {
			let classType = "\(valueType)".between("<", ">")!
			fatalError("\(valueType) must set to \(classType)")
		}
	}

	/**
	 set basic type value
	 - parameter valueType: valueType
	 - parameter value:     value
	 - parameter key:       property key
	 */
	private func setPropertyValue(valueType: Any.Type, value: AnyObject, key: String) {
		switch value {
		case is [String], is [Int], is [Bool], is [Float], is [Character]:
			setValue(value, forKey: key)
		case let checkValue where !(checkValue is String) && "\(valueType)".containsString("String"):
			setValue(value.stringValue, forKey: key)
			break
		default:
			setValue(value, forKey: key)
		}
	}
}

private let noPermissionTypes = ["Optional<Int>", "Optional<Bool>", "Optional<Double>", "Optional<Float>"]

public protocol SireJson {
	func toDictionary() -> AnyObject?
}

extension String {
	private func between(left: String, _ right: String) -> String? {
		guard
		let leftRange = rangeOfString(left), rightRange = rangeOfString(right, options: .BackwardsSearch)
		where left != right && leftRange.endIndex != rightRange.startIndex
		else { return nil }

		return self[leftRange.endIndex ... rightRange.startIndex.predecessor()]
	}

	private func chompRight(suffix: String) -> String {
		if let suffixRange = rangeOfString(suffix, options: .BackwardsSearch) {
			if suffixRange.endIndex >= endIndex {
				return self[startIndex ..< suffixRange.startIndex]
			} else {
				return self[suffixRange.endIndex ..< endIndex]
			}
		}
		return self
	}
}
protocol Instanceable {
	init()
}

extension NSObject: Instanceable {
	private class func newInstance(className: String) -> Instanceable? {
		if let classType: Instanceable.Type = getClassFromStringName(className) {
			return classType.init()
		} else {
			return nil
		}
	}

	private class func getClassFromStringName<T: NSObject>(className: String) -> T.Type? {
		let className = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String + "." + className
		guard let classType = NSClassFromString(className) as? T.Type else {
			print("Class name \(className) not found,or you can't define the class in another class,please check className !")
			return nil
		}
		return classType
	}
}

extension SireJson {
	public func toDictionary() -> AnyObject? {
		let mirror = Mirror(reflecting: self)
		if mirror.children.count > 0 {
			var result: [String: AnyObject] = [:]
			for children in mirror.children {
				let propertyNameString = children.label!
				let value = children.value

				if let jsonValue = value as? SireJson {
					result[propertyNameString] = jsonValue.toDictionary()
				} else {
					result[propertyNameString] = value as? AnyObject
				}
			}
			return result
		}
		return self as? AnyObject
	}
}

extension Optional: SireJson {
 public	func toDictionary() -> AnyObject? {
		if let x = self {
			if let value = x as? SireJson {
				return value.toDictionary()
			}
		}
		return nil
	}
}
extension String: SireJson { }
extension Int: SireJson { }
extension Bool: SireJson { }
extension Dictionary: SireJson { }
extension Array: SireJson { }
extension NSObject: SireJson { }

