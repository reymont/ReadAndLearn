

* [java基础：Object的equals方法 - 刘彦亮的专栏 - CSDN博客 ](http://blog.csdn.net/u013628152/article/details/43372279)

二：尝试重写Obejct的equals方法

```java
public class Cat2 {
	private String color;
	private int height;
	private int weight;

	Cat2(String color, int height, int weight) {
		this.color = color;
		this.height = height;
		this.weight = weight;
	}

	public String getColor() {
		return color;
	}

	public void setColor(String color) {
		this.color = color;
	}

	public int getHeight() {
		return height;
	}

	public void setHeight(int height) {
		this.height = height;
	}

	public int getWeight() {
		return weight;
	}

	public void setWeight(int weight) {
		this.weight = weight;
	}

	/**
	 * 重写Object的equals方法
	 */
	public boolean equals(Object obj) {
		if (obj == null) {
			return false;
		} else if (obj instanceof Cat2) {
			Cat2 catObj = (Cat2) obj;
			if (catObj.getColor() == this.color
					&& catObj.getHeight() == this.height
					&& catObj.getWeight() == this.weight) {
				return true;
			}

		}
		return false;
	}

	public static void main(String[] args) {
		Cat2 cat1 = new Cat2("red", 1, 2);
		Cat2 cat2 = new Cat2("red", 1, 2);
		System.out.println(cat1.equals(cat2));
	}

}
```