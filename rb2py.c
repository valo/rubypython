/* rb2py.c

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

VALUE rb2py_module = Qnil;

VALUE initialize_rb2py()
{
	if(rb_gv_get("$0") == 0) {
        ruby_init_loadpath();
        ruby_script("python");
    }
    rb_require("rb2py");
    VALUE pythonModule = rb_const_get(rb_cObject, rb_intern("Python"));
    rb2py_module = rb_const_get(pythonModule, rb_intern("Rb2Py"));
    return Qnil;
}

int initialize_rb2py_safe()
{
    int status;
    rb_protect(initialize_rb2py, 0, &status);
    return !status;
}

static VALUE convert(VALUE ruby)
{
    VALUE result = rb_funcall(rb2py_module, rb_intern("convert"), 1, ruby);
    NUM2ULONG(result); // just to check that it doesn't cause an exception
    return result;
}

PyObject *rb2py(VALUE ruby)
{
    RESET_STACK;
    int status = 0;
    VALUE intResult = rb_protect(convert, ruby, &status);
    if (status) {
        if (CLASS_OF(ruby_errinfo) == rb_eNotImpError) {
            ruby_errinfo = Qnil;
            return wrap_ruby(ruby);
        }
        raise_py_exception();
        return NULL;
    }
    return (PyObject*)NUM2ULONG(intResult);
}
