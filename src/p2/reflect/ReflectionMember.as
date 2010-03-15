package p2.reflect {

	public class ReflectionMember {
		protected var _declaredBy:String;
		protected var _name:String;
		protected var source:XML;

        private var _metaDataItems:Array;
		
		public function ReflectionMember(source:XML) {
			this.source = source;
			_declaredBy = source.@declaredBy;
			_name = source.@name;
		}
		
		public function get declaredBy():String {
			return _declaredBy;
		}

        public function get metaDataItems():Array {
            return _metaDataItems ||= parseMetaDataItems();
        }
		
		public function get name():String {
			return _name;
		}
		
		public function toString():String {
			return source.toXMLString();
		}

        public function getMetaDataByName(name:String):ReflectionMetaData {
            return findFirst(metaDataItems, function(item:*, index:int, items:Array):Boolean {
                return (item.name == name);
            });
        }

        private function parseMetaDataItems():Array {
            var items:Array = [];
            var list:XMLList = source..metadata;
            var item:XML;
            for each(item in list) {
                items.push(new ReflectionMetaData(item));
            }
            return items;
        }
	}
}
