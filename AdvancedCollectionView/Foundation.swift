//
//  Foundation.swift
//  AdvancedCollectionView
//
//  Created by Zachary Waldowski on 12/15/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation

func assertMainThread(file: StaticString = __FILE__, line: UWord = __LINE__) {
    assert(NSThread.isMainThread(), "This code must be called on the main thread.")
}

// MARK: Index path

public func ==(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}
public func <(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
    
}

extension NSIndexPath: Comparable { }

extension NSIndexPath: CollectionType {
    
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return length }
    
    public subscript (position: Int) -> Int {
        return indexAtPosition(position)
    }
    
    public func generate() -> IndexingGenerator<NSIndexPath> {
        return IndexingGenerator(self)
    }
    
}

extension NSIndexPath {
    
    // This is intended for compatibility with ArrayLiteralConvertible
    // c'est la vie
    public convenience init(indexes elements: Int...) {
        self.init(indexes: elements, length: elements.count)
    }
    
}

extension NSIndexPath {
    
    var globalInfo: (section: Section, item: Int) {
        if length == 1 {
            return (.Global, self[0])
        }
        return (.Index(self[0]), self[1])
    }
    
}


// MARK: Index set

public func -=(left: NSMutableIndexSet, right: NSIndexSet) {
    left.removeIndexes(right)
}

public func +=(left: NSMutableIndexSet, right: NSIndexSet) {
    left.addIndexes(right)
}

public func -=(left: NSMutableIndexSet, right: NSRange) {
    left.removeIndexesInRange(right)
}

public func +=(left: NSMutableIndexSet, right: NSRange) {
    left.addIndexesInRange(right)
}

public func -(left: NSIndexSet, right: NSIndexSet) -> NSMutableIndexSet {
    let indexSet = left.mutableCopy() as NSMutableIndexSet
    indexSet.removeIndexes(right)
    return indexSet
}

public func +(left: NSIndexSet, right: NSIndexSet) -> NSMutableIndexSet {
    let indexSet = left.mutableCopy() as NSMutableIndexSet
    indexSet.addIndexes(right)
    return indexSet
}

extension NSIndexSet {
    
    public convenience init(range: Range<Int>) {
        self.init(indexesInRange: NSRange(range))
    }
    
}

extension NSIndexSet {
    
    public convenience init(indexes elements: Int...) {
        let set = NSMutableIndexSet()
        for idx in elements {
            set.addIndex(idx)
        }
        self.init(indexSet: set)
    }
    
}

public struct IndexSetGenerator: GeneratorType, SequenceType {
    
    private let indexSet: NSIndexSet
    private let reverse: Bool
    private let range: Range<Int>?
    private var currentIndex: Int?
    
    private func toOptional(value: Int, transform: (Int -> Int?)? = nil) -> Int? {
        if value == NSNotFound {
            return nil
        }
        
        if let transform = transform {
            return transform(value)
        }
        
        return value
    }
    
    private init(indexSet: NSIndexSet, reverse: Bool = false, range: Range<Int>? = nil) {
        self.indexSet = indexSet
        self.reverse = reverse
        self.range = range
        
        switch (reverse, range) {
        case (false, .None):
            currentIndex = toOptional(indexSet.firstIndex)
        case (false, .Some(let range)):
            currentIndex = indexSet.indexGreaterThanOrEqualToIndex(range.startIndex)
        case (true, .None):
            currentIndex = toOptional(indexSet.lastIndex)
        case (true, .Some(let range)):
            currentIndex = indexSet.indexLessThanIndex(range.endIndex)
        default:
            currentIndex = nil
        }
    }
    
    public mutating func next() -> Int? {
        if let current = currentIndex {
            switch (reverse, range) {
            case (false, .None):
                currentIndex = toOptional(indexSet.indexGreaterThanIndex(current))
            case (false, .Some(let range)):
                currentIndex = toOptional(indexSet.indexGreaterThanIndex(current)) {
                    $0 < range.endIndex ? $0 : nil
                }
            case (true, .None):
                currentIndex = toOptional(indexSet.indexLessThanIndex(current))
            case (true, .Some(let range)):
                currentIndex = toOptional(indexSet.indexLessThanIndex(current)) {
                    $0 >= range.startIndex ? $0 : nil
                }
            default:
                currentIndex = nil
            }
            
            return current
        }
        return nil
    }
    
    public func generate() -> IndexSetGenerator {
        return IndexSetGenerator(indexSet: indexSet, reverse: reverse, range: range)
    }
    
}

extension NSIndexSet: SequenceType {
    
    public func generate() -> IndexSetGenerator {
        return IndexSetGenerator(indexSet: self)
    }
    
    public func range(range: Range<Int>) -> IndexSetGenerator {
        return IndexSetGenerator(indexSet: self, range: range)
    }
    
    public func reverse(inRange range: Range<Int>? = nil) -> IndexSetGenerator {
        return IndexSetGenerator(indexSet: self, reverse: true, range: range)
    }
    
}
