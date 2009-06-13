# rb2py.rb

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

require "pythonapi"
require "translate_exceptions"

module Python
  module Rb2Py    
    @converters = {}
    
    module_function
    
    def converters
      @converters
    end
  
    def convert(obj)
      thisclass = obj.class
        while true
          begin
            begin
              return converters[thisclass].call(obj) if converters.include? thisclass
              thisclass = thisclass.superclass
            rescue NotImplementedError # indicates a converter has failed
              thisclass = thisclass.superclass
              next
            end
          rescue NoMethodError
            raise NotImplementedError
          end
        end
    end
  
    def emptyconverter(obj)
      if obj.respond_to? :__python__
        obj.__python__
      else
        raise NotImplementedError
      end
    end

    def nullconverter(null) 
      PythonAPI::py_return_none
    end
  
    def trueconverter(bool) 
      PythonAPI::py_return_true
    end
  
    def falseconverter(bool)
      PythonAPI::py_return_false
    end
  
    def fixconverter(num)
      PythonAPI::py_int_from_long(num)
    end
  
    def stringconverter(string)
      PythonAPI::py_string_from_string(string.to_s)
    end
    
    def floatconverter(float)
      PythonAPI::py_float_from_double(float)
    end
    
    converters[nil] = method :emptyconverter
    converters[NilClass] = method :nullconverter
    converters[TrueClass] = method :trueconverter
    converters[FalseClass] = method :falseconverter
    converters[Fixnum] = method :fixconverter
    converters[String] = method :stringconverter 
    converters[Symbol] = method :stringconverter
    converters[Float] = method :floatconverter

    Exceptions.exc_translations.each_key do |key|
      converters[key] = Exceptions.method("translate_%s" % key)
    end


  end
end