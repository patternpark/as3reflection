package p2.reflect {

	public class ReflectionAccessor extends ReflectionMember {
		protected var _access:String;
		protected var _type:String;
		
		public function ReflectionAccessor(source:XML, lock:Lock) {
			super(source);
			_access = source.@access;
			_type = source.@type;
		}
		
		public static function create(source:XML):ReflectionAccessor {
			return new ReflectionAccessor(source, new Lock());
		}
		
		public function get access():String {
			return _access;
		}
		
		public function get type():String {
			return _type;			
		}		
	}
}

class Lock {
}
