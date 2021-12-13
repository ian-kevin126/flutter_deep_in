# 【Flutter】AutomaticKeepAliveClientMixin页面保持

在切换页面时，经常会刷新页面，为了避免initState方法重复调用

1、添加AutomaticKeepAliveClientMixin，

```ruby
class _LCNewsPageState extends State<LCNewsPage> with AutomaticKeepAliveClientMixin
```

2、并实现对应的方法bool get wantKeepAlive => true;，

```dart
  @override
  bool get wantKeepAlive => true;
```

3、同时build方法实现父方法 super.build(context);

```java
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Container(
      child: Scaffold(appBar: AppBar(), body: body()),
    );
  }
```

# 【Flutter】webview_flutter显示白屏

```cpp
flutter: allowing navigation to NavigationRequest(url: http://m.weibo.cn/2803301701/4483025884548508, isForMainFrame: true)
flutter: Page started loading: http://m.weibo.cn/2803301701/4483025884548508
flutter: allowing navigation to NavigationRequest(url: https://m.weibo.cn/2803301701/4483025884548508, isForMainFrame: true)
flutter: allowing navigation to NavigationRequest(url: https://m.weibo.cn/status/4483025884548508?, isForMainFrame: true)
flutter: allowing navigation to NavigationRequest(url: about:blank, isForMainFrame: false)
flutter: Page finished loading: https://m.weibo.cn/status/4483025884548508?
```

日志打印显示已经加载网页，而且成功，但是页面显示白屏。

#### 解决方案：

在iOS项目里面的info.list添加如下标签

```xml
<key>io.flutter.embedded_views_preview</key>
    <true/>
```

# 【Flutter】安卓签名和包名

#### 1、包名

##### 第一步：

更改`/android/app/src/main/AndroidManifest.xml`文件中的标签名称：

```bash
<application
    android:name="io.flutter.app.FlutterApplication"
    android:label="APP名字" 
```

更改AndroidManifest.xml文件中的包名称：

```go
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="your.package.name">
```

##### 第二步

修改`/android/app/build.gradle`文件中内容

```bash
defaultConfig {
    applicationId "your.package.name"
    minSdkVersion 16
    targetSdkVersion 27
    versionCode 1
    versionName "1.0"
    testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
}
```

##### 第三步

修改`android/app/src/main/kotlin/com/weixunbang/jingzhunke/MainActivity.kt`类中的包

```css
package your.package.name

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
```

##### 第四步

修改`/android/app/src/main/kotlin`下的文件路径名称，如图

![img](https://upload-images.jianshu.io/upload_images/1243891-28a747cf9f0f3259.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

截屏2020-05-26 下午5.13.17.png



#### 2、签名

##### 第一步

打开Mac下的终端，输入如下命令

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias androidKey
```

![img](https://upload-images.jianshu.io/upload_images/1243891-6515051590be2c0a.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

截屏2020-05-26 下午5.53.25.png
生成的签名地址：`/Users/lc/key.jks`

- 查看签名

```cpp
keytool -list -v -keystore key.jks
```

##### 第二步

在`android`下创建`key.properties`文件，并添加如下内容

```jsx
storePassword=<你刚才填写的密码>
keyPassword=<你刚才填写的密码>
keyAlias=androidKey
storeFile=<密钥的绝对路径>
```

![img](https://upload-images.jianshu.io/upload_images/1243891-11a972715030c031.png?imageMogr2/auto-orient/strip|imageView2/2/w/704/format/webp)

截屏2020-05-26 下午5.33.05.png

##### 第三步

然后编辑`android/app/build.gradle`文件
在`android`上方添加如下代码：

```ruby
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
```

![img](https://upload-images.jianshu.io/upload_images/1243891-46e758c8a325be1c.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

截屏2020-05-26 下午5.35.46.png

在`buildTypes`上添加如下代码：

```bash
signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile file(keystoreProperties['storeFile'])
           storePassword keystoreProperties['storePassword']
       }
   }
```

![img](https://upload-images.jianshu.io/upload_images/1243891-6236164f8c4bf579.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

buildTypes里面可以自己配置debug还是release，来打debug包和release包。

# 【Flutter】图表显示charts_flutter折线图/柱状图/饼状图等

**使用第三方charts_flutter：[https://pub.dev/packages/charts_flutter](https://links.jianshu.com/go?to=https%3A%2F%2Fpub.dev%2Fpackages%2Fcharts_flutter)**

- Google出品，没有文档（可以在GitHub代码里的issues查找问题）
- 支持动画
- 支持左右滑动
- 支持自定义颜色

### 折线图

```c
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartTestPage extends StatelessWidget {
  const ChartTestPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chart_flutter")),
      body: Column(children: [Container(height: 240, child: _simpleLine())]),
    );
  }

  Widget _simpleLine() {
    var random = Random();

    var data = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, random.nextInt(100)),
      LinearSales(3, random.nextInt(100)),
    ];

    var seriesList = [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];

    return charts.LineChart(seriesList, animate: true);
  }
}

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
```

![img](https://upload-images.jianshu.io/upload_images/1243891-7605c37f08380742?imageMogr2/auto-orient/strip|imageView2/2/w/894/format/webp)

在这里插入图片描述

#### 折线图-添加圆点/区域LineRendererConfig



```c
    return charts.LineChart(seriesList,
        animate: true,
        defaultRenderer:
            charts.LineRendererConfig(
            // 圆点大小
            radiusPx: 5.0,
            stacked: false,
            // 线的宽度
            strokeWidthPx: 2.0,
            // 是否显示线
            includeLine: true,
            // 是否显示圆点
            includePoints: true,
            // 是否显示包含区域
            includeArea: true,
            // 区域颜色透明度 0.0-1.0
            areaOpacity: 0.2 ,
            ));
