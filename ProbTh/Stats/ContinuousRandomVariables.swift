//
//  ContinuousRandomVariables.swift
//  ProbTh
//
//  Created by sbond75 on 9/15/22.
//  Copyright © 2022 sbond75. All rights reserved.
//

import Foundation
import PythonKit

func pyeval(_ code: String) -> PythonObject {
    //return Python.builtins["eval"].dynamicallyCall(withArguments: [code])
    //return Python.main["eval"].dynamicallyCall(withArguments: [code])
    return Python.import("__main__")[dynamicMember: "__builtins__"][dynamicMember: "eval"].dynamicallyCall(withArguments: [code])
}

// Set PYTHONPATH
func initPython() {
    // Warm-up interpreter
    let sys = Python.import("sys")
    
    // Add ginac, etc. to the include path
    var success = S_RunString("import sys; sys.path.extend(filter(lambda x: len(x)>0, '\(PYTHONPATH)'.split(':')))")
    if !success { fatalError() }
    
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
    
    success = S_RunString("from ginac import *")
    if !success { fatalError() }
    
    // http://moebinv.sourceforge.net/pyGiNaC.html near "integral(x, 0, t, x*x+sin(x))"
    let integration = pyeval("x = realsymbol('x'); t = realsymbol('t'); integral(x, 0, t, x*x+sin(x))")
}
