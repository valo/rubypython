/* cross_exceptions.c

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

void raise_py_exception()
{
    VALUE exc_description = rb_str_new2("ruby code generated ");
    rb_str_concat(exc_description, rb_obj_as_string(CLASS_OF(ruby_errinfo)));
    rb_str_cat2(exc_description, ": '");
    rb_str_concat(exc_description, rb_obj_as_string(ruby_errinfo));
    rb_str_cat2(exc_description, "'");
    PyErr_SetString(PyExc_RuntimeError, STR2CSTR(exc_description));
    ruby_errinfo = Qnil;
}

void raise_rb_exception()
{
    PyObject *exc_type;
    PyObject *exc_value;
    PyObject *exc_tb;
    PyErr_Fetch(&exc_type, &exc_value, &exc_tb);
    PyObject *type_name = PyObject_GetAttrString(exc_type, "__name__");
    PyObject *value_name;
    if (exc_value != NULL) value_name = PyObject_Str(exc_value);
    else {
        Py_INCREF(Py_None);
        value_name = Py_None;
    }
    PyObject *values = PyTuple_Pack(2, type_name, value_name);
    PyObject *exc_format = PyString_FromString("python code generated %s: '%s'");
    PyObject *exc_description = PyString_Format(exc_format, values);
    char *exc_description_c = PyString_AsString(exc_description);
    Py_DECREF(exc_description);
    Py_DECREF(exc_format);
    Py_DECREF(values);
    Py_DECREF(type_name);
    Py_DECREF(value_name);
    Py_DECREF(exc_type);
    Py_XDECREF(exc_value);
    Py_XDECREF(exc_tb);
    
    rb_raise(rb_eRuntimeError, exc_description_c);
}