# wrapper.rb

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

require 'pythonapi'

module Python
  module Wrapper
    class BaseWrapper
      
      # memory management methods
      
      def initialize(python_id)
        PythonAPI.py_incref(python_id)
        ObjectSpace.define_finalizer(self, Proc.new { PythonAPI.py_decref(python_id) })
        @__python__ = python_id
        @wrapper_valid = true
      end
      
      attr_reader :__python__
      
      def wrapper_valid?
        return @wrapper_valid
      end
      
      def invalidate
        @wrapper_valid = false
        PythonAPI.py_decref(@__python__)
        ObjectSpace.undefine_finalizer(self)
      end
      
      # method calling / attribute access methods
      
      def call_python_method(meth, *args)
        attribute = PythonAPI.py_object_get_attr_string(@__python__, meth)
        begin
          if (PythonAPI.py_callable_check(attribute))
            result = PythonAPI.py_object_call_object(attribute, args)
            begin
              return PythonAPI.py2rb(result)
            ensure
              py_decref(result)
            end
          else 
            if (args.size > 0) 
              raise ArgumentError.new("wrong number of arguments (%d for 0)" % args.size)
            else
              return PythonAPI.py2rb(attribute)
            end
          end
        ensure
          py_decref(attribute)
        end
      end
      
    end
  end
end