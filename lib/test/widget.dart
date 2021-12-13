import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


// 在 Flutter 中， widget 的功能是“描述一个UI元素的配置信息”，它就是说， Widget 其实并不是表示最终绘制在设备屏幕上的显示元素，所谓的配置信息就是 Widget 接收的参数，
// 比如对于 Text 来讲，文本的内容、对齐方式、文本样式都是它的配置信息。

// @immutable 代表 Widget 是不可变的，这会限制 Widget 中定义的属性（即配置信息）必须是不可变的（final），为什么不允许 Widget 中定义的属性变化呢？这是因为，Flutter
// 中如果属性发生则会重新构建Widget树，即重新创建新的 Widget 实例来替换旧的 Widget 实例，所以允许 Widget 的属性变化是没有意义的，因为一旦 Widget 自己的属性变了自己就会被替换。
// 这也是为什么 Widget 中定义的属性必须是 final 的原因。

// widget类继承自DiagnosticableTree，DiagnosticableTree即“诊断树”，主要作用是提供调试信息
@immutable // 不可变的
abstract class Widget extends DiagnosticableTree {
  // Key: 这个key属性类似于 React/Vue 中的key，主要的作用是决定是否在下一次build时复用旧的 widget ，决定的条件在canUpdate()方法中。
  const Widget({ this.key });

  final Key? key;

  // createElement()：正如前文所述“一个 widget 可以对应多个Element”；Flutter 框架在构建UI树时，会先调用此方法生成对应节点的Element对象。此方法是 Flutter 框架隐式调用的，在我们开发过程中基本不会调用到
  @protected
  @factory
  Element createElement();

  @override
  String toStringShort() {
    final String type = objectRuntimeType(this, 'Widget');
    return key == null ? type : '$type-$key';
  }
  // debugFillProperties(...) 复写父类的方法，主要是设置诊断树的一些特性。
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.dense;
  }

  @override
  @nonVirtual
  bool operator ==(Object other) => super == other;

  @override
  @nonVirtual
  int get hashCode => super.hashCode;

  // canUpdate(...)是一个静态方法，它主要用于在 widget 树重新build时复用旧的 widget ，其实具体来说，应该是：是否用新的 widget 对象去更新旧UI树上所对应的Element对象的配置；通过其源码我们可以看到，
  // 只要new widget与old widget的runtimeType和key同时相等时就会用new widget去更新Element对象的配置，否则就会创建新的Element。
  static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType
        && oldWidget.key == newWidget.key;
  }
}

// Widget类本身是一个抽象类，其中最核心的就是定义了createElement()接口，在 Flutter 开发中，我们一般都不用直接继承Widget类来实现一个新组件，相反，我们通常会通过继承StatelessWidget或StatefulWidget
// 来间接继承widget类来实现。StatelessWidget和StatefulWidget都是直接继承自Widget类，而这两个类也正是 Flutter 中非常重要的两个抽象类，它们引入了两种 widget 模型。

// 既然 Widget 只是描述一个UI元素的配置信息，那么真正的布局、绘制是由谁来完成的呢？Flutter 框架的的处理流程是这样的：

// 1，根据 Widget 树生成一个 Element 树，Element 树中的节点都继承自 Element 类。
// 2，根据 Element 树生成 Render 树（渲染树），渲染树中的节点都继承自RenderObject 类。
// 3，根据渲染树生成 Layer 树，然后上屏显示，Layer 树中的节点都继承自 Layer 类。
// 真正的布局和渲染逻辑在 Render 树中，Element 是 Widget 和 RenderObject 的粘合剂，可以理解为一个中间代理。我们通过一个例子来说明，假设有如下 Widget 树：
// Container( // 一个容器 widget
//   color: Colors.blue, // 设置容器背景色
//   child: Row( // 可以将子widget沿水平方向排列
//     children: [
//     Image.network('https://www.example.com/1.png'), // 显示图片的 widget
//     const Text('A'),
//   ],
//   ),
// );
// 注意，如果 Container 设置了背景色，Container 内部会创建一个新的 ColoredBox 来填充背景，相关逻辑如下：
// if (color != null) current = ColoredBox(color: color!, child: current);

// 而 Image 内部会通过 RawImage 来渲染图片、Text 内部会通过 RichText 来渲染文本，所以最终的 Widget树、Element 树、渲染树结构如下：

// 这里需要注意：
// 三棵树中，Widget 和 Element 是一一对应的，但并不和 RenderObject 一一对应。比如 StatelessWidget 和 StatefulWidget 都没有对应的 RenderObject。
// 渲染树在上屏前会生成一棵 Layer 树，这个我们将在后面原理篇介绍，在前面的章节中读者只需要记住以上三棵树就行。

// >>>>> StatelessWidget
// 它继承自Widget类，重写了createElement方法：
// @override
// StatelessElement createElement() => StatelessElement(this);

// StatelessElement间接继承自Element类，与StatelessWidget相对应（作为其配置数据）；StatelessWidget用于不需要维护状态的场景，它通常在build方法中通过其它widget来构建UI
// 在构建过程中会递归地构建其嵌套的widget。

// class ContextRoute extends StatelessWidget  {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Context测试"),
//       ),
//       body: Container(
//         child: Builder(builder: (context) {
//           // 在 widget 树中向上查找最近的父级`Scaffold`  widget
//           Scaffold scaffold = context.findAncestorWidgetOfExactType<Scaffold>();
//           // 直接返回 AppBar的title， 此处实际上是Text("Context测试")
//           return (scaffold.appBar as AppBar).title;
//         }),
//       ),
//     );
//   }
// }