```

![img](https://upload-images.jianshu.io/upload_images/1243891-c5c2f05a582de741?imageMogr2/auto-orient/strip|imageView2/2/w/822/format/webp)

在这里插入图片描述

#### 折线图-虚线dashPatternFn

```c
    var seriesList = [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data,
      )
    ];
```

![img](https://upload-images.jianshu.io/upload_images/1243891-ca01c0c229846275?imageMogr2/auto-orient/strip|imageView2/2/w/842/format/webp)

在这里插入图片描述

#### 折线图-自定义颜色charts.ColorUtil.fromDartColor(Color(0xFFE41E31))

```c
    var seriesList = [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFFE41E31)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data,
      )
    ];
```

#### 折线图-多条线

```c
    var seriesList = [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFFE41E31)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data1,
      ),
      charts.Series<LinearSales, int>(
        id: 'User',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFF13A331)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        // dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data2,
      ),
      charts.Series<LinearSales, int>(
        id: 'Dart',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFF6300A1)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        // dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data3,
      )
    ];
```

![img](https://upload-images.jianshu.io/upload_images/1243891-1194cd6fcaf7771b?imageMogr2/auto-orient/strip|imageView2/2/w/878/format/webp)

在这里插入图片描述

#### 折线图-针对单个线特殊处理customSeriesRenderers

```c
    var seriesList = [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFFE41E31)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data1,
      ),
      charts.Series<LinearSales, int>(
        id: 'User',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFF13A331)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        // dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data2,
      ),
      charts.Series<LinearSales, int>(
        id: 'Dart',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFF6300A1)),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        // dashPatternFn: (_, __) => [8, 2, 4, 2],
        data: data3,
      )..setAttribute(charts.rendererIdKey, 'customArea'),
    ];

    return charts.LineChart(seriesList, animate: true, customSeriesRenderers: [
      charts.LineRendererConfig(
        // RendererId
        customRendererId: 'customArea',

        // 圆点大小
        radiusPx: 5.0,
        stacked: false,
        // 线的宽度
        strokeWidthPx: 2.0,
        // 是否显示线
        includeLine: true,
        // 是否显示圆点
        includePoints: true,
        // 是否显示包含区域
        includeArea: true,
        // 区域颜色透明度 0.0-1.0
        areaOpacity: 0.2,
      ),
    ]);
```

![img](https://upload-images.jianshu.io/upload_images/1243891-f44f38d28c56fe6f?imageMogr2/auto-orient/strip|imageView2/2/w/860/format/webp)

在这里插入图片描述

### 柱状图

```c
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartTestPage extends StatelessWidget {
  const ChartTestPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chart_flutter")),
      body: Column(children: [Container(height: 240, child: _simpleBar())]),
    );
  }

  Widget _simpleBar() {
    var random = Random();

    var data = [
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
    ];
  
    var seriesList = [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];

    return charts.BarChart(
      seriesList,
      animate: true,
    );
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}  
```

![img](https://upload-images.jianshu.io/upload_images/1243891-4db63e19cce9fd8d?imageMogr2/auto-orient/strip|imageView2/2/w/832/format/webp)

在这里插入图片描述

#### 柱状图-左右滑动

```c
    return charts.BarChart(
      seriesList,
      animate: true,
      behaviors: [
        charts.SlidingViewport(),
        charts.PanAndZoomBehavior(),
      ],
      domainAxis: new charts.OrdinalAxisSpec(
          viewport: new charts.OrdinalViewport('2010', 6)),
    );
```

![img](https://upload-images.jianshu.io/upload_images/1243891-96fe17248afc97f8?imageMogr2/auto-orient/strip|imageView2/2/w/868/format/webp)

在这里插入图片描述

#### 柱状图-多组横向展示

```c
    var seriesList = [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data1,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data2,
      )
    ];
```

![img](https://upload-images.jianshu.io/upload_images/1243891-a3c874fc9f8f439d?imageMogr2/auto-orient/strip|imageView2/2/w/864/format/webp)

在这里插入图片描述

#### 柱状图-多组上下展示barGroupingType

```c
    return charts.BarChart(
      seriesList,
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      behaviors: [
        charts.SlidingViewport(),
        charts.PanAndZoomBehavior(),
      ],
      domainAxis: new charts.OrdinalAxisSpec(
          viewport: new charts.OrdinalViewport('2010', 6)),
    );
```

![img](https://upload-images.jianshu.io/upload_images/1243891-ce826be8768ebe35?imageMogr2/auto-orient/strip|imageView2/2/w/842/format/webp)

在这里插入图片描述

#### 柱状图-横向展示vertical

```c
    return charts.BarChart(
      seriesList,
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      vertical: false,
    );
