//
//  Localizator.swift
//  EDLocalizator
//
//  Created by Eugene Kalyada on 06.09.17.
//  Copyright © 2017 Eugene Kalyada. All rights reserved.
//

import UIKit

private class Localizator {

	static let sharedInstance = Localizator()
	var resourcePath : String = "Localizable"

	lazy var localizableDictionary: NSDictionary! = {
		if let path = Bundle.main.path(forResource: self.resourcePath, ofType: "plist") {
			return NSDictionary(contentsOfFile: path)
		}
		fatalError("Localizable file NOT found")
	}()

	func localize(string: String) -> String {
		guard var localizedString = localizableDictionary.value(forKeyPath:string) as? String else {
			print("Missing translation for: \(string)")
			return string
		}
		localizedString.isLocalized = true
		return localizedString
	}

}
protocol PropertyStoring {

	associatedtype T

	func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
}

extension PropertyStoring {
	func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
		guard let value = objc_getAssociatedObject(self, key) as? T else {
			return defaultValue
		}
		return value
	}
}


struct AssociatedKeys {
	static var isLocalized: UInt8 = 0
}

extension String : PropertyStoring {

	typealias T = Bool

	private struct CustomProperties {
		static var isLocalized = false
	}

	public var isLocalized: Bool {
		get {
			return getAssociatedObject(&CustomProperties.isLocalized, defaultValue: CustomProperties.isLocalized)
		}
		set {
			return objc_setAssociatedObject(self, &CustomProperties.isLocalized, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}

	public var localized : String {
		get {
			if !isLocalized {
				return Localizator.sharedInstance.localize(string: self)
			}
			return self
		}
	}

	public func localized(_ args:CVarArg...) -> String {

		return String(format: self.localized, arguments:args)
	}
}
