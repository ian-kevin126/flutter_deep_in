# Dart语法篇之基础语法(一)

简述:

又是一段新的开始，Dart这门语言相信很多人都是通过Flutter这个框架才了解的，因为Flutter相比Dart更被我们所熟知。很多人迟迟不愿尝试Flutter原因大多数是因为学习成本高，显然摆在面前的是需要去重新学习一门新的语言dart，然后再去学习一个开发框架Flutter,再加上很多莫名奇妙的坑,不说多的就从Github上Flutter项目issue数来看坑是着实不少，所以很多人也就望而却步了。当然这个问题是一个新的技术框架刚开始都可能存在的，但我们更需要看到Flutter框架跨平台技术思想先进性。

为什么要开始一系列Dart相关的文章?

很简单，就是为了更好地开发Flutter, 其实开发Flutter使用Dart的核心知识点并不需要太过于全面，有些东西根本用不到，所以该系列文章也将是有选择性选取Dart一些常用技术点讲解。另一方面，读过我文章的小伙伴就知道我是Kotlin的狂热忠实粉, 其实语言都是相通，你可以从Dart身上又能看到Kotlin的身影，所以我上手Dart非常快，可以对比着学习。所以后期Dart文章我会将Dart与Kotlin作为对比讲解，所以如果你学过Kotlin那么恭喜你，上手Dart将会非常快。

该系列Dart文章会讲哪些内容呢?

本系列文章主要会涉及以下内容: dart基本语法、变量常量和类型推导、集合、函数、面向对象的Mixins、泛型、生成器函数、Async和Await、Stream和Future、Isolate和EventLoop以及最后基本介绍下DartVM的工作原理。

## 一、Hello Dart

> 这是第一个Hello Dart程序，很多程序入口都是从main函数开始，所以dart也不例外，一起来看下百变的main函数

```dart
//main标准写法
void main() {
  print('Hello World!');//注意: Dart和Java一样表达式以分号结尾，写习惯Kotlin的小伙伴需要注意了, 这可能是你从Kotlin转Dart最大不适之一。
}

//dart中void类型，作为函数返回值类型可以省略
main() {
  print('Hello World!');  
}

//如果函数内部只有一个表达式，可以省略大括号，使用"=>"箭头函数; 
//而对于Kotlin则是如果只有一个表达式，可以省略大括号，使用"="连接，类似 fun main(args: Array<String>) = println('Hello World!')
void main() => print('Hello World!');

//最简写形式
main() => print('Hello World!');
```

## 二、数据类型