```

![img](https://upload-images.jianshu.io/upload_images/1243891-1da5328890ff3f39?imageMogr2/auto-orient/strip|imageView2/2/w/846/format/webp)

在这里插入图片描述

#### 柱状图-柱头文本显示

```c
    return charts.BarChart(
      seriesList,
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
    );
```

![img](https://upload-images.jianshu.io/upload_images/1243891-e149dc576cea73e5?imageMogr2/auto-orient/strip|imageView2/2/w/864/format/webp)

在这里插入图片描述

### 饼状图

```c
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartTestPage extends StatelessWidget {
  const ChartTestPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chart_flutter")),
      body: Column(children: [
        Container(height: 300, child: _simplePie()),
      ]),
    );
  }

  Widget _simplePie() {
    var random = Random();

    var data = [
      PieSales(0, random.nextInt(100)),
      PieSales(1, random.nextInt(100)),
      PieSales(2, random.nextInt(100)),
      PieSales(3, random.nextInt(100)),
    ];

    var seriesList = [
      charts.Series<PieSales, int>(
        id: 'Sales',
        domainFn: (PieSales sales, _) => sales.year,
        measureFn: (PieSales sales, _) => sales.sales,
        data: data,
      )
    ];

    return charts.PieChart(seriesList, animate: true);
  }
}

class PieSales {
  final int year;
  final int sales;

  PieSales(this.year, this.sales);
}
```

![img](https://upload-images.jianshu.io/upload_images/1243891-985e72df7d8b9333?imageMogr2/auto-orient/strip|imageView2/2/w/844/format/webp)

在这里插入图片描述

#### 饼状图-自定义颜色

```c
var data = [
      PieSales(0, random.nextInt(100), charts.ColorUtil.fromDartColor(Color(0xFF126610))),
      PieSales(1, random.nextInt(100), charts.ColorUtil.fromDartColor(Color(0xFF522210))),
      PieSales(2, random.nextInt(100), charts.ColorUtil.fromDartColor(Color(0xFF929910))),
      PieSales(3, random.nextInt(100), charts.ColorUtil.fromDartColor(Color(0xFFD26699))),
    ];

class PieSales {
  final int year;
  final int sales;
  final charts.Color color;

  PieSales(this.year, this.sales, this.color);
}
```

![img](https://upload-images.jianshu.io/upload_images/1243891-52244c750e522ec4?imageMogr2/auto-orient/strip|imageView2/2/w/852/format/webp)

在这里插入图片描述

#### 饼状图-文本显示

```c
    var seriesList = [
      charts.Series<PieSales, int>(
        id: 'Sales',
        domainFn: (PieSales sales, _) => sales.year,
        measureFn: (PieSales sales, _) => sales.sales,
        colorFn: (PieSales sales, _) => sales.color,
        data: data,
        labelAccessorFn: (PieSales row, _) => '${row.year}: ${row.sales}',
      )
    ];

    return charts.PieChart(seriesList,
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.outside)
        ]));
```

![img](https://upload-images.jianshu.io/upload_images/1243891-4a2b9a2672f5f6bb?imageMogr2/auto-orient/strip|imageView2/2/w/882/format/webp)

在这里插入图片描述

#### 饼状图-空心显示

```c
    return charts.PieChart(seriesList,
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 60,
          arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.outside)
        ]));
```

# 【Flutter】flutter_tts语音播放文本

第三方库flutter_tts：[https://pub.dev/packages/flutter_tts](https://links.jianshu.com/go?to=https%3A%2F%2Fpub.dev%2Fpackages%2Fflutter_tts)

- 支持的语音：
  ja-JP, el-GR, en-AU, ar-SA, hu-HU, sv-SE, zh-CN, fr-CA, en-US, it-IT, ro-RO, sk-SK, ko-KR, en-IE, zh-HK, fr-FR, nl-NL, id-ID, pt-BR, pt-PT, cs-CZ, en-GB, de-DE, da-DK, es-ES, pl-PL, ru-RU, zh-TW, es-MX, en-ZA, hi-IN, en-IN, th-TH, no-NO, tr-TR, fi-FI, nl-BE, he-IL
- 支持设置音量
- 支持设置语速
- 支持设置音调
- 支持暂定
- 支持结束



```c
import 'package:flutter_tts/flutter_tts.dart';

class TTSUtil {
  TTSUtil._();
  static TTSUtil _manager;
  factory TTSUtil() {
    if (_manager == null) {
      _manager = TTSUtil._();
    }
    return _manager;
  }
  FlutterTts flutterTts;

  initTTS() {
    flutterTts = FlutterTts();
  }

  Future speak(String text) async {
    /// 设置语言
    await flutterTts.setLanguage("zh-CN");
    
    /// 设置音量
    await flutterTts.setVolume(0.8);

    /// 设置语速
    await flutterTts.setSpeechRate(0.5);

    /// 音调
    await flutterTts.setPitch(1.0);

    // text = "你好，我的名字是李磊，你是不是韩梅梅？";
    if (text != null) {
      if (text.isNotEmpty) {
        await flutterTts.speak(text);
      }
    }
  }
  
  /// 暂停
  Future _pause() async {
    await flutterTts.pause();
  }

  /// 结束
  Future _stop() async {
    await flutterTts.stop();
  }
}
```

# 【Flutter】io库里自带的WebSocket使用

```c
import 'dart:io';

