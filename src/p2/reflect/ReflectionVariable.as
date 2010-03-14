package p2.reflect {
	public class ReflectionVariable extends ReflectionMember {
		protected var _type:String;

		public function ReflectionVariable(source:XML, lock:Lock) {
			super(source);
			_type = source.@type;
		}
		
		public static function create(source:XML):ReflectionVariable {
			return new ReflectionVariable(source, new Lock());
		}
		
		public function get type():String {
			return _type;
		}
	}
}

class Lock {
}