在dart中的一切皆是对象，包括数字、布尔值、函数等，它们和Java一样都继承于Object, 所以它们的默认值也就是null. 在dart主要有: 布尔类型bool、数字类型num(数字类型又分为int，double，并且两者父类都是num)、[字符串](https://www.zhihu.com/search?q=字符串&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})类型String、集合类型(List, Set, Map)、Runes类和Symbols类型(后两个用的并不太多)

### 1、[布尔类型](https://www.zhihu.com/search?q=布尔类型&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})(bool)

在dart中和C语言一样都是使用`bool`来声明一个[布尔类型变量](https://www.zhihu.com/search?q=布尔类型变量&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})或常量，而在Kotlin则是使用`Boolean` 来声明，但是一致的是它对应的值只有两个true和false.

```dart
main() {
    bool isClosed = true;//注意，dart还是和Java类似的 [类型][变量名]方式声明，这个和Kotlin的 [变量名]:[类型]不一样.
    bool isOpened = false;
}
```

### 2、数字类型(num、int、double)

在dart中num、int、double都是类,然后int、double都继承num抽象类，这点和Kotlin很类似，在Kotlin中Number、Int、Double都是类，然后Int、Double都继承于Number. 注意，**但是在dart中没有float, short, long类型**

```dart
main() {
    double pi = 3.141592653;
    int width = 200;
    int height = 300;
    print(width / height);//注意:这里和Kotlin、Java都不一样，两个int类型相除是double类型小数，而不是整除后的整数。
    print(width ~/ height);//注意: 这才是dart整除正确姿势
}
```

此外和Java、Kotlin一样，dart也拥有一些数字常用的函数:

```dart
main() {
    print(3.141592653.toStringAsFixed(3)); //3.142 保留有效数字
    print(6.6.floor());//6向下取整
    print((-6.6).ceil()); //-6 向上取整
    print(9.9.ceil()); //10 向上取整
    print(666.6.round()); //667 四舍五入
    print((-666.6).abs()); // 666.6 取绝对值
    print(666.6.toInt()); //666 转化成int,这中toInt、toDouble和Kotlin类似
    print(999.isEven); //false 是否是偶数
    print(999.isOdd); //true 是否是奇数
    print(666.6.toString()); //666.6 转化成字符串
}
```

### 3、字符串类型(String)

在Dart中支持单引号、双引号、三引号以及$字符串模板用法和Kotlin是一模一样的。

```dart
main() {
    String name = 'Hello Dart!';//单引号
    String title = "'Hello Dart!'";//双引号
    String description = """
          Hello Dart! Hello Dart!
          Hello Dart!
          Hello Dart! Hello Dart!
    """;//三引号
    num value = 2;
    String result = "The result is $value";//单值引用
    num width = 200;
    num height = 300;
    String square = "The square is ${width * height}";//表达式的值引用
}
```

和Kotlin一样，dart中也有很多字符串操作的方法，比如字符串拆分、子串等

```dart
main() {
  String url = "https://mrale.ph/dartvm/";

  print(url.split("://")[0]); //字符串分割split方法，类似Java和Kotlin

  print(url.substring(3, 9)); //字符串截取substring方法, 类似Java和Kotlin

  print(url.codeUnitAt(0)); //取当前索引位置字符的UTF-16码

  print(url.startsWith("https")); //当前字符串是否以指定字符开头, 类似Java和Kotlin

  print(url.endsWith("/")); //当前字符串是否以指定字符结尾, 类似Java和Kotlin

  print(url.toUpperCase()); //大写, 类似Java和Kotlin

  print(url.toLowerCase()); //小写, 类似Java和Kotlin

  print(url.indexOf("ph")); //获取指定字符的索引位置, 类似Java和Kotlin

  print(url.contains("http")); //字符串是否包含指定字符, 类似Java和Kotlin

  print(url.trim()); //去除字符串的首尾空格, 类似Java和Kotlin

  print(url.length); //获取字符串长度

  print(url.replaceFirst("t", "A")); //替换第一次出现t字符位置的字符

  print(url.replaceAll("m", "M")); //全部替换, 类似Java和Kotlin
}
```

### 4、类型检查(is和is!)和强制类型转换(as)

和Kotlin一样，dart也是通过 **is** 关键字来对类型进行检查以及使用 **as** 关键字对类型进行强制转换，如果判断不是某个类型dart中使用 **is!** , 而在Kotlin中正好相反则用 **!is** 表示。

```dart
main() {
    int number = 100;
    double distance = 200.5;
    num age = 18;
    print(number is num);//true
    print(distance is! int);//true
    print(age as int);//18
}
```

### 5、Runes和Symbols类型

在Dart中的Runes和Symbols类型使用并不多，这里做个简单的介绍, Runes类型是UTF-32字节单元定义的Unicode字符串，Unicode可以使用数字表示字母、数字和符号，然而在dart中String是一系列的UTF-16的字节单元，所以想要表示32位的Unicode的值，就需要用到Runes类型。我们一般使用`\uxxxx`这种形式来表示一个Unicode码，`xxxx` 表示4个十六进制值。当十六进制数据多余或者少于4位时，将十六进制数放入到花括号中，例如，微笑表情（ ）是`\u{1f600}`。而Symbols类型则用得很少，一般用于Dart中的反射，但是注意在Flutter中禁止使用反射。

```dart
main() {
  var clapping = '\u{1f44f}';
  print(clapping);
  print(clapping.codeUnits);//返回十六位的字符单元数组
  print(clapping.runes.toList());

  Runes input = new Runes(
      '\u2665  \u{1f605}  \u{1f60e}  \u{1f47b}  \u{1f596}  \u{1f44d}');
  print(new String.fromCharCodes(input));
}
```

### 6、Object类型

在Dart中所有东西都是对象，都继承于Object, 所以可以使用Object可以定义任何的变量，而且赋值后，类型也可以更改。

```dart
main() {
    Object color = 'black';
    color = 0xff000000;//运行正常，0xff000000类型是int, int也继承于Object   
}
```

### 7、[dynamic类型](https://www.zhihu.com/search?q=dynamic类型&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})

在Dart中还有一个和Object类型非常类似的类型那就是dynamic类型，下面讲到的var声明的变量未赋值的时候就是dynamic类型， 它可以像Object一样可以改变类型。dynamic类型一般用于无法确定具体类型, 注意: **建议不要滥用dynamic，一般尽量使用Object**, 如果你对Flutter和Native原生通信PlatformChannel代码熟悉的话，你会发现里面大量使用了dynamic, 因为可能native数据类型无法对应dart中的数据类型,此时dart接收一般就会使用dynamic.

Object和dynamic区别在于: Object会在**编译阶段**检查类型，而dynamic不会在**编译阶段**检查类型。

```dart
main() {
    dynamic color = 'black';
    color = 0xff000000;//运行正常，0xff000000类型是int, int也继承于Object
}
```

## 三、变量和常量

### 1、var关键字

在dart中可以使用var来替代具体类型的声明，会**自动推导变量的类型**，这是因为var并不是直接存储值，而是存储值的对象引用，所以var可以声明任何变量。这一点和Kotlin不一样，在Kotlin中声明可变的变量都必须需要使用var关键字，而Kotlin的类型推导是默认行为和var并没有直接关系。注意: 在Flutter开发一般会经常使用var声明变量，以便于可以自动推导变量的类型。

```dart
main() {
  int colorValue = 0xff000000;
  var colorKey = 'black'; //var声明变量 自动根据赋值的类型，推导为String类型 
  // 使用var声明集合变量 
  var colorList = ['red', 'yellow', 'blue', 'green'];
  var colorSet = {'red', 'yellow', 'blue', 'green'};
  var colorMap = {'white': 0xffffffff, 'black': 0xff000000};
}
```

但是在使用var声明变量的时候，需要注意的是: **如果var声明的变量开始不初始化，不仅值可以改变它的类型也是可以被修改的，但是一旦开始初始化赋值后，它的类型就确定了，后续不能被改变。**

```dart
main() {
  var color; // 仅有声明未赋值的时候，这里的color的类型是dynamic,所以它的类型是可以变的 
  color = 'red';
  print(color is String); //true 
  color = 0xffff0000;
  print(color is int); //true 

  var colorValue = 0xffff0000; //声明时并赋值，这里colorValue类型已经推导出为int,并且确定了类型 
  colorValue = 'red'; //错误，这里会抛出编译异常，String类型的值不能赋值给int类型 
  print(colorValue is int); //true
}
```

### 2、常量(final和const)

在dart中声明常量可以使用**const**或**final** 两个关键字，注意: 这两者的区别在于如果常量是编译期就能初始化的就用const(有点类似Kotlin中的const val) 如果常量是运行时期初始化的就用final(有点类似Kotlin中的val)

```dart
main() {    
  const PI = 3.141592653;//const定义常量    
  final nowTime = DateTime.now();//final定义常量
}
```

## 四、集合(List、Set、Map)

### 1、集合List

在dart中的List和Kotlin还是很大的区别，换句话说Dart整个集合类型系统的划分都和Kotlin都不一样，比如Dart中集合就没有严格区分成可变集合(Kotlin中MutableList)和不变集合(Kotlin中的List)，在使用方式上你会感觉它更像数组，但是它是可以随意对元素增删改成的。

- List初始化方式

```dart
main() {       
   List<String> colorList = ['red', 'yellow', 'blue', 'green'];//直接使用[]形式初始化       
   var colorList = <String> ['red', 'yellow', 'blue', 'green'];   
}
```

- List常用的函数

```dart
main() { 
   List<String> colorList = ['red', 'yellow', 'blue', 'green'];       
   colorList.add('white');//和Kotlin类似通过add添加一个新的元素       
   print(colorList[2]);//可以类似Kotlin一样，直接使用数组下标形式访问元素       
   print(colorList.length);//获取集合的长度，这个Kotlin不一样，Kotlin中使用的是size       
   colorList.insert(1, 'black');//在集合指定index位置插入指定的元素       
   colorList.removeAt(2);//移除集合指定的index=2的元素，第3个元素       
   colorList.clear();//清除所有元素       
   print(colorList.sublist(1,3));//截取子集合       
   print(colorList.getRange(1, 3));//获取集合中某个范围元素       
   print(colorList.join('<--->'));//类似Kotlin中的joinToString方法，输出: red<--->yellow<--->blue<--->green       
   print(colorList.isEmpty);       
   print(colorList.contains('green'));       
} 
```

- List的遍历方式

```dart
main() {
   List<String> colorList = ['red', 'yellow', 'blue', 'green'];//for-i遍历       
   for(var i = 0; i < colorList.length; i++) {//可以使用var或int           
       print(colorList[i]);               
   }       
  //forEach遍历       
  colorList.forEach((color) => print(color));//forEach的参数为Function. =>使用了箭头函数       
  //for-in遍历       
  for(var color in colorList) {
      print(color);       
  }       
  //while+iterator迭代器遍历，类似Java中的iteator       
  while(colorList.iterator.moveNext()) {           
      print(colorList.iterator.current);       
  }   
} 
```

### 2、集合Set

集合Set和列表List的区别在于 **集合中的元素是不能重复** 的。所以添加重复的元素时会返回false,表示添加不成功.

- Set初始化方式

```dart
main() {       
   Set<String> colorSet= {'red', 'yellow', 'blue', 'green'};//直接使用{}形式初始化       
   var colorList = <String> {'red', 'yellow', 'blue', 'green'};   
}
```

- 集合中的交、并、补集，在Kotlin并没有直接给到计算集合交、并、补的API

```dart
main() {       
   var colorSet1 = {'red', 'yellow', 'blue', 'green'};       
   var colorSet2 = {'black', 'yellow', 'blue', 'green', 'white'};       
   print(colorSet1.intersection(colorSet2));//交集-->输出: {'yellow', 'blue', 'green'}       
   print(colorSet1.union(colorSet2));//并集--->输出: {'black', 'red', 'yellow', 'blue', 'green', 'white'}       
   print(colorSet1.difference(colorSet2));//补集--->输出: {'red'}   
}
```

- Set的遍历方式(和List一样)

```dart
main() {       
   Set<String> colorSet = {'red', 'yellow', 'blue', 'green'};       
   //for-i遍历       
   for (var i = 0; i < colorSet.length; i++) {         
       //可以使用var或int         
       print(colorSet[i]);       
   }       
   //forEach遍历       
   colorSet.forEach((color) => print(color)); //forEach的参数为Function. =>使用了箭头函数       
   //for-in遍历       
   for (var color in colorSet) {         
       print(color);       
   }       
   //while+iterator迭代器遍历，类似Java中的iteator       
   while (colorSet.iterator.moveNext()) {         
       print(colorSet.iterator.current);       
   }     
}
```

### 3、集合Map

集合Map和Kotlin类似，key-value形式存储，并且 **Map对象的中key是不能重复的**

- Map初始化方式

```dart
main() {       
   Map<String, int> colorMap = {'white': 0xffffffff, 'black':0xff000000};//使用{key:value}形式初始化    
   var colorMap = <String, int>{'white': 0xffffffff, 'black':0xff000000};   
}
```

- Map中常用的函数

```dart
main() {       
   Map<String, int> colorMap = {'white': 0xffffffff, 'black':0xff000000};       
   print(colorMap.containsKey('green'));//false       
   print(colorMap.containsValue(0xff000000));//true       
   print(colorMap.keys.toList());//['white','black']       
   print(colorMap.values.toList());//[0xffffffff, 0xff000000]       
   colorMap['white'] = 0xfffff000;//修改指定key的元素       
   colorMap.remove('black');//移除指定key的元素   
}
```

- Map的遍历方式

```dart
main() {       
   Map<String, int> colorMap = {'white': 0xffffffff, 'black':0xff000000};       
   //for-each key-value       
   colorMap.forEach((key, value) => print('color is $key, color value is $value'));   
}
```

- Map.fromIterables将List集合转化成Map

```dart
main() {       
   List<String> colorKeys = ['white', 'black'];       
   List<int> colorValues = [0xffffffff, 0xff000000];       
   Map<String, int> colorMap = Map.fromIterables(colorKeys, colorValues);   
} 
```

### 4、集合常用的操作符

dart对于集合操作的也非常符合现代语言的特点，含有丰富的集合操作符API，可以让你处理结构化的数据更加简单。

```dart
main() {
  List<String> colorList = ['red', 'yellow', 'blue', 'green'];
  //forEach箭头函数遍历
  colorList.forEach((color) => {print(color)});
  colorList.forEach((color) => print(color)); //箭头函数遍历，如果箭头函数内部只有一个表达式可以省略大括号

  //map函数的使用
  print(colorList.map((color) => '$color_font').join(","));

  //every函数的使用，判断里面的元素是否都满足条件，返回值为true/false
  print(colorList.every((color) => color == 'red'));

  //sort函数的使用
  List<int> numbers = [0, 3, 1, 2, 7, 12, 2, 4];
  numbers.sort((num1, num2) => num1 - num2); //升序排序
  numbers.sort((num1, num2) => num2 - num1); //降序排序
  print(numbers);

  //where函数使用，相当于Kotlin中的filter操作符，返回符合条件元素的集合
  print(numbers.where((num) => num > 6));

  //firstWhere函数的使用，相当于Kotlin中的find操作符，返回符合条件的第一个元素，如果没找到返回null
  print(numbers.firstWhere((num) => num == 5, orElse: () => -1)); //注意: 如果没有找到，执行orElse代码块，可返回一个指定的默认值

  //singleWhere函数的使用，返回符合条件的第一个元素，如果没找到返回null，但是前提是集合中只有一个符合条件的元素, 否则就会抛出异常
  print(numbers.singleWhere((num) => num == 4, orElse: () => -1)); //注意: 如果没有找到，执行orElse代码块，可返回一个指定的默认值

  //take(n)、skip(n)函数的使用，take(n)表示取当前集合前n个元素, skip(n)表示跳过前n个元素，然后取剩余所有的元素
  print(numbers.take(5).skip(2));

  //List.from函数的使用，从给定集合中创建一个新的集合,相当于clone一个集合
  print(List.from(numbers));

  //expand函数的使用, 将集合一个元素扩展成多个元素或者将多个元素组成二维数组展开成平铺一个一位数组
  var pair = [
    [1, 2],
    [3, 4]
  ];
  print('flatten list: ${pair.expand((pair) => pair)}');

  var inputs = [1, 2, 3];
  print('duplicated list: ${inputs.expand((number) =>[
    number,
    number,
    number
  ])}');
}
```

## 五、流程控制

### 1、for循环

```dart
main() {
    List<String> colorList = ['red', 'yellow', 'blue', 'green'];
    for (var i = 0; i < colorList.length; i++) {//可以用var或int
        print(colorList[i]);
    }
}
```

### 2、while循环

```dart
main() {
    List<String> colorList = ['red', 'yellow', 'blue', 'green'];
    var index = 0;
    while (index < colorList.length) {
        print(colorList[index++]);
    }
}
```

### 3、do-while循环

```dart
main() {
    List<String> colorList = ['red', 'yellow', 'blue', 'green'];
    var index = 0;
    do {
        print(colorList[index++]);
    } while (index < colorList.length);
}
```

### 4、break和continue

```dart
main() {
    List<String> colorList = ['red', 'yellow', 'blue', 'green'];
    for (var i = 0; i < colorList.length; i++) {//可以用var或int
        if(colorList[i] == 'yellow') {
            continue;
        }
        if(colorList[i] == 'blue') {
            break;
        }
        print(colorList[i]);
    }
}
```

### 5、if-else

```dart
void main() {
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  for (var i = 0; i < numbers.length; i++) {
    if (numbers[i].isEven) {
      print('偶数: ${numbers[i]}');
    } else if (numbers[i].isOdd) {
      print('奇数: ${numbers[i]}');
    } else {
      print('非法数字');
    }
  }
}
```

### 6、三目运算符(? : )

```dart
void main() {
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  for (var i = 0; i < numbers.length; i++) {
      num targetNumber = numbers[i].isEven ? numbers[i] * 2 : numbers[i] + 4;
      print(targetNumber);
  }
}
```

### 7、switch-case语句

```dart
Color getColor(String colorName) {
  Color currentColor = Colors.blue;
  switch (colorName) {
    case "read":
      currentColor = Colors.red;
      break;
    case "blue":
      currentColor = Colors.blue;
      break;
    case "yellow":
      currentColor = Colors.yellow;
      break;
  }
  return currentColor;
}
```

### 8、Assert(断言)

在dart中如果[条件表达式](https://www.zhihu.com/search?q=条件表达式&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})结果不满足条件，则可以使用 `assert` 语句中断代码的执行。特别是在Flutter源码中随处可见都是assert断言的使用。注意: **断言只在检查模式下运行有效，如果在生产模式运行，则断言不会执行。**

```dart
assert(text != null);//text为null,就会中断后续代码执行
assert(urlString.startsWith('https'));
```

## 六、运算符

### 1、[算术运算符](https://www.zhihu.com/search?q=算术运算符&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})

| 名称 | 运算符 | 例子 |

|: --- :|: --- :|: ------------------------ :|

| 加 | + | var result = 1 + 1; |

| 减 | - | var result = 5 - 1; |

| 乘 | * | var result = 3 * 5; |

| 除 | / | var result = 3 / 5; [//0.6](https://link.zhihu.com/?target=https%3A//0.0.0.6/) |

| 整除 | ~/ | var result = 3 ~/ 5; //0 |

| 取余 | % | var result = 5 % 3; //2 |



### 2、[条件运算符](https://www.zhihu.com/search?q=条件运算符&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})

| 名称 | 运算符 | 例子 |

|:----:|:---:|:------:|

| 大于 | > | 2 > 1 |

| 小于 | < | 1 < 2 |

| 等于 | == | 1 == 1 |

| 不等于 | != | 3 != 4 |

| 大于等于 | >= | 5 >= 4 |

| 小于等于 | <= | 4 <= 5 |

### 3、[逻辑运算符](https://www.zhihu.com/search?q=逻辑运算符&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})

| 名称 | 运算符 | 例子 |

|:---:|:----:|:----------------:|

| 或 | \|\| | 2 > 1 \|\| 3 < 1 |

| 与 | && | 2 > 1 && 3 < 1 |

| 非 | ！ | !(2 > 1) |

### 4、位运算符

| 名称 | 运算符 |

|:---:|:---:|

| 位与 | & |

| 位或 | \| |

| 位非 | ~ |

| 异或 | ^ |

| 左移 | << |

| 右移 | >> |

### 5、三目运算符

**condition ? expr1 : expr2**

```dart
var isOpened = (value == 1) ? true : false;
```

### 6、空安全运算符

| 操作符 | 解释 |

|:-----------------------:|:---------------------------------------:|

| result = expr1 ?? expr2 | 若expr1为null, 返回expr2的值，否则返回expr1的值 |

| expr1 ??= expr2 | 若expr1为null, 则把expr2的值赋值给expr1 |

| result = expr1?.value | 若expr1为null, 就返回null,否则就返回expr1.value的值 |

- 1、**result = expr1 ?? expr2**

如果发现expr1为null,就返回expr2的值，否则就返回expr1的值, 这个类似于Kotlin中的 **result = expr1 ?: expr2**

```dart
  main() {
      var choice = question.choice ?? 'A';
      //等价于
      var choice2;
      if(question.choice == null) {
          choice2 = 'A';
      } else {
          choice2 = question.choice;
      }
  }
```



- 2、**expr1 ??= expr2** 等价于 **expr1 = expr1 ?? expr2** (转化成第一种)

```dart
  main() {
      var choice ??= 'A';
      //等价于
      if(choice == null) {
          choice = 'A';
      }
  }
```



- 3、**result = expr1?.value**

如果expr1不为null就返回expr1.value，否则就会返回null, 类似Kotlin中的 ?. 如果expr1不为null,就执行后者

```dart
var choice = question?.choice;   //等价于  
if(question == null){
   return null;   
} else {       
   return question.choice;   
}
question?.commit();   //等价于   
if(question == null){       
   return;//不执行commit()   
} else {       
  question.commit();//执行commit方法  
}   
```



### 7、级联操作符(..)

级联操作符是 `..`, 可以让你对一个对象中字段进行链式调用操作，类似Kotlin中的apply或run标准库函数的使用。

```dart
question
    ..id = '10001'
    ..stem = '第一题: xxxxxx'
    ..choices = <String> ['A','B','C','D']
    ..hint = '听音频做题';
```

Kotlin中的run函数实现对比

```kotlin
question.run {
    id = '10001'
    stem = '第一题: xxxxxx'
    choices = <String> ['A','B','C','D']
    hint = '听音频做题'    
}
```

### 8、运算符重载

在dart支持运算符自定义重载,使用**operator**关键字定义重载函数

```dart
class Vip {
  final int level;
  final int score;

  const Vip(this.level, this.score);

  bool operator >(Vip other) =>
      level > other.level || (level == other.level && score > other.score);

  bool operator <(Vip other) =>
      level < other.level || (level == other.level && score < other.score);

  bool operator ==(Vip other) =>
      level == other.level &&
      score == other.level; //注意: 这段代码可能在高版本的Dart中会报错，在低版本是OK的
  //上述代码，在高版本Dart中，Object中已经重载了==,所以需要加上covariant关键字重写这个重载函数。
  @override
  bool operator ==(covariant Vip other) =>
      (level == other.level && score == other.score);

  @override
  int get hashCode => super.hashCode; //伴随着你还需要重写hashCode，至于什么原因大家应该都知道
}


main() {
    var userVip1 = Vip(4, 3500);
    var userVip2 = Vip(4, 1200);
    if(userVip1 > userVip2) {
        print('userVip1 is super vip');
    } else if(userVip1 < userVip2) {
        print('userVip2 is super vip');
    }
}
```

## 七、异常

dart中的异常捕获方法和Java,Kotlin类似，使用的也是**try-catch-finally**; 对特定异常的捕获使用**on**关键字. dart中的常见异常有: **NoSuchMethodError**(当在一个对象上调用一个该对象没有 实现的函数会抛出该错误)、**ArgumentError** (调用函数的参数不合法会抛出这个错误)

```dart
main() {
  int num = 18;
  int result = 0;
  try {
    result = num ~/ 0;
  } catch (e) {//捕获到IntegerDivisionByZeroException
    print(e.toString());
  } finally {
    print('$result');
  }
}

//使用on关键字捕获特定的异常
main() {
  int num = 18;
  int result = 0;
  try {
    result = num ~/ 0;
  } on IntegerDivisionByZeroException catch (e) {//捕获特定异常
    print(e.toString());
  } finally {
    print('$result');
  }
}
```

## 八、函数

在dart中函数的地位一点都不亚于对象，支持闭包和[高阶函数](https://www.zhihu.com/search?q=高阶函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A88728224})，而且dart中的函数也会比Java要灵活的多，而且Kotlin中的一些函数特性，它也支持甚至比Kotlin支持的更全面。比如支持默认值参数、可选参数、命名参数等.

### 1、函数的基本用法

```dart
main() {
    print('sum is ${sum(2, 5)}');
}

num sum(num a, num b) {
    return a + b;
}
```

### 2、函数参数列表传参规则

```dart
//num a, num b, num c, num d 最普通的传参: 调用时，参数个数和参数顺序必须固定
add1(num a, num b, num c, num d) {
  print(a + b + c + d);
}

//[num a, num b, num c, num d]传参: 调用时，参数个数不固定，但是参数顺序需要一一对应, 不支持命名参数
add2([num a, num b, num c, num d]) {
  print(a + b + c + d);
}

//{num a, num b, num c, num d}传参: 调用时，参数个数不固定，参数顺序也可以不固定，支持命名参数,也叫可选参数，是dart中的一大特性，这就是为啥Flutter代码那么多可选属性，大量使用可选参数
add3({num a, num b, num c, num d}) {
  print(a + b + c + d);
}

//num a, num b, {num c, num d}传参: 调用时，a,b参数个数固定顺序固定，c,d参数个数和顺序也可以不固定
add4(num a, num b, {num c, num d}) {
  print(a + b + c + d);
}

main() {
  add1(100, 100, 100, 100); //最普通的传参: 调用时，参数个数和参数顺序必须固定
  add2(100, 100); //调用时，参数个数不固定，但是参数顺序需要一一对应, 不支持命名参数(也就意味着顺序不变)
  add3(
      b: 200,
      a: 200,
      c: 100,
      d: 100); //调用时，参数个数不固定，参数顺序也可以不固定，支持命名参数(也就意味着顺序可变)
  add4(100, 100, d: 100, c: 100); //调用时，a,b参数个数固定顺序笃定，c,d参数个数和顺序也可以不固定
}
```

### 3、函数默认参数和可选参数(以及与Kotlin对比)

dart中函数的默认值参数和可选参数和Kotlin中默认值参数和命名参数一致，只是写法上不同而已

```dart
add3({num a, num b, num c, num d = 100}) {//d就是默认值参数，给的默认值是100
   print(a + b + c + d);
}

main() {
    add3(b: 200, a: 100, c: 800);
}
```

与Kotlin对比

```kotlin
fun add3(a: Int, b: Int, c: Int, d: Int = 100) {
    println(a + b + c + d)
}

fun main(args: Array<String>) {
    add3(b = 200, a = 100, c = 800)
}
```

### 4、函数类型与高阶函数

在dart函数也是一种类型Function,可以作为函数参数传递，也可以作为返回值。类似Kotlin中的FunctionN系列函数

```dart
main() {
  Function square = (a) {
    return a * a;
  };

  Function square2 = (a) {
    return a * a * a;
  };

  add(3, 4, square, square2)
}

num add(num a, num b, [Function op, Function op2]) {
  //函数作为参数传递
  return op(a) + op2(b);
}
```

### 5、函数的简化以及箭头函数

在dart中的如果在函数体内只有一个表达式，那么就可以使用箭头函数来简化代码，这点也和Kotlin类似，只不过在Kotlin中人家叫lambda表达式，只是写法上不一样而已。

```dart
add4(num a, num b, {num c, num d}) {
  print(a + b + c + d);
}

add5(num a, num b, {num c, num d})  =>  print(a + b + c + d);
```

## 九、面向对象

在dart中一切皆是对象，所以面向对象在Dart中依然举足轻重，下面就先通过一个简单的例子认识下dart的面向对象，后续会继续深入。

### 1、类的基本定义和使用

```dart
abstract class Person {
    String name;
    int age;
    double height;
    Person(this.name, this.age, this.height);//注意，这里写法可能大家没见过， 这点和Java是不一样，这里实际上是一个dart的语法糖。但是这里不如Kotlin，Kotlin是直接把this.name传值的过程都省了。
    //与上述的等价代码,当然这也是Java中必须要写的代码
    Person(String name, int age, double height) {
        this.name = name;
        this.age = age;
        this.height = height;
    }   
    //然而Kotlin很彻底只需要声明属性就行,下面是Kotlin实现代码
    abstract class Person(val name: String, val age: Int, val height: Double)     
}

class Student extends Person {//和Java一样同时使用extends关键字表示继承
    Student(String name, int age, double height, double grade): super(name, age, height);//在 Dart里：类名(变量，变量,...) 是构造函数的写法, :super()表示该构造调用父类，这里构造时传入三个参数
}
```

### 2、类中属性的getter和setter访问器(类似Kotlin)

```dart
abstract class Person {
  String _name; ////相当于kotlin中的var 修饰的变量有setter、getter访问器，在dart中没有访问权限, 默认_下划线开头变量表示私有权限，外部文件无法访问
  final int _age;//相当于kotlin中的val 修饰的变量只有getter访问器
  Person(this._name, this._age); //这是上述简写形式

  //使用set关键字 计算属性 自定义setter访问器
  set name(String name) => _name = name;
  //使用get关键字 计算属性 自定义getter访问器
  bool get isStudent => _age > 18;
}
```



# Dart语法篇之集合的使用与源码解析(二)

[在这蓝色天空下](https://www.jianshu.com/u/34c6a68519b9)

### 一、List

在dart中的List集合是具有长度的可索引对象集合，它没有委托dart:collection包中集合实现，完全由内部自己实现。

初始化

```dart
main() { //初始化一:直接使用[]形式初始化 List colorList1 = ['red', 'yellow', 'blue', 'green'];

//初始化二: var + 泛型
    var colorList2 = <String> ['red', 'yellow', 'blue', 'green'];

    //初始化三: 初始化定长集合
    List<String> colorList3 = List(4);//初始化指定大小为4的集合,
    colorList3.add('deepOrange');//注意: 一旦指定了集合长度，不能再调用add方法，否则会抛出Cannot add to a fixed-length list。也容易理解因为一个定长的集合不能再扩展了。
   print(colorList3[2]);//null,此外初始化4个元素默认都是null

   //初始化四: 初始化空集合且是可变长的
   List<String> colorList4 = List();//相当于List<String> colorList4 =  []
   colorList4[2] = 'white';//这里会报错，[]=实际上就是一个运算符重载，表示修改指定index为2的元素为white，然而它长度为0所以找不到index为2元素，所以会抛出IndexOutOfRangeException
}
```

遍历

```dart
main() {
  List<String> colorList = ['red', 'yellow', 'blue', 'green']; //for-i遍历
  for (var i = 0; i < colorList.length; i++) {
    //可以使用var或int
    print(colorList[i]);
  } //forEach遍历
  colorList.forEach((color) => print(color)); //forEach的参数为Function. =>使用了箭头函数
  //for-in遍历
  for (var color in colorList) {
    print(color);
  }
  //while+iterator迭代器遍历，类似Java中的iteator
  while (colorList.iterator.moveNext()) {
    print(colorList.iterator.current);
  }
}
```

常用的函数

```dart
main() {
  List<String> colorList = ['red', 'yellow', 'blue', 'green'];
  colorList.add('white');
//和Kotlin类似通过add添加一个新的元素
  List<String> newColorList = ['white', 'black'];
  colorList.addAll(newColorList); //addAll添加批量元素
  print(colorList[2]); //可以类似Kotlin一样，直接使用数组下标形式访问元素
  print(colorList.length); //获取集合的长度，这个Kotlin不一样，Kotlin中使用的是size
  colorList.insert(1, 'black'); //在集合指定index位置插入指定的元素
  colorList.removeAt(2); //移除集合指定的index=2的元素，第3个元素
  colorList.clear(); //清除所有元素
  print(colorList.sublist(1, 3)); //截取子集合
  print(colorList.getRange(1, 3)); //获取集合中某个范围元素
  print(colorList.join(
      '<--->')); //类似Kotlin中的joinToString方法，输出: red<--->yellow<--->blue<--->green
  print(colorList.isEmpty);
  print(colorList.contains('green'));
}
```

构造函数源码分析
dart中的List有很多个构造器，一个主构造器和多个命名构造器。主构造器中有个length可选参数.

```dart
external factory List([int length]);//主构造器，传入length可选参数，默认为0

external factory List.filled(int length, E fill, {bool growable = false});//filled命名构造器，只能声明定长的数组

external factory List.from(Iterable elements, {bool growable = true});

factory List.of(Iterable elements, {bool growable = true}) => List.from(elements, growable: growable);//委托给List.from构造器来实现

external factory List.unmodifiable(Iterable elements);
```

exteranl关键字(插播一条内容)

> 注意: 问题来了，可能大家看到List源码的时候一脸懵逼，构造函数没有具体的实现。不知道有没有注意 到exteranl 关键字。external修饰的函数具有一种实现函数声明和实现体分离的特性。这下应该就明白了，也就是对应实现在别的地方。实际上你可以在DartSDK中的源码找到，以List举例，对应的是 sdk/sdk_nnbd/lib/_internal/vm/lib/array_patch.dart, 此外对应的external函数实现会有一个 @patch注解 修饰.



```dart
@patch
class List<E> {
  //对应的是List主构造函数的实现
  @patch
  factory List([int length]) native "List_new";//实际上这里是通过native层的c++数组来实现，具体可参考runtime/lib/array.cc

 //对应的是List.filled构造函数的实现,fill是需要填充元素值, 默认growable是false，默认不具有扩展功能
  @patch
  factory List.filled(int length, E fill, {bool growable: false}) {
    var result = growable ? new _GrowableList<E>(length) : new _List<E>(length);//可以看到如果是可变长，就会创建一个_GrowableList，否则就创建内部私有的_List
    if (fill != null) {//fill填充元素值不为null,就返回length长度填充值为fill的集合
      for (int i = 0; i < length; i++) {
        result[i] = fill;
      }
    }
    return result;//否则直接返回相应长度的空集合
  }

 //对应的是List.from构造函数的实现,可将Iterable的集合加入到一个新的集合中，默认growable是true,默认具备扩展功能
  @patch
  factory List.from(Iterable elements, {bool growable: true}) {
    if (elements is EfficientLengthIterable<E>) {
      int length = elements.length;
      var list = growable ? new _GrowableList<E>(length) : new _List<E>(length);//如果是可变长，就会创建一个_GrowableList，否则就创建内部私有的_List
      if (length > 0) {
        //只有在必要情况下创建iterator
        int i = 0;
        for (var element in elements) {
          list[i++] = element;
        }
      }
      return list;
    }
    //如果elements是一个Iterable<E>,就不需要为每个元素做类型测试
    //因为在一般情况下，如果elements是Iterable<E>，在开始循环之前会用单个类型测试替换其中每个元素的类型测试。但是注意下: 等等，我发现下面这段源码好像有点问题，难道是我眼神不好，if和else内部执行代码一样。    
    if (elements is Iterable<E>) {
      //创建一个_GrowableList
      List<E> list = new _GrowableList<E>(0);
      //遍历elements将每个元素重新加入到_GrowableList中
      for (E e in elements) {
        list.add(e);
      }
      //如果是可变长的直接返回这个list即可
      if (growable) return list;
      //否则调用makeListFixedLength使得集合变为定长集合,实际上调用native层的c++实现
      return makeListFixedLength(list);
    } else {
      List<E> list = new _GrowableList<E>(0);
      for (E e in elements) {
        list.add(e);
      }
      if (growable) return list;
      return makeListFixedLength(list);
    }
  }

  //对应的是List.unmodifiable构造函数的实现
  @patch
  factory List.unmodifiable(Iterable elements) {
    final result = new List<E>.from(elements, growable: false);
    //这里利用了List.from构造函数创建一个定长的集合result
    return makeFixedListUnmodifiable(result);
  }
  ...
}
```

对应的List.from sdk的源码解析

```php
//sdk/lib/_internal/vm/lib/internal_patch.dart中的makeListFixedLength
@patch
List<T> makeListFixedLength<T>(List<T> growableList)
 native "Internal_makeListFixedLength";

//runtime/lib/growable_array.cc 中的Internal_makeListFixedLength
DEFINE_NATIVE_ENTRY(Internal_makeListFixedLength, 0, 1) {
 GET_NON_NULL_NATIVE_ARGUMENT(GrowableObjectArray, array,
 arguments->NativeArgAt(0));
 return Array::MakeFixedLength(array, /* unique = */ true);//调用Array::MakeFixedLength C++方法变为定长集合
}

//runtime/vm/object.cc中的Array::MakeFixedLength 返回一个RawArray
RawArray* Array::MakeFixedLength(const GrowableObjectArray& growable_array, bool unique) {

 ASSERT(!growable_array.IsNull());
 Thread* thread = Thread::Current();
 Zone* zone = thread->zone();
 intptr_t used_len = growable_array.Length();
 //拿到泛型类型参数，然后准备复制它们
 const TypeArguments& type_arguments =
 TypeArguments::Handle(growable_array.GetTypeArguments());

 //如果集合为空
 if (used_len == 0) {
 //如果type_arguments是空，那么它就是一个原生List，不带泛型类型参数的
    if (type_arguments.IsNull() && !unique) {
     //这是一个原生List(没有泛型类型参数)集合并且是非unique，直接返回空数组
         return Object::empty_array().raw();
    }
 // 根据传入List的泛型类型参数，创建一个新的空的数组
    Heap::Space space = thread->IsMutatorThread() ? Heap::kNew : Heap::kOld;//如果是MutatorThread就开辟新的内存空间否则复用旧的
    Array& array = Array::Handle(zone, Array::New(0, space));//创建一个新的空数组array
    array.SetTypeArguments(type_arguments);//设置拿到的类型参数
    return array.raw();//返回一个相同泛型参数的新数组
 }

 //如果集合不为空，取出growable_array中的data数组，且返回一个带数据新的数组array
 const Array& array = Array::Handle(zone, growable_array.data());
    ASSERT(array.IsArray());
    array.SetTypeArguments(type_arguments);//设置拿到的类型参数
    //这里主要是回收原来的growable_array,数组长度置为0，内部data数组置为空数组
    growable_array.SetLength(0);
    growable_array.SetData(Object::empty_array());
    //注意: 定长数组实现的关键点来了，会调用Truncate方法将array截断used_len长度
    array.Truncate(used_len);
    return array.raw();//最后返回array.raw()
}
```

- 总结一下

List.from的源码实现，首先传入elements的Iterate<E>, 如果elements不带泛型参数，也就是所谓的原生集合类型，并且是非unique，直接返回空数组; 如果带泛型参数空集合，那么会创建新的空集合并带上原来泛型参数返回；如果是带泛型参数非空集合，会取出其中data数组，来创建一个新的复制原来数据的集合并带上原来泛型参数返回，最后需要截断把数组截断成原始数组长度。

- 为什么需要exteranl function

关键就是在于它能实现声明和实现分离，这样就能复用同一套对外API的声明，然后对应多套多平台的实现，如果对源码感兴趣的小伙伴就会发现相同API声明在js中也有另一套实现，这样不管是dart for web 还是dart for vm对于上层开发而言都是一套API，对于上层开发者是透明的。

### 二、Set

dart:core包中的Set集合实际上是委托到dart:collection中的LinkedHashSet来实现的。集合Set和列表List的区别在于 集合中的元素是不能重复 的。所以添加重复的元素时会返回false,表示添加不成功.

- Set初始化方式

```dart
main() {
  Set<String> colorSet = {'red', 'yellow', 'blue', 'green'}; //直接使用{}形式初始化
  var colorList = <String>{'red', 'yellow', 'blue', 'green'};
}
```

- 集合中的交、并、补集，在Kotlin并没有直接给到计算集合交、并、补的API

```bash
main() {
  var colorSet1 = {'red', 'yellow', 'blue', 'green'};
  var colorSet2 = {'black', 'yellow', 'blue', 'green', 'white'};
  print(
      colorSet1.intersection(colorSet2)); //交集-->输出: {'yellow', 'blue', 'green'}
  print(colorSet1.union(
      colorSet2)); //并集--->输出: {'black', 'red', 'yellow', 'blue', 'green', 'white'}
  print(colorSet1.difference(colorSet2)); //补集--->输出: {'red'}
}
```

- Set的遍历方式(和List一样)

```dart
main() {
  Set<String> colorSet = {'red', 'yellow', 'blue', 'green'};
//for-i遍历
  for (var i = 0; i < colorSet.length; i++) {
    //可以使用var或int
    print(colorSet[i]);
  }
  //forEach遍历
  colorSet.forEach((color) => print(color)); //forEach的参数为Function. =>使用了箭头函数
  //for-in遍历
  for (var color in colorSet) {
    print(color);
  }
  //while+iterator迭代器遍历，类似Java中的iteator
  while (colorSet.iterator.moveNext()) {
    print(colorSet.iterator.current);
  }
}
```

- 构造函数源码分析

```dart
    //主构造器委托到LinkedHashSet主构造器 
    factory Set() = LinkedHashSet<E>; 
    //Set的命名构造器identity委托给LinkedHashSet的identity
    factory Set.identity() = LinkedHashSet<E>.identity; 
    //Set的命名构造器from委托给LinkedHashSet的from 
    factory Set.from(Iterable elements) = LinkedHashSet<E>.from;
    //Set的命名构造器of委托给LinkedHashSet的of
    factory Set.of(Iterable<E> elements) = LinkedHashSet<E>.of;
```

- 对应LinkedHashSet的源码分析,篇幅有限感兴趣可以去深入研究

```dart
 abstract class LinkedHashSet implements Set { 
  //LinkedHashSet主构造器声明带了三个函数类型参数作为可选参数,同样是通过exteranl实现声明和实现分离，要深入可找到对应的@Patch实现
 external factory LinkedHashSet( {bool equals(E e1, E e2), int hashCode(E e), bool isValidKey(potentialKey)});

//LinkedHashSet命名构造器from   
factory LinkedHashSet.from(Iterable elements) {
  //内部直接创建一个LinkedHashSet对象
  LinkedHashSet<E> result = LinkedHashSet<E>();
  //并将传入elements元素遍历加入到LinkedHashSet中
  for (final element in elements) {
    result.add(element);
  }
  return result;
}

//LinkedHashSet命名构造器of，首先创建一个LinkedHashSet对象，通过级联操作直接通过addAll方法将元素加入到elements
factory LinkedHashSet.of(Iterable<E> elements) =>
    LinkedHashSet<E>()..addAll(elements);

void forEach(void action(E element));

Iterator<E> get iterator;
} 
```

- 对应的 sdk/lib/_internal/vm/lib/collection_patch.dart 中的@Patch LinkedHashSet

```csharp
@patch 
class LinkedHashSet { 
  @patch 
  factory LinkedHashSet( {bool equals(E e1, E e2), int hashCode(E e), bool isValidKey(potentialKey)}) {
    if (isValidKey == null) { 
        if (hashCode == null) {
          if (equals == null) { 
            return new _CompactLinkedHashSet(); //可选参数都为null,默认创建_CompactLinkedHashSet
          } 
          hashCode = _defaultHashCode; 
        } else { 
          if (identical(identityHashCode, hashCode) && identical(identical, equals)) { 
            return new _CompactLinkedIdentityHashSet();//创建_CompactLinkedIdentityHashSet 
          }
          equals ??= _defaultEquals; 
        }
      } else { 
        hashCode ??= _defaultHashCode;
        equals ??= _defaultEquals; 
      } 
    return new _CompactLinkedCustomHashSet(equals, hashCode, isValidKey);//可选参数identical,默认创建_CompactLinkedCustomHashSet 
  }

  @patch
  factory LinkedHashSet.identity() => new _CompactLinkedIdentityHashSet<E>();
} 
```

### 三、Map

dart:core 包中的 Map集合 实际上是 委托到dart:collection中的LinkedHashMap 来实现的。集合Map和Kotlin类似，key-value形式存储，并且 Map对象的中key是不能重复的

- Map初始化方式

```dart
main() {
  Map<String, int> colorMap = {
    'white': 0xffffffff,
    'black': 0xff000000
  }; //使用{key:value}形式初始化
  var colorMap = <String, int>{'white': 0xffffffff, 'black': 0xff000000};
  var colorMap = Map<String, int>(); //创建一个空的Map集合
//实际上等价于下面代码，后面会通过源码说明
  var colorMap = LinkedHashMap<String, int>();
}
```

- Map中常用的函数

```dart
main() {
  Map<String, int> colorMap = {'white': 0xffffffff, 'black': 0xff000000};
  print(colorMap.containsKey('green')); //false
  print(colorMap.containsValue(0xff000000)); //true
  print(colorMap.keys.toList()); //['white','black']
  print(colorMap.values.toList()); //[0xffffffff, 0xff000000]
  colorMap['white'] = 0xfffff000; //修改指定key的元素
  colorMap.remove('black'); //移除指定key的元素
}
```

- Map的遍历方式

```dart
main() {
  Map<String, int> colorMap = {'white': 0xffffffff, 'black': 0xff000000};
//for-each key-value
  colorMap
      .forEach((key, value) => print('color is $key, color value is $value'));
}
```

- Map.fromIterables将List集合转化成Map

```dart
main() {
  List<String> colorKeys = ['white', 'black'];
  List<int> colorValues = [0xffffffff, 0xff000000];
  Map<String, int> colorMap = Map.fromIterables(colorKeys, colorValues);
}
```

- 构造函数源码分析

```dart
external factory Map(); //主构造器交由外部@Patch实现, 实际上对应的@Patch实现还是委托给LinkedHashMap

factory Map.from(Map other) = LinkedHashMap.from;//Map的命名构造器from委托给LinkedHashMap的from

factory Map.of(Map other) = LinkedHashMap.of;//Map的命名构造器of委托给LinkedHashMap的of

external factory Map.unmodifiable(Map other);//unmodifiable构造器交由外部@Patch实现

factory Map.identity() = LinkedHashMap.identity;//Map的命名构造器identity交由外部@Patch实现

factory Map.fromIterable(Iterable iterable, {K key(element), V value(element)}) = LinkedHashMap.fromIterable;//Map的命名构造器fromIterable委托给LinkedHashMap的fromIterable

factory Map.fromIterables(Iterable keys, Iterable values) = LinkedHashMap.fromIterables;//Map的命名构造器fromIterables委托给LinkedHashMap的fromIterables
```

- 对应LinkedHashMap构造函数源码分析

```dart
abstract class LinkedHashMap implements Map { //主构造器交由外部@Patch实现 external factory LinkedHashMap( {bool equals(K key1, K key2), int hashCode(K key), bool isValidKey(potentialKey)});

//LinkedHashMap命名构造器identity交由外部@Patch实现
external factory LinkedHashMap.identity();

//LinkedHashMap的命名构造器from
factory LinkedHashMap.from(Map other) {
  //创建一个新的LinkedHashMap对象
  LinkedHashMap<K, V> result = LinkedHashMap<K, V>();
  //遍历other中的元素，并添加到新的LinkedHashMap对象
  other.forEach((k, v) {
    result[k] = v;
  });
  return result;
}

//LinkedHashMap的命名构造器of,创建一个新的LinkedHashMap对象，通过级联操作符调用addAll批量添加map到新的LinkedHashMap中
factory LinkedHashMap.of(Map<K, V> other) =>
    LinkedHashMap<K, V>()..addAll(other);

//LinkedHashMap的命名构造器fromIterable，传入的参数是iterable对象、key函数参数、value函数参数两个可选参数
factory LinkedHashMap.fromIterable(Iterable iterable,
    {K key(element), V value(element)}) {
  //创建新的LinkedHashMap对象，通过MapBase中的static方法_fillMapWithMappedIterable，给新的map添加元素  
  LinkedHashMap<K, V> map = LinkedHashMap<K, V>();
  MapBase._fillMapWithMappedIterable(map, iterable, key, value);
  return map;
}

//LinkedHashMap的命名构造器fromIterables
factory LinkedHashMap.fromIterables(Iterable<K> keys, Iterable<V> values) {
//创建新的LinkedHashMap对象，通过MapBase中的static方法_fillMapWithIterables，给新的map添加元素
  LinkedHashMap<K, V> map = LinkedHashMap<K, V>();
  MapBase._fillMapWithIterables(map, keys, values);
  return map;
}
}

//MapBase中的_fillMapWithMappedIterable
static void _fillMapWithMappedIterable( Map map, Iterable iterable, key(element), value(element)) { key ??= _id; value ??= _id;

for (var element in iterable) {//遍历iterable，给map对应复制
    map[key(element)] = value(element);
  }
}

// MapBase中的_fillMapWithIterables static void _fillMapWithIterables(Map map, Iterable keys, Iterable values) { Iterator keyIterator = keys.iterator;//拿到keys的iterator Iterator valueIterator = values.iterator;//拿到values的iterator

bool hasNextKey = keyIterator.moveNext();//是否有NextKey
  bool hasNextValue = valueIterator.moveNext();//是否有NextValue

  while (hasNextKey && hasNextValue) {//同时遍历迭代keys，values
    map[keyIterator.current] = valueIterator.current;
    hasNextKey = keyIterator.moveNext();
    hasNextValue = valueIterator.moveNext();
  }

  if (hasNextKey || hasNextValue) {//最后如果其中只要有一个为true,说明key与value的长度不一致，抛出异常
    throw ArgumentError("Iterables do not have same length.");
  }
}
```

- Map的@Patch对应实现，对应 sdk/lib/_internal/vm/lib/map_patch.dart 中

```dart
@patch 
class Map {
  @patch
  factory Map.unmodifiable(Map other) {
    return new UnmodifiableMapView(new Map.from(other));
  }

  @patch
  factory Map() => new LinkedHashMap<K, V>();
 //可以看到Map的创建实际上最终还是对应创建了LinkedHashMap<K, V>
}
```

### 四、Queue

Queue队列顾名思义先进先出的一种数据结构，在Dart对队列也做了一定的支持, 实际上Queue的实现是委托给ListQueue来实现。 Queue继承于EfficientLengthIterable<E>接口，然后EfficientLengthIterable<E>接口又继承了Iterable<E>.所以意味着Queue可以向List那样使用丰富的操作函数。并且由Queue派生出了 DoubleLinkedQueue和ListQueue

- 初始化

```csharp
import 'dart:collection'; //注意: Queue位于dart:collection包中需要导包

main() {
  //通过主构造器初始化
  var queueColors = Queue();
  queueColors.addFirst('red');
  queueColors.addLast('yellow');
  queueColors.add('blue');

  //通过from命名构造器初始化
  var queueColors2 = Queue.from(['red', 'yellow', 'blue']);
  //通过of命名构造器初始化
  var queueColors3 = Queue.of(['red', 'yellow', 'blue']);
}
```

- 常用的函数

```csharp
import 'dart:collection'; //注意: Queue位于dart:collection包中需要导包

main() {
  var queueColors = Queue()
    ..addFirst('red')
    ..addLast('yellow')
    ..add('blue')
    ..addAll(['white', 'black'])
    ..remove('black')
    ..clear();
}
```

- 遍历

```dart
import 'dart:collection'; //注意: Queue位于dart:collection包中需要导包

main() {
  Queue colorQueue = Queue.from(['red', 'yellow', 'blue', 'green']);
//for-i遍历
  for (var i = 0; i < colorQueue.length; i++) {
    //可以使用var或int
    print(colorQueue.elementAt(i));
    //注意: 获取队列中的元素不用使用colorQueue[i], 因为Queue内部并没有去实现[]运算符重载
  }
  //forEach遍历
  colorQueue.forEach((color) => print(color));
  //forEach的参数为Function. =>使用了箭头函数
  //for-in遍历
  for (var color in colorQueue) {
    print(color);
  }
}
```

- 构造函数源码分析

```dart
factory Queue() = ListQueue;//委托给ListQueue主构造器

factory Queue.from(Iterable elements) = ListQueue<E>.from;//委托给ListQueue<E>的命名构造器from

factory Queue.of(Iterable<E> elements) = ListQueue<E>.of;//委托给ListQueue<E>的命名构造器of
```

- 对应的ListQueue的源码分析

```dart
class ListQueue extends ListIterable implements Queue { 
  static const int _INITIAL_CAPACITY = 8;//默认队列的初始化容量是8 
  List _table; 
  int _head; 
  int _tail; 
  int _modificationCount = 0;

  ListQueue([int? initialCapacity])
    : _head = 0,
      _tail = 0,
      _table = List<E?>(_calculateCapacity(initialCapacity));
//有趣的是可以看到ListQueque内部实现是一个List<E?>集合, E?还是一个泛型类型为可空类型，但是目前dart的可空类型特性还在实验中，不过可以看到它的源码中已经用起来了。

//计算队列所需要容量大小
static int _calculateCapacity(int? initialCapacity) {
  //如果initialCapacity为null或者指定的初始化容量小于默认的容量就是用默认的容量大小
  if (initialCapacity == null || initialCapacity < _INITIAL_CAPACITY) {

    return _INITIAL_CAPACITY;
  } else if (!_isPowerOf2(initialCapacity)) {//容量大小不是2次幂
    return _nextPowerOf2(initialCapacity);//找到大小是接近number的2次幂的数
  }
  assert(_isPowerOf2(initialCapacity));//断言检查
  return initialCapacity;//最终返回initialCapacity,返回的容量大小一定是2次幂的数
}

//判断容量大小是否是2次幂
static bool _isPowerOf2(int number) => (number & (number - 1)) == 0;

//找到大小是接近number的二次幂的数
static int _nextPowerOf2(int number) {
  assert(number > 0);
  number = (number << 1) - 1;
  for (;;) {
    int nextNumber = number & (number - 1);
    if (nextNumber == 0) return number;
    number = nextNumber;
  }
}

//ListQueue的命名构造函数from
factory ListQueue.from(Iterable<dynamic> elements) {
  //判断elements 是否是List<dynamic>类型
  if (elements is List<dynamic>) {
    int length = elements.length;//取出长度
    ListQueue<E> queue = ListQueue<E>(length + 1);//创建length + 1长度的ListQueue
    assert(queue._table.length > length);//必须保证新创建的queue的长度大于传入elements的长度
    for (int i = 0; i < length; i++) {
      queue._table[i] = elements[i] as E;//然后就是给新queue中的元素赋值，注意需要强转成泛型类型E
    }
    queue._tail = length;//最终移动队列的tail尾部下标，因为可能存在实际长度大于实际元素长度
    return queue;
  } else {
    int capacity = _INITIAL_CAPACITY;
    if (elements is EfficientLengthIterable) {//如果是EfficientLengthIterable类型，就将elements长度作为初始容量不是就使用默认容量
      capacity = elements.length;
    }
    ListQueue<E> result = ListQueue<E>(capacity);
    for (final element in elements) {
      result.addLast(element as E);//通过addLast从队列尾部插入
    }
    return result;//最终返回result
  }
}

//ListQueue的命名构造函数of
factory ListQueue.of(Iterable<E> elements) =>
    ListQueue<E>()..addAll(elements); //直接创建ListQueue<E>()并通过addAll把elements加入到新的ListQueue中
...
} 
```

### 五、LinkedList

在dart中LinkedList比较特殊，它不是一个带泛型集合，因为它泛型类型上界是LinkedListEntry, 内部的数据结构实现是一个双链表，链表的结点是LinkedListEntry的子类，且内部维护了_next和_previous指针。此外它并没有实现List接口

- 初始化

```dart
import 'dart:collection'; //注意: LinkedList位于dart:collection包中需要导包 
main() { 
  var linkedList = LinkedList>(); 
  var prevLinkedEntry = LinkedListEntryImpl(99); 
  var currentLinkedEntry = LinkedListEntryImpl(100); 
  var nextLinkedEntry = LinkedListEntryImpl(101); 
  linkedList.add(currentLinkedEntry); 
  currentLinkedEntry.insertBefore(prevLinkedEntry);//在当前结点前插入一个新的结点 
  currentLinkedEntry.insertAfter(nextLinkedEntry);//在当前结点后插入一个新的结点 
  linkedList.forEach((entry) => print('${entry.value}'));
}

//需要定义一个LinkedListEntry子类 
class LinkedListEntryImpl extends LinkedListEntry> { 
  final T value;

  LinkedListEntryImpl(this.value);

  @override
  String toString() {
    return "value is $value";
  }
}
```

- 常用的函数

```cpp
    currentLinkedEntry.insertBefore(prevLinkedEntry);//在当前结点前插入一个新的结点 
    currentLinkedEntry.insertAfter(nextLinkedEntry);//在当前结点后插入一个新的结点 
    currentLinkedEntry.previous;//获取当前结点的前一个结点 
    currentLinkedEntry.next;//获取当前结点的后一个结点 
    currentLinkedEntry.list;//获取LinkedList 
    currentLinkedEntry.unlink();//把当前结点entry从LinkedList中删掉
```

- 遍历

```dart
  //forEach迭代 
  linkedList.forEach((entry) => print('${entry.value}')); 
  //for-i迭代 
  for (var i = 0; i < linkedList.length; i++) { 
    print('${linkedList.elementAt(i).value}'); 
  } 
  //for-in迭代 
  for (var element in linkedList) { 
    print('${element.value}'); 
  }
```

### 六、HashMap

- 初始化

```dart
import 'dart:collection'; //注意: HashMap位于dart:collection包中需要导包

main() {
  var hashMap = HashMap(); //通过HashMap主构造器初始化
  hashMap['a'] = 1;
  hashMap['b'] = 2;
  hashMap['c'] = 3;
  var hashMap2 = HashMap.from(hashMap); //通过HashMap命名构造器from初始化
  var hashMap3 = HashMap.of(hashMap); //通过HashMap命名构造器of初始化
  var keys = ['a', 'b', 'c'];
  var values = [1, 2, 3];
  var hashMap4 =
      HashMap.fromIterables(keys, values); //通过HashMap命名构造器fromIterables初始化

  hashMap2.forEach((key, value) => print('key: $key  value: $value'));
}
```

- 常用的函数

```dart
import 'dart:collection'; //注意: HashMap位于dart:collection包中需要导包

main() {
  var hashMap = HashMap(); //通过HashMap主构造器初始化
  hashMap['a'] = 1;
  hashMap['b'] = 2;
  hashMap['c'] = 3;
  print(hashMap.containsKey('a')); //false
  print(hashMap.containsValue(2)); //true
  print(hashMap.keys.toList()); //['a','b','c']
  print(hashMap.values.toList()); //[1, 2, 3]
  hashMap['a'] = 55; //修改指定key的元素
  hashMap.remove('b'); //移除指定key的元素
}
```

- 遍历

```dart
import 'dart:collection'; //注意: HashMap位于dart:collection包中需要导包

main() {
  var hashMap = HashMap(); //通过HashMap主构造器初始化
  hashMap['a'] = 1;
  hashMap['b'] = 2;
  hashMap['c'] = 3;
  //for-each key-value
  hashMap.forEach((key, value) => print('key is $key, value is $value'));
}
```

- 构造函数源码分析

```dart
  //主构造器交由外部@Patch实现 external 
  factory HashMap( {bool equals(K key1, K key2), int hashCode(K key), bool isValidKey(potentialKey)});

  //HashMap命名构造器identity交由外部@Patch实现 
  external factory HashMap.identity();

  //HashMap命名构造器from 
  factory HashMap.from(Map other) { 
    //创建一个HashMap对象 
    Map result = HashMap(); 
    //遍历other集合并把元素赋值给新的HashMap对象 
    other.forEach((k, v) { 
      result[k] = v; 
    }); 
    return result; 
  }

  //HashMap命名构造器of，把other添加到新创建HashMap对象 
  factory HashMap.of(Map other) => HashMap()..addAll(other);

  //HashMap命名构造器fromIterable 
  factory HashMap.fromIterable(Iterable iterable, {K key(element), V value(element)}) { Map map = HashMap();//创建一个新的HashMap对象 MapBase._fillMapWithMappedIterable(map, iterable, key, value);//通过MapBase中的_fillMapWithMappedIterable赋值给新的HashMap对象 return map; }

  //HashMap命名构造器fromIterables 
  factory HashMap.fromIterables(Iterable keys, Iterable values) { Map map = HashMap();//创建一个新的HashMap对象 MapBase._fillMapWithIterables(map, keys, values);//通过MapBase中的_fillMapWithIterables赋值给新的HashMap对象 return map; }
```

- HashMap对应的@Patch源码实现,sdk/lib/_internal/vm/lib/collection_patch.dart

```csharp
@patch 
class HashMap { 
  @patch 
  factory HashMap( {bool equals(K key1, K key2), int hashCode(K key), bool isValidKey(potentialKey)}) { 
    if (isValidKey == null) { 
      if (hashCode == null) { 
        if (equals == null) { 
          return new _HashMap();//创建私有的_HashMap对象 
        } 
        hashCode = _defaultHashCode; 
      } else { 
        if (identical(identityHashCode, hashCode) && identical(identical, equals)) {
          return new _IdentityHashMap();//创建私有的_IdentityHashMap对象 
        } 
        equals ??= _defaultEquals; 
      } 
    } else { 
      hashCode ??= _defaultHashCode; 
      equals ??= _defaultEquals; 
    } 
    return new _CustomHashMap(equals, hashCode, isValidKey);//创建私有的_CustomHashMap对象 
  }

  @patch
  factory HashMap.identity() => new _IdentityHashMap<K, V>();

  Set<K> _newKeySet();
} 
```

### 七、Map、HashMap、LinkedHashMap、SplayTreeMap区别

在Dart中还有一个SplayTreeMap，它的初始化、常用的函数和遍历方式和LinkedHashMap、HashMap使用类似。但是Map、HashMap、LinkedHashMap、SplayTreeMap有什么区别呢。

- Map
  Map是key-value键值对集合。在Dart中的Map中的每个条目都可以迭代的。迭代顺序取决于HashMap，LinkedHashMap或SplayTreeMap的实现。如果您使用Map构造函数创建实例，则默认情况下会创建一个LinkedHashMap。
- HashMap
  HashMap不保证插入顺序。如果先插入key为A的元素，然后再插入具有key为B的另一个元素，则在遍历Map时，有可能先获得元素B。
- LinkedHashMap
  LinkedHashMap保证插入顺序。根据插入顺序对存储在LinkedHashMap中的数据进行排序。如果先插入key为A的元素，然后再插入具有key为B的另一个元素，则在遍历Map时，总是先取的key为A的元素，然后再取的key为B的元素。
- SplayTreeMap
  SplayTreeMap是一个自平衡二叉树，它允许更快地访问最近访问的元素。基本操作如插入，查找和删除可以在O（log（n））时间复杂度中完成。它通过使经常访问的元素靠近树的根来执行树的旋转。因此，如果需要更频繁地访问某些元素，则使用SplayTreeMap是一个不错的选择。但是，如果所有元素的数据访问频率几乎相同，则使用SplayTreeMap是没有用的。

### 八、命名构造函数from和of的区别以及使用建议

通过上述各个集合源码可以看到，基本上每个集合(List、Set、LinkedHashSet、LinkedHashMap、Map、HashMap等)中都有from和of命名构造函数。可能有的人有疑问了，它们有什么区别，各自的应用场景呢。其实答案从源码中就看出一点了。以List,Map中的from和of为例。

```php
main() {
  var map = {'a': 1, 'b': 2, 'c': 3};
  var fromMap = Map.from(map); //返回类型是Map<dynamic, dynamic>
  var ofMap = Map.of(map); //返回类型是Map<String, int>

  var list = [1, 2, 3, 4];
  var fromList = List.from(list); //返回类型是List<dynamic>
  var ofList = List.of(list); //返回类型是List<int>
}
```

从上述例子可以看出List、Map中的from函数返回对应的集合泛型类型是 List<dynamic> 和 Map<dynamic, dynamic> 而of函数返回对应集合泛型类型实际类型是 List<int> 和 Map<String, int>。我们都知道dynamic是一种无法确定的类型，在编译期不检查类型，只在运行器检查类型，而具体类型是在编译期检查类型。而且从源码中可以看到 from函数往往会处理比较复杂逻辑比如需要重新遍历传入的集合然后把元素加入到新的集合中，而of函数只需要创建一个新的对象通过addAll函数批量添加传入的集合元素。

所以这里为了代码效率考虑给出建议是: 如果你传入的原有集合元素类型是确定的，请尽量使用of函数创建新的集合，否则就可以考虑使用from函数。



# Dart语法篇之集合操作符函数与源码分析(三)

在上一篇文章中，我们全面地分析了常用集合的使用以及集合部分源码的分析。那么这一节讲点更实用的内容，绝对可以提高你的Flutter开发效率的函数，那就是集合中常用的操作符函数。这次说的内容的比较简单就是怎么用，以及源码内部是怎么实现的。

## 一、`Iterable<E>`

在dart中几乎所有集合拥有的[操作符函数](https://www.zhihu.com/search?q=操作符函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90373910})(例如: map、every、where、reduce等)都是因为继承或者实现了`Iterable`。

### 1、Iterable类关系图



![img](https://pic4.zhimg.com/80/v2-f4d993a98e54d8f8d68995bb5f4d083b_720w.jpg)



### 2、Iterable类方法图



![img](https://pic4.zhimg.com/80/v2-bc49466367706b10fbd7c66a3319cdd7_720w.jpg)



## 二、forEach

### 1、介绍

```dart
void forEach(void f(E element))
```

forEach在dart中用于**遍历和迭代集合**，也是dart中操作集合最常用的方法之一。接收一个`f(E element)`函数作为参数，返回值类型为空void.

### 2、使用方式

```dart
main() {
  var languages = <String>['Dart', 'Kotlin', 'Java', 'Javascript', 'Go', 'Python', 'Swift'];
  languages.forEach((language) => print('The language is $language'));//由于只有一个表达式，所以可以直接使用箭头函数。
  languages.forEach((language){
     if(language == 'Dart' || language == 'Kotlin') {
         print('My favorite language is $language');
     } 
  });
}
```

### 3、源码解析

```dart
void forEach(void f(E element)) {
    //可以看到在forEach内部实际上就是利用for-in迭代，每迭代一次就执行一次f函数，
    //并把当前element回调出去
    for (E element in this) f(element);
  }
```

## 三、map

### 1、介绍

```dart
Iterable<T> map<T>(T f(E e))
```

map函数主要用于**集合中元素的映射**，也可以映射转化成其他类型的元素。可以看到map接收一个`T f(E e)`函数作为参数，最后返回一个泛型参数为`T`的`Iterable`。实际上是返回了带有元素的一个新的**惰性`Iterable`**, 然后通过迭代的时候，对每个元素都调用`f`函数。注意: `f`函数是一个接收泛型参数为`E`的元素,然后返回一个泛型参数为`T`的元素，这就是map可以将原集合中每个元素映射成其他类型元素的原因。

### 2、使用方式

```dart
main() {
  var languages = <String>['Dart', 'Kotlin', 'Java', 'Javascript', 'Go', 'Python', 'Swift'];
  print(languages.map((language) => 'develop language is ${language}').join('---'));    
}
```

### 3、源码解析

以上面的例子为例， * 1、首先，需要明确一点，`languages`内部本质是一个`_GrowableList<T>`, 我们都知道`_GrowableList<T>`是继承了`ListBase<T>`,然后`ListBase<E>`又mixin with `ListMixin<E>`.所以`languages.map`函数调用就是调用`ListMixin<E>`中的map函数，实际上还是相当于调用了自身的成员函数map.



![img](https://pic3.zhimg.com/80/v2-bac1581d83ed5103b13c4f4f307932ee_720w.jpg)



```dart
@pragma("vm:entry-point")
class _GrowableList<T> extends ListBase<T> {//_GrowableList<T>是继承了ListBase<T>
    ...
}

abstract class ListBase<E> extends Object with ListMixin<E> {//ListBase mixin with ListMixin<E>
    ...
}
```

- 2、然后可以看到`ListMixin<E>`实际上实现了`List<E>`,然后`List<E>`继承了`EfficientLengthIterable<E>`，最后`EfficientLengthIterable<E>`继承`Iterable<E>`，所以最终的map函数来自于`Iterable<E>`但是具体的实现定义在`ListMinxin<E>`中。

```dart
abstract class ListMixin<E> implements List<E> {
    ...
     //可以看到这里是直接返回一个MappedListIterable，它是一个惰性Iterable
     Iterable<T> map<T>(T f(E element)) => MappedListIterable<E, T>(this, f);
    ... 
}
```

- 3、为什么是惰性的呢，**可以看到它并不是直接返回转化后的集合，而是返回一个带有值的MappedListIterable的，如果不执行`elementAt`方法，是不会触发执行map传入的`f`函数**, 所以它是惰性的。

```dart
class MappedListIterable<S, T> extends ListIterable<T> {
  final Iterable<S> _source;//_source存储了所携带的原集合
  final _Transformation<S, T> _f;//_f函数存储了map函数传入的闭包，

  MappedListIterable(this._source, this._f);

  int get length => _source.length;
  //注意: 只有elementAt函数执行的时候，才会触发执行_f方法，然后通过_source的elementAt函数取得原集合中的元素，
  //最后针对_source中的每个元素执行_f函数处理。
  T elementAt(int index) => _f(_source.elementAt(index));
}
```

- 4、一般不会单独使用map函数，因为单独使用map的函数时，仅仅返回的是惰性的`MappedListIterable`。由上面的源码可知，仅仅在elementAt调用的时候才会触发map中的闭包。所以我们一般使用完map后会配合`toList()、toSet()`函数或者触发`elementAt`函数的函数(例如这里的`join`)一起使用。

```dart
languages.map((language) => 'develop language is ${language}').toList();//toList()方法调用才会真正去执行map中的闭包。

languages.map((language) => 'develop language is ${language}').toSet();//toSet()方法调用才会真正去执行map中的闭包。

languages.map((language) => 'develop language is ${language}').join('---');//join()方法调用才会真正去执行map中的闭包。

  List<E> toList({bool growable = true}) {
    List<E> result;
    if (growable) {
      result = <E>[]..length = length;
    } else {
      result = List<E>(length);
    }
    for (int i = 0; i < length; i++) {
      result[i] = this[i];//注意: 这里的this[i]实际上是运算符重载了[]，最终就是调用了elementAt函数，这里才会真正的触发map中的闭包，
    }
    return result;
  }
```

## 四、any

### 1、介绍

```dart
bool any(bool test(E element))
```

any函数主要用于**检查是否存在任意一个满足条件的元素，只要匹配到第一个就返回true, 如果遍历所有元素都不符合才返回false**. any函数接收一个`bool test(E element)`函数作为参数，`test`函数回调一个`E`类型的`element`并返回一个`bool`类型的值。

### 2、使用方式

```dart
main() {
    bool isDartExisted = languages.any((language) => language == 'Dart');
}
```

### 3、源码解析

```dart
bool any(bool test(E element)) {
    int length = this.length;//获取到原集合的length
    //遍历原集合，只要找到符合test函数的条件，就返回true
    for (int i = 0; i < length; i++) {
      if (test(this[i])) return true;
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    //遍历完集合后，未找到符合条件的集合就返回false
    return false;
  }
```

## 五、every

### 1、介绍

```dart
bool every(bool test(E element))
```

every函数主要用于**检查是否集合所有元素都满足条件，如果都满足就返回true, 只要存在一个不满足条件的就返回false.** every函数接收一个`bool test(E element)`函数作为参数，`test`函数回调一个`E`类型的`element`并返回一个`bool`类型的值。

### 2、使用方式

```dart
main() {
    bool isDartAll = languages.every((language) => language == 'Dart');
}
```

### 3、源码解析

```dart
bool every(bool test(E element)) {
  //利用for-in遍历集合，只要找到不符合test函数的条件，就返回false.
    for (E element in this) {
      if (!test(element)) return false;
    }
//遍历完集合后，找到所有元素符合条件就返回true    
    return true;
  }
```

## 六、where

### 1、介绍

```dart
Iterable<E> where(bool test(E element))
```

where函数主要用于**过滤符合条件的元素，类似Kotlin中的filter的作用，最后返回符合条件元素的集合。** where函数接收一个`bool test(E element)`函数作为参数，最后返回一个泛型参数为`E`的`Iterable`。类似map一样，where这里也是返回一个惰性的`Iterable<E>`, 然后对它的`iterator`进行迭代，对每个元素都执行`test`方法。

### 2、使用方式

```dart
main() {
   List<int> numbers = [0, 3, 1, 2, 7, 12, 2, 4];
   print(numbers.where((num) => num > 6));//输出: (7,12)
   //注意: 这里是print的内容实际上输出的是Iterable的toString方法返回的内容。
}
```

### 3、源码解析

- 1、首先，需要明确一点`numbers`实际上是一个`_GrowableList<T>`和`map`的分析原理类似，最终还是调用了`ListMixin`中的`where`函数。

```dart
//可以看到这里是直接返回一个WhereIterable对象，而不是返回过滤后元素集合，所以它返回的Iterable也是惰性的。
Iterable<E> where(bool test(E element)) => WhereIterable<E>(this, test);
```

- 2、然后，继续深入研究下`WhereIterable`是如何实现的

```dart
class WhereIterable<E> extends Iterable<E> {
  final Iterable<E> _iterable;//传入的原集合
  final _ElementPredicate<E> _f;//传入的where函数中闭包参数

  WhereIterable(this._iterable, this._f);

  //注意: 这里WhereIterable的迭代借助了iterator，这里是直接创建一个WhereIterator，并传入元集合_iterable中的iterator以及过滤操作函数。
  Iterator<E> get iterator => new WhereIterator<E>(_iterable.iterator, _f);

  // Specialization of [Iterable.map] to non-EfficientLengthIterable.
  Iterable<T> map<T>(T f(E element)) => new MappedIterable<E, T>._(this, f);
}
```

- 3、然后，继续深入研究下`WhereIterator`是如何实现的

```dart
class WhereIterator<E> extends Iterator<E> {
  final Iterator<E> _iterator;//存储集合中的iterator对象
  final _ElementPredicate<E> _f;//存储where函数传入闭包函数

  WhereIterator(this._iterator, this._f);

  //重写moveNext函数
  bool moveNext() {
  //遍历原集合的_iterator
    while (_iterator.moveNext()) {
    //注意: 这里会执行_f函数，如果满足条件就会返回true, 不符合条件的直接略过，迭代下一个元素；
    //那么外部迭代时候，就可以通过current获得当前元素，这样就实现了在原集合基础上过滤拿到符合条件的元素。
      if (_f(_iterator.current)) {
        return true;
      }
    }
    //迭代完_iterator所有元素后返回false,以此来终止外部迭代。
    return false;
  }
  //重写current的属性方法
  E get current => _iterator.current;
}
```

- 4、一般在使用的`WhereIterator`的时候，外部肯定还有一层`while`迭代，但是这个`WhereIterator`比较特殊，`moveNext()`的返回值由`where`中闭包函数参数返回值决定的，符合条件元素`moveNext()`就返回true,不符合就略过，迭代检查下一个元素，直至整个集合迭代完毕，`moveNext()`返回false,以此也就终止了外部的迭代循环。
- 5、上面分析，`WhereIterable`是惰性的，那它啥时候触发呢? 没错就是在迭代它的`iterator`时候才会触发，以上面例子为例

```dart
print(numbers.where((num) => num > 6));//输出: (7,12)，最后会调用Iterable的toString方法返回的内容。

//看下Iterable的toString方法实现
String toString() => IterableBase.iterableToShortString(this, '(', ')');//这就是为啥输出样式是 (7,12)
//继续查看IterableBase.iterableToShortString
  static String iterableToShortString(Iterable iterable,
      [String leftDelimiter = '(', String rightDelimiter = ')']) {
    if (_isToStringVisiting(iterable)) {
      if (leftDelimiter == "(" && rightDelimiter == ")") {
        // Avoid creating a new string in the "common" case.
        return "(...)";
      }
      return "$leftDelimiter...$rightDelimiter";
    }
    List<String> parts = <String>[];
    _toStringVisiting.add(iterable);
    try {
      _iterablePartsToStrings(iterable, parts);//注意:这里实际上就是通过将iterable转化成List，内部就是通过迭代iterator,以此会触发WhereIterator中的_f函数。
    } finally {
      assert(identical(_toStringVisiting.last, iterable));
      _toStringVisiting.removeLast();
    }
    return (StringBuffer(leftDelimiter)
          ..writeAll(parts, ", ")
          ..write(rightDelimiter))
        .toString();
  }

  /// Convert elements of [iterable] to strings and store them in [parts]. 这个函数代码实现比较多，这里给出部分代码
void _iterablePartsToStrings(Iterable iterable, List<String> parts) {
  ...
  int length = 0;
  int count = 0;
  Iterator it = iterable.iterator;
  // Initial run of elements, at least headCount, and then continue until
  // passing at most lengthLimit characters.
  //可以看到这是外部迭代while
  while (length < lengthLimit || count < headCount) {
    if (!it.moveNext()) return;//这里实际上调用了WhereIterator中的moveNext函数，经过_f函数处理的moveNext()
    String next = "${it.current}";//获取current.
    parts.add(next);
    length += next.length + overhead;
    count++;
  }
  ...
}
```

## 七、firstWhere和singleWhere和lastWhere

### 1、介绍

```dart
E firstWhere(bool test(E element), {E orElse()})
E lastWhere(bool test(E element), {E orElse()})
E singleWhere(bool test(E element), {E orElse()})
```

首先从源码声明结构上来看，firstWhere、lastWhere和singleWhere是一样，它们都是接收两个参数，一个是必需参数:`test`筛选条件闭包函数，另一个是可选参数:`orElse`闭包函数。

但是它们用法却不同，firstWhere主要是**用于筛选顺序第一个符合条件的元素，可能存在多个符合条件元素**；lastWhere主要是**用于筛选顺序最后一个符合条件的元素，可能存在多个符合条件元素**；singleWhere主要是**用于筛选顺序唯一一个符合条件的元素，不可能存在多个符合条件元素，存在的话就会抛出异常IterableElementError.tooMany()， 所以使用它的使用需要谨慎注意下**

### 2、使用方式

```dart
main() {
   var numbers = <int>[0, 3, 1, 2, 7, 12, 2, 4];
   //注意: 如果没有找到，执行orElse代码块，可返回一个指定的默认值-1
   print(numbers.firstWhere((num) => num == 5, orElse: () => -1)); 
   //注意: 如果没有找到，执行orElse代码块，可返回一个指定的默认值-1
   print(numbers.lastWhere((num) => num == 2, orElse: () => -1)); 
   //注意: 如果没有找到，执行orElse代码块，可返回一个指定的默认值，前提是集合中只有一个符合条件的元素, 否则就会抛出异常
   print(numbers.singleWhere((num) => num == 4, orElse: () => -1)); 
}
```

### 3、源码解析

```dart
//firstWhere
  E firstWhere(bool test(E element), {E orElse()}) {
    for (E element in this) {//直接遍历原集合，只要找到第一个符合条件的元素就直接返回，终止函数
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();//遍历完集合后，都没找到符合条件的元素并且外部传入了orElse就会触发orElse函数
    //否则找不到元素，直接抛出异常。所以这里需要注意下，如果不想抛出异常，可能你需要处理下orElse函数。
    throw IterableElementError.noElement();
  }

  //lastWhere
  E lastWhere(bool test(E element), {E orElse()}) {
    E result;//定义result来记录每次符合条件的元素
    bool foundMatching = false;//定义一个标志位是否找到符合匹配的。
    for (E element in this) {
      if (test(element)) {//每次找到符合条件的元素，都会重置result，所以result记录了最新的符合条件元素，那么遍历到最后，它也就是最后一个符合条件的元素
        result = element;
        foundMatching = true;//找到后重置标记位
      }
    }
    if (foundMatching) return result;//如果标记位为true直接返回result即可
    if (orElse != null) return orElse();//处理orElse函数
    //同样，找不到元素，直接抛出异常。可能你需要处理下orElse函数。
    throw IterableElementError.noElement();
  }

  //singleWhere
  E singleWhere(bool test(E element), {E orElse()}) {
    E result;
    bool foundMatching = false;
    for (E element in this) {
      if (test(element)) {
        if (foundMatching) {//主要注意这里，只要foundMatching为true,说明已经找到一个符合条件的元素，如果触发这条逻辑分支，说明不止一个元素符合条件就直接抛出IterableElementError.tooMany()异常
          throw IterableElementError.tooMany();
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
     //同样，找不到元素，直接抛出异常。可能你需要处理下orElse函数。
    throw IterableElementError.noElement();
  }
```

## 八、join

### 1、介绍

```dart
String join([String separator = ""])
```

join函数主要是用于**将集合所有元素值转化成字符串，中间用指定的`separator`连接符连接**。 可以看到join函数比较简单，接收一个`separator`分隔符的可选参数，可选参数默认值是空字符串，最后返回一个字符串。

### 2、使用方式

```dart
main() {
   var numbers = <int>[0, 3, 1, 2, 7, 12, 2, 4];
   print(numbers.join('-'));//输出: 0-3-1-2-7-12-2-4
}
```

### 3、源码解析

```dart
//接收separator可选参数，默认值为""
  String join([String separator = ""]) {
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) return "";
    //创建StringBuffer
    StringBuffer buffer = StringBuffer();
    //如果分隔符为空或空字符串
    if (separator == null || separator == "") {
      //do-while遍历iterator,然后直接拼接元素
      do {
        buffer.write("${iterator.current}");
      } while (iterator.moveNext());
    } else {
    //如果分隔符不为空
      //先加入第一个元素
      buffer.write("${iterator.current}");
      //然后while遍历iterator
      while (iterator.moveNext()) {
        buffer.write(separator);//先拼接分隔符
        buffer.write("${iterator.current}");//再拼接元素
      }
    }
    return buffer.toString();//最后返回最终的字符串。
  }
```

## 九、take

### 1、介绍

```dart
Iterable<E> take(int count)
```

take函数主要是用于**截取原集合前count个元素组成的集合**，take函数接收一个`count`作为函数参数，最后返回一个泛型参数为`E`的`Iterable`。类似where一样，take这里也是返回一个惰性的`Iterable<E>`, 然后对它的`iterator`进行迭代。

takeWhile函数主要用于

### 2、使用方式

```dart
main() {
   List<int> numbers = [0, 3, 1, 2, 7, 12, 2, 4];
   print(numbers.take(5));//输出(0, 3, 1, 2, 7)
}
```

### 3、源码解析

- 1、首先, 需要明确一点`numbers.take`调用了`ListMixin`中的`take`函数，可以看到并没有直接返回集合前`count`个元素，而是返回一个`TakeIterable<E>`惰性`Iterable`。

```dart
Iterable<E> take(int count) {
    return TakeIterable<E>(this, count);
  }
```

- 2、然后，继续深入研究`TakeIterable`

```dart
class TakeIterable<E> extends Iterable<E> {
  final Iterable<E> _iterable;//存储原集合
  final int _takeCount;//take count

  factory TakeIterable(Iterable<E> iterable, int takeCount) {
    ArgumentError.checkNotNull(takeCount, "takeCount");
    RangeError.checkNotNegative(takeCount, "takeCount");
    if (iterable is EfficientLengthIterable) {//如果原集合是EfficientLengthIterable，就返回创建EfficientLengthTakeIterable
      return new EfficientLengthTakeIterable<E>(iterable, takeCount);
    }
    //否则就返回TakeIterable
    return new TakeIterable<E>._(iterable, takeCount);
  }

  TakeIterable._(this._iterable, this._takeCount);

//注意: 这里是返回了TakeIterator，并传入原集合的iterator以及_takeCount
  Iterator<E> get iterator {
    return new TakeIterator<E>(_iterable.iterator, _takeCount);
  }
}
```

- 3、然后，继续深入研究`TakeIterator`.

```dart
class TakeIterator<E> extends Iterator<E> {
  final Iterator<E> _iterator;//存储原集合中的iterator
  int _remaining;//存储需要截取的前几个元素的数量

  TakeIterator(this._iterator, this._remaining) {
    assert(_remaining >= 0);
  }

  bool moveNext() {
    _remaining--;//通过_remaining作为游标控制迭代次数
    if (_remaining >= 0) {//如果_remaining大于等于0就会继续执行moveNext方法
      return _iterator.moveNext();
    }
    _remaining = -1;
    return false;//如果_remaining小于0就返回false,终止外部循环
  }

  E get current {
    if (_remaining < 0) return null;
    return _iterator.current;
  }
}
```

- 4、所以上述例子中最终还是调用`Iterable`的`toString`方法，方法中会进行`iterator`的迭代，最终会触发惰性`TakeIterable`中的`TakeIterator`的`moveNext`方法。

## 十、takeWhile

### 1、介绍

```dart
Iterable<E> takeWhile(bool test(E value))
```

takeWhile函数主要用于**依次选择满足条件的元素，直到遇到第一个不满足的元素，并停止选择**。takeWhile函数接收一个`test`条件函数作为函数参数，然后返回一个惰性的`Iterable<E>`。

### 2、使用方式

```dart
main() {
  List<int> numbers = [3, 1, 2, 7, 12, 2, 4];
  print(numbers.takeWhile((number) => number > 2).toList());//输出: [3] 遇到1的时候就不满足大于2条件就终止筛选。
}
```

### 3、源码解析

- 1、首先，因为`numbers`是`List<int>`所以还是调用`ListMixin`中的`takeWhile`函数

```dart
Iterable<E> takeWhile(bool test(E element)) {
    return TakeWhileIterable<E>(this, test);//可以看到它仅仅返回的是TakeWhileIterable，而不是筛选后符合条件的集合，所以它是惰性。
  }
```

- 2、然后，继续看下`TakeWhileIterable<E>`的实现

```dart
class TakeWhileIterable<E> extends Iterable<E> {
  final Iterable<E> _iterable;
  final _ElementPredicate<E> _f;

  TakeWhileIterable(this._iterable, this._f);

  Iterator<E> get iterator {
    //重写iterator，创建一个TakeWhileIterator对象并返回。
    return new TakeWhileIterator<E>(_iterable.iterator, _f);
  }
}

//TakeWhileIterator
class TakeWhileIterator<E> extends Iterator<E> {
  final Iterator<E> _iterator;
  final _ElementPredicate<E> _f;
  bool _isFinished = false;

  TakeWhileIterator(this._iterator, this._f);

  bool moveNext() {
    if (_isFinished) return false;
    //原集合_iterator遍历结束或者原集合中的当前元素current不满足_f条件，就返回false以此终止外部的迭代。
    //进一步说明了只有moveNext调用，才会触发_f的执行，此时惰性的Iterable才得以执行。
    if (!_iterator.moveNext() || !_f(_iterator.current)) {
      _isFinished = true;//迭代结束重置_isFinished为true
      return false;
    }
    return true;
  }

  E get current {
    if (_isFinished) return null;//如果迭代结束，还取current就直接返回null了
    return _iterator.current;
  }
}
```

## 十、skip

### 1、介绍

```dart
Iterable<E> skip(int count)
```

skip函数主要是用于**跳过原集合前count个元素后，剩下元素组成的集合**，skip函数接收一个`count`作为函数参数，最后返回一个泛型参数为`E`的`Iterable`。类似where一样，skip这里也是返回一个惰性的`Iterable<E>`, 然后对它的`iterator`进行迭代。

### 2、使用方式

```dart
main() {
  List<int> numbers = [3, 1, 2, 7, 12, 2, 4];
  print(numbers.skip(2).toList());//输出: [2, 7, 12, 2, 4] 跳过前两个元素3,1 直接从第3个元素开始    
}
```

### 3、源码解析

- 1、首先，因为`numbers`是`List<int>`所以还是调用`ListMixin`中的`skip`函数

```dart
Iterable<E> skip(int count) => SubListIterable<E>(this, count, null);//返回的是一个SubListIterable惰性Iterable，传入原集合和需要跳过的count大小
```

- 2、然后，继续看下`SubListIterable<E>`的实现,这里只看下`elementAt`函数实现

```dart
class SubListIterable<E> extends ListIterable<E> {
  final Iterable<E> _iterable; // Has efficient length and elementAt.
  final int _start;//这是传入的需要skip的count
  final int _endOrLength;//这里传入为null
  ...
  int get _endIndex {
    int length = _iterable.length;//获取原集合长度
    if (_endOrLength == null || _endOrLength > length) return length;//_endIndex为原集合长度
    return _endOrLength;
  }

  int get _startIndex {//主要看下_startIndex的实现
    int length = _iterable.length;//获取原集合长度
    if (_start > length) return length;//如果skip的count超过集合自身长度，_startIndex为原集合长度
    return _start;//否则返回skip的count
  }

  E elementAt(int index) {
    int realIndex = _startIndex + index;//相当于把原集合中每个元素原来index,整体向后推了_startIndex,最后获取真实映射的realIndex
    if (index < 0 || realIndex >= _endIndex) {//如果realIndex越界就会抛出异常
      throw new RangeError.index(index, this, "index");
    }
    return _iterable.elementAt(realIndex);//否则就取对应realIndex在原集合中的元素。
  }
  ...
}
```

## 十一、skipWhile

### 1、介绍

```dart
Iterable<E> skipWhile(bool test(E element))
```

skipWhile函数主要用于**依次跳过满足条件的元素，直到遇到第一个不满足的元素，并停止筛选**。skipWhile函数接收一个`test`条件函数作为函数参数，然后返回一个惰性的`Iterable<E>`。

### 2、使用方式

```dart
main() {
  List<int> numbers = [3, 1, 2, 7, 12, 2, 4];
  print(numbers.skipWhile((number) => number < 4).toList());//输出: [7, 12, 2, 4]
  //因为3、1、2都是满足小于4的条件，所以直接skip跳过，直到遇到7不符合条件停止筛选，剩下的就是[7, 12, 2, 4]
}
```

### 3、源码解析

- 1、首先，因为`numbers`是`List<int>`所以还是调用`ListMixin`中的`skipWhile`函数

```dart
Iterable<E> skipWhile(bool test(E element)) {
    return SkipWhileIterable<E>(this, test);//可以看到它仅仅返回的是SkipWhileIterable，而不是筛选后符合条件的集合，所以它是惰性的。
  }
```

- 2、然后，继续看下`SkipWhileIterable<E>`的实现

```dart
class SkipWhileIterable<E> extends Iterable<E> {
  final Iterable<E> _iterable;
  final _ElementPredicate<E> _f;

  SkipWhileIterable(this._iterable, this._f);
 //重写iterator，创建一个SkipWhileIterator对象并返回。
  Iterator<E> get iterator {
    return new SkipWhileIterator<E>(_iterable.iterator, _f);
  }
}

//SkipWhileIterator
class SkipWhileIterator<E> extends Iterator<E> {
  final Iterator<E> _iterator;//存储原集合的iterator
  final _ElementPredicate<E> _f;//存储skipWhile中筛选闭包函数
  bool _hasSkipped = false;//判断是否已经跳过元素的标识，默认为false

  SkipWhileIterator(this._iterator, this._f);

//重写moveNext函数
  bool moveNext() {
    if (!_hasSkipped) {//如果是最开始第一次没有跳过任何元素
      _hasSkipped = true;//然后重置标识为true,表示已经进行了第一次跳过元素的操作
      while (_iterator.moveNext()) {//迭代原集合中的iterator
        if (!_f(_iterator.current)) return true;//只要找到符合条件的元素，就略过迭代下一个元素，不符合条件就直接返回true终止当前moveNext函数，而此时外部迭代循环正式从当前元素开始迭代，
      }
    }
    return _iterator.moveNext();//那么遇到第一个不符合条件元素之后所有元素就会通过_iterator.moveNext()正常返回
  }

  E get current => _iterator.current;
}
```

## 十二、follwedBy

### 1、介绍

```dart
Iterable<E> followedBy(Iterable<E> other)
```

followedBy函数主要用于**在原集合后面追加拼接另一个`Iterable<E>`集合**，followedBy函数接收一个`Iterable<E>`参数，最后又返回一个`Iterable<E>`类型的值。

### 2、使用方式

```dart
main() {
  var languages = <String>['Kotlin', 'Java', 'Dart', 'Go', 'Python'];
  print(languages.followedBy(['Swift', 'Rust', 'Ruby', 'C++', 'C#']).toList());//输出: [Kotlin, Java, Dart, Go, Python, Swift, Rust, Ruby, C++, C#]
}
```

### 3、源码解析

- 1、首先，还是调用`ListMixin`中的`followedBy`函数

```dart
Iterable<E> followedBy(Iterable<E> other) =>
      FollowedByIterable<E>.firstEfficient(this, other);//这里实际上还是返回一个惰性的FollowedByIterable对象，这里使用命名构造器firstEfficient创建对象
```

- 2、然后，继续看下`FollowedByIterable`中的`firstEfficient`实现

```dart
factory FollowedByIterable.firstEfficient(
      EfficientLengthIterable<E> first, Iterable<E> second) {
    if (second is EfficientLengthIterable<E>) {//List肯定是一个EfficientLengthIterable，所以会创建一个EfficientLengthFollowedByIterable，传入的参数first是当前集合，second是需要在后面拼接的集合
      return new EfficientLengthFollowedByIterable<E>(first, second);
    }
    return new FollowedByIterable<E>(first, second);
  }
```

- 3、然后，继续看下`EfficientLengthFollowedByIterable`的实现,这里只具体看下`elementAt`函数的实现

```dart
class EfficientLengthFollowedByIterable<E> extends FollowedByIterable<E>
    implements EfficientLengthIterable<E> {
  EfficientLengthFollowedByIterable(
      EfficientLengthIterable<E> first, EfficientLengthIterable<E> second)
      : super(first, second);
 ... 
  E elementAt(int index) {//elementAt在迭代过程会调用
    int firstLength = _first.length;//取原集合的长度
    if (index < firstLength) return _first.elementAt(index);//如果index小于原集合长度就从原集合中获取元素
    return _second.elementAt(index - firstLength);//否则就通过index - firstLength 计算新的下标从拼接的集合中获取元素。
  }
  ...
}
```

## 十三、expand

### 1、介绍

```dart
Iterable<T> expand<T>(Iterable<T> f(E element))
```

expand函数主要用于**将集合中每个元素扩展为零个或多个元素或者将多个元素组成二维数组展开成平铺一个[一维数组](https://www.zhihu.com/search?q=一维数组&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90373910})**。 expand函数接收一个`Iterable<T> f(E element)`函数作为函数参数。这个闭包函数比较特别，特别之处在于`f`函数返回的是一个`Iterable<T>`,那么就意味着可以将原集合中每个元素扩展成多个相同元素。注意expand函数最终还是返回一个惰性的`Iterable<T>`

### 2、使用方式

```dart
main() {
   var pair = [
     [1, 2],
     [3, 4]
   ];
   print('flatten list: ${pair.expand((pair) => pair).toList()}');//输出: flatten list: [1, 2, 3, 4]
   var inputs = [1, 2, 3];
   print('duplicated list: ${inputs.expand((number) => [number, number, number]).toList()}');//输出: duplicated list: [1, 1, 1, 2, 2, 2, 3, 3, 3]
}
```

### 3、源码解析

- 1、首先还是调用`ListMixin`中的`expand`函数。

```dart
Iterable<T> expand<T>(Iterable<T> f(E element)) =>
      ExpandIterable<E, T>(this, f);//可以看到这里并没有直接返回扩展的集合，而是创建一个惰性的ExpandIterable对象返回，
```

- 2、然后继续深入`ExpandIterable`

```dart
typedef Iterable<T> _ExpandFunction<S, T>(S sourceElement);

class ExpandIterable<S, T> extends Iterable<T> {
  final Iterable<S> _iterable;
  final _ExpandFunction<S, T> _f;

  ExpandIterable(this._iterable, this._f);

  Iterator<T> get iterator => new ExpandIterator<S, T>(_iterable.iterator, _f);//注意: 这里iterator是一个ExpandIterator对象，传入的是原集合的iterator和expand函数中闭包函数参数_f
}

//ExpandIterator的实现
class ExpandIterator<S, T> implements Iterator<T> {
  final Iterator<S> _iterator;
  final _ExpandFunction<S, T> _f;
  //创建一个空的Iterator对象_currentExpansion
  Iterator<T> _currentExpansion = const EmptyIterator();
  T _current;

  ExpandIterator(this._iterator, this._f);

  T get current => _current;//重写current

//重写moveNext函数，只要当迭代的时候，moveNext执行才会触发闭包函数_f执行。
  bool moveNext() {
   //如果_currentExpansion返回false终止外部迭代循环
    if (_currentExpansion == null) return false;
    //开始_currentExpansion是一个空的Iterator对象，所以moveNext()为false
    while (!_currentExpansion.moveNext()) {
      _current = null;
      //迭代原集合中的_iterator
      if (_iterator.moveNext()) {
        //如果_f抛出异常，先重置_currentExpansion为null, 遇到 if (_currentExpansion == null) return false;就会终止外部迭代
        _currentExpansion = null;
        _currentExpansion = _f(_iterator.current).iterator;//执行_f函数
      } else {
        return false;
      }
    }
    _current = _currentExpansion.current;
    return true;
  }
}
```

## 十四、reduce

### 1、介绍

```dart
E reduce(E combine(E previousValue, E element))
T fold<T>(T initialValue, T combine(T previousValue, E element))
```

[reduce函数](https://www.zhihu.com/search?q=reduce函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90373910})主要**用于集合中元素依次归纳(combine)，每次归纳后的结果会和下一个元素进行归纳，它可以用来累加或累乘，具体取决于[combine函数](https://www.zhihu.com/search?q=combine函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90373910})中操作，combine函数中会回调上一次归纳后的值和当前元素值，reduce提供的是获取累积迭代结果的便利条件.** **fold和reduce几乎相同，唯一区别是fold可以指定初始值。** 但是需要注意的是，combine函数返回值的类型必须和集合泛型类型一致。

### 2、使用方式

```dart
main() {
  List<int> numbers = [3, 1, 2, 7, 12, 2, 4];
  print(numbers.reduce((prev, curr) => prev + curr)); //累加
  print(numbers.fold(2, (prev, curr) => (prev as int) + curr)); //累加
  print(numbers.reduce((prev, curr) => prev + curr) / numbers.length); //求平均数
  print(numbers.fold(2, (prev, curr) => (prev as int) + curr) / numbers.length); //求平均数
  print(numbers.reduce((prev, curr) => prev * curr)); //累乘
  print(numbers.fold(2, (prev, curr) => (prev as int) * curr)); //累乘

  var strList = <String>['a', 'b', 'c'];
  print(strList.reduce((prev, curr) => '$prev*$curr')); //拼接字符串
  print(strList.fold('e', (prev, curr) => '$prev*$curr')); //拼接字符串
}
```

### 3、源码解析

```dart
E reduce(E combine(E previousValue, E element)) {
    int length = this.length;
    if (length == 0) throw IterableElementError.noElement();
    E value = this[0];//初始值默认取第一个
    for (int i = 1; i < length; i++) {//从第二个开始遍历
      value = combine(value, this[i]);//combine回调value值和当前元素值，然后把combine的结果归纳到value上，依次处理。
      if (length != this.length) {
        throw ConcurrentModificationError(this);//注意: 在操作过程中不允许删除和添加元素否则就会出现ConcurrentModificationError
      }
    }
    return value;
  }

  T fold<T>(T initialValue, T combine(T previousValue, E element)) {
    var value = initialValue;//和reduce唯一区别在于这里value初始值是外部指定的
    int length = this.length;
    for (int i = 0; i < length; i++) {
      value = combine(value, this[i]);
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    return value;
  }
```

## 十五、elementAt

### 1、介绍

```dart
E elementAt(int index)
```

elementAt函数用于**获取对应index下标的元素**，传入一个index参数，返回对应泛型类型`E`的元素。

### 2、使用方式

```text
main() {
  print(numbers.elementAt(3));//elementAt一般不会直接使用，更多是使用[]，运算符重载的方式间接使用。 
}
```

### 3、源码解析

```dart
E elementAt(int index) {
    ArgumentError.checkNotNull(index, "index");
    RangeError.checkNotNegative(index, "index");
    int elementIndex = 0;
    //for-in遍历原集合，找到对应elementIndex元素并返回
    for (E element in this) {
      if (index == elementIndex) return element;
      elementIndex++;
    }
    //找不到抛出RangeError
    throw RangeError.index(index, this, "index", null, elementIndex);
  }
```

## 总结

到这里，有关dart中集合操作符函数相关内容就结束了，关于集合操作符函数使用在Flutter中开发非常有帮助，特别在处理集合数据中，可以让你的代码实现更优雅，不要再是一上来就for循环直接开干，虽然也能实现，但是如果能适当使用操作符函数，将会使代码更加简洁。欢迎继续关注，下一篇Dart中的函数的使用...



# Dart语法篇之函数的使用(四)

简述:

在上一篇文章中我们详细地研究了一下集合有关内容，包括集合的操作符的使用甚至我们还深入到源码实现原理，从原理上掌握集合的使用。那么这篇文章来研究一下Dart的另一个重要语法: **函数**。

这篇主要会涉及到: 函数命名参数、可选参数、参数默认、闭包函数、[箭头函数](https://www.zhihu.com/search?q=箭头函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})以及函数作为对象使用。

## 一、函数参数

在Dart函数参数是一个比较重要的概念，此外它涉及到概念的种类比较多，比如[位置参数](https://www.zhihu.com/search?q=位置参数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})、命名参数、可选位置参数、可选命名参数等等。函数总是有一个所谓[形参列表](https://www.zhihu.com/search?q=形参列表&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})，虽然这个参数列表可能为空，比如**[getter函数](https://www.zhihu.com/search?q=getter函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})就是没有参数列表的**. 此外在Dart中函数参数大致可分为两种: **位置参数和命名参数**，来一张图理清它们的概念关系



![img](https://pic3.zhimg.com/80/v2-4507b0f462f98194796c0cdb2f2e757a_720w.jpg)



### 1、位置参数

**位置参数可以必需的也可以是可选**。

- 无参数

```dart
//无参数类型-这是不带函数参数或者说参数列表为空
String getDefaultErrorMsg() => 'Unknown Error!';
//无参数类型-等价于上面函数形式，同样是参数列表为空
get getDefaultErrorMsg => 'Unknown Error!';
```

- 必需位置参数

```dart
//必需位置参数类型-这里的exception是必需的位置参数
String getErrorMsg(Exception exception) => exception.toString();
```

- 可选位置参数

```dart
//注意: 可选位置参数是中括号括起来表示，例如[String error]
String getErrorMsg([String error]) => error ?? 'Unknown Error!';
```

- 必需位置参数和可选位置参数混合

```dart
//注意: 可选位置参数必须在必需位置参数的后面
String getErrorMsg(Exception exception, [String extraInfo]) => '${exception.toString()}---$extraInfo';
```

### 2、命名参数

命名参数**始终是可选参数**。为什么是命名参数，这是因为在调用函数时可以任意指定参数名来传参。

- 可选命名参数

```dart
//注意: 可选命名参数是大括号括起来表示，例如{num a, num b, num c, num d}
num add({num a, num b, num c, num d}) {
   return a + b + c + d;
}
//调用
main() {
   print(add(d: 4, b: 3, a: 2, c: 1));//这里的命名参数就是可以任意顺序指定参数名传值,例如d: 4, b: 3, a: 2, c: 1
}
```

- 必需位置参数和可选命名参数混合

```dart
//注意: 可选命名参数必须在必需位置参数的后面
num add(num a, num b, {num c, num d}) {
   return a + b + c + d;
}
//调用
main() {
   print(add(4, 5, d: 3, c: 1));//这里的命名参数就是可以任意顺序指定参数名传值,例如d: 3, c: 1,但是必需参数必须按照顺序传参。
}
```

- 注意: 可选位置参数和可选命名参数不能混合在一起使用，因为可选参数列表只能位于整个函数形参列表的最后。

```dart
void add7([num a, num b], {num c, num d}) {//非法声明，想想也没有必要两者一起混合使用场景。所以
   ...
}
```

### 3、关于可选位置参数`[num a, num b]`和可选命名参数`{num a, num b}`使用场景

可能问题来了，啥时候使用可选位置参数，啥时候使用可选命名参数呢?

这里给个建议: **首先，参数是非必需的也就是可选的，如果可选参数个数只有一个建议直接使用可选位置参数`[num a, num b]`；如果可选参数个数是多个的话建议用可选命名参数`{num a, num b}`.** 因为多个参数可选，指定参数名传参对整体代码可读性有一定的增强。

### 4、参数默认值(针对可选参数)

首先，需要明确一点，参数默认值只针对可选参数才能添加的。可以使用 **=** 来定义命名和位置参数的默认值。**默认值必须是编译时常量。如果没有提供默认值，则默认值为null**。

- 可选位置参数默认值

```dart
num add(num a, num b, num c, [num d = 5]}) {//使用=来赋值默认值
    return a + b + c + d;
}
main() {
    print(add(1, 2, 3));//有默认值参数可以省略不传 实际上求和结果是: 1 + 2 + 3 + 5(默认值)
    print(add(1, 2, 3, 4));//有默认值参数指定传入4，会覆盖默认值，所以求和结果是: 1 + 2 + 3 + 4
}
```

- 可选命名参数默认值

```dart
num add({num a, num b, num c = 3, num d = 4}) {
    return a + b + c + d;
}
main() {
    print(add(100, 100, d: 100, c: 100));    
}
```

## 二、匿名函数(闭包，lambda)

在Dart中可以创建一个没有函数名称的函数，这种函数称为**匿名函数，或者[lambda函数](https://www.zhihu.com/search?q=lambda函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})或者闭包函数**。但是和其他函数一样，它也有形参列表，可以有可选参数。

```dart
(num x) => x;//没有函数名，有必需的位置参数x
(num x) {return x;}//等价于上面形式
(int x, [int step]) => x + step;//没有函数名，有可选的位置参数step
(int x, {int step1, int step2}) => x + step1 + step2;////没有函数名，有可选的命名参数step1、step2
```

### 闭包在dart中的应用

闭包函数在dart用的特别多，单从集合中操作符来说就有很多。

```dart
main() {
  List<int> numbers = [3, 1, 2, 7, 12, 2, 4];
  //reduce函数实现累加，reduce函数中接收的(prev, curr) => prev + curr就是一个闭包
  print(numbers.reduce((prev, curr) => prev + curr));
  //还可以不用闭包形式来写，但是这并不是一个好的方案,不建议下面这样使用。
  plus(prev, curr) => prev + curr;
  print(numbers.reduce(plus));
}
//reduce函数定义
 E reduce(E combine(E value, E element)) {//combine闭包函数
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw IterableElementError.noElement();
    }
    E value = iterator.current;
    while (iterator.moveNext()) {
      value = combine(value, iterator.current);//执行combine函数
    }
    return value;
  }
```

## 三、箭头函数

在Dart中还有一种函数的简写形式，那就是**箭头函数**。箭头函数**是只能包含一行表达式**的函数，会注意到它**没有花括号，而是带有箭头**的。箭头函数更有助于代码的可读性，类似于Kotlin或Java中的lambda表达式`->`的写法。

```dart
main() {
  List<int> numbers = [3, 1, 2, 7, 12, 2, 4];
  print(numbers.reduce((prev, curr) {//闭包简写形式
        return prev + curr;
  }));
  print(numbers.reduce((prev, curr) => prev + curr)); //等价于上述形式，箭头函数简写形式
}
```

## 四、[局部函数](https://www.zhihu.com/search?q=局部函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})

在Dart中还有一种可以直接定义在函数体内部的函数，可以把称为**局部函数或者内嵌函数**。我们知道函数声明可以出现顶层，比如常见的main函数等等。局部函数的好处就是从作用域角度来看，它可以访问外部函数变量，并且还能避免引入一个额外的[外部函数](https://www.zhihu.com/search?q=外部函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})，使得整个函数功能职责统一。

```dart
//定义外部函数fibonacci
int fibonacci(int n) {
    //定义局部函数lastTwo
    List<int> lastTwo(int n) {
        if(n < 1) {
           return <int>[0, 1];  
        } else {
           var p = lastTwo(n - 1);
           return <int>[p[1], p[0] + p[1]];
        }
    }
    return lastTwo(n)[1];
}
```

## 五、顶层函数和[静态函数](https://www.zhihu.com/search?q=静态函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})

在Dart中有一种特别的函数，我们知道在面向对象语言中比如Java，并不能直接定义一个函数的，而是需要定义一个类，然后在类中定义函数。但是在Dart中可以不用在类中定义函数，而是直接基于dart文件顶层定义函数，这种函数我们一般称为**[顶层函数](https://www.zhihu.com/search?q=顶层函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A90785284})**。最常见就是main函数了。而静态函数就和Java中类似，依然使用**static关键字来声明**，然后必须是**定义在类的内部**的。

```dart
//顶层函数，不定义在类的内部
main() {
  print('hello dart');
}

class Number {
    static int getValue() => 100;//static修饰定义在类的内部。
}
```

## 六、main函数

每个应用程序都有一个顶级的main()函数，它作为应用程序的入口点。main()函数返回void，所以在dart可以直接省略void，并有一个可选的列表参数作为参数。

```dart
//你一般看到的main是这样的
main() {
  print('hello dart');
}
//实际上它和Java类似可以带个参数列表
main(List<String> args) {
  print('hello dart: ${args[0]}, ${args[1]}');//用dart command执行的时候: dart test.dart arg0 arg1 =>输出:hello dart: arg0, arg1    
}
```

## 七、Function函数对象

在Dart中一切都是对象，函数也不例外，函数可以作为一个参数传递。其中`Function`类是代表所有函数的公共顶层接口抽象类。`Function`类中并没有声明任何实例方法。但是它有一个非常重要的静态类函数`apply`. 该函数接收一个`Function`对象`function`，一个`List`的参数`positionalArguments`以及一个可选参数`Map<Symbol, dynamic>`类型的`namedArguments`。大家似乎明白了什么？知道为啥dart中函数支持位置参数和命名参数吗? 没错就是它们两个参数功劳。实际上，**apply()函数提供一种使用动态确定的参数列表来调用函数的机制，通过它我们就能处理在编译时参数列表不确定的情况**。

```dart
abstract class Function {
  external static apply(Function function, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments]);//可以看到这是external声明，我们需要找到对应的function_patch.dart实现

  int get hashCode;

  bool operator ==(Object other);
}
```

在sdk源码中找到`sdk/lib/_internal/vm/lib/function_patch.dart`对应的`function_patch`的实现

```dart
@patch
class Function {
  // TODO(regis): Pass type arguments to generic functions. Wait for API spec.
  //可以看到内部私有的_apply函数，最终接收两个List原生类型的参数arguments,names分别代表着我们使用函数时
  //定义的所有参数List集合arguments(包括位置参数和命名参数)以及命名参数名List集合names，不过它是委托到native层的Function_apply C++函数实现的。
  static _apply(List arguments, List names) native "Function_apply";

  @patch
  static apply(Function function, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments]) {
    //计算外部函数位置参数的个数  
    int numPositionalArguments = 1 + // 默认同时会传入function参数，所以默认+1
        (positionalArguments != null ? positionalArguments.length : 0);//位置参数的集合不为空就返回集合长度否则返回0
    //计算外部函数命名参数的个数    
    int numNamedArguments = namedArguments != null ? namedArguments.length : 0;;//命名参数的集合不为空就返回集合长度否则返回0
    //计算所有参数个数总和: 位置参数个数 + 命名参数个数
    int numArguments = numPositionalArguments + numNamedArguments;
    //创建一个定长为所有参数个数大小的List集合arguments
    List arguments = new List(numArguments);
    //集合第一个元素默认是传入的function对象
    arguments[0] = function;
    //然后从1的位置开始插入所有的位置参数到arguments参数列表中
    arguments.setRange(1, numPositionalArguments, positionalArguments);
    //然后再创建一个定长为命名参数长度的List集合
    List names = new List(numNamedArguments);
    int argumentIndex = numPositionalArguments;
    int nameIndex = 0;
    //遍历命名参数Map集合
    if (numNamedArguments > 0) {
      namedArguments.forEach((name, value) {
        arguments[argumentIndex++] = value;//把命名参数对象继续插入到arguments集合中
        names[nameIndex++] = internal.Symbol.getName(name);//并把对应的参数名标识存入names集合中
      });
    }
    return _apply(arguments, names);//最后调用_apply函数传入所有参数对象集合以及命名参数名称集合
  }
}
```

不妨再来瞅瞅C++层中的`Function_apply`的实现

```cpp
DEFINE_NATIVE_ENTRY(Function_apply, 0, 2) {
  const int kTypeArgsLen = 0;  // TODO(regis): Add support for generic function.
  const Array& fun_arguments =
      Array::CheckedHandle(zone, arguments->NativeArgAt(0));//获取函数的所有参数对象数组 fun_arguments
  const Array& fun_arg_names =
      Array::CheckedHandle(zone, arguments->NativeArgAt(1));//获取函数的命名参数参数名数组 fun_arg_names
  const Array& fun_args_desc = Array::Handle(
      zone, ArgumentsDescriptor::New(kTypeArgsLen, fun_arguments.Length(),
                                     fun_arg_names));//利用 fun_arg_names生成对应命名参数描述符集合
 //注意: 这里会调用DartEntry中的InvokeClosure函数，传入了所有参数对象数组 fun_arguments和fun_arg_names生成对应命名参数描述符集合
//最后返回result
  const Object& result = Object::Handle(
      zone, DartEntry::InvokeClosure(fun_arguments, fun_args_desc));
  if (result.IsError()) {
    Exceptions::PropagateError(Error::Cast(result));
  }
  return result.raw();
}
```



# Dart语法篇之面向对象基础(五)

简述:

从这篇文章开始，我们继续Dart语法篇的第五讲, dart中的面向对象基础。我们知道在Dart中一切都是对象，所以面向对象在Dart开发中是非常重要的。此外它还和其他有点不一样的地方，比如多继承mixin、构造器不能被重载、setter和getter的访问器函数等。

## 一、属性访问器(accessor)函数setter和getter

在Dart类的属性中有一种为了方便访问它的值特殊函数，那就是setter,getter属性访问器函数。**实际上，在dart中每个实例属性始终有与之对应的setter,[getter函数](https://www.zhihu.com/search?q=getter函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361})(若是final修饰只读属性只有getter函数, 而可变属性则有setter，getter两种函数)。而在给实例属性赋值或获取值时，实际上内部都是对setter和getter函数的调用**。

### 1、属性访问器函数setter

setter函数名前面添加**前缀`set`**, 并只接收一个参数。setter调用语法于传统的变量赋值是一样的。如果一个实例属性是可变的，那么一个setter属性访问器函数就会为它自动定义，所有实例属性的赋值实际上都是对[setter函数](https://www.zhihu.com/search?q=setter函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361})的调用。这一点和Kotlin中的setter，getter非常相似。

```dart
class Rectangle {
  num left, top, width, height;

  Rectangle(this.left, this.top, this.width, this.height);
  set right(num value) => left = value - width;//使用set作为前缀，只接收一个参数value
  set bottom(num value) => top = value - height;//使用set作为前缀，只接收一个参数value
}

main() {
  var rect = Rectangle(3, 4, 20, 15);
  rect.right = 15;//调用setter函数时，可以直接使用类似属性赋值方式调用right函数。
  rect.bottom = 12;//调用setter函数时，可以直接使用类似属性赋值方式调用bottom函数。
}
```

对比Kotlin中的实现

```kotlin
class Rectangle(var left: Int, var top: Int, var width: Int, var height: Int) {
    var right: Int = 0//在kotlin中表示可变使用var,只读使用val
        set(value) {//kotlin中定义setter
            field = value
            left = value - width
        }
    var bottom: Int = 0
        set(value) {//kotlin中定义setter
            field = value
            top = value - height
        }
}

fun main(args: Array<String>) {
    val rect = Rectangle(3, 4, 20, 15);
    rect.right = 15//调用setter函数时，可以直接使用类似属性赋值方式调用right函数。
    rect.bottom = 12//调用setter函数时，可以直接使用类似属性赋值方式调用bottom函数。
}
```

### 2、属性访问器函数getter

Dart中所有实例属性的访问都是通过调用getter函数来实现的。每个实例数额行始终都有一个与之关联的getter,由Dart编译器提供的。

```dart
class Rectangle {
  num left, top, width, height;

  Rectangle(this.left, this.top, this.width, this.height);
  get square => width * height; ;//使用get作为前缀，getter来计算面积.
  set right(num value) => left = value - width;//使用set作为前缀，只接收一个参数value
  set bottom(num value) => top = value - height;//使用set作为前缀，只接收一个参数value
}

main() {
  var rect = Rectangle(3, 4, 20, 15);
  rect.right = 15;//调用setter函数时，可以直接使用类似属性赋值方式调用right函数。
  rect.bottom = 12;//调用setter函数时，可以直接使用类似属性赋值方式调用bottom函数。
  print('the rect square is ${rect.square}');//调用getter函数时，可以直接使用类似读取属性值方式调用square函数。
}
```

对比kotlin实现

```kotlin
class Rectangle(var left: Int, var top: Int, var width: Int, var height: Int) {
    var right: Int = 0
        set(value) {
            field = value
            left = value - width
        }
    var bottom: Int = 0
        set(value) {
            field = value
            top = value - height
        }

    val square: Int//因为只涉及到了只读，所以使用val
        get() = width * height//kotlin中定义getter
}

fun main(args: Array<String>) {
    val rect = Rectangle(3, 4, 20, 15);
    rect.right = 15
    rect.bottom = 12
    println(rect.square)//调用getter函数时，可以直接使用类似读取属性值方式调用square函数。
}
```

### 3、属性访问器函数使用场景

其实，上面`setter`，`getter`函数实现的目的，普通函数也能做到的。但是如果用`setter`,`getter`函数形式更符合编码规范。既然普通函数也能做到，那具体什么时候使用`setter`,`getter`函数，什么时候使用普通函数呢。这不得不把这个问题和另一问题转化一下成为: 哪种场景该定义属性还是定义函数的问题(关于这个问题，记得很久之前在讨论Kotlin的语法详细介绍过)。我们都知道**函数一般描述动作行为，而属性则是描述状态数据结构(状态可能经过多个属性值计算得到)。** 如果类中需要向外暴露类中某个状态那么更适合使用`setter`,`getter`函数；如果是触发类中的某个行为操作，那么普通函数更适合一点。

比如下面这个例子，`draw`绘制矩形动作更适合使用普通函数来实现，`square`获取矩形的面积更适合使用getter函数来实现,可以仔细体会下。

```dart
class Rectangle {
  num left, top, width, height;

  Rectangle(this.left, this.top, this.width, this.height);

  set right(num value) => left = value - width; //使用set作为前缀，只接收一个参数value
  set bottom(num value) => top = value - height; //使用set作为前缀，只接收一个参数value
  get square => width * height; //getter函数计算面积，描述Rectangle状态特性
  bool draw() {
    print('draw rect'); //draw绘制函数，触发是动作行为
    return true;
  }
}

main() {
  var rect = Rectangle(3, 4, 20, 15);
  rect.right = 15; //调用setter函数时，可以直接使用类似属性赋值方式调用right函数。
  rect.bottom = 12; //调用setter函数时，可以直接使用类似属性赋值方式调用bottom函数。
  print('the rect square is ${rect.square}');
  rect.draw();
}
```

## 二、面向对象中的变量

### 1、实例变量

实例变量实际上就是类的成员变量或者称为成员属性，当声明一个实例变量时，它会确保每一个对象实例都有自己唯一属性的拷贝。如果要表示实例私有属性的话就直接在属性名前面加下划线 **`_`**,例如`_width`和`_height`

```dart
class Rectangle {
  num left, top, _width, _height;//声明了left,top,_width,_height四个成员属性，未初始化时，它们的默认值都是null
}
```

上述例子中的`left, top, width, height`都是会自动引入一个`getter`和`setter`.事实上，在dart中属性都不是直接访问的，所有对字段属性的引用都是对属性访问器函数的调用, 只有访问器函数才能直接访问它的状态。

### 2、类变量([static变量](https://www.zhihu.com/search?q=static变量&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361}))与顶层变量

**类变量**实际上就是`static`修饰的变量，属于类的作用域范畴；**顶层变量**就是**定义的变量不在某个具体类体内**，而是处于整个代码文件中，相当于文件顶层，和[顶层函数](https://www.zhihu.com/search?q=顶层函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361})差不多意思。`static`变量更多人愿意把它称为**[静态变量](https://www.zhihu.com/search?q=静态变量&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361})**，但是在**Dart中静态变量不仅仅包括static变量还包括顶层变量**。

其实对于**类变量和顶层变量的访问都还是通过调用它的访问器函数来实现的**，但是类变量和顶层变量有点特殊，**它们是延迟初始化的**，在`getter`函数第一次被调用时类变量或顶层变量才执行初始化，也即是第一次引用类变量或顶层变量的时候。如果类变量或顶层变量没有被初始化默认值还是`null`.

```dart
class Animal {}
class Dog extends Animal {}
class Cat extends Animal {
    Cat() {
        print("I'm a Cat!");
    }
}
//注意,这里变量不定义在任何具体类体内，所以这个animal是一个顶层变量。
//虽然看似创建了Cat对象，但是由于顶层变量延迟初始化的原因，这里根本就没有创建Cat对象
Animal animal = Cat();
main() {
    animal = Dog();//然后又将animal引用指向了一个新的Dog对象，
}
```

顶层变量是具有延迟初始化过程，所以`Cat`对象并没有创建，因为整个代码执行中并没有去访问`animal`，所以无法触发第一次`getter`函数，也就导致`Cat`对象没有创建，直接表现是根本就不会输出`I'm a Cat!`这句话。这就是为什么顶层变量是延迟初始化的原因，`static`变量同理。

### 3、final 变量

在Dart中使用 **`final`** 关键字修饰变量，表示该变量初始化后不能再被修改。**`final`** 变量只有 **`getter`** 访问器函数，没有 **`setter`** 函数。类似于Kotlin中的`val`修饰的变量。声明成`final`的变量必须在实例方法运行前进行初始化，所以初始化`final`变量有很多中方法。注意: 建议尽量使用`final`来声明变量

```dart
class Person {
    final String gender = '男';//直接在声明的时候初始化，这种方式比较局限，针对基本数据类型还可以，但如果是一个对象类型就显示不合适了。
    final String name;
    final int age;
    Person(this.name, this.age);//利用构造函数为final变量初始化。
    //上述代码等价于下面实现
    Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
}
```

**`final`与`const`的区别**，就好比Kotlin中的`val`与`const val`之间的区别，**`const`是编译期就进行了初始化**，而 **`final`则是运行期进行初始化**。

### 4、常量对象

在dart有些**对象是在编译期就可以计算的常量**，所以在dart中支持常量对象的定义，**常量对象**的创建需要使用 **`const`** 关键字。**常量对象的创建也是调用类的构造函数，但是注意必须是[常量构造函数](https://www.zhihu.com/search?q=常量构造函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361})**，该构造函数是用 **`const`** 关键字修饰的。常量构造函数**必须是数字、布尔值或[字符串](https://www.zhihu.com/search?q=字符串&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91352361})，此外常量构造函数不能有函数体**，但是它可以有初始化列表。

```dart
class Point {
    final double x, y;
    const Point(this.x, this.y);//常量构造函数，使用const关键字且没有函数体
}

main() {
    const defaultPoint = const Point(0, 0);//创建常量对象
}
```

## 三、构造函数

### 1、主构造函数

**主构造函数**是Dart中创建对象最普通一种构造函数，而且**主构造函数只能有一个，如果没有指定主构造函数，那么会默认自动分配一个默认无参的主构造函数**。此外**dart中构造函数不支持重载**

```dart
class Person {
    var name;
    //隐藏了默认的无参构造函数Person();
}
//等价于:
class Person {
    var name;
    Person();//一般把与类名相同的函数称为主构造函数
}
//等价于
class Person {
    var name;
    Person(){}
}

class Person {
    final String name;
    final int age;
    Person(this.name, this.age);//显式声明有参主构造函数
    Person();//编译异常，注意: dart不支持同时重载多个构造函数。
}
```

**构造函数初始化列表** **`:`**

```dart
class Point3D extends Point {
    double z;
    Point3D(a, b, c): z = c / 2, super(a, b);//初始化列表，多个初始化步骤用逗号分隔；先初始化z ,然后执行super(a, b)调用父类的构造函数
}
//等价于
class Point3D extends Point {
    double z;
    Point3D(a, b, c): z = c / 2;//如果初始化列表没有调用父类构造函数，
    //那么就会存在一个隐含的父类构造函数super调用将会默认添加到初始化列表的尾部
}
```

初始化的顺序如下图:

![img](https://pic1.zhimg.com/80/v2-e9d9aef87e0f3a1d4fa1ceb5e2561bc4_720w.jpg)



**初始化实例变量几种方式**

```dart
//方式一: 通过实例变量声明时直接赋默认值初始化
class Point {
    double x = 0, y = 0;
}

//方式二: 使用构造函数初始化方式
class Point {
    double x, y;
    Point(this.x, this.y);
}

//方式三: 使用初始化列表初始化
class Point {
    double x, y;
    Point(double a, double b): x = a, y = b;//:后跟初始化列表
}

//方式四: 在构造函数中初始化，注意这个和方式二还是有点不一样的。
class Point {
    double x, y;
    Point(double a, double b) {
        x = a;
        y = b;
    }
}
```

### 2、命名构造函数

通过上面主构造函数我们知道在**Dart中的构造函数是不支持重载的，实际上Dart中连基本的普通函数都不支持函数重载**。 那么问题来了，我们经常会遇到构造函数重载的场景，有时候需要指定不同的构造函数形参来创建不同的对象。所以为了解决不同参数来创建对象问题，**虽然抛弃了函数重载，但是引入命名构造函数的概念**。它可以指定任意参数列表来构建对象，只不过的是需要给构造函数指定特定的名字而已。

```dart
class Person {
  final String name;
  int age;

  Person(this.name, this.age);

  Person.withName(this.name);//通过类名.函数名形式来定义命名构造函数withName。只需要name参数就能创建对象，
  //如果没有命名构造函数，在其他语言中，我们一般使用函数重载的方式实现。
}

main () {
  var person = Person('mikyou', 18);//通过主构造函数创建对象
  var personWithName = Person.withName('mikyou');//通过命名构造函数创建对象
}
```

### 3、重定向构造函数

有时候需要将**构造函数重定向到同一个类中的另一个构造函数**，**重定向构造函数的主体为空，构造函数的调用出现在冒号(:)之后**。

```dart
class Point {
    double x, y;
    Point(this.x, this.y);
    Point.withX(double x): this(x, 0);//注意这里使用this重定向到Point(double x, double y)主构造函数中。
}
//或者
import 'dart:math';

class Point {
  double distance;

  Point.withDistance(this.distance);

  Point(double x, double y) : this.withDistance(sqrt(x * x + y * y));//注意:这里是主构造函数重定向到命名构造函数withDistance中。
}
```

### 4、factory工厂构造函数

一般来说，构造函数总是会创建一个新的实例对象。但是有时候会遇到并不是每次都需要创建新的实例，可能需要使用缓存，如果仅仅使用上面普通构造函数是很难做到的。那么这时候就需要**factory工厂构造函数**。**它使用`factory`关键字来修饰构造函数，并且可以从缓存中的返回已经创建实例或者返回一个新的实例**。在dart中任意构造函数都可以被替换成工厂方法， 它看起来和普通构造函数没什么区别，可能没有初始化列表或初始化参数，但是它**必须有一个返回对象的函数体**。

```dart
class Logger {
  //实例属性
  final String name;
  bool mute = false;

  // _cache is library-private, thanks to
  // the _ in front of its name.
  static final Map<String, Logger> _cache =
      <String, Logger>{};//类属性

  factory Logger(String name) {//使用factory关键字声明工厂构造函数，
    if (_cache.containsKey(name)) {
      return _cache[name]//返回缓存已经创建实例
    } else {
      final logger = Logger._internal(name);//缓存中找不到对应的name logger，调用_internal命名构造函数创建一个新的Logger实例
      _cache[name] = logger;//并把这个实例加入缓存中
      return logger;//注意: 最后返回这个新创建的实例
    }
  }

  Logger._internal(this.name);//定义一个命名私有的构造函数_internal

  void log(String msg) {//实例方法
    if (!mute) print(msg);
  }
}
```

## 三、抽象方法、抽象类和接口

抽象方法就是**声明一个方法而不提供它的具体实现**。任何实例的方法都可以是抽象的，包括getter,setter,操作符或者普通方法。含有抽象方法的类本身就是一个抽象类，抽象类的声明使用关键字 **`abstract`**.

```dart
abstract class Person {//abstract声明抽象类
  String name();//抽象普通方法
  get age;//抽象getter
}

class Student extends Person {//使用extends继承
  @override
  String name() {
    // TODO: implement name
    return null;
  }

  @override
  // TODO: implement age
  get age => null;
}
```

在Dart中并没有像其他语言一样有个 `interface`的关键字修饰。因为**Dart中每个类都默认隐含地定义了一个接口**。

```dart
abstract class Speaking {//虽然定义的是抽象类，但是隐含地定义接口Speaking
  String speak();
}

abstract class Writing {//虽然定义的是抽象类，但是隐含地定义接口Writing
  String write();
}

class Student implements Speaking, Writing {//使用implements关键字实现接口
  @override
  String speak() {//重写speak方法
    // TODO: implement speak
    return null;
  }

  @override
  String write() {//重写write方法
    // TODO: implement write
    return null;
  }
}
```

## 四、类函数

类函数顾名思义就是**类的函数，它不属于任何一个实例，所以它也就不能被继承**。类函数使用 **`static`** 关键字修饰，调用时可以直接使用类名.函数名的方式调用。

```dart
class Point {
    double x,y;
    Point(this.x, this.y);
    static double distance(Point p1, Point p2) {//使用static关键字，定义类函数。
        var dx = p1.x - p2.x;
        var dy = p1.y - p2.y;
        return sqrt(dx * dx + dy * dy);
    }
}
main() {
    var point1 = Point(2, 3);
    var point2 = Point(3, 4);
    print('the distance is ${Point.distance(point1, point2)}');//使用Point.distance => 类名.函数名方式调用
}
```



# Dart语法篇之面向对象继承和Mixins(六)

简述:

上一篇文章中我们详细地介绍了Dart中的面向对象的基础，这一篇文章中我们继续探索Dart中面向对象的重点和难点(继承和mixins). mixins(混合)特性是很多语言中都是没有的。这篇文章主要涉及到Dart中的普通继承、mixins多继承的形式(实际上本质并不是真正意义的[多继承](https://www.zhihu.com/search?q=多继承&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129}))、mixins线性化分析、mixins类型、mixins使用场景等。

## 一、类的单继承

### 1、基本介绍

Dart中的单继承和其他语言中类似，都是通过使用 **`extends`** 关键字来声明。例如

```dart
class Student extends Person {//Student类称为子类或派生类，Person类称为父类或基类或超类。这一点和Java中是一致的。
    ...
}
```

### 2、继承中的[构造函数](https://www.zhihu.com/search?q=构造函数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})

- **子类中构造函数会默认调用父类中无参构造函数(一般为主构造函数)**。

```dart
class Person {
  String name;
  String age;

  Person() {
    print('person');
  }
}

class Student extends Person {
  String classRoom;
  Student() {
    print('Student');
  }
}

main(){
  var student = Student();//构造Student()时会先调用父类中无参构造函数，再调用子类中无参构造函数
}
```

输出结果:

```text
person
Student

Process finished with exit code 0
```

- **若父类中没有默认无参的构造函数，则需要显式调用父类的构造函数(可以是命名构造函数也可以主构造函数或其他), 并且在初始化列表的尾部显式调用父类中构造函数, 也即是类构造函数 `:`后面列表的尾部**。

```dart
class Person {
  String name;
  int age;

  Person(this.name, this.age); //指定了带参数的构造函数为主构造函数，那么父类中就没有默认无参构造函数
  //再声明两个命名构造函数
  Person.withName(this.name);

  Person.withAge(this.age);
}

class Student extends Person {
  String classRoom;

  Student(String name, int age) : super(name, age) { //显式调用父类主构造函数
    print('Student');
  }

  Student.withName(String name) : super.withName(name) {} //显式调用父类命名构造函数withName

  Student.withAge(int age) : super.withAge(age) {} //显式调用父类命名构造函数withAge
}

main() {
  var student1 = Student('mikyou', 18);
  var student2 = Student.withName('mikyou');
  var student3 = Student.withAge(18);
}
```

- **父类的构造函数在子类构造函数体开始执行的位置调用，如果有初始化列表，初始化列表会在父类构造函数执行之前执行**。

```dart
class Person {
  String name;
  int age;

  Person(this.name, this.age); //指定了带参数的构造函数为主构造函数，那么父类中就没有默认无参构造函数
}

class Student extends Person {
  final String classRoom;

  Student(String name, int age, String room) : classRoom = room, super(name, age) {//注意super(name, age)必须位于初始化列表尾部
    print('Student');
  }
}

main() {
  var student = Student('mikyou', 18, '三年级八班');
}
```

## 二、基于Mixins的多继承

除了上面和其他语言类似的单继承外，在Dart中还提供了另一继承的机制就是基于**Mixins的多继承**，但是它**不是真正意义上类的多继承，它始终还是只能有一个[超类](https://www.zhihu.com/search?q=超类&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})(基类)**。

### 1、为什么需要Mixins?

为什么需要Mixins多继承？它实际上为了解决单继承所带来的问题，我们很多语言中都是采用**了单继承+接口多实现**的方式。但是这种方式并不能很好适用于所有场景。

假设一下下面场景，我们把车进行分类，然后下面的颜色条表示各种车辆具有的能力。



![img](https://pic4.zhimg.com/80/v2-795c436a05e96c8f984109b60f0e3c0b_720w.jpg)



我们通过上图就可以看到，这些车辆都有一个共同的父类 **`Vehicle`**,然后它又由两个抽象的子类: **`MotorVehicle`** 和 **`NonMotorVehicle`** 。有些类是具有相同的[行为和能力](https://www.zhihu.com/search?q=行为和能力&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})，但是有的类又有自己独有的行为和能力。比如公交车 **`Bus`** 和摩托车 **`Motor`** 都能使用汽油驱动，但是摩托车 **`Motor`** 还能载货公交车 **`Bus`** 却不可以。

如果**仅仅是单继承模型下**，**无法把部分子类具有相同行为和能力抽象放到[基类](https://www.zhihu.com/search?q=基类&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})，因为对于不具有该行为和能力的子类来说是不妥的，所以只能在各自子类另外实现**。那么就问题来了，部分具有相同能力和行为的子类中都要保留一份相同的代码实现。这就是产生冗余，突然觉得单继承模型有点鸡肋，食之无味弃之可惜。

```dart
//单继承模型的普通实现
abstract class Vehicle {}

abstract class MotorVehicle extends Vehicle {}

abstract class NonMotorVehicle extends Vehicle {}

class Motor extends MotorVehicle {
  void petrolDriven() => print("汽油驱动");

  void passengerService() => print('载人');

  void carryCargo() => print('载货');
}

class Bus extends MotorVehicle {
  void petrolDriven() => print("汽油驱动");

  void electricalDriven() => print("电能驱动");

  void passengerService() => print('载人');
}

class Truck extends MotorVehicle {
  void petrolDriven() => print("汽油驱动");

  void carryCargo() => print('载货');
}

class Bicycle extends NonMotorVehicle {
  void electricalDriven() => print("电能驱动");

  void passengerService() => print('载人');
}

class Bike extends NonMotorVehicle {
  void passengerService() => print('载人');
}
```

可以从上述实现代码来看发现，有很多相同冗余代码实现，请注意这里所说的相同代码是连具体实现都相同的。很多人估计想到一个办法那就是将各个能力提升成接口，然后各自的选择去实现相应能力。但是我们知道即使抽成了接口，各个实现类中还是需要写对应的实现代码，冗余还是无法摆脱。不妨我们来试试用接口:

```dart
//单继承+接口多实现
abstract class Vehicle {}

abstract class MotorVehicle extends Vehicle {}

abstract class NonMotorVehicle extends Vehicle {}

//将各自的能力抽成独立的接口，这样的好处就是可以从抽象角度对不同的实现类赋予不同接口能力，
// 职责更加清晰,但是这个只是一方面的问题，它还是无法解决相同能力实现代码冗余的问题
abstract class PetrolDriven {
  void petrolDriven();
}

abstract class PassengerService {
  void passengerService();
}

abstract class CargoService {
  void carryCargo();
}

abstract class ElectricalDriven {
  void electricalDriven();
}

//对于Motor赋予了PetrolDriven、PassengerService、CargoService能力
class Motor extends MotorVehicle implements PetrolDriven, PassengerService, CargoService {
  @override
  void carryCargo() => print('载货');//仍然需要重写carryCargo

  @override
  void passengerService() => print('载人');//仍然需要重写passengerService

  @override
  void petrolDriven() => print("汽油驱动");//仍然需要重写petrolDriven
}

//对于Bus赋予了PetrolDriven、ElectricalDriven、PassengerService能力
class Bus extends MotorVehicle implements PetrolDriven, ElectricalDriven, PassengerService {
  @override
  void electricalDriven() => print("电能驱动");//仍然需要重写electricalDriven

  @override
  void passengerService() => print('载人');//仍然需要重写passengerService

  @override
  void petrolDriven() => print("汽油驱动");//仍然需要重写petrolDriven
}

//对于Truck赋予了PetrolDriven、CargoService能力
class Truck extends MotorVehicle implements PetrolDriven, CargoService {
  @override
  void carryCargo() => print('载货');//仍然需要重写carryCargo

  @override
  void petrolDriven() => print("汽油驱动");//仍然需要重写petrolDriven
}

//对于Bicycle赋予了ElectricalDriven、PassengerService能力
class Bicycle extends NonMotorVehicle implements ElectricalDriven, PassengerService {
  @override
  void electricalDriven() => print("电能驱动");//仍然需要重写electricalDriven

  @override
  void passengerService() => print('载人');//仍然需要重写passengerService
}

//对于Bike赋予了PassengerService能力
class Bike extends NonMotorVehicle implements PassengerService {
  @override
  void passengerService() => print('载人');//仍然需要重写passengerService
}
```

针对相同实现代码冗余的问题，使用Mixins就能很好的解决。**它能复用类中某个行为的具体实现**，**而不是像接口仅仅从抽象角度规定了实现类具有哪些能力，至于具体实现接口方法都必须重写，也就意味着即使是相同的实现还得重新写一遍**。一起看下Mixins改写后代码:

```dart
//mixins多继承模型实现
abstract class Vehicle {}

abstract class MotorVehicle extends Vehicle {}

abstract class NonMotorVehicle extends Vehicle {}

//将各自的能力抽成独立的Mixin类
mixin PetrolDriven {//使用mixin关键字代替class声明一个Mixin类
  void petrolDriven() => print("汽油驱动");
}

mixin PassengerService {//使用mixin关键字代替class声明一个Mixin类
  void passengerService() => print('载人');
}

mixin CargoService {//使用mixin关键字代替class声明一个Mixin类
  void carryCargo() => print('载货');
}

mixin ElectricalDriven {//使用mixin关键字代替class声明一个Mixin类
  void electricalDriven() => print("电能驱动");
}

class Motor extends MotorVehicle with PetrolDriven, PassengerService, CargoService {}//利用with关键字使用mixin类

class Bus extends MotorVehicle with PetrolDriven, ElectricalDriven, PassengerService {}//利用with关键字使用mixin类

class Truck extends MotorVehicle with PetrolDriven, CargoService {}//利用with关键字使用mixin类

class Bicycle extends NonMotorVehicle with ElectricalDriven, PassengerService {}//利用with关键字使用mixin类

class Bike extends NonMotorVehicle with PassengerService {}//利用with关键字使用mixin类
```

可以对比发现Mixins类能真正地解决相同代码冗余的问题，并能实现很好的复用；所以使用[Mixins多继承模型](https://www.zhihu.com/search?q=Mixins多继承模型&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})可以很好地解决单继承模型所带来冗余问题。

### 2、Mixins是什么?

用dart官网一句话来概括: **Mixins是一种可以在多个类层次结构中复用类代码的方式**。

- 基本语法

**方式一:** Mixins类使用关键字 **`mixin`** 声明定义

```dart
mixin PetrolDriven {//使用mixin关键字代替class声明一个Mixin类
  void petrolDriven() => print("汽油驱动");
}

class Motor extends MotorVehicle with PetrolDriven {//使用with关键字来使用mixin类
    ...
}

class Petrol extends PetrolDriven{//编译异常，注意:mixin类不能被继承
    ...
}

main() {
    var petrolDriven = PetrolDriven()//编译异常，注意:mixin类不能实例化
}
```

**方式二:** Dart中的普通类当作Mixins类使用

```dart
class PetrolDriven {
    factory PetrolDriven._() => null;//主要是禁止PetrolDriven被继承以及实例化
    void petrolDriven() => print("汽油驱动");
}

class Motor extends MotorVehicle with PetrolDriven {//普通类也可以作为Mixins类使用
    ...
}
```

### 3、使用Mixins多继承的场景

那么问题来了，什么时候去使用Mixins呢？

**当想要在不同的类[层次结构](https://www.zhihu.com/search?q=层次结构&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})中多个类之间共享相同的行为时或者无法合适抽象出部分子类共同的行为到基类中时**. 比如说上述例子中在 **`MotorVehicle`** ([机动车](https://www.zhihu.com/search?q=机动车&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129}))和 **`Non-MotorVehicle`** (非机动车)两个不同类层次结构中，其中 **`Bus`** (公交车)和 **`Bicycle`** (电动自行车)都有相同行为 **`ElectricalDriven`** 和 **`PassengerService`.** 但是很明显你无法把这个两个共同的行为抽象到基类 **`Vehicle`** 中，因为这样的话 **`Bike`** (自行车)继承 **`Vehicle`** 会自动带有一个 **`ElectricalDriven`** 行为就比较诡异。所以这种场景下**mixins就是一个不错的选择**，**可以跨类层次之间复用相同行为的实现**。

### 4、Mixins的线性化分析

在说Mixins线性化分析之前，一起先来看个例子

```dart
class A {
   void printMsg() => print('A'); 
}
mixin B {
    void printMsg() => print('B'); 
}
mixin C {
    void printMsg() => print('C'); 
}

class BC extends A with B, C {}
class CB extends A with C, B {}

main() {
    var bc = BC();
    bc.printMsg();

    var cb = CB();
    cb.printMsg();
}
```

不妨考虑下上述例子中应该输出啥呢?

输出结果:

```text
C
B

Process finished with exit code 0
```

为什么会是这样的结果？实际上可以通过线性分析得到输出结果。理解Mixin线性化分析有一点很重要就是: **在Dart中Mixins多继承并不是真正意义上的多继承，实际上还是单继承；而每次Mixin都是会创建一个新的中间类。并且这个中间类总是在基类的上层**。

关于上述结论可能有点难以理解，下面通过一张mixins继承结构图就能清晰明白了:



![img](https://pic4.zhimg.com/80/v2-61face2ce56e695328248e33142cabc7_720w.jpg)



通过上图，我们可以很清楚发现**Mixins并不是经典意义上获得多重继承的方法。 Mixins是一种抽象和复用一系列操作和状态的方式，而是生成多个中间的mixin类**(比如生成ABC类，AB类，ACB类，AC类)。它类似于从扩展类获得的复用，但**由于它是线性的，因此与单继承兼容**。

上述[mixins代码](https://www.zhihu.com/search?q=mixins代码&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})在语义理解上可以转化成下面形式:

```dart
//A with B 会产生AB类混合体，B类中printMsg方法会覆盖A类中的printMsg方法,那么AB中间类保留是B类中的printMsg方法
class AB = A with B;
//AB with C 会产生ABC类混合体,C类中printMsg方法会覆盖AB混合类中的printMsg方法，那么ABC中间类保留C类中printMsg方法
class ABC = AB with C;
//最终BC类相当于继承的是ABC类混合体，最后调用的方法是ABC中间类保留C类中printMsg方法，最后输出C
class BC extends ABC {}

//A with C 会产生AC类混合体，C类中printMsg方法会覆盖A类中的printMsg方法,那么AC中间类保留是C类中的printMsg方法
class AC = A with C;
//AC with B 会产生ACB类混合体,B类中printMsg方法会覆盖AC混合类中的printMsg方法，那么ACB中间类保留B类中printMsg方法
class ACB = AC with B;
//最终CB类相当于继承的是ACB类混合体，最后调用的方法是ACB中间类保留B类中printMsg方法，最后输出B
class CB extends ACB {}
```

### 5、Mixins中的类型

有了上面的探索，不妨再来考虑一个问题，mixin的实例对象是什么类型呢? 我们都知道它肯定是它基类的子类型。 一起来看个例子：

```dart
class A {
   void printMsg() => print('A'); 
}
mixin B {
    void printMsg() => print('B'); 
}
mixin C {
    void printMsg() => print('C'); 
}

class BC extends A with B, C {}
class CB extends A with C, B {}

main() {
    var bc = BC();
    print(bc is A);
    print(bc is B);
    print(bc is C);

    var cb = CB();
    print(cb is A);
    print(cb is B);
    print(cb is C);
}
```

输出结果:

```text
true
true
true
true
true
true

Process finished with exit code 0
```

可以看到输出结果全都是`true`, 这是为什么呢？

其实通过上面那张图就能找到答案，我们知道[mixin with](https://www.zhihu.com/search?q=mixin+with&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A91883129})后就会生成新的中间类，比如中间类`AB、ABC`. 同时也会生成 一个新的接口`AB、ABC`(因为所有Dart类都定义了对应的接口, Dart类是可以直接当做接口实现的)。新的中间类`AB`继承基类`A`以及`A`类和`B`类混合的成员(方法和属性)副本，但它也实现了`A`接口和`B`接口。那么就很容易理解，`ABC`混合类最后会实现了`A`、`B`、`C`三个接口，最后`BC`类继承`ABC`类实际上也相当于间接实现了`A`、`B`、`C`三个接口，所以`BC`类肯定是`A`、`B`、`C`的子类型，故所有输出都是`true`。

其实一般情况mixin中间类和接口都是不能直接引用的，比如这种情况:

```dart
class BC extends A with B, C {}//这种情况我们无法直接引用中间AB混合类和接口、ABC混合类和接口
```

但是如果这么写，就能直接引用中间混合类和接口了:

```dart
class A {
  void printMsg() => print('A');
}
mixin B {
  void printMsg() => print('B');
}
mixin C {
  void printMsg() => print('C');
}

class AB = A with B;

class ABC = AB with C;

class D extends AB {}

class E implements AB {
  @override
  void printMsg() {
    // TODO: implement printMsg
  }
}

class F extends ABC {}

class G implements ABC {
  @override
  void printMsg() {
    // TODO: implement printMsg
  }
}

main() {
  var ab = AB();
  print(ab is A);
  print(ab is B);

  var e = E();
  print(e is A);
  print(e is B);
  print(e is AB);

  var abc = ABC();
  print(abc is A);
  print(abc is B);
  print(abc is C);

  var f = F();
  print(f is A);
  print(f is B);
  print(f is C);
  print(f is AB);
  print(f is ABC);
}
```

输出结果:

```text
true
true
true
true
true
true
true
true
true
true
true
true
true

Process finished with exit code 0
```

## 参考资料

- [Dart: What are mixins?](https://link.zhihu.com/?target=https%3A//medium.com/flutter-community/dart-what-are-mixins-3a72344011f3)



# Dart语法篇之类型系统与泛型(七)

简述:

下面开始Dart语法篇的第七篇类型系统和泛型，上一篇我们用了一篇Dart中可空和非空类型译文做了铺垫。实际上，Dart中的类型系统是不够严格，这当然和它的历史原因有关。在dart最开始诞生之初，它的定位是一门像javascript一样的动态语言，[动态语言](https://www.zhihu.com/search?q=动态语言&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943})的类型系统是比较松散的，所以在Dart类型也是可选的。然后动态语言类型系统松散对开发者并不是一件好事，程序逻辑一旦复杂，松散的类型可能就变得混乱，分析起来非常痛苦，但是有静态类型检查可以在编译的时候就快速定位问题所在。

其实，dart类型系统不够严格，这一点不仅仅体现在可选类型上和还没有划分可空与非空类型上，甚至还体现dart中的泛型类型安全上，这一点我会通过对比Kotlin和Dart中泛型实现。你会发现Dart和Kotlin泛型安全完全走不是一个路子，而且dart泛型安全是不可靠的，但是也会发现dart2.0之后对这块做很大的改进。

## 一、可选类型

在Dart中的类型实际上是可选的，也就是在Dart中函数类型，参数类型，变量类型是可以直接省略的。

```dart
sum(a, b, c, d) {//函数参数类型和返回值类型可以省略
  return a + b + c + d;
}

main() {
  print('${sum(10, 12, 14, 12)}');//正常运行
}
```

上述的`sum`函数既没有返回值类型也没有参数类型，可能有的人会疑惑如果`sum`函数最后一个形参传入一个`String`类型会是怎么样。

答案是: 静态类型检查分析正常但是编译运行异常。

```dart
sum(a, b, c, d) {
  return a + b + c + d;
}

main() {
  print('${sum(10, 12, 14, "12312")}');//静态检查类型检查正常，运行异常
}

//运行结果
Unhandled exception:
type 'String' is not a subtype of type 'num' of 'other' //请先记住这个子类型不匹配异常问题，因为在后面会详细分析子类型的含义，而且Dart、Flutter开发中会经常看到这个异常。

Process finished with exit code 255
```

虽然，可选类型从一方面使得整个代码变得简洁以及具有动态性，但是从另一方面它会使得静态检查类型难以分析。但是这也使得dart中失去了基于类型**函数重载**特性。我们都知道函数重载是静态语言中比较常见的语法特性，可是在dart中是不支持的。比如在其他语言我们一般使用构造器重载解决多种方式构造对象的场景，但是dart不支持构造器重载，所以为了解决这个问题，Dart推出了命名构造器的概念。那可选类型语法特性为什么会和函数重载特性冲突呢?

我们可以使用反证法，假设dart支持函数重载，那么可能就会有以下这段代码:

```dart
class IllegalCode {
  overloaded(num data) {

  }
  overloaded(List data){//假设支持函数重载，实际上这是非法的

  }
}

main() {
    var data1 = 100; 
    var data2 = ["100"];
    //由于dart中的类型是可选的，以下函数调用，根本就无法分辨下面代码实际上调用哪个overloaded函数。
    overloaded(data1);
    overloaded(data2);
}
```

个人一些想法，如果仅从可选类型角度去考虑的话，实际上dart现在是可以支持基于类型的函数重载的，因为Dart有类型推导功能。如果dart能够推导出上述data1和data2类型，那么就可以根据推导出的类型去匹配重载的函数。Kotlin就是这样做的，以Kotlin为例:

```kotlin
fun overloaded(data: Int) {
    //....
}

fun overloaded(data: List<String>) {
   //....
}

fun main(args: Array<String>) {
    val data1 = 100 //这里Kotlin也是采用类型推导为Int
    val data2 = listOf("100")//这里Kotlin也是采用类型推导为List<String>
    //所以以下重载函数的调用在Kotlin中是合理的
    overloaded(data1)
    overloaded(data2)
}
```

实际上，Dart官方在Github提到过Dart迁移到新的类型系统中，Dart是有能力支持函数重载的 。具体可以参考这个dartlang的issue: [https://github.com/dart-lang/sdk/issues/26488](https://link.zhihu.com/?target=https%3A//github.com/dart-lang/sdk/issues/26488)



![img](https://pic1.zhimg.com/80/v2-11be61eaa37f30d9e324fe451386ba94_720w.jpg)



但是，dart为什么不支持函数重载呢? 其实，不是没有能力支持，而是没有必要的。其实在很多的现代语言比如GO，Rust中的都是没有函数重载。Kotlin中也推荐使用默认值参数替代函数重载,感兴趣的可以查看我之前的一篇文章[https://juejin.im/post/5ac0dabaf265da237a4d2941](https://link.zhihu.com/?target=https%3A//juejin.im/post/5ac0dabaf265da237a4d2941)。然而在dart中函数也是支持默认值参数的，其实函数重载更容易让人困惑，就比如Java中的`Thread`类中7，8个构造函数重载放在一起，让人就感到困惑。具体参考这个讨论: [https://groups.google.com/a/dartlang.org/forum/#!topic/misc/Ye9wlWih5PA](https://link.zhihu.com/?target=https%3A//groups.google.com/a/dartlang.org/forum/%23!topic/misc/Ye9wlWih5PA)



![img](https://pic4.zhimg.com/80/v2-68ea3fad1f29bda312b95de33eea3677_720w.jpg)



## 二、接口类型

在Dart中没有直接显示声明接口的方法，没有类似`interface`的关键字来声明接口，而是隐性地通过类声明引入。所以每个类都存在一个对应名称隐性的接口，dart中的类型也就是接口类型。

```dart
//定义一个抽象类Person,同时它也是一个隐性的Person接口
abstract class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  get description => "My name is $name, age is $age";
}

//定义一个Student类，使用implements关键字实现Person接口
class Student implements Person {
  @override
  // TODO: implement age
  int get age => null;//重写age getter函数，由于在Person接口中是final修饰，所以它只有getter访问器函数，作为接口实现就是需要重写它所有的函数，包括它的getter或setter方法。

  @override
  // TODO: implement description
  get description => null;//重写定义description方法

  @override
  // TODO: implement name
  String get name => null;//重写name getter函数，由于在Person接口中是final修饰，所以它只有getter访问器函数，作为接口实现就是需要重写它所有的函数，包括它的getter或setter方法。
}

//定义一个Student2类，使用extends关键字继承Person抽象类
class Student2 extends Person {
  Student2(String name, int age) : super(name, age);//调用父类中的构造函数

  @override
  get description => "Student: ${super.description}";//重写父类中的description方法
}
```

## 三、泛型

### 1、泛型的基本介绍

Dart中的泛型和其他语言差不多，但是Dart中的类型是可选的，使用泛型可以限定类型；使用泛型可以减少很多模板代码。

一起来看个例子:

```dart
//这是一个打印int类型msg的PrintMsg
class PrintMsg {
  int _msg;

  set msg(int msg) {
    this._msg = msg;
  }

  void printMsg() {
    print(_msg);
  }
}

//现在又需要支持String，double甚至其他自定义类的Msg，我们可能这么加
class Msg {
  @override
  String toString() {
    return "This is Msg";
  }
}

class PrintMsg {
  int _intMsg;
  String _stringMsg;
  double _doubleMsg;
  Msg _msg;

  set intMsg(int msg) {
    this._intMsg = msg;
  }

  set stringMsg(String msg) {
    this._stringMsg = msg;
  }

  set doubleMsg(double msg) {
    this._doubleMsg = msg;
  }

  set msg(Msg msg) {
    this._msg = msg;
  }

  void printIntMsg() {
    print(_intMsg);
  }

  void printStringMsg() {
    print(_stringMsg);
  }

  void printDoubleMsg() {
    print(_doubleMsg);
  }

  void printMsg() {
    print(_msg);
  }
}

//但是有了泛型以后，我们可以把上述代码简化很多:
class PrintMsg<T> {
  T _msg;

  set msg(T msg) {
    this._msg = msg;
  }

  void printMsg() {
    print(_msg);
  }
}
```

补充一点Dart中可以指定实际的泛型参数类型，也可以省略。省略实际上就相当于指定了[泛型参数](https://www.zhihu.com/search?q=泛型参数&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943})类型为`dynamic`类型。

```dart
class Test {
  List<int> nums = [1, 2, 3, 4];
  Map<String, int> maps = {'a': 1, 'b': 2, 'c': 3, 'd': 4};

//上述定义可简写成如下形式,但是不太建议使用这种形式，仅在必要且适当的时候使用
  List nums = [1, 2, 3, 4];
  Map maps = {'a': 1, 'b': 2, 'c': 3, 'd': 4};

//上述定义相当于如下形式
  List<dynamic> nums = [1, 2, 3, 4];
  Map<dynamic, dynamic> maps = {'a': 1, 'b': 2, 'c': 3, 'd': 4};
}
```

### 2、泛型的使用

- 类泛型的使用

\```dart //定义类的泛型很简单，只需要在类名后加: ；如果需要多个泛型类型参数，可以在尖括号中追加，用逗号分隔 class List { T element;

```dart
void add(T element) {
  //...
}
```

} ```

- 函数泛型的使用

\```dart //定义函数的泛型 void add(T elememt) {//函数参数类型为[泛型类型](https://www.zhihu.com/search?q=泛型类型&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943}) //... }

T elementAt(int index) {//函数参数返回值类型为泛型类型 //... }

E transform(R data) {//函数参数类型和函数参数返回值类型均为泛型类型 //... } ```

- 集合泛型的使用

\```dart var list = [1, 2, 3]; //相当于如下形式 List list = [1, 2, 3];

var map = {'a':1, 'b':2, 'c':3}; //相当于如下形式 Map map = {'a':1, 'b':2, 'c':3}; ```

- 泛型的上界限定

```dart
dart //和Java一样泛型上界限定可以使用extends关键字来实现 class List<T extends num> { T element; void add(T element) { //... } }
```

### 3、子类、子类型和子类型化关系

- 泛型类与非泛型类

我们可以把Dart中的类可分为两大类: **泛型类**和**非泛型类**

先说**非泛型类**也就是开发中接触最多的一般类，一般的类去定义一个变量的时候，它的**类**实际就是这个变量的类型. 例如定义一个Student类，我们会得到一个Student类型

泛型类比非泛型类要更加复杂，实际上**一个泛型类可以对应无限种类型**。为什么这么说，其实很容易理解。我们从前面文章知道，在定义泛型类的时候会定义[泛型形参](https://www.zhihu.com/search?q=泛型形参&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943})，要想拿到一个合法的泛型类型就需要在外部使用地方传入具体的类型实参替换定义中的类型形参。我们知道在Dart中`List`是一个类，它不是一个类型。由它可以衍生成无限种泛型类型。例如`List<String>、List<int>、List<List<num>>、List<Map<String,int>>`

- 何为子类型

我们可能会经常在Flutter开发中遇到subtype子类型的错误: `type 'String' is not a subtype of type 'num' of 'other'`. 到底啥是子类型呢? 它和子类是一个概念吗?

首先给出一个数学归纳公式:

**如果G是一个有n个类型参数的泛型类，而A[i]是B[i]的子类型且属于 1..n的范围，那么可表示为G \* G的子类型，其中 A \* B 可表示A是B的子类型。**

上述是不是很抽象，其实Dart中的子类型概念和Kotlin中子类型概念极其相似。

我们一般说**子类**就是[派生类](https://www.zhihu.com/search?q=派生类&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943})，该类一般会继承它的父类(也叫基类)。例如: `class Student extends Person{//...}`,这里的Student一般称为Person的**子类**。

而**子类型**则不一样，我们从上面就知道一个类可以有很多类型，那么子类型不仅仅是想子类那样继承关系那么严格。子类型定义的规则一般是这样的: **任何时候如果需要的是A类型值的任何地方，都可以使用B类型的值来替换的，那么就可以说B类型是A类型的子类型或者称A类型是B类型的超类型**。可以明显看出子类型的规则会比子类规则更为宽松。那么我们可以一起分析下面几个例子:



![img](https://pic2.zhimg.com/80/v2-9953fe6f8ef700226eb36beddc8f0c4d_720w.jpg)



**注意:** **某个类型也是它自己本身的子类型，很明显String类型的值任意出现地方，String肯定都是可以替换的**。属于[子类关系](https://www.zhihu.com/search?q=子类关系&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943})的一般也是子类型关系。像double类型值肯定不能替代int类型值出现的地方，所以它们不存在子类型关系.

- 子类型化关系:

**如果A类型的值在任何时候任何地方出现都能被B类型的值替换，B类型就是A类型的子类型，那么B类型到A类型之间这种映射替换关系就是子类型化关系**

### 4、协变(covariant)

一提到协变，可能我们还会对应另外一个词那就是逆变，实际上在Dart1.x的版本中是既支持协变又支持逆变的，但是在Dart2.x版本仅仅支持协变的。有了子类型化关系的概念，那么协变就更好理解了，协变实际上就是**保留子类型化关系**，首先，我们需要去明确一下这里所说的保留子类型化关系是针对谁而言的呢?

比如说`int`是`num`的子类型，因为**在Dart中所有泛型类都默认是协变**的，所以`List<int>`就是`List<num>`的子类型，这就是保留了子类型化关系，保留的是泛型参数(`int`和`num`)类型的子类型化关系.

一起看个例子:

```dart
class Fruit {
  final String color;

  Fruit(this.color);
}

class Apple extends Fruit {
  Apple() : super("red");
}

class Orange extends Fruit {
  Orange() : super("orange");
}

void printColors(List<Fruit> fruits) {
  for (var fruit in fruits) {
    print('${fruit.color}');
  }
}

main() {
  List<Apple> apples = <Apple>[];
  apples.add(Apple());
  printColors(apples);//Apple是Fruit的子类型，所以List<Apple>是List<Fruit>子类型。
  // 所以printColors函数接收一个List<Fruit>类型，可以使用List<Apple>类型替代
  List<Orange> oranges = <Orange>[];
  oranges.add(Orange());
  printColors(oranges);//同理

  List<Fruit> fruits = <Fruit>[];
  fruits.add(Fruit('purple'));
  printColors(fruits);//Fruit本身也是Fruit的子类型，所以List<Fruit>肯定是List<Fruit>子类型
}
```

### 5、协变在Dart中的应用

实际上，在Dart中协变默认用于泛型类型实际上还有用于另一种场景**协变方法参数类型**. 可能对专业术语有点懵逼，先通过一个例子来看下:

```dart
//定义动物基类
class Animal {
  final String color;

  Animal(this.color);
}

//定义Cat类继承Animal
class Cat extends Animal {
  Cat() : super('black cat');
}

//定义Dog类继承Animal
class Dog extends Animal {
  Dog() : super('white dog');
}

//定义一个装动物的笼子类
class AnimalCage {
  void putAnimal(Animal animal) {
    print('putAnimal: ${animal.color}');
  }
}

//定义一个猫笼类
class CatCage extends AnimalCage {
  @override
  void putAnimal(Animal animal) {//注意: 这里方法参数是Animal类型
    super.putAnimal(animal);
  }
}

//定义一个狗笼类
class DogCage extends AnimalCage {
    @override
    void putAnimal(Animal animal) {//注意: 这里方法参数是Animal类型
      super.putAnimal(animal);
    }
}
```

我们需要去重写putAnimal方法，由于是继承自AnimalCage类，所以方法参数类型是Animal.这会造成什么问题呢? 一起来看下:

```dart
main() {
  //创建一个猫笼对象
  var catCage = CatCage();
  //然后却可以把一条狗放进去，如果按照设计原理应该猫笼子只能put猫。
  catCage.putAnimal(Dog());//这行静态检查以及运行都可以通过。

  //创建一个狗笼对象
  var dogCage = DogCage();
  //然后却可以把一条猫放进去，如果按照设计原理应该狗笼子只能put狗。
  dogCage.putAnimal(Cat());//这行静态检查以及运行都可以通过。
}
```

其实对于上述的出现问题，我们更希望putAnimal的参数更具体些，为了解决上述问题你需要使用 **`covariant`** 协变关键字。

```dart
//定义一个猫笼类
class CatCage extends AnimalCage {
  @override
  void putAnimal(covariant Cat animal) {//注意: 这里使用covariant协变关键字 表示CatCage对象中的putAnimal方法只接收Cat对象
    super.putAnimal(animal);
  }
}

//定义一个狗笼类
class DogCage extends AnimalCage {
    @override
    void putAnimal(covariant Dog animal) {//注意: 这里使用covariant协变关键字 表示DogCage对象中的putAnimal方法只接收Dog对象
      super.putAnimal(animal);
    }
}
//调用
main() {
  //创建一个猫笼对象
  var catCage = CatCage();
  catCage.putAnimal(Dog());//这时候这样调用就会报错, 报错信息: Error: The argument type 'Dog' can't be assigned to the parameter type 'Cat'.
}
```

为了进一步验证结论，可以看下这个例子:

```dart
typedef void PutAnimal(Animal animal);

class TestFunction {
  void putCat(covariant Cat animal) {}//使用covariant协变关键字

  void putDog(Dog animal) {}

  void putAnimal(Animal animal) {}
}

main() {
  var function = TestFunction()
  print(function.putCat is PutAnimal);//true 因为使用协变关键字
  print(function.putDog is PutAnimal);//false
  print(function.putAnimal is PutAnimal);//true 本身就是其子类型
}
```

### 6、为什么Kotlin比Dart的泛型型变更安全

实际上Dart和Java一样，泛型型变都存在安全问题。以及`List`集合为例，`List`在Dart中既是**可变的，又是协变的**，这样就会存在安全问题。然而Kotlin却不一样，在Kotlin把集合分为可变集合`MutableList<E>`和只读集合`List<E>`，其中`List<E>`在Kotlin中就是**不可变的，协变的**，这样就不会存在安全问题。下面这个例子将对比Dart和Kotlin的实现:

- Dart中的实现

```dart
class Fruit {
  final String color;

  Fruit(this.color);
}

class Apple extends Fruit {
  Apple() : super("red");
}

class Orange extends Fruit {
  Orange() : super("orange");
}

void printColors(List<Fruit> fruits) {//实际上这里List是不安全的。
  for (var fruit in fruits) {
    print('${fruit.color}');
  }
}

main() {
  List<Apple> apples = <Apple>[];
  apples.add(Apple());
  printColors(apples);//printColors传入是一个List<Apple>，因为是协变的
}
```

为什么说printColors函数中的`List<Fruit>`是不安全的呢，外部`main`函数中传入的是一个`List<Apple>`.所以printColors函数中的`fruits`实际上是一个`List<Apple>`.可是`printColors`这样改动呢?

```dart
void printColors(List<Fruit> fruits) {//实际上这里List是不安全的。
  fruits.add(Orange());//静态检查都是通过的,Dart1.x版本中运行也是可以通过的，但是好在Dart2.x版本进行了优化，
  // 在2.x版本中运行是会报错的:type 'Orange' is not a subtype of type 'Apple' of 'value'
  // 由于在Dart中List都是可变的，在fruits中添加Orange(),实际上是在List<Apple>中添加Orange对象，这里就会出现安全问题。
  for (var fruit in fruits) {
    print('${fruit.color}');
  }
}
```

- Kotlin中的实现

然而在Kotlin中的不会存在上面那种问题，Kotlin对集合做了很细致的划分，分为可变与只读。只读且协变的泛型类型更具安全性。一起看下Kotlin怎么做到的。

```kotlin
open class Fruit(val color: String)

class Apple : Fruit("red")

class Orange : Fruit("orange")

fun printColors(fruits: List<Fruit>) {
    fruits.add(Orange())//此处编译不通过，因为在Kotlin中只读集合List<E>，没有add, remove之类修改集合的方法只有读的方法，
    //所以它不会存在List<Apple>中还添加一个Orange的情况出现。
    for (fruit in fruits) {
        println(fruit.color)
    }
}

fun main() {
    val apples = listOf(Apple())
    printColors(apples)
}
```

## 四、类型具体化

### 1、类型检测

在Dart中一般使用 **`is`** 关键字做类型检测，这一点和Kotlin中是一致的，如果判断不是某个类型dart中使用**is!**, 而在Kotlin中正好相反则用 **!is** 表示。类型检测就是对表达式结果值的动态类型与目标类型做对比测试。

```dart
main() {
  var apples = [Apple()];
  print(apples is List<Apple>);
}
```

### 2、强制类型转化

强制类型转换在Dart中一般使用 **as** 关键字，这一点也和Kotlin中是一致的。强制类型转换是对一个表达式的值转化目标类型，如果转化失败就会抛出`CastError`异常。

```dart
Object o = [1, 2, 3];
o as List;
o as Map;//抛出异常
```

## 五、总结

到这里我们就把Dart中的[类型系统](https://www.zhihu.com/search?q=类型系统&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"article"%2C"sourceId"%3A93671943})和泛型介绍完毕了，相信这篇文章将会使你对Dart中的类型系统有一个更全面的认识。其实通过Dart中泛型，就会发现Dart2.x真的优化很多东西，比如泛型安全的问题，虽然静态检查能通过但是运行无法通过，换做Dart1.x运行也是可以通过的。Dart2.x将会越来越严谨越来越完善，说明Dart在改变这是一件好事，一起期待它的更多特性。下一篇我们将进入Dart中更为核心的部分异步编程系列，感谢关注~~~.