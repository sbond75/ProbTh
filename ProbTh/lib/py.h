// Based on https://github.com/VADL-2022/SIFT/blob/nasa/driver/py.h

#ifndef PY_H
#define PY_H

#include <Python.h> /* must be first */

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

void S_ShowLastError(void);
  
// Returns true on success
bool S_RunString(const char *str);

// Returns a Python object on success, otherwise NULL. When finished with the return value, call `Py_XDECREF(result);` where `result` is the return value of this function.
PyObject* S_RunStringAndGetResult(const char *str);

// Returns true on success
bool S_RunFile(const char *path, int argc, char **argv);

#ifdef __cplusplus
}
#endif

#endif
