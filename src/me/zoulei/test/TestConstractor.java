package me.zoulei.test;

public class TestConstractor {

	final String a;
	
	public TestConstractor() {
		this.a = "112";
	}
	
	public TestConstractor(String a) {
		this();
	}

	public static void main(String[] args) {
		System.out.println(new TestConstractor("asadsa").a);

	}

}
