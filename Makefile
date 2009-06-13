# This makefile is a temporary solution.  It only works on OS X with my precise configuration.
# If someone who knows how to use automake, etc wants to fix it, I would be very grateful.

CFLAGS = -I/usr/lib/ruby/1.8/universal-darwin9.0/ `python-config --cflags` -g -Wno-strict-prototypes
LDFLAGS = -lruby `python-config --ldflags` -bundle -flat_namespace -undefined suppress -L. -lbridge

COMMON_C = rb2py.c py2rb.c initializers.c cross_exceptions.c wrapper_py.c
COMMON_O = rb2py.o py2rb.o initializers.o cross_exceptions.o wrapper_py.o



all: _ruby.so _rubyapi.so python.bundle pythonapi_.bundle

clean:
	-rm *_wrap.c *.o *.so *.bundle *.dylib ruby.py rubyapi.py 

libbridge.dylib: rb2py.o py2rb.o initializers.o cross_exceptions.o wrapper_py.o
	$(LD) $(COMMON_O) -lruby `python-config --ldflags` -dylib -o $@

_ruby.so: ruby_wrap.o libbridge.dylib
	$(LD) $(LDFLAGS) ruby_wrap.o -o $@

_rubyapi.so: rubyapi_wrap.o libbridge.dylib
	$(LD) $(LDFLAGS) rubyapi_wrap.o -o $@
	
python.bundle: python_wrap.o libbridge.dylib
	$(LD) $(LDFLAGS) python_wrap.o -o $@
	
pythonapi_.bundle: pythonapi__wrap.o libbridge.dylib
	$(LD) $(LDFLAGS) pythonapi__wrap.o $(COMMON_O) -o $@


ruby_wrap.c: ruby.i
	swig -python ruby.i
	
rubyapi_wrap.c: rubyapi.i
	swig -python rubyapi.i
	
python_wrap.c: python.i
	swig -ruby python.i
	
pythonapi__wrap.c: pythonapi_.i
	swig -ruby -autorename pythonapi_.i
	
rb2py.o: bridge.h
py2rb.o: bridge.h
initializers.o: bridge.h
cross_exceptions.o: bridge.h
wrapper_py.o: bridge.h
ruby_wrap.o: bridge.h
rubyapi_wrap.o: bridge.h
python_wrap.o: bridge.h
pythonapi__wrap.o: bridge.h
