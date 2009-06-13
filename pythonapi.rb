# pythonapi.rb

=begin 
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
=end

# This is to overcome the naming requirements of SWIG/Ruby

require 'pythonapi_'

module PythonAPI
  
  module Constants
    for const_name in Pythonapi_.constants
      const_set(const_name, Pythonapi_.const_get(const_name) )
    end
  end
  
  include Constants
  
  module_function

  extend Pythonapi_
  
  def py_return_true
    py_incref(PY_TRUE)
    PY_TRUE
  end
  
  def py_return_false
    py_incref(PY_FALSE)
    PY_FALSE
  end
    
  def py_return_none
    py_incref(PY_NONE)
    PY_NONE
  end
  
  public_class_method :py_return_true, :py_return_false, :py_return_none
  public_class_method(*Pythonapi_.public_methods)
  
end