class Point
end
p=Point.new             #所有的类对象都有一个名为new的方法
puts p.class            #查看这个对象是什么类型
puts p.is_a?Point

class Point
    def initialize(x, y)    #Ruby的构造函数。类对象new方法在创建一个实例后，自动调用该实例的initalize方法。
        @x, @y = x, y       #initialize自动成为类的私有方法，不能显示的对p调动initialize
    end                     #实例变量以@打头，属于self指定的对象。实例变量只能被实例方法访问。除反射机制之外。

    def to_s                #返回代表该对象的字符串
        "(#@x,#@y)"
    end

    def x                   #提供访问器方法返回变量的值
        @x
    end

    def y
        @y
    end
end

p = Point.new(1, 2)
puts p
puts p.x
q = Point.new(p.x*2,p.y*3)
puts q

class MutablePoint
    def initialize(x,y); @x, @y= x, y; end

    def x;@x;end
    def y;@y;end

    def x=(value)
        @x = value
    end

    def y=(value)
        @y = value
    end

    def to_s                #返回代表该对象的字符串
        "(#@x,#@y)"
    end
end
p = MutablePoint.new(1,1)
p.x = 0
p.y = 0
puts p

#所有的类都是模块（Class类为Module的子类）
#在任何类的定义中调用Module的方法attr_reader和attr_accessor
#attr_reader创建同名的读方法
#attr_accessor创建同名的读写方法

class Point
    attr_accessor :x,:y
end

class Point
    attr_reader :x,:y
end

#可以用符号:x，也可以用字符串"x"表示方法的属性
class Point
    attr_reader "x","y"
end
p =Point.new(1,2)
puts p.x

class PointAttr
    attr :x
end
puts "attr -----------------"
p =PointAttr.new
puts p.x

class PointAttr
    attr :x, true
end
puts "attr -----------------"
pa =PointAttr.new
pa.x=11
puts pa.x


class Foo                   
  attr_accessor :bar, :baz  
end                         
foo = Foo.new
puts foo.bar
foo.bar = 'jelly'
puts foo.bar

class Foo
    def bar
    @bar
    end

    def bar=(value)
    @bar = value
    end

    def baz
    @baz
    end

    def baz=(value)
    @baz = value
    end
end
foo = Foo.new
puts foo.bar
foo.bar = 'jelly'
puts foo.bar


#阅读到7.16小结（David Flanagan, Yukihiro Matsumoto. Ruby编程语言[M]. 电子工业出版社, 2009.）

