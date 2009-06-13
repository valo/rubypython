/* python.i

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

%module python

%{
    #include "bridge.h"
    #include <stdio.h>
%}

%init %{
    if (!initialize_python()) return;
%}

%typemap(in) PyObject* %{
    $1 = rb2py($input);
%}

%typemap(freearg) PyObject* %{
    Py_XDECREF($1);
%}

%typemap(out) PyObject* %{
    $result = py2rb($1);
%}

%typemap(newfree) PyObject* %{
    Py_XDECREF($1);
%}

%{
    PyObject *py_eval(const char *command) {
        PyObject *locals = PyDict_New();
        PyObject *main_module = PyImport_ImportModule("__main__");
        if (!locals || !main_module) {
            Py_XDECREF(locals);
            Py_XDECREF(main_module);
            raise_rb_exception();
            return NULL;
        }
        PyObject *globals = PyModule_GetDict(main_module);
        
        PyObject *result = PyRun_String(command, Py_eval_input, globals, locals);
        Py_DECREF(locals);
        Py_DECREF(main_module);
        if (!result) {
            raise_rb_exception();
            return NULL;
        }
        return result;
    }
%}

%newobject py_eval;
PyObject *py_eval(const char *);