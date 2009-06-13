# py2rb.py

"""
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
"""

from rubyapi import *
import types

converters = {}

def convert(obj):
	thistype = type(obj)
	while not converters.has_key(thistype):
		thistype = thistype.__base__
	return converters[thistype](obj)

def emptyconverter(obj):
    try:
        return obj.__ruby__
    except NameError:
	    return NotImplemented

def nullconverter(none):
	return Qnil

def booleanconverter(boolean):
	if (boolean):
		return Qtrue
	else:
		return Qfalse

def intconverter(integer):
	return LONG2NUM(integer)

def stringconverter(string):
	return rb_str_new2(string)
	
def floatconverter(flt):
    return rb_float_new(flt)

converters[None] = emptyconverter
converters[types.NoneType] = nullconverter
converters[bool] = booleanconverter
converters[int] = intconverter
converters[str] = stringconverter
converters[float] = floatconverter