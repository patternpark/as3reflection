package p2.reflect {
	import flash.xml.XMLNode;
	

	public class ReflectionMethodParameter {
		protected var source:XML;
		protected var _index:int;
		protected var _type:String;
		protected var _optional:Boolean;
		
		public function ReflectionMethodParameter(source:XML, lock:Lock) {
			this.source = source;
			_index = source.@index;
			_type = source.@type;
			_optional = (source.@optional == "true");
		}
		
		public static function create(source:XML):ReflectionMethodParameter {
			return new ReflectionMethodParameter(source, new Lock());
		}
		
		public function get index():int {
			return _index;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function get optional():Boolean {
			return _optional;
		}
		
		public function toString():String {
			return source.toXMLString();
		}
	}
}

class Lock {
}