class LCWebSocketManager {
  LCWebSocketManager._();
  static LCWebSocketManager _manager;
  factory LCWebSocketManager() {
    if (_manager == null) {
      _manager = LCWebSocketManager._();
    }
    return _manager;
  }

  WebSocket _webSocket;

  initWebSocket({Function success, Function failure}) async {
    var _linkAddress = "ws://62.234.***.***:5300?token=";
    var token = "";

    try {
      _webSocket = await WebSocket.connect(_linkAddress + token);
      print("【WebSocket】创建链接");
      if (_webSocket.readyState == WebSocket.open) {
        success();
        _ping();
        _webSocket.listen((onData) {
          print("【WebSocket】接收到消息 == > $onData");
          _chengaMessage(onData);

        }, onError: (error) {
          print("【WebSocket】错误 == > $error");
        }, onDone: () {
          print("【WebSocket】结束链接");
        });
      } else {
        failure();
        return;
      }
    } catch (e) {
      failure();
      return;
    }
  }
  
  /// 发送心跳包
  _ping() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      if (_webSocket.readyState == WebSocket.open) {
        _webSocket.add("hello, my name is lichuang!");
        _ping();
      }
    });
  }
  
  /// 发送消息
  sendMessage() {
    _webSocket.add("hello, my name is lilei!");
  }

  /// 关闭
  closeConnect() {
    _webSocket.close();
  }

  /// 当前状态
  currentState() {
    switch (_webSocket.readyState) {
      case WebSocket.connecting:
        print('【WebSocket】当前状态 ==> connecting');
        break;
      case WebSocket.open:
        print('【WebSocket】当前状态 ==> open');
        break;
      case WebSocket.closing:
        print('【WebSocket】当前状态 ==> closing');
        break;
      case WebSocket.closed:
        print('【WebSocket】当前状态 ==> closed');
        break;
      default:
    }
  }
  
  /// 处理接收到的消息
  _chengaMessage(dynamic data) {
    var model = ReceiveMessageModel.fromJson(convert.jsonDecode(data));
    if (model.type == 0) {
      print("【WebSocket】消息消息");
      TTSUtil().initTTS();
      TTSUtil().speak(model.data.label);
    } else if (model.type == 1) {
      print("【WebSocket】我是心跳");
    } else if (model.type == 2) {
      print("【WebSocket】链接成功");
    }
  }
}

class ReceiveMessageModel {
  int type;
  ReceiveMessageDetailModel data;
  ReceiveMessageModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    data = ReceiveMessageDetailModel.fromJson(json['data']);
  }
}

