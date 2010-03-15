package {
	/**
	 * This file has been automatically created using
	 * #!/usr/bin/ruby script/generate suite
	 * If you modify it and run this script, your
	 * modifications will be lost!
	 */

	import asunit.framework.TestSuite;
	import p2.reflect.FindFirstTest;
	import p2.reflect.ReflectionMetaDataTest;
	import p2.reflect.ReflectionTest;

	public class AllTests extends TestSuite {

		public function AllTests() {
			addTest(new p2.reflect.FindFirstTest());
			addTest(new p2.reflect.ReflectionMetaDataTest());
			addTest(new p2.reflect.ReflectionTest());
		}
	}
}
