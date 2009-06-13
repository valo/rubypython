require 'pythonapi'

module Python
  module Rb2Py
    module Exceptions
      include PythonAPI::Constants
      
      # no direct translation: fatal, SecurityError, ThreadError, LocalJumpError, RegexpError, ScriptError
      # requires special translation: SignalException
      
      @@exc_translations = {
        Exception => PYEXC_EXCEPTION,
        # TODO: replace generic "exception" with custom RubyException
        StandardError => PYEXC_STANDARDERROR,
        SystemExit => PYEXC_SYSTEMEXIT,
        Interrupt => PYEXC_KEYBOARDINTERRUPT,
        ArgumentError => PYEXC_TYPEERROR, # Python uses TypeError for wrong number of arguments
        # Sometimems ArgumentError might need to be ValueError?
        EOFError => PYEXC_EOFERROR,
        IndexError => PYEXC_INDEXERROR,
        RangeError => PYEXC_INDEXERROR, # RangeError and IndexError are conceptually the same thing
        IOError => PYEXC_IOERROR,
        RuntimeError => PYEXC_RUNTIMEERROR,
        SystemCallError => PYEXC_OSERROR,
        TypeError => PYEXC_TYPEERROR,
        ZeroDivisionError => PYEXC_ZERODIVISIONERROR,
        NotImplementedError => PYEXC_NOTIMPLEMENTEDERROR,
        NoMemoryError => PYEXC_MEMORYERROR,
        NoMethodError => PYEXC_ATTRIBUTEERROR,
        FloatDomainError => PYEXC_OVERFLOWERROR,
        SystemStackError => PYEXC_SYSTEMERROR,
        NameError => PYEXC_NAMEERROR,
        SyntaxError => PYEXC_SYNTAXERROR,
        LoadError => PYEXC_IMPORTERROR
      }

      def exc_translations
        @@exc_translations
      end
      module_function :exc_translations
      
      @@exc_translations.each_pair do |ruby, python|
        meth_name = "translate_%s" % ruby
        define_method(meth_name) { |exc| PythonAPI.py_object_call_object(python, [exc.message]) }
        module_function meth_name
      end
        
    end
  end
end