class ReceiveMessageDetailModel {
  int id;
  String label;
  ReceiveMessageDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        label = json['label'];
}
```

# 【Flutter】使用flutter_sound进行录音、语音播放及录音时动画处理

> 【Flutter】使用flutter_sound进行录音、语音播放及录音时动画处理
> [https://blog.csdn.net/tianzhilan0/article/details/108492697](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Ftianzhilan0%2Farticle%2Fdetails%2F108492697)

![img](https://upload-images.jianshu.io/upload_images/1243891-f4c564ec870eb7af?imageMogr2/auto-orient/strip|imageView2/2/w/750/format/webp)

在这里插入图片描述

使用第三方flutter_sound:[https://pub.dev/packages/flutter_sound](https://links.jianshu.com/go?to=https%3A%2F%2Fpub.dev%2Fpackages%2Fflutter_sound)

- flutter_sound支持多种录音格式
- flutter_sound支持多种播放格式
- flutter_sound支持音频振幅大小
- CustomPainter自定义音浪震动动画



```c
/*
 * @Descripttion: 
 * @version: 
 * @Author: lichuang
 * @Date: 2020-09-07 15:44:44
 * @LastEditors: lichuang
 * @LastEditTime: 2020-09-08 19:07:18
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

enum RecordPlayState {
  record,
  recording,
  play,
  playing,
}

class RecordPage extends StatefulWidget {
  RecordPage({Key key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  RecordPlayState _state = RecordPlayState.record;

  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;

  // StreamSubscription _dbPeakSubscription;
  FlutterSoundRecorder flutterSound;
  String _recorderTxt = '00:00:00';
  // String _playerTxt = '00:00:00';

  double _dbLevel = 0.0;
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  FlutterSoundPlayer playerModule = FlutterSoundPlayer();

  var _path = "";
  var _duration = 0.0;
  var _maxLength = 59.0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> _initializeExample(bool withUI) async {
    await playerModule.closeAudioSession();

    await playerModule.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);

    await playerModule.setSubscriptionDuration(Duration(milliseconds: 30));
    await recorderModule.setSubscriptionDuration(Duration(milliseconds: 30));
    initializeDateFormatting();
  }

  Future<void> init() async {
    recorderModule.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _initializeExample(false);

    if (Platform.isAndroid) {
      // copyAssets();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cancelRecorderSubscriptions();
    _cancelPlayerSubscriptions();
    _releaseFlauto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF0C141F),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          brightness: Brightness.dark,
          title: Text(
            '录音',
            style: TextStyle(color: Colors.white, fontSize: 18),
          )),
      backgroundColor: Color(0xFF0C141F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _timeShow(),
          ),
          Positioned(
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).padding.bottom + 15,
              child: _actionShow())
        ],
      ),
    );
  }

  Widget _timeShow() {
    return Column(children: [
      Container(
          width: double.maxFinite,
          height: ScreenUtil().setHeight(120),
          alignment: Alignment.center,
          child: Text(_recorderTxt,
              style: TextStyle(fontSize: 36, color: Colors.white))),
      SizedBox(height: ScreenUtil().setHeight(60)),
      CustomPaint(
          size: Size(double.maxFinite, 100),
          painter:
              LCPainter(amplitude: _dbLevel / 2, number: 30 - _dbLevel ~/ 20)),
    ]);
  }

  Widget _actionShow() {
    var _width = ScreenUtil.screenWidthDp - 30;
    var _height = _width * 0.8;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFF1A283B),
        ),
        height: _height,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Offstage(
                offstage: _state == RecordPlayState.play ||
                        _state == RecordPlayState.playing
                    ? false
                    : true,
                child: InkWell(
                    onTap: () {
                      setState(() async {
                        _state = RecordPlayState.record;
                        _path = "";
                        _recorderTxt = "00:00:00";
                        _dbLevel = 0.0;
                        await _stopPlayer();
                        _state = RecordPlayState.record;
                      });
                    },
                    child: Container(
                      width: _width / 3,
                      child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                          child: Image.asset('assets/images/record_reset.png')),
                    ))),
            InkWell(
                onTap: () {
                  if (_state == RecordPlayState.record) {
                    _startRecorder();
                  } else if (_state == RecordPlayState.recording) {
                    _stopRecorder();
                  } else if (_state == RecordPlayState.play) {
                    _startPlayer();
                  } else if (_state == RecordPlayState.playing) {
                    _pauseResumePlayer();
                  }
                },
                child: Container(
                  width: _width / 3,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                  child: Container(
                      child: Image.asset(_state == RecordPlayState.record
                          ? "assets/images/record_start.png"
                          : _state == RecordPlayState.recording
                              ? "assets/images/record_recording.png"
                              : _state == RecordPlayState.play
                                  ? "assets/images/record_play.png"
                                  : "assets/images/record_playing.png")),
                )),
            Offstage(
                offstage: _state == RecordPlayState.play ||
                        _state == RecordPlayState.playing
                    ? false
                    : true,
                child: InkWell(
                    onTap: () {},
                    child: Container(
                      width: _width / 3,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                      child: Container(
                          child:
                              Image.asset('assets/images/record_finish.png')),
                    )))
          ]),
          SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Offstage(
                offstage: _state == RecordPlayState.play ||
                        _state == RecordPlayState.playing
                    ? false
                    : true,
                child: InkWell(
                    onTap: () {
                      setState(() async {
                        _state = RecordPlayState.record;
                        _path = "";
                        _recorderTxt = "00:00:00";
                        _dbLevel = 0.0;
                        await _stopPlayer();
                        _state = RecordPlayState.record;
                      });
                    },
                    child: Container(
                        width: _width / 3,
                        alignment: Alignment.center,
                        child: Text(
                          "重录",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        )))),
            InkWell(
                onTap: () {
                  if (_state == RecordPlayState.record) {
                    _startRecorder();
                  } else if (_state == RecordPlayState.recording) {
                    _stopRecorder();
                  } else if (_state == RecordPlayState.play) {
                    _startPlayer();
                  } else if (_state == RecordPlayState.playing) {
                    _pauseResumePlayer();
                  }
                },
                child: Container(
                    width: _width / 3,
                    alignment: Alignment.center,
                    child: Text(
                      _state == RecordPlayState.record
                          ? "录音"
                          : _state == RecordPlayState.recording
                              ? "结束"
                              : _state == RecordPlayState.play ? "播放" : "暂停",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ))),
            Offstage(
                offstage: _state == RecordPlayState.play ||
                        _state == RecordPlayState.playing
                    ? false
                    : true,
                child: InkWell(
                    onTap: () {},
                    child: Container(
                        width: _width / 3,
                        alignment: Alignment.center,
                        child: Text(
                          "完成",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        )))),
          ])
        ]));
  }

  /// 开始录音
  _startRecorder() async {
    try {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
      PermissionStatus status = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.microphone);
      if (status != PermissionStatus.granted) {
        EasyLoading.showToast("未获取到麦克风权限");
        throw RecordingPermissionException("未获取到麦克风权限");
      }
      print('===>  获取了权限');
      Directory tempDir = await getTemporaryDirectory();
      var time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String path =
          '${tempDir.path}/${recorderModule.slotNo}-$time${ext[Codec.aacADTS.index]}';
      print('===>  准备开始录音');
      await recorderModule.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        bitRate: 8000,
        sampleRate: 8000,
      );
      print('===>  开始录音');

      /// 监听录音
      _recorderSubscription = recorderModule.onProgress.listen((e) {
        if (e != null && e.duration != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
          if (date.second >= _maxLength) {
            _stopRecorder();
          }
          setState(() {
            _recorderTxt = txt.substring(0, 8);
            _dbLevel = e.decibels;
            print("当前振幅：$_dbLevel");
          });
        }
      });
      this.setState(() {
        _state = RecordPlayState.recording;
        _path = path;
        print("path == $path");
      });
    } catch (err) {
      setState(() {
        _stopRecorder();
        _state = RecordPlayState.record;
        _cancelRecorderSubscriptions();
      });
    }
  }

  /// 结束录音
  _stopRecorder() async {
    try {
      await recorderModule.stopRecorder();
      print('stopRecorder');
      _cancelRecorderSubscriptions();
      _getDuration();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    setState(() {
      _dbLevel = 0.0;
      _state = RecordPlayState.play;
    });
  }

  /// 取消录音监听
  void _cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }

  /// 取消播放监听
  void _cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  /// 释放录音和播放
  Future<void> _releaseFlauto() async {
    try {
      await playerModule.closeAudioSession();
      await recorderModule.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  /// 获取录音文件秒数
  Future<void> _getDuration() async {
    Duration d = await flutterSoundHelper.duration(_path);
    _duration = d != null ? d.inMilliseconds / 1000.0 : 0.00;
    print("_duration == $_duration");
    var minutes = d.inMinutes;
    var seconds = d.inSeconds % 60;
    var millSecond = d.inMilliseconds % 1000 ~/ 10;
    _recorderTxt = "";
    if (minutes > 9) {
      _recorderTxt = _recorderTxt + "$minutes";
    } else {
      _recorderTxt = _recorderTxt + "0$minutes";
    }

    if (seconds > 9) {
      _recorderTxt = _recorderTxt + ":$seconds";
    } else {
      _recorderTxt = _recorderTxt + ":0$seconds";
    }
    if (millSecond > 9) {
      _recorderTxt = _recorderTxt + ":$millSecond";
    } else {
      _recorderTxt = _recorderTxt + ":0$millSecond";
    }
    print(_recorderTxt);
    setState(() {});
  }

  /// 开始播放
  Future<void> _startPlayer() async {
    try {
      if (await _fileExists(_path)) {
        await playerModule.startPlayer(
            fromURI: _path,
            codec: Codec.aacADTS,
            whenFinished: () {
              print('==> 结束播放');
              _stopPlayer();
              setState(() {});
            });
      } else {
        EasyLoading.showToast("未找到文件路径");
        throw RecordingPermissionException("未找到文件路径");
      }

      _cancelPlayerSubscriptions();
      _playerSubscription = playerModule.onProgress.listen((e) {
        if (e != null) {
          // print("${e.duration} -- ${e.position} -- ${e.duration.inMilliseconds} -- ${e.position.inMilliseconds}");
          // DateTime date = new DateTime.fromMillisecondsSinceEpoch(
          //     e.position.inMilliseconds,
          //     isUtc: true);
          // String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

          // this.setState(() {
          // this._playerTxt = txt.substring(0, 8);
          // });
        }
      });
      setState(() {
        _state = RecordPlayState.playing;
      });
      print('===> 开始播放');
    } catch (err) {
      print('==> 错误: $err');
    }
    setState(() {});
  }

  /// 结束播放
  Future<void> _stopPlayer() async {
    try {
      await playerModule.stopPlayer();
      print('===> 结束播放');
      _cancelPlayerSubscriptions();
    } catch (err) {
      print('==> 错误: $err');
    }
    setState(() {
      _state = RecordPlayState.play;
    });
  }

  /// 暂停/继续播放
  void _pauseResumePlayer() {
    if (playerModule.isPlaying) {
      playerModule.pausePlayer();
      _state = RecordPlayState.play;
      print('===> 暂停播放');
    } else {
      playerModule.resumePlayer();
      _state = RecordPlayState.playing;
      print('===> 继续播放');
    }
    setState(() {});
  }

  /// 判断文件是否存在
  Future<bool> _fileExists(String path) async {
    return await File(path).exists();
  }
}

class LCPainter extends CustomPainter {
  final double amplitude;
  final int number;
  LCPainter({this.amplitude = 100.0, this.number = 20});
  @override
  void paint(Canvas canvas, Size size) {
    var centerY = 0.0;
    var width = ScreenUtil.screenWidth / number;

    for (var a = 0; a < 4; a++) {
      var path = Path();
      path.moveTo(0.0, centerY);
      var i = 0;
      while (i < number) {
        path.cubicTo(width * i, centerY, width * (i + 1),
            centerY + amplitude - a * (30), width * (i + 2), centerY);
        path.cubicTo(width * (i + 2), centerY, width * (i + 3),
            centerY - amplitude + a * (30), width * (i + 4), centerY);
        i = i + 4;
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = a == 0 ? Colors.blueAccent : Colors.blueGrey.withAlpha(50)
            ..strokeWidth = a == 0 ? 3.0 : 2.0
            ..maskFilter = MaskFilter.blur(
              BlurStyle.solid,
              5,
            )
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
```

# 【Flutter】二维码生成，Widget转图片，图片保存相册

> 【Flutter】二维码生成，Widget转图片，图片保存相册
> [https://blog.csdn.net/tianzhilan0/article/details/108519768](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Ftianzhilan0%2Farticle%2Fdetails%2F108519768)

### 1、生成二维码

使用qr_flutter：[https://pub.dev/packages/qr_flutter](https://links.jianshu.com/go?to=https%3A%2F%2Fpub.dev%2Fpackages%2Fqr_flutter)

```c
    Container(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width / 5,
          right: MediaQuery.of(context).size.width / 5),
      child: QrImage(
        data: 'This QR code has an embedded image as well',
        version: QrVersions.auto,
        gapless: false,
        embeddedImage: AssetImage('assets/images/demo_head_f02.jpg'),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(80, 80),
        ),
      ),
    )
```

### 2、Widget转图片

```c
class WidgetToImage extends StatefulWidget {
  WidgetToImage({Key key}) : super(key: key);

  @override
  _WidgetToImageState createState() => _WidgetToImageState();
}

class _WidgetToImageState extends State<WidgetToImage> {
  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        key: _globalKey,
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 20),
            child: Text(
              "味多美A店会员注册",
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 5,
                right: MediaQuery.of(context).size.width / 5),
            child: QrImage(
              data: 'This QR code has an embedded image as well',
              version: QrVersions.auto,
              gapless: false,
              embeddedImage: AssetImage('assets/images/demo_head_f02.jpg'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(80, 80),
              ),
            ),
          ),
        ]));
  }

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      return Uint8List(10);
    }
  }
}
```

### 3、图片保存至相册

图片保存至相册：[https://blog.csdn.net/tianzhilan0/article/details/108278021](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Ftianzhilan0%2Farticle%2Fdetails%2F108278021)

# 【Flutter】自定义插件开发

### 1、创建工程

```cpp
flutter create --org com.kinsomy --template=plugin -i swift -a kotlin hello 
```

- --org选项：指定您的组织
- --template选项：1、package 开发Dart包 2、plugin 创建插件包
- -i选项：iOS开发语言swift或者oc
- -a选项：Android开发语言java或者kotlin

#### 目录介绍：

- lib/hello.dart:
  插件包的Dart API.
- android/src/main/java/com/yourcompany/hello/HelloPlugin.java:
  插件包API的Android实现.
- ios/Classes/HelloPlugin.m:
  插件包API的ios实现.
- example/:
  一个依赖于该插件的Flutter应用程序，来说明如何使用它

### 2、Android Studio编辑Android插件包

首先终端运行

```bash
cd hello/example
flutter build apk
```

结构展示

```csharp
Running Gradle task 'assembleRelease'...                                
                                                                
Removed unused resources: Binary resource data reduced from 46KB to 36KB: Removed 20%                              
Running Gradle task 'assembleRelease'...                                                                           
Running Gradle task 'assembleRelease'... Done                     207.4s (!)
✓ Built build/app/outputs/flutter-apk/app-release.apk (15.0MB).
localhost:example lc$ 
```

打开Android Studio，选择`Open an existing Android Studio Project`打开项目

![img](https://upload-images.jianshu.io/upload_images/1243891-31975dcd0e71a59b.png?imageMogr2/auto-orient/strip|imageView2/2/w/796/format/webp)

```swift
package com.example.lchelper;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

 import android.app.Service;
 import android.content.Context;
 import android.content.pm.PackageInfo;
 import android.content.pm.PackageManager;
 import android.os.Build;
 import android.os.Vibrator;

 import java.util.HashMap;
 import java.util.Map;

/** LchelperPlugin */
public class LchelperPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "lchelper");
    channel.setMethodCallHandler(this);
  }
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "lchelper");
    channel.setMethodCallHandler(new LchelperPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } 
     else if (call.method.equals("PackageInfo")){
       //获取设备信息
         Map<String, String> map = new HashMap<>();
         map.put("systemVersion", android.os.Build.VERSION.RELEASE);
         map.put("deviceType", android.os.Build.MODEL);
         map.put("deviceName", Build.DEVICE);
         result.success(map);
     }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
