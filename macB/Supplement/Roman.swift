//
//  Roman.swift
//  macB
//
//  Created by Denis Dobanda on 20.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

private let _numeralPairs: [String: Int] = [
        "M":  1000,
        "CM": 900,
        "D":  500,
        "CD": 400,
        "C":  100,
        "XC": 90,
        "L":  50,
        "XL": 40,
        "X":  10,
        "IX": 9,
        "V":  5,
        "IV": 4,
        "I":  1
    ]

private func _with<T>(_ first: T?, _ second: T?, combine: (T, T) -> T?) -> T? {
    guard let first = first, let second = second else {
        return nil
    }
    return combine(first, second)
}

extension Int {
    var romanNumeral: String {
        var integerValue = self
        var numeralString = ""
        let mappingList: [(Int, String)] = [
            (1000, "M"), (900, "CM"), (500, "D"),
            (400, "CD"), (100, "C"), (90, "XC"),
            (50, "L"), (40, "XL"), (10, "X"),
            (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]
        for i in mappingList where (integerValue >= i.0) {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString.append(i.1)
            }
        }
        return numeralString
    }
    
    public init?(roman numeral: String) {
        guard !numeral.isEmpty else {
            return nil
        }
        let pairs: [String: Int] = _numeralPairs
        
        func createFrom(_ numeral: String) -> Int? {
            guard !numeral.isEmpty else {
                return 0
            }
            for index in [2, 1] {
                let count = numeral.count
                guard index <= count else {
                    continue
                }
                let head = numeral[0 ..< index]
                guard let value = pairs[head] else {
                    continue
                }
                let rest = numeral[index ..< count]
                if !rest.isEmpty {
                    let partValue = rest.count >= 2
                        ? (pairs[rest[0 ..< 2]] ?? pairs[rest[0 ..< 1]])
                        :  pairs[rest[0 ..< 1]]
                    guard partValue != nil, partValue! <= value else {
                        return nil
                    }
                }
                return _with(value, createFrom(rest), combine: +)
            }
            return nil
        }
        
        guard let value = createFrom(numeral.uppercased()) else {
            return nil
        }
        self = value
    }
}
