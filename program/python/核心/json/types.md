

This module defines names for some object types that are used by the standard Python interpreter, but not for the types defined by various extension modules. Also, it does not include some of the types that arise during processing such as the listiterator type. It is safe to use from types import * — the module does not export any names besides the ones listed here. New names exported by future versions of this module will all end in Type.

Typical use is for functions that do different things depending on their argument types, like the following:

```py
from types import *
def delete(mylist, item):
    if type(item) is IntType:
       del mylist[item]
    else:
       mylist.remove(item)
```
Starting in Python 2.2, built-in factory functions such as int() and str() are also names for the corresponding types. This is now the preferred way to access the type instead of using the types module. Accordingly, the example above should be written as follows:

```py
def delete(mylist, item):
    if isinstance(item, int):
       del mylist[item]
    else:
       mylist.remove(item)
```
The module defines the following names:

types.NoneType
The type of None.

types.TypeType
The type of type objects (such as returned by type()); alias of the built-in type.

types.BooleanType
The type of the bool values True and False; alias of the built-in bool.

New in version 2.3.

types.IntType
The type of integers (e.g. 1); alias of the built-in int.

types.LongType
The type of long integers (e.g. 1L); alias of the built-in long.

types.FloatType
The type of floating point numbers (e.g. 1.0); alias of the built-in float.

types.ComplexType
The type of complex numbers (e.g. 1.0j). This is not defined if Python was built without complex number support.

types.StringType
The type of character strings (e.g. 'Spam'); alias of the built-in str.

types.UnicodeType
The type of Unicode character strings (e.g. u'Spam'). This is not defined if Python was built without Unicode support. It’s an alias of the built-in unicode.

types.TupleType
The type of tuples (e.g. (1, 2, 3, 'Spam')); alias of the built-in tuple.

types.ListType
The type of lists (e.g. [0, 1, 2, 3]); alias of the built-in list.

types.DictType
The type of dictionaries (e.g. {'Bacon': 1, 'Ham': 0}); alias of the built-in dict.

types.DictionaryType
An alternate name for DictType.

types.FunctionType
types.LambdaType
The type of user-defined functions and functions created by lambda expressions.

types.GeneratorType
The type of generator-iterator objects, produced by calling a generator function.

New in version 2.2.

types.CodeType
The type for code objects such as returned by compile().

types.ClassType
The type of user-defined old-style classes.

types.InstanceType
The type of instances of user-defined old-style classes.

types.MethodType
The type of methods of user-defined class instances.

types.UnboundMethodType
An alternate name for MethodType.

types.BuiltinFunctionType
types.BuiltinMethodType
The type of built-in functions like len() or sys.exit(), and methods of built-in classes. (Here, the term “built-in” means “written in C”.)

types.ModuleType
The type of modules.

types.FileType
The type of open file objects such as sys.stdout; alias of the built-in file.

types.XRangeType
The type of range objects returned by xrange(); alias of the built-in xrange.

types.SliceType
The type of objects returned by slice(); alias of the built-in slice.

types.EllipsisType
The type of Ellipsis.

types.TracebackType
The type of traceback objects such as found in sys.exc_traceback.

types.FrameType
The type of frame objects such as found in tb.tb_frame if tb is a traceback object.

types.BufferType
The type of buffer objects created by the buffer() function.

types.DictProxyType
The type of dict proxies, such as TypeType.__dict__.

types.NotImplementedType
The type of NotImplemented

types.GetSetDescriptorType
The type of objects defined in extension modules with PyGetSetDef, such as FrameType.f_locals or array.array.typecode. This type is used as descriptor for object attributes; it has the same purpose as the property type, but for classes defined in extension modules.

New in version 2.5.

types.MemberDescriptorType
The type of objects defined in extension modules with PyMemberDef, such as datetime.timedelta.days. This type is used as descriptor for simple C data members which use standard conversion functions; it has the same purpose as the property type, but for classes defined in extension modules.

CPython implementation detail: In other implementations of Python, this type may be identical to GetSetDescriptorType.

New in version 2.5.

types.StringTypes
A sequence containing StringType and UnicodeType used to facilitate easier checking for any string object. Using this is more portable than using a sequence of the two string types constructed elsewhere since it only contains UnicodeType if it has been built in the running version of Python. For example: isinstance(s, types.StringTypes).

New in version 2.2.

## 参考

1. https://docs.python.org/2/library/types.html