```

### 3、编辑iOS插件包

首先终端操作

```bash
cd hello/example
flutter build ios --no-codesign
```

![img](https://upload-images.jianshu.io/upload_images/1243891-acc0f7cac852a2c9.png?imageMogr2/auto-orient/strip|imageView2/2/w/718/format/webp)

编辑第三方[https://blog.csdn.net/weixin_34162401/article/details/91390081](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Fweixin_34162401%2Farticle%2Fdetails%2F91390081)

### 4、插件发布到pub

在发布之前，确保pubspec.yaml,、README.md以及CHANGELOG.md文件的内容都正确填写完毕。可以通过`dry-run`命令来`看准备是否就绪`。

```rust
flutter packages pub publish --dry-run
```

检查无误后，可以执行下面的命令，发布到[Pub](https://links.jianshu.com/go?to=https%3A%2F%2Fpub.dartlang.org%2F)上。

```rust
flutter packages pub publish
```

# 【Flutter】Mac环境下打包apk

1、打开终端生成签名文件

```bash
keytool -genkey -v -keystore ~/sign.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sign
```

结果

```csharp
输入密钥库口令:  
再次输入新口令: 
您的名字与姓氏是什么?
  [Unknown]:  yuanzhiying
您的组织单位名称是什么?
  [Unknown]:  gongsi
