/* pythonapi_.i

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

%module pythonapi_

%{
#include "Python.h"
#include "bridge.h"
%}

%init %{
    if (!Py_IsInitialized()) Py_Initialize();
%}

%typemap(constant) PyObject* %{
    rb_define_const($module, "$symname", ULONG2NUM((unsigned long)$1));
%}

%typemap(in) PyObject* %{
    $1 = (PyObject*)NUM2ULONG($input);
%}

%typemap(out) PyObject* %{
    $result = ULONG2NUM((unsigned long)$1);
%}

%constant PyObject *Py_True;
%constant PyObject *Py_False;
%constant PyObject *Py_None;
%constant PyObject *Py_NotImplemented;

%constant PyObject *PyExc_BaseException;
%constant PyObject *PyExc_Exception;
%constant PyObject *PyExc_StandardError;
%constant PyObject *PyExc_ArithmeticError;
%constant PyObject *PyExc_LookupError;
%constant PyObject *PyExc_AssertionError;
%constant PyObject *PyExc_AttributeError;
%constant PyObject *PyExc_EOFError;
%constant PyObject *PyExc_EnvironmentError;
%constant PyObject *PyExc_FloatingPointError;
%constant PyObject *PyExc_IOError;
%constant PyObject *PyExc_ImportError;
%constant PyObject *PyExc_IndexError;
%constant PyObject *PyExc_KeyError;
%constant PyObject *PyExc_KeyboardInterrupt;
%constant PyObject *PyExc_MemoryError;
%constant PyObject *PyExc_NameError;
%constant PyObject *PyExc_NotImplementedError;
%constant PyObject *PyExc_OSError;
%constant PyObject *PyExc_OverflowError;
%constant PyObject *PyExc_ReferenceError;
%constant PyObject *PyExc_RuntimeError;
%constant PyObject *PyExc_SyntaxError;
%constant PyObject *PyExc_SystemError;
%constant PyObject *PyExc_SystemExit;
%constant PyObject *PyExc_TypeError;
%constant PyObject *PyExc_ValueError;
%constant PyObject *PyExc_ZeroDivisionError;

#ifdef SWIGWIN
%constant PyObject *PyExc_WindowsError;
#endif

void Py_INCREF(PyObject *);
void Py_DECREF(PyObject *);
void Py_CLEAR(PyObject *);
void Py_XINCREF(PyObject *);
void Py_XDECREF(PyObject *);

PyObject *PyInt_FromLong(long);
PyObject *PyString_FromString(const char*);
PyObject *PyFloat_FromDouble(double);

PyObject *PyObject_GetAttrString(PyObject*, const char*);

%typemap(in) PyObject *args %{
    long ary_length = RARRAY($input)->len;
    $1 = PyTuple_New(ary_length);
    if (!$1) raise_rb_exception();
    long i;
    PyObject *item;
    for (i = 0; i < ary_length; i++) {
        item = rb2py(rb_ary_entry($input, i));
        if (!item) {
            Py_DECREF($1);
            raise_rb_exception();
        }
        if (PyTuple_SetItem($1, i, item)) {
            Py_DECREF($1);
            Py_DECREF(item);
            raise_rb_exception();
        }
    }
%}

%typemap(freearg) PyObject *args %{
    Py_DECREF($1);
%}

%{
    static VALUE fill_translated_dict(VALUE pair, VALUE python_dict) 
    {
        PyObject *dict = (PyObject *)python_dict;
        VALUE key_ruby = rb_ary_entry(pair, 0);
        VALUE value_ruby = rb_ary_entry(pair, 1);
        PyObject *key = rb2py(key_ruby);
        if (!key) raise_rb_exception();
        PyObject *value = rb2py(value_ruby);
        if (!value) {
            Py_DECREF(key);
            raise_rb_exception();
        }
        int set_status = PyDict_SetItem(dict, key, value);
        Py_DECREF(key);
        Py_DECREF(value);
        if (set_status) raise_rb_exception();
        return Qnil;
    }
%}

%typemap(in) PyObject *kw %{
    if (!rb_obj_is_instance_of($input, rb_cHash)) $1 = NULL;
    else {
        $1 = PyDict_New();
        rb_iterate(rb_each, $input, fill_translated_dict, (VALUE)$1);
    }
%}

%typemap(freearg) PyObject *kw %{
    Py_XDECREF($1);
%}

PyObject* PyObject_Call(PyObject *callable_object, PyObject *args, PyObject *kw);
PyObject* PyObject_CallObject(PyObject *callable_object, PyObject *args);

%typemap(out) int %{
    $result = $1 ? Qtrue : Qfalse;
%}

int PyCallable_Check(PyObject *);


