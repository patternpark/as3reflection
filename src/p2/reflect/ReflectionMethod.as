package p2.reflect {

	public class ReflectionMethod extends ReflectionMember {
		protected var _parameters:Array;
		protected var _returnType:String;
		
		public function ReflectionMethod(source:XML, lock:Lock) {
			super(source);
			_returnType = source.@returnType;
		}
		
		public static function create(source:XML):ReflectionMethod {
			return new ReflectionMethod(source, new Lock());
		}
		
		private function buildParameters():Array {
			var parameters:Array = new Array();
			var list:XMLList = source..parameter;
			var param:ReflectionMethodParameter;
			var item:XML;
			for each(item in list) {
				param = ReflectionMethodParameter.create(item);
				parameters.push(param);
			}
			return parameters;
		}
		
		public function get returnType():String {
			return _returnType;			
		}
		
		public function get parameters():Array {
			if(_parameters == null) {
				_parameters = buildParameters();
			}
			return _parameters;
		}
	}
}

class Lock {
}