您的组织名称是什么?
  [Unknown]:  gongsi
您所在的城市或区域名称是什么?
  [Unknown]:  beijing
您所在的省/市/自治区名称是什么?
  [Unknown]:  beijing
该单位的双字母国家/地区代码是什么?
  [Unknown]:  CN
CN=yuanzhiying, OU=gongsi, O=gongsi, L=beijing, ST=beijing, C=CN是否正确?
  [否]:  Y

正在为以下对象生成 2,048 位RSA密钥对和自签名证书 (SHA256withRSA) (有效期为 10,000 天):
     CN=yuanzhiying, OU=gongsi, O=gongsi, L=beijing, ST=beijing, C=CN
[正在存储/Users/yuanzhiying/sign.jks]
```

查看生成的签名文件

```cpp
keytool -list -v -keystore sign.jks
输入密钥库口令:  <输入密钥>
```

2、在Android Studio中flutter项目目录/android/app下创建文件夹key，将生成的sign.jks文件拖放到key文件夹下。

![img](https://upload-images.jianshu.io/upload_images/1243891-8cd7feef2d9a09eb.png?imageMogr2/auto-orient/strip|imageView2/2/w/548/format/webp)

3、在flutter项目目录android下创建文件key.properties，并添加以下内容：

```undefined
storePassword=123456
keyPassword=123456
keyAlias=sign
storeFile=key/sign.jks
```

![img](https://upload-images.jianshu.io/upload_images/1243891-5564bb13a336f600.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

4、打开/android/app/build.gradle文件，添加以下内容

```ruby
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
```

![img](https://upload-images.jianshu.io/upload_images/1243891-96cb63f2482cb6b0.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

5、在android studio项目下的terminal中，执行打包命令：

```undefined
flutter build apk
```

# 【Flutter】使用BottomAppBar自定义bottomNavigationBar

![img](https://upload-images.jianshu.io/upload_images/4044518-0ae6c5f20c3f2b51.png?imageMogr2/auto-orient/strip|imageView2/2/w/684/format/webp)

使用Flutter原生的`FloatingActionButton`+`BottomAppBar`实现，配合`Scaffold`使用更舒服，适合不喜欢自己用Widget组合自定义BottomAppBar的小伙伴。

实现思路为：
1、自定义`floatingActionButtonLocation`控制`FloatingActionButton`的位置；
2、自定义`BottomAppBar`的`shape`属性，绘制`BottomAppBar`的边框。
`demo`地址：[https://github.com/tianzhilan0/flutter-BottomAppBar](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Ftianzhilan0%2Fflutter-BottomAppBar)

```dart
import 'package:flutter/material.dart';
import 'package:flutterdemo/add/AddPage.dart';
import 'package:flutterdemo/home/HomePage.dart';
import 'package:flutterdemo/found/FoundPage.dart';
import 'package:flutterdemo/message/MessagePage.dart';
import 'package:flutterdemo/mine/MinePage.dart';


