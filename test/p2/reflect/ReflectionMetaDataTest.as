package p2.reflect {

	import asunit.framework.TestCase;

	public class ReflectionMetaDataTest extends TestCase {

        private var controller:Reflection;
        private var authenticate:ReflectionMethod;

		public function ReflectionMetaDataTest(methodName:String=null) {
			super(methodName);
		}

		override protected function setUp():void {
			super.setUp();
            controller = Reflection.create(FakeController);
            authenticate = controller.getMethodByName('authenticate');
		}

		override protected function tearDown():void {
			super.tearDown();
		}

        public function testGetMembersByMetaDataName():void {
            var members:Array = controller.getMembersByMetaData('OtherFilter');
            assertEquals(3, members.length);
            var prop:ReflectionMember;
            prop = members.shift();
            assertEquals('authenticate', prop.name);
            prop = members.shift();
            assertEquals('doSomething', prop.name);
            prop = members.shift();
            assertEquals('someProp', prop.name);
        }

        public function testGetMembersByMetaDataNameWithNoResult():void {
            var members:Array = controller.getMembersByMetaData('UnknownFilter');
            assertEquals(0, members.length);
        }

        public function testMetaDataItemsCollection():void {
            var items:Array = authenticate.metaDataItems;
            assertEquals(2, items.length);
        }
        
        public function testGetMetaDataByName():void {
            var beforeFilter:ReflectionMetaData = authenticate.getMetaDataByName('BeforeFilter');
            assertEquals('BeforeFilter', beforeFilter.name);
            assertEquals('beforeFilter.args', 2, beforeFilter.args.length);
            assertEquals('beforeFilter.order', 1, beforeFilter.order);
            assertEquals('beforeFilter.foo', 'bar', beforeFilter.foo);
        }
	}
}
