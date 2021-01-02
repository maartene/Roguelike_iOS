//
//  RNG.swift
//
//  Created by Maarten Engels on 01/01/2021.
//

import Foundation

struct PRNG: RandomNumberGenerator {
    var seed: UInt64
    
    // This RNG function uses Squirrel Eiserloh's hash function to generate "random" numbers.
    mutating func next() -> UInt64 {
        seed = Squirrel3(seed)
        return seed
    }
}
