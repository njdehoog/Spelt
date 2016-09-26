//
//  Stencil+MathFilters.swift
//  Spelt
//
//  Created by Niels de Hoog on 23/02/16.
//  Copyright © 2016 Invisible Pixel. All rights reserved.
//

import Foundation

enum NumericVariableType {
    case integerType(Int)
    case doubleType(Double)
    
    init?(_ value: Any?) {
        switch value {
        case let number as Double:
            self = .doubleType(number)
        case let number as Int:
            self = .integerType(number)
        default:
            return nil
        }
    }
}

func /(left: NumericVariableType, right: NumericVariableType) -> Any {
    switch left {
    case .integerType(let left):
        switch right {
        case .integerType(let right):
            return Double(left) / Double(right)
        case .doubleType(let right):
            return Double(left) / right
        }
    case .doubleType(let left):
        switch right {
        case .integerType(let right):
            return left / Double(right)
        case .doubleType(let right):
            return left / right
        }
    }
}

func dividedByFilter(_ value: Any?, arguments: [Any?]) throws -> Any? {
    guard arguments.count == 1 else {
        throw TemplateSyntaxError("'divided_by' filter expects exactly 1 argument, not \(arguments.count)")
    }
    
    guard let dividend = NumericVariableType(value) else {
        throw TemplateSyntaxError("'divided_by' filter expects numeric argument")
    }
    
    guard let divisor = NumericVariableType(arguments[0]) else {
        throw TemplateSyntaxError("'divided_by' filter expects numeric argument")
    }
    
    return dividend / divisor
}

func floorFilter(_ value: Any?) throws -> Any? {
    guard let doubleValue = value as? Double else {
        throw TemplateSyntaxError("'floor' filter expects floating point value")
    }
    
    return Int(floor(doubleValue))
}

func ceilFilter(_ value: Any?) throws -> Any? {
    guard let doubleValue = value as? Double else {
        throw TemplateSyntaxError("'ceil' filter expects floating point value")
    }
    
    return Int(ceil(doubleValue))
}
