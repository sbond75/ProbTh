//
//  CountingMethods.swift
//  ProbTh
//
//  Created by sbond75 on 9/1/22.
//  Copyright © 2022 sbond75. All rights reserved.
//
// This file corresponds to section 2.2 of the TB

import Foundation
import Bow
import BowGeneric
import BigInt

protocol Counter {
    var totalNumberOfChoices: BigInt { get }
}

// [Custom name:] CounterBCS = Counter By Choosing Selection:
// A "Counter" instance by choosing one item from a bunch of orthogonal choices.
// Example:
// "A certain make of automobile is available in any of three colors: red, blue, or green, and
// comes with either a large or small engine. In how many ways can a buyer choose a car?" -> CounterBCS.totalNumberOfChoices
//
// "The Fundamental Principle of Counting
// Assume that k operations are to be performed. If there are n_1 ways to perform the first
// operation, and if for each of these ways there are n_2 ways to perform the second operation,
// and if for each choice of ways to perform the first two operations there are n3 ways to
// perform the third operation, and so on, then the total number of ways to perform the
// sequence of k operations is n_1 * n_2 * ⋯ * n_k."
class CounterBCS: Counter {
    // `attributes` in the above example: one list is red, blue, or green. Another list is large or small (i.e., ["large", "small"]).
    init(attributes: [[Any]]) {
        self.attributes = attributes
    }
    
    init(attributeCounts: [Int]) {
        self.attributes = attributeCounts.map{Array<Any>(repeating: Int.min, count: $0)}
    }
    
    var totalNumberOfChoices: BigInt {
        return attributes.reduce(BigInt(1), {acc,x in
            acc * BigInt(x.count)
        })
    }
    
    var attributes: [[Any]]
}

// https://stackoverflow.com/questions/33666197/how-to-calculate-the-21-21-factorial-in-swift
//func factorial(_ n: Int) -> Double {
//  return (1...n).map(Double.init).reduce(1.0, *)
//}

// https://github.com/attaswift/BigInt
func factorial(_ n: Int) -> BigInt {
    if n == 0 {
        return BigInt(1)
    }
    return (1 ... n).map { BigInt($0) }.reduce(BigInt(1), *)
}

// "A permutation is an ordering of a collection of objects. For example, there are six permutations
// of the letters A, B, C: ABC, ACB, BAC, BCA, CAB, and CBA."
// "There are 3 choices for the object to
// place first. After that choice is made, there are 2 choices remaining for the object to place
// second. Then there is 1 choice left for the object to place last. Therefore, the total number of
// ways to order three objects is (3)(2)(1) = 6. This reasoning can be generalized. The number of
// permutations of a collection of n objects is" [the factorial of n]
// Example:
// "Five people stand in line at a movie theater. Into how many different orders can they be
// arranged?" -> Permutation(numberOfItemsToArrange: 5).totalNumberOfChoices
// Example:
// "Five lifeguards are available for duty one Saturday afternoon. There are three lifeguard
// stations. In how many ways can three lifeguards be chosen and ordered among the stations?" [keyword: "ordered" (next to "among the stations" at the end) -- indicates permutation since "order matters"] -> Permutation(numberOfItemsToArrange: 5).totalNumberOfChoices(takingOnly: 3)
class Permutation: Counter {
    init(numberOfItemsToArrange n: Int) {
        self.n = n
    }
    
    // "The number of permutations of n objects is `n!`"
    var totalNumberOfChoices: BigInt {
        return factorial(n)
    }
    
    // "The number of permutations of k objects chosen from a group of n objects is":
    func totalNumberOfChoices(takingOnly k: Int) -> BigInt {
        return factorial(n) / factorial(n - k)
    }
    
    var n: Int // i.e. `numberOfItemsToArrange`
}

// "In some cases, when choosing a set of objects from a larger set, we don’t care about the ordering
// of the chosen objects; we care only which objects are chosen. For example, we may not care
// which lifeguard occupies which station; we might care only which three lifeguards are chosen.
// Each distinct group of objects that can be selected, without regard to order, is called a
// combination. We will now show how to determine the number of combinations of k objects
// chosen from a set of n objects. We will illustrate the reasoning with the result of Example 2.13.
// In that example, we showed that there are 60 permutations of three objects chosen from five.
// Denoting the objects A, B, C, D, E, Figure 2.4 presents a list of all 60 permutations.":
// ABC ABD ...etc.
// ACB ADB
// BAC BAD
// BCA ...
// CAB
// CBA
// ^notice how in a column, the order is the only difference -- the choices from the set of lifeguards remain the same three objects.
// So, we take the Permutation formula and simply divide by the number of permutations of three objects which is `3!` in the example above, or more generally, just `k!`.
// Example:
// "At a certain event, 30 people attend, and 5 will be chosen at random to receive door prizes.
// The prizes are all the same, so the order in which the people are chosen does not matter. How
// many different groups of five people can be chosen?" -> Combination(numberOfItemsToArrange: 30).totalNumberOfChoices(takingOnly: 5)
class Combination: Permutation {
    override var totalNumberOfChoices: BigInt {
        // TODO: correct impl?
        return totalNumberOfChoices(takingOnly: n)
    }
    
    override func totalNumberOfChoices(takingOnly k: Int) -> BigInt {
        return super.totalNumberOfChoices(takingOnly: k) / factorial(k)
    }
}
typealias Binomial = Combination; // Combination is also known as "Binomial" -- a special case of Multinomial with only two factorials on the bottom in `n!/(k!(n-k)!)`: one for considering the amount we're taking (`k!`) and one for the rest (`(n-k)!`).

// This represents "the number of ways to divide n objects into groups of `k_1,...,k_r` where `k_1+...+k_r = n`" (from lecture notes) -- this is: `n!/(k_1! * ... * k_r!)`
// Example:
// "Twenty lightbulbs are to be arranged on a string. Six of the bulbs are red, four are blue, seven
// are green, and three are white. In how many ways can the bulbs be arranged?" -> Multinomial(numberOfItemsToArrange: 20, groupSizes: [6, 4, 7, 3]).totalNumberOfChoices
class Multinomial: Counter {
    init(numberOfItemsToArrange n: Int, groupSizes: [Int]) {
        self.n = n
        self.groupSizes = groupSizes
    }
    
    var totalNumberOfChoices: BigInt {
        return factorial(n) / groupSizes.reduce(1, {acc,x in
            acc * factorial(x)
        })
    }
    
    var n: Int // i.e. `numberOfItemsToArrange`
    var groupSizes: [Int]
}
