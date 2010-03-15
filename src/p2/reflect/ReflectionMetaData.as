package p2.reflect {

    /**
     * Parses:
     * <metadata name="BeforeFilter">
     *   <arg key="order" value="1"/>
     * </metadata>
     */
    dynamic public class ReflectionMetaData {

        private var _args:Array;
		private var _description:XML;
		private var _name:String;

		public function ReflectionMetaData(description:XML) {
			_description = description;
        }

		public function get name():String {
			return _name ||= _description.@name;
		}

        public function get description():XML {
            return _description;
        }

        public function get args():Array {
            return _args ||= parseArgs();
        }

        public function getValueFor(argumentKey:String):* {
            return findFirst(args, function(item:Object, index:int, items:Array):Boolean {
                return (item.key == argumentKey);
            });
        }

        private function parseArgs():Array {
            var items:Array = [];
            var list:XMLList = description..arg;
            var item:XML;
            var key:String;
            var value:*;
            for each(item in list) {
                key = item.@key;
                value = item.@value;
                items.push({ key: key, value: value });
                this[key] = value;
            }
            return items;
        }
    }
}