class LCTabbarController extends StatefulWidget {
  LCTabbarController({Key key}) : super(key: key);

  @override
  _LCTabbarControllerState createState() => _LCTabbarControllerState();
}

class _LCTabbarControllerState extends State<LCTabbarController> {

  int currentIndex;
  final pages = [HomePage(), FoundPage(), MessagePage(), MinePage()];
  List titles = ["首页", "发现", "消息", "我的"];
  List normalImgUrls = [
    "http://img4.imgtn.bdimg.com/it/u=3432620279,1821211839&fm=26&gp=0.jpg",
    "http://img4.imgtn.bdimg.com/it/u=3432620279,1821211839&fm=26&gp=0.jpg",
    "http://img4.imgtn.bdimg.com/it/u=3432620279,1821211839&fm=26&gp=0.jpg",
    "http://img4.imgtn.bdimg.com/it/u=3432620279,1821211839&fm=26&gp=0.jpg"];
  List selectedImgUrls = [
    "http://img2.imgtn.bdimg.com/it/u=1414450711,2877842653&fm=26&gp=0.jpg",
    "http://img2.imgtn.bdimg.com/it/u=1414450711,2877842653&fm=26&gp=0.jpg",
    "http://img2.imgtn.bdimg.com/it/u=1414450711,2877842653&fm=26&gp=0.jpg",
    "http://img2.imgtn.bdimg.com/it/u=1414450711,2877842653&fm=26&gp=0.jpg",
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 5;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("底部导航栏"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70,
        height: 70,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: Colors.white,
        ),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            print("你点击了ADD");
            //调整进入Addpage()
          },
          elevation: 5,
          backgroundColor: Colors.yellow,
          ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            SizedBox(height: 49, width: itemWidth, child: tabbar(0)),
            SizedBox(height: 49, width: itemWidth, child: tabbar(1)),
            SizedBox(height: 49, width: itemWidth, ),
            SizedBox(height: 49, width: itemWidth, child: tabbar(2)),
            SizedBox(height: 49, width: itemWidth, child: tabbar(3)),

          ]
        ),
      ),
      body: pages[currentIndex],
    ); 
  }
  
  // 自定义BottomAppBar
  Widget tabbar(int index) {
    //设置默认未选中的状态
    TextStyle style = TextStyle(fontSize: 12, color: Colors.black);
    String imgUrl = normalImgUrls[index];
    if (currentIndex == index) {
      //选中的话
      style = TextStyle(fontSize: 13, color: Colors.blue);
      imgUrl = selectedImgUrls[index];
    }
    //构造返回的Widget
    Widget item = Container(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(imgUrl, width: 25, height: 25),
            Text(
              titles[index],
              style: style,
            )
          ],
        ),
        onTap: () {
          if (currentIndex != index) {
            setState(() {
              currentIndex = index;
            });
          }
        },
      ),
    );
    return item;
  }
}
```