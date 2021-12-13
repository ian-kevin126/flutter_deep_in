learDart() {
  testVariable();
  testFunction();
  testMixin();
  testFuture();
  testStream();
}

// 1，变量声明
void testVariable() {
  // 1，类似于JavaScript中的var，它可以接受任何类型的变量，不同的是，Dart中的var变量一旦赋值，类型便会确定，再不能改变其类型。
  var hi = 'hello world';
  // hi = 3;  // A value of type 'int' can't be assigned to a variable of type 'String'

  // 2，dynamic和Object，Object是dart所有对象的根基类，也就是说在dart中所有类型都是Object的子类（包括Function和Null），所以任何类型的数据都可以赋值给Object声明的变量
  // dynamic和Object声明的变量都可以赋值任意变量，且后期可以改变赋值的类型，这和car是不同的
  dynamic a;
  Object b;

  a = 'hi world';
  b = 'hi flutter';

  a = 1;
  b = false;

  // dynamic 与 Object 不同的是，dynamic声明的对象编译器会提供所有可能的组合，而Object声明的对象只能使用Object的属性和方法，否则编译器会报错
  // print(b.length); // The getter 'length' isn't defined for the type 'Object'.
  print(a + 2);

  // dynamic这个特点使得我们在使用它的时候需要格外注意，这很容易引入一个运行时错误，比如下面代码在编译时不会报错，而在运行时会报错
  // print(a.xx); // a是number类型的，没有xx属性，编译时不会报错，运行时会报错。

  // 3，final和const：如果你打算定义一个以后不会更改的变量，那么使用final或者const。
  // 两者的区别是：const变量是一个编译时常量（编译时直接替换为常量值），final变量在第一次使用时被初始化。被final和const修饰的变量，变量类型可以省略。
  // 都可以省略String这个类型声明

  // const String str_1 = 'hi world';
  const str_1 = 'hi world';
  final str_2 = 'hi dart';
  final String str_3 = 'hi world';

  // 4，空安全（null-safety）：dart中一切都是对象，这意味着如果我们定义一个数字，在初始化它之前如果我们使用了它，加入没有某种检查机制，则不会报错。
  // test(){
  //   int i;
  //   print(i * 8);
  // }
  // 在引入空安全之前，上面的代码在执行前不会报错，但会触发一个运行时错误，原因是i的值为null。但是现在又了空安全，在定义变量时我们可以指定变量是可空还是不可空

  int i = 8; // 默认不可空，必须在定义时初始化
  int? j; // 定义为可空，对于可空变量，我们在使用前必须判空

  // 如果我们预期变量不能为空，但在定义时不能确定其初始值，则可以加上late关键字
  // 表示稍后会初始化，但是在正式使用它之前必须得保证初始化过了，否则会报错
  late int k;
  k = 9;

  // 如果一个变量我们定义为可空类型，在某些情况下，即使我们给它赋值过了，但是预处理器仍然有可能识别不出，这时候我们就要显示
  //（通过在变量后面加一个“！“符号）告诉预处理器它已经不是null了，比如：
  //  test() {
  //   int? i;
  //   Function? fun;
  //
  //   say(){
  //     if(i != null) {
  //       print(i! * 8); // The '!' will have no effect because the receiver can't be null.
  //     }
  //     if(fun != null) {
  //       fun!(); // The '!' will have no effect because the receiver can't be null.
  //     }
  //   }
  //
  //   say?.call(); // The receiver can't be null, so the null-aware operator '?.' is unnecessary.
  // }
}

// 2，函数：dart是一种真正的面向对象的语言，所以即使是函数也是对象，并且有一个类型Function。这意味着函数可以赋值给变量或者作为参数传递给其他函数，这是函数式编程的典型特征。
testFunction() {
  // 1）函数声明
  bool isNoble(int? atomicNumber) {
    return atomicNumber != null;
  }
  // dart函数声明如果没有显式声明返回值类型时，会默认当做dynamic处理，【注意，函数返回值没有类型推断】，实例见下面：// typedef bool CALLBACK();

  // 2）对于只包含一个表达式的函数，可以使用简写语法：
  bool isNumber(int b) => true;

  // 3）函数作为变量
  var say = (str) {
    print(str);
  };
  say('hi');

  // 4）函数作为参数传递
  void execute(var callback) {
    callback();
  }

  execute(() => print('xx'));

  // 5）可选的位置参数：包装一组函数参数，用[]标记为可选的未知参数，并放在参数列表的最后面
  String saySomething(String from, String msg, [String? device]) {
    var result = '$from says $msg';
    if (device != null) {
      result = '$result with a $device';
    }
    print('$result');
    return result;
  }

  saySomething('Kevin', 'Tom'); // Kevin says Tom
  saySomething('Kevin', 'Tom', 'something'); // Kevin says Tom with a something

  // 6）可选的命名参数：定义函数时，使用{param 1, param 2, ...}，放在参数列表的最后面，用于指定命名参数
  void enableFlags(int a, {int? bold, int? hidden}) {
    if (bold != 2 && hidden != 2) {
      print('true');
    }
    print('false');
  }

  enableFlags(1, bold: 2, hidden: 2);

  // 【注意：可选命名参数在flutter中使用非常多，不能同时使用可选的位置参数和可选的命名参数。】
}

