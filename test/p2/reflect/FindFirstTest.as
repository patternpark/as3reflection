package p2.reflect {

	import asunit.framework.TestCase;

	public class FindFirstTest extends TestCase {

		public function FindFirstTest(methodName:String=null) {
			super(methodName);
		}

		public function testEmptyArray():void {
            assertNull(findFirst([], null));
		}

        public function testFirstItem():void {
            var result:String = findFirst(['one', 'two', 'three'], function(item:String, index:int, items:Array):Boolean {
                    return (item == 'one');
            });
            assertEquals('one', result);
        }

        public function testFindMiddleItem():void {
            var result:String = findFirst(['one', 'two', 'three'], function(item:String, index:int, items:Array):Boolean {
                    return (item == 'two');
            });
            assertEquals('two', result);
        }

        public function testFindLastItem():void {
            var result:String = findFirst(['one', 'two', 'three'], function(item:String, index:int, items:Array):Boolean {
                    return (item == 'three');
            });
            assertEquals('three', result);
        }

        public function testNoItemFound():void {
            var result:String = findFirst(['one', 'two', 'three'], function(item:String, index:int, items:Array):Boolean {
                    return (item == 'four');
            });
            assertNull(result);
        }

	}
}
