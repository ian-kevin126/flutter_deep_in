import 'package:flutter/material.dart';
import 'package:flutter_deep_in/test/dart_basics.dart';

void main() {
  runApp(MyApp());
}

// 在flutter中，大多数东西都是widget（组件），flutter在构建页面时，会调用组件的build方法，widget的主要工作是提供一个build()方法来描述如何构建UI页面
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp 是Material 库中提供的 Flutter APP 框架，通过它可以设置应用的名称、主题、语言、首页及路由列表等。MaterialApp也是一个 widget。
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// StatefulWidget可以拥有状态，这些状态在widget生命周期中是可以变的，而StatelessWidget是不可变的。
// StatefulWidget至少由两个类组成：一个StatefulWidget类和一个State类，StatefulWidget本身是不变的，但是State类中持有的状态在widget生命周期中可能会变化
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  // _MyHomePageState类是MyHomePage类对应的状态类。看到这里，读者可能已经发现：和MyApp 类不同， MyHomePage类中并没有build方法，取而代之的是，build方法被挪到了_MyHomePageState方法中。
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// State类，包含三个主要的东西：
class _MyHomePageState extends State<MyHomePage> {
  // 1，该组件的状态
  int _counter = 0;

  // 2，操作状态的方法
  void _incrementCounter() {
    learDart();
    // setState方法的作用是通知Flutter框架，有状态发生了改变，Flutter框架收到通知后，会执行build方法来根据新的状态重新构建页面，flutter
    // 对此方法作了优化，使重新执行变得很快，所以我们可以重新构建任何需要更新的部分，而无需分别去修改各个widget。
    setState(() {
      _counter++;
    });
  }

  // 3，构建UI界面
  // 构建UI界面的逻辑在build方法中，当MyHomePage第一次创建时，_MyHomePageState类会被创建，当初始化完成后，Flutter框架会调用 widget 的build方法来构建 widget 树，
  // 最终将 widget 树渲染到设备屏幕上。
  @override
  Widget build(BuildContext context) {
    // Scaffold 是 Material 库中提供的页面脚手架，它提供了默认的导航栏、标题和包含主屏幕 widget 树（后同“组件树”或“部件树”）的body属性，组件树可以很复杂。路由默认都是通过Scaffold创建。
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

//为什么要将 build 方法放在 State 中，而不是放在StatefulWidget中？
//现在，我们回答之前提出的问题，为什么build()方法放在State（而不是StatefulWidget）中 ？这主要是为了提高开发的灵活性。如果将build()方法放在StatefulWidget中则会有两个问题：
// 1，状态访问不便。
// 试想一下，如果我们的StatefulWidget有很多状态，而每次状态改变都要调用build方法，由于状态是保存在 State 中的，如果build方法在StatefulWidget中，那么build方法和状态分别在两个类中，
// 那么构建时读取状态将会很不方便！试想一下，如果真的将build方法放在 StatefulWidget 中的话，由于构建用户界面过程需要依赖 State，所以build方法将必须加一个State参数，大概是下面这样：
// Widget build(BuildContext context, State state){
//   //state.counter
//   ...
// }
// 这样的话就只能将State的所有状态声明为公开的状态，这样才能在State类外部访问状态！但是，将状态设置为公开后，状态将不再具有私密性，这就会导致对状态的修改将会变的不可控。但如果将build()方法放在
// State中的话，构建过程不仅可以直接访问状态，而且也无需公开私有状态，这会非常方便。
//
// 2，继承StatefulWidget不便。
// 例如，Flutter 中有一个动画 widget 的基类AnimatedWidget，它继承自StatefulWidget类。AnimatedWidget中引入了一个抽象方法build(BuildContext context)，继承自AnimatedWidget的动画
// widget 都要实现这个build方法。现在设想一下，如果StatefulWidget 类中已经有了一个build方法，正如上面所述，此时build方法需要接收一个 State 对象，这就意味着AnimatedWidget必须将自己的
// State 对象(记为_animatedWidgetState)提供给其子类，因为子类需要在其build方法中调用父类的build方法，代码可能如下：

// class MyAnimationWidget extends AnimatedWidget{
//  @override
//  Widget build(BuildContext context, State state){
//    //由于子类要用到AnimatedWidget的状态对象_animatedWidgetState，
//    //所以AnimatedWidget必须通过某种方式将其状态对象_animatedWidgetState
//    //暴露给其子类
//    super.build(context, _animatedWidgetState)
//  }
//}

//这样很显然是不合理的，因为 AnimatedWidget 的状态对象是AnimatedWidget内部实现细节，不应该暴露给外部。
//如果要将父类状态暴露给子类，那么必须得有一种传递机制，而做这一套传递机制是无意义的，因为父子类之间状态的传递和子类本身逻辑是无关的。
//综上所述，可以发现，对于StatefulWidget，将build方法放在 State 中，可以给开发带来很大的灵活性。