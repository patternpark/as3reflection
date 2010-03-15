package p2.reflect {

    public class FakeController {

        [OtherFilter]
        public var someProp:String;

        [OtherFilter]
        [BeforeFilter(order=1, foo='bar')]
        public function authenticate():void {
        }

        [AfterFilter(order=2)]
        public function cleanRecords():void {
        }

        [OtherFilter(someKey='hello')]
        public function doSomething():void {
        }

        public function load():void {
        }
    }
}
