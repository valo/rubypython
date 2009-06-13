/* rubyapi.i

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

%module rubyapi

%{
    #include "bridge.h"
    
    VALUE safe_objects = 0;
%}

#define VALUE unsigned long

%init %{
    ruby_init();
    if (!initialize_rb2py_safe()) {
        raise_py_exception();
        return;
    }
    if (!initialize_py2rb()) return;
    
    rb_gc_register_address(&safe_objects);
%}

%constant VALUE Qfalse;
%constant VALUE Qtrue;
%constant VALUE Qnil;
%constant VALUE Qundef;

VALUE LONG2NUM(long);
VALUE rb_str_new2(const char*);
VALUE rb_float_new(double);
VALUE rb_ary_new2(long);
void rb_ary_store(VALUE, long, VALUE);

VALUE rb_inspect(VALUE);

%{
    static VALUE call_method(VALUE data_cast)
    {
        PyObject *data = (PyObject *)data_cast;
        PyObject *method = PySequence_GetItem(data, 0);
        PyObject *args = PySequence_GetItem(data, 1);
        if (!method || !args) {
            Py_XDECREF(method);
            Py_XDECREF(args);
            return 0;
        }
        PyObject *result = PyObject_CallObject(method, args);
        Py_DECREF(method);
        Py_DECREF(args);
        return (VALUE)result;
    }
      
    PyObject *rb_protect_(PyObject *method, PyObject *args)
    {
        PyObject *data = PyTuple_Pack(2, method, args);
        if (!data) return NULL;
        int status = 0;
        VALUE result = rb_protect(call_method, (VALUE)data, &status);
        Py_DECREF(data);
        if (PyErr_Occurred()) return NULL;
        if (status) {
            raise_py_exception();
            if (result != Qnil) Py_XDECREF((PyObject *)result);
            return NULL;
        }
        return (PyObject *)result;
    }
%}

%newobject rb_protect_;
PyObject *rb_protect_(PyObject *method, PyObject *args);

%pythoncode %{
rb_protect = rb_protect_
%}

%{
    void save_object(VALUE obj)
    {
        if (safe_objects == 0) safe_objects = rb_ary_new();
        rb_ary_push(safe_objects, obj);
    }
    
    void unsave_object(VALUE obj)
    {
        if (safe_objects == 0) safe_objects = rb_ary_new();
        rb_ary_delete(safe_objects, obj);
    }
%}

void save_object(VALUE obj);
void unsave_object(VALUE obj);

PyObject *rb2py(VALUE);
VALUE py2rb(PyObject *);

%typemap(in) (int argc, VALUE *argv) %{
    $1 = (int)PySequence_Length($input);
    if ($1 == -1) return NULL;
    PyObject *list_item;
    $2 = ALLOCA_N(VALUE, $1);
    int list_index;
    for (list_index = 0; list_index < $1; list_index++) {
        list_item = PySequence_GetItem($input, list_index);
        $2[list_index] = PyInt_AsUnsignedLongMask(list_item);
        Py_XDECREF(list_item);
    }
%} 

%typemap(in) ID %{
    char *str = PyString_AsString($input);
    $1 = rb_intern(str);
%}

VALUE ID2SYM(ID);
ID SYM2ID(VALUE);
int rb_respond_to(VALUE, ID);

VALUE rb_funcall2(VALUE, ID, int argc, VALUE *argv);

%pythoncode %{
rb_funcall = rb_funcall2
%}