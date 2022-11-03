//
//  ContinuousRandomVariables.swift
//  ProbTh
//
//  Created by sbond75 on 9/15/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import PythonKit

// Returns true on success
func pyrun(_ code: String) -> Bool {
    initPython()
    
    return S_RunString(code.cString(using: .utf8))
}
func pyeval(_ code: String) -> PythonObject? {
    if let p = pyeval_(code) {
        return PythonObject(p)
    }
    return nil
}
// Runs the given code and then evals the expression given, returning the result of the expression.
func pyrun(_ run: String, thenEval eval: String) -> PythonObject? {
    if let p = pyrun_(run, thenEval: eval) {
        return PythonObject(p)
    }
    return nil
}

func pyeval_(_ code: String) -> OwnedPyObjectPointer? {
    initPython()
    
    //return Python.builtins["eval"].dynamicallyCall(withArguments: [code])
    //return Python.main["eval"].dynamicallyCall(withArguments: [code])
    //return Python.import("__main__")[dynamicMember: "__builtins__"][dynamicMember: "eval"].dynamicallyCall(withArguments: [code])
    //let ownedObj = code.pythonObject.borrowedPyObject // NOTE: `ownedPyObject` increfs, borrowedPyObject doesn't [see `final class PyReference {` in PythonKit/PythonKit/Python.swift]. TODO: what about decref? when does it do it? we should probably decref after the call to S_EvalExpressionAndGetResult, not before..
    //PyObject_Repr(ownedObj.bindMemory(to: PyObject.self, capacity: 1)) // NOTE: should use return value..
    //return OwnedPyObjectPointer(S_EvalExpressionAndGetResult(UnsafePointer(ownedObj.bindMemory(to: Int8.self, capacity: 1))))
    return OwnedPyObjectPointer(S_EvalExpressionAndGetResult(code.cString(using: .utf8)))
}
// Runs the given code and then evals the expression given, returning the result of the expression.
func pyrun_(_ run: String, thenEval eval: String) -> OwnedPyObjectPointer? {
    if (pyrun(run)) {
        return pyeval_(eval)
    }
    return nil
}

func integTest() {
//    // Define helpers
//    success = S_RunString("import __main__; __main__.eval = eval")
//    if !success { fatalError() }

//    let ginac = Python.import("ginac")
//    let integral = ginac["integral"]
//    let realsymbol = ginac["realsymbol"]
//
//    // http://moebinv.sourceforge.net/pyGiNaC.html near "integral(x, 0, t, x*x+sin(x))"
//    let x = realsymbol.dynamicallyCall(withArguments: ["x"])
//    let t = realsymbol.dynamicallyCall(withArguments: ["t"])
//    let integration = integral.dynamicallyCall(withArguments: [x, 0, t, Python.builtins["__globals__"]])
    
    //success = S_RunString("from ginac import *")
    // https://docs.sympy.org/latest/modules/integrals/integrals.html
    let success = S_RunString("from sympy import *; init_printing(use_unicode=False, wrap_line=False)")
    if !success { fatalError() }
    
    // http://moebinv.sourceforge.net/pyGiNaC.html near "integral(x, 0, t, x*x+sin(x))"
    //let integrationSuccess = pyrun("x = realsymbol('x'); t = realsymbol('t'); f = integral(x, 0, t, x*x+sin(x)); print(f)")
    let integrationSuccess = pyrun("x = Symbol('x'); print(pretty(integrate(x**2 + x + 1, x)))")
}

fileprivate var inittedPython = false
// Set PYTHONPATH
func initPython() {
    guard !inittedPython else { return }
    
    // Warm-up interpreter
    let sys = Python.import("sys")
    
    // Add ginac, etc. to the include path
    let success = S_RunString("import sys; sys.path.extend(filter(lambda x: len(x)>0, '\(PYTHONPATH)'.split(':')))")
    if !success { fatalError() }
    
    //integTest()
    
    inittedPython = true
}

func deinitPython() {
    guard inittedPython else { return }
    
    Py_Finalize()
    
    inittedPython = false
}
