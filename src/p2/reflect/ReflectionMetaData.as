package p2.reflect {

    dynamic public class ReflectionMetaData {

        private var source:XML;
        private var _name:String;
        private var _args:Array;

		public function ReflectionMetaData(source:XML) {
			this.source = source;
		}

        public function get name():String {
            return _name ||= source.@name;
        }

        public function get args():Array {
            return _args ||= parseArgs();
        }

        public function toString():String {
            return source.toString();
        }

        public function getValueFor(argumentKey:String):* {
            return findFirst(args, function(item:Object, index:int, items:Array):Boolean {
                return (item.key == argumentKey);
            });
        }

        private function parseArgs():Array {
            var items:Array = [];
            var list:XMLList = source..arg;
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

/*
Parses:
<metadata name="BeforeFilter">
  <arg key="order" value="1"/>
</metadata>
*/
