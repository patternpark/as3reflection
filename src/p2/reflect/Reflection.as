package p2.reflect {
    import flash.net.getClassByAlias;
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    public class Reflection {
        private static var READ_WRITE:String = "readwrite";
        private static var READ_ONLY:String = "readonly";
        private static var WRITE_ONLY:String = "writeonly";
        private static var reflections:Object;
        private var _accessors:Array;
        private var _allMembers:Array;
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
        
        public function get variables():Array {
            return _variables ||= buildVariables();
        }

        private function buildVariables():Array {
            var result:Array = [];
            var list:XMLList = description..variable;
            var item:XML;
            for each(item in list) {
                result.push(ReflectionVariable.create(item));
            }
            return result;
        }
        
        public function get readWriteMembers():Array {
            return _readWriteMembers ||= buildReadWriteMembers();
        }

        private function buildReadWriteMembers():Array {
            var result:Array = [];

            variables.forEach(function(item:*, index:int, items:Array):void {
                result.push(item);
            });

            accessors.forEach(function(accessor:ReflectionAccessor, index:int, items:Array):void {
                if(accessor.access == READ_WRITE) {
                    result.push(accessor);
                }
            });
            
            return result;
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
            return _interfaceNames ||= buildInterfaceNames();
        }

        private function buildInterfaceNames():Array {
            var result:Array = new Array();
            var list:XMLList = description..implementsInterface.@type;
            var item:XML;
            for each(item in list) {
                result.push(item);
            }
            return result;
        }
        
        public function get extendedClasses():Array {
            return _extendedClasses ||= buildExtendedClasses();
        }

        private function buildExtendedClasses():Array {
            var result:Array = [];
            var list:XMLList = description..extendsClass.@type;
            var item:XML;
            for each(item in list) {
                result.push(item);
            }
            return result;
        }
        
        public function get types():Array {
            if(_types == null) {
                _types = extendedClasses.concat(interfaceNames);
            }
            return _types;
        }
        
        public function get name():String {
            return _name ||= _description.@name;
        }
        
        public function get base():String {
            return _base ||= _description.@base;
        }
        
        public function get isClass():Boolean {
            return _isClass;
        }
        
        public function get isDynamic():Boolean {
            return _isDynamic ||= (_description.@isDynamic == "true");
        }
        
        public function get isFinal():Boolean {
            return _isFinal ||= (_description.@isFinal == "true");
        }
        
        public function get isStatic():Boolean {
            return _isStatic ||= (_description.@isStatic == "true");
        }
        
        public function get methods():Array {
            return _methods ||= buildMethods();
        }
        
        public function get accessors():Array {
            return _accessors ||= buildAccessors();
        }

        /**
         * An alphabetized list of all variables, accessors and methods.
         **/
        public function get allMembers():Array {
            return _allMembers ||= buildAllMembers();
        }

        private function buildAllMembers():Array {
            return variables.concat(accessors).concat(methods).sortOn('name');
        }
        
        public function get methodNames():Array {
            return _methodNames ||= buildMethodNames();
        }

        private function buildMethodNames():Array {
            var result:Array = [];
            var list:XMLList = description..method.@name;
            var item:XML;
            for each(item in list) {
                result.push(item.toString());
            }
            return result;
        }
        
        public function hasMethod(methodName:String):Boolean {
            return (methodNames.indexOf(methodName) > -1);
        }

        public function getMembersByMetaData(name:String):Array {
            return allMembers.filter(function(item:ReflectionMember, index:int, items:Array):Boolean {
                return (item.getMetaDataByName(name) != null);
            });
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

