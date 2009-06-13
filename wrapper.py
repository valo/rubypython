# wrapper.py

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

import rubyapi

def inspect_value(value):
    ruby = rubyapi.rb_protect(rubyapi.rb_inspect, (value,))
    return rubyapi.rb2py(ruby)

class method_wrapper (object):
    def __init__(self, value, method_name):
        self.value = value
        self.method_name = method_name

    def __get_ruby_unsafe(self):
        method_sym = rubyapi.ID2SYM(self.method_name)
        return rubyapi.rb_funcall(self.value, "method",  (method_sym,))
    
    def __get_ruby_safe(self):
        return rubyapi.rb_protect(self.__get_ruby_unsafe, ())
    
    __ruby__ = property(__get_ruby_safe)
    
    def __call_unsafe(self, *args):
        ruby_args = []
        for arg in args:
            ruby_args.append(rubyapi.py2rb(arg))
        
        return rubyapi.rb_funcall(self.value, self.method_name, ruby_args)
        
    def __call__(self, *args):
        value_result = rubyapi.rb_protect(self.__call_unsafe, args)
        return rubyapi.rb2py(value_result)
        
    def __repr__(self):
        return "<method :%s of ruby object %s>" % (self.method_name, inspect_value(self.value))

class method_mapping (object):
    def __init__(self, method_name):
        super(method_mapping, self).__init__()
        self.method_name = method_name
        
    def __get__(self, obj, type = None):
        if rubyapi.rb_respond_to(obj.__ruby__, self.method_name):
            return method_wrapper(obj.__ruby__, self.method_name)
        else:
            raise AttributeError("ruby object %s does not respond to method :%s" % (inspect_value(obj.__ruby__), self.method_name))

class base_wrapper (object):
    def __init__(self, value):
        self.__ruby__ = value
        rubyapi.save_object(self.__ruby__)
        
    def __del__(self):
        rubyapi.unsave_object(self.__ruby__)
        
    def __getattr__(self, attr):
        if rubyapi.rb_respond_to(self.__ruby__, attr):
            return method_wrapper(self.__ruby__, attr)
        names = [attr + "?"]
        if attr.startswith("is"):
            names.append(attr[2:] + "?")
        if attr.endswith("p"):
            names.append(attr[:-1] + "?")
        if attr.startswith("force"):
            names.append(attr[5:] + "!")
        if attr.startswith("inplace"):
            names.append(attr[7:] + "!")
        if attr.startswith("in_place"):
            names.append(attr[8:] + "!")
        if attr.endswith("bang"):
            names.append(attr[:-4] + "!")
        for name in names:
            if name.startswith("_"):
                names.append(name[1:])
            if name.endswith("_"):
                names.append(name[:-1])
            if name.endswith("_?") or name.endswith("_!"):
                names.append(name[:-2])
        for name in names:
            if rubyapi.rb_respond_to(self.__ruby__, name):
                return method_wrapper(self.__ruby__, name)
        
        raise AttributeError("%r has no attribute %r" % (self, attr))
            
    def __repr__(self):
        return "[rb]%s" % self.inspect()
    
    __str__ = method_mapping("to_s")
    
    __lt__ = method_mapping("<")
    __le__ = method_mapping("<=")
    __eq__ = method_mapping("==")
    __ne__ = method_mapping("!=")
    __gt__ = method_mapping(">")
    __ge__ = method_mapping(">=")
    
    __cmp__ = method_mapping("<=>")
    
    __hash__ = method_mapping("hash")
    
    __call__ = method_mapping("call")
    
    __len__ = method_mapping("size")
    __getitem__ = method_mapping("[]")
    __setitem__ = method_mapping("[]=")
    __contains__ = method_mapping("include?")
    
    __add__ = method_mapping("+")
    __sub__ = method_mapping("-")
    __mul__ = method_mapping("*")
    __div__ = method_mapping("/")
    __mod__ = method_mapping("%")
    __divmod__ = method_mapping("divmod")
    __pow__ = method_mapping("**")
    __lshift__ = method_mapping("<<")
    __rshift__ = method_mapping(">>")
    __and__ = method_mapping("&")
    __or__ = method_mapping("|")
    __xor__ = method_mapping("^")
