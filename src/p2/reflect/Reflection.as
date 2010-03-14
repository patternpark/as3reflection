package p2.reflect {
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;
    import flash.net.getClassByAlias;
    import flash.utils.getDefinitionByName;
    
    public class Reflection {
        private static var READ_WRITE:String = "readwrite";
        private static var READ_ONLY:String = "readonly";
        private static var WRITE_ONLY:String = "writeonly";
        private static var reflections:Object;
        private var _accessors:Array;
        private var _base:String;
        private var _classReference:Class;
        private var _constructor:ReflectionMethod;
        private var _description:XML;
        private var _extendedClasses:Array;
        private var _interfaceNames:Array;
        private var _isClass:Boolean;
        private var _isDynamic:Boolean;
        private var _isFinal:Boolean;
        private var _isStatic:Boolean;
        private var _methodNames:Array;
        private var _methods:Array;
        private var _name:String;
        private var _readMembers:Array;
        private var _readWriteMembers:Array;
        private var _types:Array;
        private var _variables:Array;
        private var _writeMembers:Array;

        public function Reflection(source:*, lock:Lock) {
            _description = describeType(source);
            _name = _description.@name;
            _base = _description.@base;
            _isDynamic = (_description.@isDynamic == "true");
            _isFinal = (_description.@isFinal == "true");
            _isStatic = (_description.@isStatic == "true");
            _isClass = (source is Class);
        }
        
        public static function create(source:*):Reflection {
            var name:String = getQualifiedClassName(source) + ((source is Class) ? "Class" : "");
            var cache:Object = getCache();
            if(cache[name] != null) {
                return cache[name];
            }
            var reflection:Reflection = new Reflection(source, new Lock());
            cache[name] = reflection;
            return reflection;
        }
        
        private static function getCache():Object {
            if(reflections == null) {
                clearCache();
            }
            return reflections;
        }
        
        public static function clearCache():void {
            reflections = new Object();
        }
        
        private function buildMethods():Array {
            var methods:Array = new Array();
            var list:XMLList = description..method;
            var item:XML;
            var method:ReflectionMethod
            for each(item in list) {
                method = ReflectionMethod.create(item);
                methods.push(method);
            }
            return methods;
        }
        
        private function buildAccessors():Array {
            var accessors:Array = new Array();
            var list:XMLList = description..accessor;
            var item:XML;
            var accessor:ReflectionAccessor;
            for each(item in list) {
                accessor = ReflectionAccessor.create(item);
                accessors.push(accessor);
            }
            return accessors;
        }
        
        public function get description():XML {
            return _description;
        }
        
        public function get hasConstructor():Boolean {
            return (constructor != null);
        }
        
        public function get classReference():Class {
            if(_classReference == null) {
                _classReference = getDefinitionByName(name.split("::").join(".")) as Class;
            }
            return _classReference;
        }
        
        public function get constructor():ReflectionMethod {
            if(_constructor == null) {
                var constr:XML = description..constructor[0];
                if(constr != null) {
                    _constructor = ReflectionMethod.create(constr);
                }
            }
            return _constructor;
        }
        
        
        public function hasAccessor(name:String, type:String, declaredBy:String=null):Boolean {
            return findFirst(accessors, function(item:*, index:int, items:Array):Boolean {
                return (item.name == name && item.type == type);
            }) != null;
        }
        
        public function hasVariable(name:String, type:String):Boolean {
            return findFirst(variables, function(item:*, index:int, items:Array):Boolean {
                return (item.name == name && item.type == type);
            }) != null;
        }
        
        public function hasReadWriteMember(name:String, type:String):Boolean {
            return findFirst(readWriteMembers, function(item:*, index:int, items:Array):Boolean {
                return (item.name == name && item.type == type);
            }) != null;
        }
        
        public function hasWriteMember(name:String, type:String):Boolean {
            return findFirst(writeMembers, function(item:*, index:int, items:Array):Boolean {
                return (item.name == name && item.type == type);
            }) != null;
        }
        
        private function findFirst(collection:Array, handler:Function):* {
            var result:*;
            collection.every(function(item:Object, index:int, items:Array):Boolean {
                    if(handler(item, index, items)) {
                    result = item;
                    return false;
                    }
                    return true;
                    });
            return result;
        }

        public function get variables():Array {
            if(_variables == null) {
                _variables = new Array();
                var list:XMLList = description..variable;
                var item:XML;
                for each(item in list) {
                    _variables.push(ReflectionVariable.create(item));
                }
            }
            return _variables;
        }
        
        public function get readWriteMembers():Array {
            if(_readWriteMembers == null) {
                _readWriteMembers = [];
                variables.forEach(function(item:*, index:int, items:Array):void {
                    _readWriteMembers.push(item);
                });
                
                var accessors:Array = this.accessors;
                var accessor:ReflectionAccessor
                for each(accessor in accessors) {
                    if(accessor.access == READ_WRITE) {
                        _readWriteMembers.push(accessor);
                    }
                }
            }
            
            return _readWriteMembers;
        }

        public function get readMembers():Array {
            if(_readMembers == null) {
                _readMembers = [];
                variables.forEach(function(item:*, index:int, items:Array):void {
                    _readMembers.push(item);
                });
                var accessors:Array = this.accessors;
                var accessor:ReflectionAccessor
                for each(accessor in accessors) {
                    if(accessor.access == READ_WRITE || accessor.access == READ_ONLY) {
                        _readMembers.push(accessor);
                    }
                }
            }
            
            return _readMembers;
        }
        
        public function get writeMembers():Array {
            if(_writeMembers == null) {
                _writeMembers = [];
                variables.forEach(function(item:*, index:int, items:Array):void {
                    _writeMembers.push(item);
                });
                var accessors:Array = this.accessors;
                var accessor:ReflectionAccessor
                for each(accessor in accessors) {
                    if(accessor.access == READ_WRITE || accessor.access == WRITE_ONLY) {
                        _writeMembers.push(accessor);
                    }
                }
            }

            return _writeMembers;
        }
        
        public function get interfaceNames():Array {
            if(_interfaceNames == null) {
                _interfaceNames = new Array();
                var list:XMLList = description..implementsInterface.@type;
                var item:XML;
                for each(item in list) {
                    _interfaceNames.push(item);
                }
            }
            return _interfaceNames;
        }
        
        public function get extendedClasses():Array {
            if(_extendedClasses == null) {
                _extendedClasses = new Array();
                var list:XMLList = description..extendsClass.@type;
                var item:XML;
                for each(item in list) {
                    _extendedClasses.push(item);
                }
            }
            return _extendedClasses;
        }
        
        public function get types():Array {
            if(_types == null) {
                _types = extendedClasses.concat(interfaceNames);
            }
            return _types;
        }
        
        public function get name():String {
            return _name;
        }
        
        public function get base():String {
            return _base;
        }
        
        public function get isClass():Boolean {
            return _isClass;
        }
        
        public function get isDynamic():Boolean {
            return _isDynamic;
        }
        
        public function get isFinal():Boolean {
            return _isFinal;
        }
        
        public function get isStatic():Boolean {
            return _isStatic;
        }
        
        public function get methods():Array {
            if(_methods == null) {
                _methods = buildMethods();
            }
            return _methods;
        }
        
        public function get accessors():Array {
            if(_accessors == null) {
                _accessors = buildAccessors();
            }
            return _accessors;
        }
        
        public function get methodNames():Array {
            if(_methodNames == null) {
                _methodNames = new Array();
                var list:XMLList = description..method.@name;
                var item:XML;
                for each(item in list) {
                    _methodNames.push(item);
                }
            }
            return _methodNames;
        }
        
        public function hasMethod(name:String):Boolean {
            var names:Array = methodNames;
            var ln:Number = names.length;
            for(var i:Number = 0; i < ln; i++) {
                if(names[i] == name) {
                    return true;
                }
            }
            return false;
        }
        
        public function getAccessorByName(name:String):ReflectionAccessor {
            var ln:Number = accessors.length
            for(var i:Number = 0; i < ln; i++) {
                if(accessors[i].name == name) {
                    return accessors[i];
                }
            }
            return null;
        }
        
        public function getMethodByName(name:String):ReflectionMethod {
            var ln:Number = methods.length;
            for(var i:Number = 0; i < ln; i++) {
                if(methods[i].name == name) {
                    return methods[i];
                }
            }
            return null;
        }
        
        // This implementation of Clone has some serious caveats...
        // a) Only member variables and accessors that are read/write will be cloned
        // b) The clone is shallow, meaning property references will not also be cloned
        public static function clone(instance:Object):Object {
            var reflection:Reflection = Reflection.create(instance);
            var clazz:Class = reflection.classReference;
            var clone:Object = new clazz();
            var members:Array = reflection.readWriteMembers;
            var name:String;
            var member:ReflectionMember;
            for each(member in members) {
                name = member.name;
                clone[name] = instance[name];
            }
            return clone;
        }
        
        public function toString():String {
            return description.toString();
        }
    }
}

class Lock {
}

