package p2.reflect {

	public class ReflectionMember {
		protected var _declaredBy:String;
		protected var _name:String;
		protected var source:XML;
		
		public function ReflectionMember(source:XML) {
			this.source = source;
			_declaredBy = source.@declaredBy;
			_name = source.@name;
		}
		
		public function get declaredBy():String {
			return _declaredBy;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function toString():String {
			return source.toXMLString();
		}
	}
}
