/* py2rb.c

Copyright (c) 2007 Daniel M Jordan

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

#include "bridge.h"
#include <stdio.h>

PyObject *py2rb_module;

int initialize_py2rb()
{
    py2rb_module = PyImport_ImportModule("py2rb");
    if (!py2rb_module) {
        return 0;
    }
    else return 1;
}

VALUE py2rb(PyObject *python)
{
    PyObject *convert_method = PyObject_GetAttrString(py2rb_module, "convert");
    if (!convert_method) {
        raise_rb_exception();
    }
    PyObject *converted = PyObject_CallFunctionObjArgs(convert_method, python, NULL);
    if (!converted) {
        Py_DECREF(convert_method);
        raise_rb_exception();
    }
    unsigned long result = PyInt_AsUnsignedLongMask(converted);
    Py_DECREF(converted);
    Py_DECREF(convert_method);
    if (PyErr_Occurred()) raise_rb_exception(); // PyInt_AsUnsignedLongMask doesn't check for errors
    return (VALUE)result;
}