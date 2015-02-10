//
//  UIKit.swift
//  AdvancedCollectionView
//
//  Created by Zachary Waldowski on 1/2/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

import UIKit

struct Constants {
    static let isiOS8 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1
    static let isiOS7 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && !isiOS8
}

private func _userInterfaceLayoutDirection() -> UIUserInterfaceLayoutDirection {
    let direction = NSParagraphStyle.defaultWritingDirectionForLanguage(nil)
    switch NSParagraphStyle.defaultWritingDirectionForLanguage(nil) {
    case .LeftToRight:
        return .LeftToRight
    case .RightToLeft:
        return .RightToLeft
    case .Natural:
        if let localization = NSBundle.mainBundle().preferredLocalizations.first as? String {
            return NSLocale.characterDirectionForLanguage(localization) == .RightToLeft ? .RightToLeft : .LeftToRight
        }
        return .LeftToRight
    }
}

extension UIUserInterfaceLayoutDirection {
    
    /// Extension-safe user layout direction
    public static let userLayoutDirection: UIUserInterfaceLayoutDirection = _userInterfaceLayoutDirection()
    
}

// MARK: Size class helpers

extension UIView {
    
    var isWideHorizontal: Bool {
        if Constants.isiOS8 {
            return traitCollection.horizontalSizeClass == .Regular
        }
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
}