// typedef bool CALLBACK();
//
// // 不指定返回类型，此时默认为dynamic，不是bool
// isNobleFun(int? a) {
//   return a != null;
// }
//
// void testFu(CALLBACK cb) {
//   print(cb());
// }
//
// // 报错，isNobleFun不是bool类型
// testFu(isNobleFun);

// 3，Mixin
testMixin() {
  // dart是不支持多继承的，但是它支持Mixin，简单来讲mixin可以“组合”多个类，我们通过一个例子来理解。
}

class Person {
  say() {
    print('say');
  }
}

mixin Eat {
  eat() {
    print('eat');
  }
}

mixin Walk {
  walk() {
    print('walk');
  }
}

mixin Code {
  code() {
    print('code');
  }
}

class Dog with Eat, Walk {}

class Man extends Person with Eat, Walk, Code {}

// 我们定义了几个mixin，然后通过with关键字将它们组合成不同的类，有一点需要注意，如果多个mixin中有同名方法，with时，会默认使用最后面的
// mixin的，mixin方法中可以通过super关键字调用之前mixin或类中的方法。

// 4，异步支持（一）—— Future
// dart类库有非常多的返回Future或者stream对象的函数，这些函数被称为异步函数：它们只会在设置好一些耗时操作之后返回，比如IO操作，而不是等到这个操作完成。
// async和await关键字支持了异步编程，允许你用同步的代码实现异步的逻辑。
testFuture() {
  // Future：它与JavaScript中高端Promise非常相似，表示一个异步操作的最终完成（或失败）及其结果值的表示，简单来说，他就是用于处理异步操作的，
  // 异步处理成功了它就执行成功的操作，异步处理失败了就捕获错误或者停止后续的操作，一个Future只会对应一个结果，要么成功，要么失败。
  // 【需要注意的是，跟JavaScript中类似，Future的所有api的返回值仍然是一个Future对象，所以可以很方便地进行链式调用。

  // 1）Future.then()：为了方便，我们使用Future.delayed创建了一个延时任务（实际场景会是一个真正耗时的任务，比如一次网络请求），即2秒之后返回结果字符串
  // 然后我们在then中接收异步结果并打印结果。
  Future.delayed(Duration(seconds: 2), () {
    return 'hello world';
  }).then((value) => print('$value'));

  // 2）Future.catchError()：如果异步任务发生错误，我们可以在catchError中捕获错误
  Future.delayed(Duration(seconds: 2), () {
    throw AssertionError('Error');
  })
      .then((value) => {
            // 执行成功会走这里
            print('success')
          })
      .catchError((e) {
    // 执行失败会走这里
    print(e);
  });

  // 但是，并不是只有catchError回调才能捕获错误，then方法还有一个可选参数 onError，我们也可以用它来捕获异常
  Future.delayed(Duration(seconds: 2), () {
    throw AssertionError('Error');
  }).then(
      (value) => {
            // 执行成功会走这里
            print('success')
          }, onError: (e) {
    // 执行失败会走这里
    print(e);
  });

  // 3）Future.whenComplete()：有些时候，我们会遇到无论异步任务执行成功或失败都需要处理的一些场景，比如网络请求前弹出加载对话框
  // 在请求结束后关闭对话框的。这种场景有两种方法，第一种是分别在then和catchError中关闭对话框，第二种就是使用Future的whenComplete回调
  Future.delayed(Duration(seconds: 2), () {
    throw AssertionError('Error');
  })
      .then((value) => {
            // 执行成功会走这里
            print('success')
          })
      .catchError((e) {
    // 执行失败会走这里
    // print(e);
  }).whenComplete(() => {
            // 无论成功或失败都会走这里
            print('complete')
          });

  // 4）Future.wait()：有些时候我们需要等待多个异步任务执行完毕之后才进行下一步。
  Future.wait([
    // 2秒后返回结果
    Future.delayed(Duration(seconds: 2), () {
      return "hello";
    }),
    // 4秒后返回结果
    Future.delayed(Duration(seconds: 4), () {
      return " world";
    })
  ]).then((results) {
    print(results[0] + results[1]);
  }).catchError((e) {
    print(e);
  });

  // 5）async和await：消除毁掉地狱
  // task() async {
  //   try{
  //     String id = await login("alice","******");
  //     String userInfo = await getUserInfo(id);
  //     await saveUserInfo(userInfo);
  //     //执行接下来的操作
  //   } catch(e){
  //     //错误处理
  //     print(e);
  //   }
  // }
}

// 4，异步支持（二）—— Stream
// Stream 也是用于接收异步事件数据，和Future不同的是，它可以接收多个异步操作的结果（成功或失败）。也就是说，在执行异步任务时，可以通过多次触发成功或失败
// 事件来传递结果数据或错误异常，Stream常用于多次读取数据的异步任务场景，如网络内容下载、文件读写等。
testStream() {
  Stream.fromFutures([
    // 1秒后返回结果
    Future.delayed(Duration(seconds: 1), () {
      return "hello 1";
    }),
    // 抛出一个异常
    Future.delayed(Duration(seconds: 2), () {
      throw AssertionError("Error");
    }),
    // 3秒后返回结果
    Future.delayed(Duration(seconds: 3), () {
      return "hello 3";
    })
  ]).listen((data) {
    print(data);
  }, onError: (e) {
    print(e.message);
  }, onDone: () {
    print('done');
  });
}
