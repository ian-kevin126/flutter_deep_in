# Dart虚拟机运行原理

## 一、Dart虚拟机

#### 1.1 引言

Dart VM是一种虚拟机，为高级编程语言Dart提供执行环境，但这并意味着Dart在D虚拟机上执行时，总是采用解释执行或者JIT编译。 例如还可以使用Dart虚拟机的AOT管道将Dart代码编译为机器代码，然后运行在Dart虚拟机的精简版环境，称之为预编译运行时(precompiled runtime)环境，该环境不包含任何编译器组件，且无法动态加载Dart源代码。

#### 1.2 虚拟机如何运行Dart代码

Dart VM有多钟方式来执行代码：

- 源码或者Kernel二进制(JIT)
- snapshot
  - AOT snapshot
  - AppJIT snapshot

区别主要在于什么时机以及如何将Dart代码转换为可执行的代码。

#### 1.3 Isolate组成

先来看看dart虚拟机中isolate的组成：

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/isolates.png)

- isolate堆是运该isolate中代码分配的所有对象的GC管理的内存存储；
- vm isolate是一个伪isolate，里面包含不可变对象，比如null，true，false；
- isolate堆能引用vm isolate堆中的对象，但vm isolate不能引用isolate堆；
- isolate彼此之间不能相互引用
- 每个isolate都有一个执行dart代码的Mutator thread，一个处理虚拟机内部任务(比如GC, JIT等)的helper thread；

isolate拥有内存堆和控制线程，虚拟机中可以有很多isolate，但彼此之间不能直接状态，只能通过dart特有的端口；isolate除了拥有一个mutator控制线程，还有一些其他辅助线程：

- 后台JIT编译线程；
- GC清理线程；
- GC并发标记线程；

线程和isolate的关系是什么呢？

- 同一个线程在同一时间只能进入一个isolate，当需要进入另一个isolate则必须先退出当前的isolate；
- 一次只能有一个Mutator线程关联对应的isolate，Mutator线程是执行Dart代码并使用虚拟机的公共的C语言API的线程

#### 1.4 ThreadPool组成

虚拟机采用线程池的方式来管理线程，定义在runtime/vm/thread_pool.h

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/ThreadPool.png)

ThreadPool的核心成员变量：

- all_workers_：记录所有的workers；
- idle_workers：_记录所有空闲的workers;
- count_started_：记录该线程池的历史累计启动workers个数;
- count_stopped_：记录该线程池的历史累计关闭workers个数；
- count_running_：记录该线程池当前正在运行的worker个数；
- count_idle_：记录该线程池当前处于空闲的worker个数，也就是idle_workers的长度；

ThreadPool核心方法：

- Run(Task*): 执行count_running_加1，并将Task设置到该Worker，
  - 当idle_workers_为空，则创建新的Worker并添加到all_workers_队列头部，count_started_加1；
  - 当idle_workers_不为空，则取走idle_workers_队列头部的Worker，count_idle_减1；
- Shutdown(): 将all_workers_和idle_workers_队列置为NULL，并将count_running_和count_idle_清零，将关闭的all_workers_个数累加到count_stopped_；
- SetIdleLocked(Worker*)：将该Worker添加到idle_workers_队列头部，count_idle_加1， count_running_减1;
- ReleaseIdleWorker(Worker*)：从all_workers_和idle_workers_队列中移除该Worker，count_idle_减1，count_stopped_加1；

对应关系图：

|                     | count_started_   | count_stopped_    | count_running_ | count_idle_      |
| :------------------ | :--------------- | :---------------- | :------------- | :--------------- |
| Run()               | +1(无空闲worker) |                   | +1             | -1(有空闲worker) |
| Shutdown()          |                  | +all_workers_个数 | 清零           | 清零             |
| SetIdleLocked()     |                  |                   | -1             | +1               |
| ReleaseIdleWorker() |                  | +1                |                | -1               |

可见，count_started_ - count_stopped_ = count_running_ + count_idle_；

## 二、JIT运行模式

#### 2.1 CFE前端编译器

看看dart是如何直接理解并执行dart源码

```
// gityuan.dart
main() => print('Hello Gityuan!');

//dart位于flutter/bin/cache/dart-sdk/bin/dart
$ dart gityuan.dart
Hello, World!
```

说明：

- Dart虚拟机并不能直接从Dart源码执行，而是执行dill二进制文件，该二进制文件包括序列化的Kernel AST(抽象语法树)。
- Dart Kernel是一种从Dart中衍生而来的高级语言，设计之初用于程序分析与转换(transformations)的中间产物，可用于代码生成与后端编译器，该kernel语言有一个内存表示，可以序列化为二进制或文本。
- 将Dart转换为Kernel AST的是CFE(common front-end）通用前端编译器。
- 生成的Kernel AST可交由Dart VM、dev_compiler以及dart2js等各种Dart工具直接使用。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/dart-to-kernel.png)

#### 2.2 kernel service

有一个辅助类isolate叫作kernel service，其核心工作就是CFE，将dart转为Kernel二进制，然后VM可直接使用Kernel二进制运行在主isolate里面运行。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/kernel-service.png)

#### 2.3 debug运行

将dart代码转换为kernel二进制和执行kernel二进制，这两个过程也可以分离开来，在两个不同的机器执行，比如host机器执行编译，移动设备执行kernel文件。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/flutter-cfe.png)

图解：

- 这个编译过程并不是flutter tools自身完成，而是交给另一个进程frontend_server来执行，它包括CFE和一些flutter专有的kernel转换器。
- hot reload：热重载机制正是依赖这一点，frontend_server重用上一次编译中的CFE状态，只重新编译实际更改的部分。

#### 2.4 RawClass内部结构

虚拟机内部对象的命名约定：使用C++定义的，其名称在头文件raw_object.h中以Raw开头，比如RawClass是描述Dart类的VM对象，RawField是描述Dart类中的Dart字段的VM对象。

1）将内核二进制文件加载到VM后，将对其进行解析以创建表示各种程序实体的对象。这里采用了懒加载模式，一开始只有库和类的基本信息被加载，内核二进制文件中的每一个实体都会保留指向该二进制文件的指针，以便后续可根据需要加载更多信息。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/kernel-loaded-1.png)

2）仅在以后需要运行时，才完全反序列化有关类的信息。（例如查找类的成员变量，创建类的实例对象等），便会从内核二进制文件中读取类的成员信息。 但功能完整的主体(FunctionNode)在此阶段并不会反序列化，而只是获取其签名。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/kernel-loaded-2.png)

到此，已从内核二进制文件加载了足够的信息以供运行时成功解析和调用的方法。

所有函数的主体都具有占位符code_，而不是实际的可执行代码：它们指向LazyCompileStub，该Stub只是简单地要求系统Runtime为当前函数生成可执行代码，然后对这些新生成的代码进行尾部调用。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/raw-function-lazy-compile.png)

#### 2.5 查看Kernel文件格式

gen_kernel.dart利用CFE将Dart源码编译为kernel binary文件(也就是dill)，可利用dump_kernel.dart能反解kernel binary文件，命令如下所示：

```Java
//将hello.dart编译成hello.dill
$ cd <FLUTTER_ENGINE_ROOT>
$ dart third_party/dart/pkg/vm/bin/gen_kernel.dart          \
       --platform out/android_debug/vm_platform_strong.dill \
       -o hello.dill                                        \
       hello.dart

//转储AST的文本表示形式
$ dart third_party/dart/pkg/vm/bin/dump_kernel.dart hello.dill hello.kernel.txt
```

gen_kernel.dart文件，需要平台dill文件，这是一个包括所有核心库(dart:core, dart:async等)的AST的kernel binary文件。如果Dart SDK已经编译过，可直接使用out/ReleaseX64/vm_platform_strong.dill，否则需要使用compile_platform.dart来生成平台dill文件，如下命令:

```Java
//根据给定的库列表，来生成platform和outline文件
$ cd <FLUTTER_ENGINE_ROOT>
$ dart third_party/dart/pkg/front_end/tool/_fasta/compile_platform.dart \
       dart:core                                                        \        
       third_party/dart/sdk/lib/libraries.json                          \
       vm_outline.dill vm_platform.dill vm_outline.dill                 
```

#### 2.6 未优化编译器

首次编译函数时，这是通过未优化编译器来完成的。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/unoptimized-compilation.png)

未优化的编译器分两步生成机器代码：

- AST -> CFG: 对函数主体的序列化AST进行遍历，以生成函数主体的控制流程图(CFG)，CFG是由填充中间语言（IL）指令的基本块组成。此阶段使用的IL指令类似于基于堆栈的虚拟机的指令：它们从堆栈中获取操作数，执行操作，然后将结果压入同一堆栈
- IL -> 机器指令：使用一对多的IL指令，将生成的CFG直接编译为机器代码：每个IL指令扩展为多条机器指令。

在此阶段没有执行优化，未优化编译器的主要目标是快速生成可执行代码。

#### 2.7 内联缓存

未优化编译过程，编译器不会尝试静态解析任何未在Kernel二进制文件中解析的调用，因此（MethodInvocation或PropertyGet AST节点）的调用被编译为完全动态的。虚拟机当前不使用任何形式的基于虚拟表(virtual table)或接口表(interface table)的调度，而是使用内联缓存实现动态调用。

虚拟机的内联缓存的核心思想是缓存方法解析后的站点结果信息，对于内联缓存最初是为了解决函数的本地代码：

- 站点调用的特定缓存(RawICData对象)将接受者的类映射到方法，缓存中记录着一些辅助信息，比如方法和基本块的调用频次计数器，该计数器记录着被跟踪类的调用频次；
- 共享的查找存根，用于实现方法调用的快速路径。该存根在给定的高速缓存中进行搜索，以查看其是否包含与接收者的类别匹配的条目。 如果找到该条目，则存根将增加频率计数器和尾部调用缓存的方法。否则，存根将调用系统Runtime来解析方法实现的逻辑，如果方法解析成功，则将更新缓存，并且随后的调用无需进入系统Runtime。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/inline-cache-1.png)

#### 2.8 编译优化

未优化编译器产生的代码执行比较慢，需要自适应优化，通过profile配置文件来驱动优化策略。内联优化，当与某个功能关联的执行计数器达到某个阈值时，该功能将提交给后台优化编译器进行优化。

优化编译的方式与未优化编译的方式相同：通过序列化内核AST来构建未优化的IL。但是，优化编译器不是直接将IL编译为机器码，而是将未优化的IL转换为基于静态单分配（SSA）形式的优化的IL。

对基于SSA的IL通过基于收集到的类型反馈，内联，范围分析，类型传播，表示选择，存储到加载，加载到加载转发，全局值编号，分配接收等一系列经典和Dart特定的优化来进行专业化推测。最后，使用线性扫描寄存器分配器和一个简单的一对多的IL指令。优化编译完成后，后台编译器会请求mutator线程输入安全点，并将优化的代码附加到该函数。下次调用该函数时，它将使用优化的代码。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/optimizing-compilation.png)

另外，有些函数包含很长的运行循环，因此在函数仍在运行时将执行从未优化的代码切换到优化的代码是有意义的，此过程之所以称为“堆栈替换”（OSR）。

VM还具有可用于控制JIT并使其转储IL以及用于JIT正在编译的功能的机器代码的标志

```Java
$ dart --print-flow-graph-optimized         \
       --disassemble-optimized              \
       --print-flow-graph-filter=myFunc     \
       --no-background-compilation          \
       hel.dart
```

#### 2.9 反优化

优化是基于统计的，可能出现违反优化的情况

```Java
void printAnimal(obj) {
  print('Animal {');
  print('  ${obj.toString()}');
  print('}');
}

// 大量调用的情况下，会推测printAnimal假设总是Cat的情况下来优化代码
for (var i = 0; i < 50000; i++)
  printAnimal(Cat());

// 此处出现的是Dog，优化版本失效，则触发反优化
printAnimal(Dog());
```

每当只要优化版本遇到无法解决的情况，它就会将执行转移到未优化功能的匹配点，然后继续执行，这个恢复过程称为去优化：未优化的功能版本不做任何假设，可以处理所有可能的输入。

虚拟机通常会在执行一次反优化后，放弃该功能的优化版本，然后在以后使用优化的类型反馈再次对其进行重新优化。虚拟机保护编译器进行推测性假设的方式有两种：

- 内联检查（例如CheckSmi，CheckClass IL指令），以验证假设是否在编译器做出此假设的使用场所成立。例如，将动态调用转换为直接调用时，编译器会在直接调用之前添加这些检查。 在此类检查中发生的取消优化称为“急切优化”，因为它在达到检查时就急于发生。
- 运行时在更改优化代码所依赖的内容时，将会丢弃优化代码。例如，优化编译器可能会发现某些类从未扩展过，并且在类型传播过程中使用了此信息。 但是，随后的动态代码加载或类最终确定可能会引入C的子类，导致假设无效。此时，运行时需要查找并丢弃所有在C没有子类的假设下编译的优化代码。 运行时可能会在执行堆栈上找到一些现在无效的优化代码，在这种情况下，受影响的帧将被标记为不优化，并且当执行返回时将进行不优化。 这种取消优化称为延迟取消优化，因为它会延迟到控制权返回到优化代码为止。

## 三、Snapshots运行模式

### 3.1 通过Snapshots运行

1）虚拟机有能力将isolate的堆（驻留在堆上的对象图）序列化成二进制的快照，启动虚拟机isolate的时候可以从快照中重新创建相同的状态。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/snapshot.png)

Snapshot的格式是低级的，并且针对快速启动进行了优化，本质上是要创建的对象列表以及如何将它们连接在一起的说明。那是快照背后的原始思想：代替解析Dart源码并逐步创建虚拟机内部的数据结构，这样虚拟机通过快照中的所有必要数据结构来快速启动isolate。

2）最初，快照不包括机器代码，但是后来在开发AOT编译器时添加了此功能。开发AOT编译器和带代码快照的动机是为了允许虚拟机在由于平台级别限制而无法进行JIT的平台上使用。

带代码的快照的工作方式几乎与普通快照相同，只是有一点点不同：它们包括一个代码部分，该部分与快照的其余部分不同，不需要反序列化。该代码节的放置方式使其可以在映射到内存后直接成为堆的一部分

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/snapshot-with-code.png)

### 3.2 通过AppJIT Snapshots运行

引入AppJIT快照可减少大型Dart应用程序（如dartanalyzer或dart2js）的JIT预热时间。当这些工具用于小型项目时，它们花费的实际时间与VM花费的JIT编译这些应用程序的时间一样多。

AppJIT快照可以解决此问题：可以使用一些模拟训练数据在VM上运行应用程序，然后将所有生成的代码和VM内部数据结构序列化为AppJIT快照。然后可以分发此快照，而不是以源（或内核二进制）形式分发应用程序。如果出现实际数据上的执行配置文件与培训期间观察到的执行配置文件不匹配，快照开始的VM仍可以采用JIT模式执行。

### 3.3 通过AppAOT Snapshots运行

AOT快照最初是为无法进行JIT编译的平台引入的，对于无法进行JIT意味着：

- AOT快照必须包含应用程序执行期间可能调用的每个功能的可执行代码;
- 可执行代码不得依赖于执行期间可能违反的任何推测性假设

为了满足这些要求，AOT编译过程会进行全局静态分析（类型流分析, TFA），以确定从已知入口点集中可访问应用程序的哪些部分，分配了哪些类的实例以及类型如何在程序中流动。 所有这些分析都是保守的：这意味着它们会在正确性方面出错，与可以在性能方面出错的JIT形成鲜明对比，因为它始终可以取消优化为未优化的代码以实现正确的行为。

然后，所有可能达到的功能都将编译为本地代码，而无需进行任何推测性优化。但是，类型流信息仍用于专门化代码（例如，取消虚拟化调用），编译完所有函数后，即可获取堆的快照。

最终的快照snapshot可以运行在预编译Runtime，该Runtime是Dart VM的特殊变体，其中不包括诸如JIT和动态代码加载工具之类的组件。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/aot.png)

AOT编译工具没有包含进Dart SDK。

```Java
//需要构建正常的dart可执行文件和运行AOT代码的runtime
$ tool/build.py -m release -a x64 runtime dart_precompiled_runtime

// 使用AOT编译器来编译APP
$ pkg/vm/tool/precompiler2 hello.dart hello.aot

//执行AOT快照
$ out/ReleaseX64/dart_precompiled_runtime hello.aot
Hello, World!
```

#### 3.3.1 Switchable Calls

1）即使进行了全局和局部分析，AOT编译的代码仍可能包含无法静态的去虚拟化的调用站点。为了补偿此AOT编译代码和运行时，采用JIT中使用的内联缓存技术的扩展。此扩展版本称为可切换呼叫 （Switchable Calls）。

JIT部分已经描述过，与调用站点关联的每个内联缓存均由两部分组成：一个缓存对象（由RawICData实例表示）和一个要调用的本机代码块（例如InlineCacheStub）。在JIT模式下，运行时只会更新缓存本身。但在AOT运行时中，可以根据内联缓存的状态选择同时替换缓存和要调用的本机代码。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/aot-ic-unlinked.png)

最初，所有动态呼叫均以未链接状态开始。首次调用此类呼叫站点时，将调用UnlinkedCallStub，它只是调用运行时帮助程序DRT_UnlinkedCall来链接此呼叫站点。

2）如果可能，DRT_UnlinkedCall尝试将呼叫站点转换为单态状态。在这种状态下，呼叫站点变成直接呼叫，该呼叫通过特殊的单态入口点进入方法，该入口点验证接收方是否具有预期的类。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/aot-ic-monomorphic.png)

在上面的示例中，假设第一次执行obj.method（）时，obj是C的实例，而obj.method则解析为C.method。

下次执行相同的调用站点时，它将直接调用C.method，从而绕过任何类型的方法查找过程。但是，它将通过特殊的入口点(已验证obj仍然是C的实例)进入C.method。如果不是这种情况，将调用DRT_MonomorphicMiss并将尝试选择下一个调用站点状态。

3）C.method可能仍然是调用的有效目标，例如obj是C的扩展类但不覆盖C.method的D类的实例。在这种情况下，检查呼叫站点是否可以转换为由SingleTargetCallStub实现的单个目标状态（见RawSingleTargetCache）。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/aot-ic-singletarget.png)

此存根基于以下事实：对于AOT编译，大多数类都使用继承层次结构的深度优先遍历来分配整数ID。如果C是具有D0，…，Dn子类的基类，并且没有一个覆盖C.method，则C.:cid <= classId（obj）<= max（D0.:cid，…，Dn .:cid）表示obj.method解析为C.method。在这种情况下，我们可以将类ID范围检查（单个目标状态）用于C的所有子类，而不是与单个类（单态）进行比较

否则，呼叫站点将切换为使用线性搜索内联缓存，类似于在JIT模式下使用的缓存。

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/aot-ic-linear.png)

最后，如果线性数组中的检查数量超过阈值，则呼叫站点将切换为使用类似字典的结构

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/aot-ic-dictionary.png)

## 四、附录

#### 4.1 源码说明

整个过程相关的核心源码，简要说明：

- runtime/vm/isolate.h： isolate对象
- runtime/vm/thread.h：与连接到isolate对象的线程关联的状态
- runtime/vm/heap/heap.h： isolate的堆
- raw_object.h： 虚拟机内部对象
- ast.dart：定义描述内核AST的类
- kernel_loader.cc：其中的LoadEntireProgram()方法用于将内核AST反序列化为相应虚拟机对象的入口点
- kernel_service.dart：实现了Kernel Service isolate
- kernel_isolate.cc：将Dart实现粘合到VM的其余部分
- pkg/front_end：用于解析Dart源码和构建内核AST
- pkg/vm: 托管了大多数基于内核的VM特定功能，例如各种内核到内核的转换；由于历史原因，某些转换还位于pkg/kernel;
- runtime/vm/compiler: 编译器源码
- runtime/vm/compiler/jit/compiler.cc：编译管道入口点
- runtime/vm/compiler/backend/il.h： IL的定义
- runtime/vm/compiler/frontend/kernel_binary_flowgraph.cc： 其中的BuildGraph(), 内核到IL的翻译开始，处理各种人工功能的IL的构建
- runtime/vm/stub_code_x64.cc：其中StubCode::GenerateNArgsCheckInlineCacheStub()，为内联缓存存根生成机器代码
- runtime/vm/runtime_entry.cc：其中InlineCacheMissHandler()处理IC没有命中的情况
- runtime/vm/compiler/compiler_pass.cc: 定义优化编译器的遍历及其顺序
- runtime/vm/compiler/jit/jit_call_specializer.h：进行大多数基于类型反馈的专业化
- runtime/vm/deopt_instructions.cc： 反优化过程
- runtime/vm/clustered_snapshot.cc：处理快照的序列化和反序列化。API函数家族Dart_CreateXyzSnapshot[AsAssembly]负责写出堆的快照，比如 Dart_CreateAppJITSnapshotAsBlobs 和Dart_CreateAppAOTSnapshotAsAssembly。
- runtime/vm/dart_api_impl.cc： 其中Dart_CreateIsolate可以选择获取快照数据以开始isolate。
- pkg/vm/lib/transformations/type_flow/transformer.dart: TFA（类型流分析）以及基于TFA结果转换的切入点
- runtime/vm/compiler/aot/precompiler.cc：其中Precompiler::DoCompileAll()是整个AOT编译的切入点

#### 4.2 参考资料

https://mrale.ph/dartvm/



# 解读Dart虚拟机的参数列表

## 一、概述

在third_party/dart/runtime/vm/flag_list.h定义了Dart虚拟机中所有标志的列表，标志分为以下几大类别：

- Product标记：可以在任何部署模式中设置，包括Product模式
- Release标志：通常可用的标志，除Product模式以外
- Precompile标志：通常可用的标志，除Product模式或已预编译的运行时以外
- Debug标志：只能在启用C++断言的VM调试模式中设置

Product、Release、Precompile、Debug这四类可控参数，可使用的范围逐次递减，比如Product flags可用于所有模式，Debug flags只能用于调试模式。Dart虚拟机总共有106个flags参数

## 二、flags参数

#### 2.1 Product flags

用法：PRODUCT_FLAG_MARCO（名称，类型，默认值，注解）

| 名称                                           | 默认值                      | 注解                                                   |
| :--------------------------------------------- | :-------------------------- | :----------------------------------------------------- |
| collect_dynamic_function_names                 | true                        | 收集所有动态函数名称以标识唯一目标                     |
| enable_kernel_expression_compilation           | true                        | 启用内核前端来编译表达式                               |
| enable_mirrors                                 | true                        | 允许导入dart:mirrors                                   |
| enable_ffi                                     | true                        | 允许导入dart:ffi                                       |
| guess_icdata_cid                               | true                        | 创建算法等操作的类型反馈                               |
| lazy_dispatchers                               | true                        | 懒惰地生成调度程序                                     |
| polymorphic_with_deopt                         | true                        | 反优化的多态调用、巨形调用                             |
| reorder_basic_blocks                           | true                        | 对基本块重新排序                                       |
| use_bare_instructions                          | true                        | 启用裸指令模式                                         |
| truncating_left_shift                          | true                        | 尽可能优化左移以截断                                   |
| use_cha_deopt                                  | true                        | 使用类层次分析，即使会导致反优化                       |
| use_strong_mode_types                          | true                        | 基于强模式类型的优化                                   |
| enable_slow_path_sharing                       | true                        | 启用共享慢速路径代码                                   |
| enable_multiple_entrypoints                    | true                        | 启用多个入口点                                         |
| experimental_unsafe_mode_use_ at_your_own_risk | false                       | 省略运行时强模式类型检查并禁用基于类型的优化           |
| abort_on_oom                                   | false                       | 如果内存分配失败则中止，仅与–old-gen-heap-size一起使用 |
| collect_code                                   | false                       | 尝试GC不常用代码                                       |
| dwarf_stack_traces                             | false                       | 在dylib快照中发出dwarf行号和内联信息，而不表示堆栈跟踪 |
| fields_may_be_reset                            | false                       | 不要优化静态字段初始化                                 |
| link_natives_lazily                            | false                       | 懒加载链接本地调用                                     |
| precompiled_mode                               | false                       | 预编译编译器模式                                       |
| print_snapshot_sizes                           | false                       | 打印生成snapshot的大小                                 |
| print_snapshot_sizes_verbose                   | false                       | 打印生成snapshot的详细大小                             |
| print_benchmarking_metrics                     | false                       | 打印其他内存和延迟指标以进行基准测试                   |
| shared_slow_path_triggers_gc                   | false                       | 测试：慢路径触发GC                                     |
| trace_strong_mode_types                        | false                       | 跟踪基于强模式类型的优化                               |
| use_bytecode_compiler                          | false                       | 从字节码编译                                           |
| use_compactor                                  | false                       | 当在旧空间执行GC时则压缩堆                             |
| enable_testing_pragmas                         | false                       | 启用神奇的编译指示以进行测试                           |
| enable_interpreter                             | false                       | 启用解释内核字节码                                     |
| verify_entry_points                            | false                       | 通过native API访问无效成员时抛出API错误                |
| background_compilation                         | USING_MULTICORE             | 根据是否多核来决定是否后台运行优化编译                 |
| concurrent_mark                                | USING_MULTICORE             | 老年代的并发标记                                       |
| concurrent_sweep                               | USING_MULTICORE             | 老年代的并发扫描                                       |
| use_field_guards                               | !USING_DBC                  | 使用字段gurad，跟踪字段类型                            |
| interpret_irregexp                             | USING_DBC                   | 使用irregexp字节码解释器                               |
| causal_async_stacks                            | !USING_PRODUCT              | 非product 则开启改进异步堆栈                           |
| marker_tasks                                   | USING_MULTICORE ? 2 : 0     | 老生代GC标记的任务数，0代表在主线程执行                |
| idle_timeout_micros                            | 1000 * 1000                 | 长时间后将空闲任务从线程池隔离，单位微秒               |
| idle_duration_micros                           | 500 * 1000                  | 允许空闲任务运行的时长                                 |
| old_gen_heap_size                              | (kWordSize <= 4) ? 1536 : 0 | 旧一代堆的最大大小，或0（无限制），单位MB              |
| new_gen_semi_max_size                          | (kWordSize <= 4) ? 8 : 16   | 新一代半空间的最大大小，单位MB                         |
| new_gen_semi_initial_size                      | (kWordSize <= 4) ? 1 : 2    | 新一代半空间的最大初始大小，单位MB                     |
| compactor_tasks                                | 2                           | 并行压缩使用的任务数                                   |
| getter_setter_ratio                            | 13                          | 用于double拆箱启发式的getter/setter使用率？            |
| huge_method_cutoff_in_tokens                   | 20000                       | 令牌中的大量方法中断：禁用大量方法的优化？             |
| max_polymorphic_checks                         | 4                           | 多态检查的最大数量，否则为巨形的？                     |
| max_equality_polymorphic_checks                | 32                          | 等式运算符中的多态检查的最大数量                       |
| compilation_counter_threshold                  | 10                          | 在解释执行函数编译完成前的函数使用次数要求，-1表示从不 |
| optimization_counter_threshold                 | 30000                       | 函数在优化前的用法计数值，-1表示从不                   |
| optimization_level                             | 2                           | 优化级别：1（有利大小），2（默认），3（有利速度）      |

optimization_level这是一个可以尝试的参数

#### 2.2 Release flags

用法：RELEASE_FLAG_MARCO（名称，product_value，类型，默认值，注解）

| 名称                                   | product值 | 默认值 | 注解                                       |
| :------------------------------------- | :-------- | :----- | :----------------------------------------- |
| eliminate_type_checks                  | true      | true   | 静态类型分析允许时消除类型检查             |
| dedup_instructions                     | true      | false  | 预编译时规范化指令                         |
| support_disassembler                   | false     | true   | 支持反汇编                                 |
| support_il_printer                     | false     | true   | 支持IL打印                                 |
| support_service                        | false     | true   | 支持服务协议                               |
| disable_alloc_stubs_after_gc           | false     | false  | 压力测试标识                               |
| disassemble                            | false     | false  | 反汇编dart代码                             |
| disassemble_optimized                  | false     | false  | 反汇编优化代码                             |
| dump_megamorphic_stats                 | false     | false  | dump巨形缓存统计信息                       |
| dump_symbol_stats                      | false     | false  | dump符合表统计信息                         |
| enable_asserts                         | false     | false  | 启用断言语句                               |
| log_marker_tasks                       | false     | false  | 记录老年代GC标记任务的调试信息             |
| randomize_optimization_counter         | false     | false  | 基于每个功能随机化优化计数器阈值，用于测试 |
| pause_isolates_on_start                | false     | false  | 在isolate开始前暂停                        |
| pause_isolates_on_exit                 | false     | false  | 在isolate退出前暂停                        |
| pause_isolates_on_unhandled_exceptions | false     | false  | 在isolate发生未捕获异常前暂停              |
| print_ssa_liveranges                   | false     | false  | 内存分配后打印有效范围                     |
| print_stacktrace_at_api_error          | false     | false  | 当API发生错误时，打印native堆栈            |
| profiler                               | false     | false  | 开启profiler                               |
| profiler_native_memory                 | false     | false  | 开启native内存统计收集                     |
| trace_profiler                         | false     | false  | 跟踪profiler                               |
| trace_field_guards                     | false     | false  | 跟踪字段cids的变化                         |
| verify_after_gc                        | false     | false  | 在GC之后启用堆验证                         |
| verify_before_gc                       | false     | false  | 在GC之前启用堆验证                         |
| verbose_gc                             | false     | false  | 开启详细GC                                 |
| verbose_gc_hdr                         | 40        | 40     | 打印详细的GC标头间隔                       |

#### 2.3 Precompile flags

用法：PRECOMPILE_FLAG_MARCO（名称，precompiled_value，product_value，类型，默认值，注释）

| 名称                         | precompiled值 | product值 | 默认值 | 说明                                       |
| :--------------------------- | :------------ | :-------- | :----- | :----------------------------------------- |
| load_deferred_eagerly        | true          | true      | false  | 急切加载延迟的库                           |
| use_osr                      | false         | true      | true   | 使用OSR                                    |
| async_debugger               | false         | false     | true   | 调试器支持异步功能                         |
| support_reload               | false         | false     | true   | 支持isolate重新加载                        |
| force_clone_compiler_objects | false         | false     | false  | 强制克隆编译器中所需的对象（ICData和字段） |
| stress_async_stacks          | false         | false     | false  | 压测异步堆栈                               |
| trace_irregexp               | false         | false     | false  | 跟踪irregexps                              |
| deoptimize_alot              | false         | false     | false  | 取消优化，从native条目返回到dart代码       |
| deoptimize_every             | 0             | 0         | 0      | 在每N次堆栈溢出检查中取消优化              |

#### 2.4 Debug flags

用法：DEBUG_FLAG_MARCO（名称，类型，默认值，注解）

| 名称                       | 默认值 | 注解                           |
| :------------------------- | :----- | :----------------------------- |
| print_variable_descriptors | false  | 在反汇编中打印变量描述符       |
| trace_cha                  | false  | 跟踪类层次分析(CHA)操作        |
| trace_ic                   | false  | 跟踪IC处理？                   |
| trace_ic_miss_in_optimized | false  | 跟踪优化中的IC未命中情况       |
| trace_intrinsified_natives | false  | 跟踪是否调用固有native         |
| trace_isolates             | false  | 跟踪isolate的创建与关闭        |
| trace_handles              | false  | 跟踪handles的分配              |
| trace_kernel_binary        | false  | 跟踪内核的读写                 |
| trace_natives              | false  | 跟踪native调用                 |
| trace_optimization         | false  | 打印优化详情                   |
| trace_profiler_verbose     | false  | 跟踪profiler详情               |
| trace_runtime_calls        | false  | 跟踪runtime调用                |
| trace_ssa_allocator        | false  | 跟踪通过SSA的寄存器分配        |
| trace_type_checks          | false  | 跟踪运行时类型检测             |
| trace_patching             | false  | 跟踪代码修补                   |
| trace_optimized_ic_calls   | false  | 跟踪优化代码中的IC调用？       |
| trace_zones                | false  | 跟踪zone的内存分配大小         |
| verify_gc_contains         | false  | 在GC期间开启地址是否包含的验证 |
| verify_on_transition       | false  | 验证dart/vm的过渡？            |
| support_rr                 | false  | 支持在RR中运行？               |

默认值全部都为false，

## 三、实现原理

#### 3.1 FLAG_LIST

[-> third_party/dart/runtime/vm/flags.cc]

```Java
FLAG_LIST(PRODUCT_FLAG_MARCO,
          RELEASE_FLAG_MARCO,
          DEBUG_FLAG_MARCO,
          PRECOMPILE_FLAG_MARCO)
```

FLAG_LIST列举了所有的宏定义，这里有四种不同的宏，接下来逐一展开说明

#### 3.2 flag宏定义

[-> third_party/dart/runtime/vm/flags.cc]

```Java
// (1) Product标记：可以在任何部署模式中设置
#define PRODUCT_FLAG_MARCO(name, type, default_value, comment)                 \
  type FLAG_##name = Flags::Register_##type(&FLAG_##name, #name, default_value, comment);

// (2) Release标志：通常可用的标志，除Product模式以外
#if !defined(PRODUCT)
#define RELEASE_FLAG_MARCO(name, product_value, type, default_value, comment)  \
  type FLAG_##name = Flags::Register_##type(&FLAG_##name, #name, default_value, comment);

// (3) Precompile标志：通常可用的标志，除Product模式或已预编译的运行时以外
#if !defined(PRODUCT) && !defined(DART_PRECOMPILED_RUNTIME)
#define PRECOMPILE_FLAG_MARCO(name, pre_value, product_value, type, default_value, comment) \
  type FLAG_##name = Flags::Register_##type(&FLAG_##name, #name, default_value, comment);

// (4) Debug标志：只能在debug调试模式运行
#if defined(DEBUG)  
#define DEBUG_FLAG_MARCO(name, type, default_value, comment)                   \
  type FLAG_##name =  Flags::Register_##type(&FLAG_##name, #name, default_value, comment);
```

这里涉及到3个宏定义：

- PRODUCT：代表Product模式；
- DART_PRECOMPILED_RUNTIME：代表运行时已预编译模式；
- DEBUG：代表调试模式；

可见，宏定义最终都是调用Flags::Register_XXX()方法，这里以FLAG_LIST中的其中一条定义来展开说明：

```Java
P(collect_code, bool, false, "Attempt to GC infrequently used code.")
//展开后等价如下
type FLAG_collect_code = Flags::Register_bool(&FLAG_collect_code, collect_code, false,
    "Attempt to GC infrequently used code.");
```

#### 3.3 Flags::Register_bool

[-> third_party/dart/runtime/vm/flags.cc]

```Java
bool Flags::Register_bool(bool* addr,
                          const char* name,
                          bool default_value,
                          const char* comment) {
  Flag* flag = Lookup(name);  //[见小节3.4]
  if (flag != NULL) {
    return default_value;
  }
  flag = new Flag(name, comment, addr, Flag::kBoolean);
  AddFlag(flag);
  return default_value;
}
```

#### 3.4 Flags::Lookup

[-> third_party/dart/runtime/vm/flags.cc]

```Java
Flag* Flags::Lookup(const char* name) {
  //遍历flags_来查找是否已存在
  for (intptr_t i = 0; i < num_flags_; i++) {
    Flag* flag = flags_[i];
    if (strcmp(flag->name_, name) == 0) {
      return flag;
    }
  }
  return NULL;
}
```

Flags类中有3个重要的静态成员变量：

```Java
static Flag** flags_; //记录所有的flags对象指针
static intptr_t capacity_;  //代表数组的容量大小
static intptr_t num_flags_;  //代表当前flags对象指针的个数
```

#### 3.5 Flag初始化

[-> third_party/dart/runtime/vm/flags.cc]

```Java
class Flag {
  Flag(const char* name, const char* comment, void* addr, FlagType type)
      : name_(name), comment_(comment), addr_(addr), type_(type) {}

  const char* name_;
  const char* comment_;
  union {
    void* addr_;
    bool* bool_ptr_;
    int* int_ptr_;
    uint64_t* uint64_ptr_;
    charp* charp_ptr_;
    FlagHandler flag_handler_;
    OptionHandler option_handler_;
  };
  FlagType type_;
}
```

#### 3.6 Flags::AddFlag

[-> third_party/dart/runtime/vm/flags.cc]

```Java
class Flag {

  void Flags::AddFlag(Flag* flag) {
    if (num_flags_ == capacity_) {
      if (flags_ == NULL) {
        capacity_ = 256;  //初始化大小为256
        flags_ = new Flag*[capacity_];
      } else {
        intptr_t new_capacity = capacity_ * 2; //扩容
        Flag** new_flags = new Flag*[new_capacity];
        for (intptr_t i = 0; i < num_flags_; i++) {
          new_flags[i] = flags_[i];
        }
        delete[] flags_;
        flags_ = new_flags;
        capacity_ = new_capacity;
      }
    }
    //将flag记录到flags_
    flags_[num_flags_++] = flag;
  }
}
```

最终，所有的flag信息都记录在Flags类的静态成员变量flags_中。

## 四、总结

- Product标记：可以在任何部署模式中设置
- Release标志：通常可用的标志，除Product模式以外
- Precompile标志：通常可用的标志，除Product模式或已预编译的运行时以外
- Debug标志：只能在启用C++断言的VM调试模式中设置



# 深入理解Dart虚拟机启动

> 基于Flutter 1.5，从源码视角来深入剖析引擎启动中的Dart虚拟机启动流程，相关源码目录见文末附录

## 一、概述

### 1.1 Dart虚拟机概述

Dart虚拟机拥有自己的Isolate，完全由虚拟机自己管理的，Flutter引擎也无法直接访问。Dart的UI相关操作，是由Root Isolate通过Dart的C++调用，或者是发送消息通知的方式，将UI渲染相关的任务提交到UIRunner执行，这样就可以跟Flutter引擎相关模块进行交互。

Isolate之间内存并不共享，而是通过Port方式通信，每个Isolate是有自己的内存以及相应的线程载体。从字面上理解，Isolate是“隔离”，isolate之间的内是逻辑隔离的。Isolate中的代码也是按顺序执行，因为Dart没有共享内存的并发，没有竞争的可能性，故不需要加锁，也没有死锁风险。对于Dart程序的并发则需要依赖多个isolate来实现。

### 1.2 Dart虚拟机启动工作

文章在介绍[flutter引擎启动](http://gityuan.com/2019/06/22/flutter_booting/)过程，有两个环节没有展开讲解，那就是DartVM和Isolate的创建过程。Dart与Isolate的启动过程是在FlutterActivity的onCreate()过程触发，在引擎启动的过程有3个环节会跟Dart与Isolate的启动相关，如下所示：

- AndroidShellHolder对象的创建过程，会执行Shell::Create()方法，这里会调用DartVMRef::Create()，[见小节2.1]
- Shell::Create()方法完成，然后创建完Shell完成对象，再接着Engine对象的创建过程，先创建RuntimeController对象，这里会调用DartIsolate::CreateRootIsolate()，[见小节3.1]
- AndroidShellHolder创建完成后，回调FlutterActivityDelegate的runBundle()过程，经过层层调用，会调用到DartIsolate::Run()，[见小节4.1]

#### 1.2.1 DartVM启动工作

AndroidShellHolder对象的创建过程，会调用到DartVMRef::Create()，进行DartVM创建，主要是为Dart虚拟机解析数据DartVMData，注册一系列Native方法，创建名专属vm的Isolate对象，初始化虚拟机内存、堆、线程、StoreBuffer等大量对象，工作内容如下：

1. 同一个进程只有一个Dart虚拟机，所有的Shell共享该进程中的Dart虚拟机，当leak_vm为false则在最后一个Shell对象退出时会回收dart虚拟机， 当leak_vm为true则即便Shell对象全部退出也不会回收dart虚拟机，这是为了优化再次启动的速度；

2. 创建的IsolateNameServer对象，里面有一个重要的成员port_mapping_，以端口名为key，端口号为value的map结构，记录所有注册的port端口； 可通过RegisterIsolatePortWithName()注册Isolate端口，通过LookupIsolatePortByName()根据端口名来查询端口号;

3. 创建DartVMData对象，从settings中解析出vm_snapshot,isolate_snapshot这两个DartSnapshot对象，DartSnapshot里有data_和instructions_两个字段；

4. 创建ListeningSocketRegistry对象，其中有两个重要的成员变量sockets_by_port_（记录以端口号为key的socket集合），sockets_by_fd_（记录以fd为key的socket集合）；

5. 通过pthread_create创建名为”dart:io EventHandler”的线程，然后进入该线程进入poll轮询方法，一旦收到事件则执行HandleEvents()

6. 执行DartUI::InitForGlobal()：执行相关对象的RegisterNatives()注册Native方法，用于Dart代码调用C++代码。

   - 创建DartLibraryNatives类型的g_natives对象，作为静态变量，其成员变量entries_和symbols_分别用于记录NativeFunction和Symbol信息；通过该对象的Register()，注册dart的native方法，用于Dart调用C++代码；通过GetNativeFunction(),GetSymbol()来查询Native方法和符号信息。
   - Canvas、DartRuntimeHooks、Paragraph、Scene、Window等大量对象都会依次执行RegisterNatives(g_natives)来注册各种Native方法，

7. 执行Dart::Init()：传递的参数params记录isolate和文件等相关callback，用于各种对象的初始化

   - 初始化VirtualMemory、OSThread、PortMap、FreeListElement、ForwardingCorpse、Api、NativeSymbolResolver、SemiSpace、StoreBuffer、MarkingStack对象
   - 初始化ThreadPool线程池对象
   - 创建名为”vm-isolate”的Isolate对象，注意此处不允许混淆符号，将新创建的isolate添加到isolates_list_head_链表；

   - 为该isolate创建Heap、ApiState等对象；
   - 创建IsolateMessageHandler，其继承于MessageHandler，MessageHandler中有两个比较重要的成员变量queue_和oob_queue_，用于记录普通消息和oob消息的队列。
   - isolate需要有一个Port端口号，通过PortMap::CreatePort()随机数生成一个整型的端口号，PortMap的成员变量map_是一个记录端口entry的HashMap，每一个entry里面有端口号，handler，以及端口状态。

**[DartVM创建流程](http://gityuan.com/img/dart_vm/DartVM.jpg)**

![DartVM](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/DartVM.jpg)

#### 1.2.2 Isolate启动工作

Dart虚拟机创建完成后，需要创建Engine对象，然后调用DartIsolate::CreateRootIsolate()来创建Isolate。每个Engine对应需要一个Isolate对象。

1. 创建DartIsolate和UIDartState对象，该对象继承于UIDartState对象；
2. 创建Root Isolate，并初始化Isolate相关信息，这个跟前面的Isolate过程一致。
   - 创建名为“Isolate-xxx”的Isolate对象，其中xxx是通过PortMap::CreatePort所创建port端口号
3. 只有root isolates能和window交互，也只有Root Isolate才会执行DartMessageHandler::Initialize()，设置task_dispatcher_等价于UITaskRunner->PostTask()；
4. DartRuntimeHooks安装过程，包括dart:isolate，dart:_internal，dart:core，dart:async，dart:io，

**[RootIsolate创建流程](http://gityuan.com/img/dart_vm/RootIsolate.jpg)**

![RootIsolate](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/RootIsolate.jpg)

### 1.3 说明

#### 1.3.1 如何注册Native方法

DartUI::InitForGlobal()这个过程再细看看

#### 1.3.2 Isolate说明

关于Isolate有以下四种：

- 虚拟机Isolate：”vm-isolate”，运行在ui线程
- 常见Isolate：“Isolate-xxx”，对于RootIsolate则属于这个类别，运行在ui线程；
- 虚拟机服务Isolate：”vm-service”，运行在独立的线程；
- 内核服务Isolate：”kernel-service”；

另外，Runtime Mode运行时模式有3种：debug，profile，release，其中debug模式使用JIT，profile/release使用AOT。在整个源码过程会有不少通过宏来控制针对不同运行模式的代码。 比如当处于非预编译模式(DART_PRECOMPILED_RUNTIME)，则开启Assert断言，否则关闭断言。

#### 1.3.3 相关类图

**[Isolate类图](http://gityuan.com/img/dart_vm/ClassIsolate.jpg)**

![ClassIsolate](http://gityuan.com/img/dart_vm/ClassIsolate.jpg)

#### 1.3.4 核心代码入口

文章在介绍[flutter引擎启动](http://gityuan.com/2019/06/22/flutter_booting/)过程，有两个环节没有展开讲解，那就是DartVM和Isolate的创建过程。Dart与Isolate的启动过程是在FlutterActivity的onCreate()过程触发，在引擎启动的过程有3个环节会跟Dart与Isolate的启动相关，如下所示：

- AndroidShellHolder对象的创建过程，会执行Shell::Create()方法，这里会调用DartVMRef::Create()，[见小节2.1]
- Shell::Create()方法完成，然后创建完Shell完成对象，再接着Engine对象的创建过程，先创建RuntimeController对象，这里会调用DartIsolate::CreateRootIsolate()，[见小节3.1]
- AndroidShellHolder创建完成后，回调FlutterActivityDelegate的runBundle()过程，经过层层调用，会调用到DartIsolate::Run()，[见小节4.1]

```Java
//创建Dart虚拟机
new AndroidShellHolder
  Shell::Create()
    DartVMRef::Create()

//创建Isolate
new Engine
  new RuntimeController
    DartIsolate::CreateRootIsolate

AndroidShellHolder::Launch
    Engine::Run
      Engine::PrepareAndLaunchIsolate
        DartIsolate::Run
```

接下来依次看看上述这3个过程。

## 二、创建Dart虚拟机

### 2.1 DartVMRef::Create

[-> flutter/runtime/dart_vm_lifecycle.cc]

```Java
static std::weak_ptr<DartVM> gVM;
static std::shared_ptr<DartVM>* gVMLeak;

DartVMRef DartVMRef::Create(Settings settings,
                            fml::RefPtr<DartSnapshot> vm_snapshot,
                            fml::RefPtr<DartSnapshot> isolate_snapshot,
                            fml::RefPtr<DartSnapshot> shared_snapshot) {
  std::lock_guard<std::mutex> lifecycle_lock(gVMMutex);

  //当该进程存在一个正在运行虚拟机，则获取其强引用，复用该虚拟机
  if (auto vm = gVM.lock()) {
    return DartVMRef{std::move(vm)};
  }

  std::lock_guard<std::mutex> dependents_lock(gVMDependentsMutex);
  ...
  //创建isolate服务
  auto isolate_name_server = std::make_shared<IsolateNameServer>();
  //创建虚拟机[见小节2.2]
  auto vm = DartVM::Create(std::move(settings),          
                           std::move(vm_snapshot),       
                           std::move(isolate_snapshot),  
                           std::move(shared_snapshot),   
                           isolate_name_server           
  );
  ...
  gVMData = vm->GetVMData();
  gVMServiceProtocol = vm->GetServiceProtocol();
  gVMIsolateNameServer = isolate_name_server;
  gVM = vm;
  //用于优化第二次的启动速度
  if (settings.leak_vm) {
    gVMLeak = new std::shared_ptr<DartVM>(vm);
  }

  return DartVMRef{std::move(vm)};
}
```

同一个进程只有一个Dart虚拟机，所有的Shell共享该进程中的Dart虚拟机，当leak_vm为false则在最后一个Shell对象退出时会回收dart虚拟机，当leak_vm为true则即便Shell对象全部退出也不会回收dart虚拟机，这是为了优化再次启动的速度。

这里创建的IsolateNameServer里面有一个重要的成员port_mapping_，以端口名为key，端口号为value的map结构，记录所有注册的port端口。

### 2.2 DartVM::Create

[-> flutter/runtime/dart_vm.cc]

```Java
std::shared_ptr<DartVM> DartVM::Create(
    Settings settings,
    fml::RefPtr<DartSnapshot> vm_snapshot,
    fml::RefPtr<DartSnapshot> isolate_snapshot,
    fml::RefPtr<DartSnapshot> shared_snapshot,
    std::shared_ptr<IsolateNameServer> isolate_name_server) {
  //只有settings有初值，其余参数为空[见小节2.2.1]
  auto vm_data = DartVMData::Create(settings,                     //
                                    std::move(vm_snapshot),       //
                                    std::move(isolate_snapshot),  //
                                    std::move(shared_snapshot)    //
  );
  ...
  //[见小节2.3]
  return std::shared_ptr<DartVM>(
      new DartVM(std::move(vm_data), std::move(isolate_name_server)));
}
```

#### 2.2.1 DartVMData::Create

[-> flutter/runtime/dart_vm_data.cc]

```Java
std::shared_ptr<const DartVMData> DartVMData::Create(
    Settings settings,
    fml::RefPtr<DartSnapshot> vm_snapshot,
    fml::RefPtr<DartSnapshot> isolate_snapshot,
    fml::RefPtr<DartSnapshot> shared_snapshot) {
  if (!vm_snapshot || !vm_snapshot->IsValid()) {
    vm_snapshot = DartSnapshot::VMSnapshotFromSettings(settings);
    ...
  }

  if (!isolate_snapshot || !isolate_snapshot->IsValid()) {
    isolate_snapshot = DartSnapshot::IsolateSnapshotFromSettings(settings);
    ...
  }

  if (!shared_snapshot || !shared_snapshot->IsValid()) {
    shared_snapshot = DartSnapshot::Empty();
    ...
  }
  //[见小节2.2.2]
  return std::shared_ptr<const DartVMData>(new DartVMData(
      std::move(settings),          //
      std::move(vm_snapshot),       //
      std::move(isolate_snapshot),  //
      std::move(shared_snapshot)    //
      ));
}
```

从settings中解析出vm_snapshot,isolate_snapshot数据。

#### 2.2.2 DartVMData初始化

[-> flutter/runtime/dart_vm_data.cc]

```Java
DartVMData::DartVMData(Settings settings,
                       fml::RefPtr<const DartSnapshot> vm_snapshot,
                       fml::RefPtr<const DartSnapshot> isolate_snapshot,
                       fml::RefPtr<const DartSnapshot> shared_snapshot)
    : settings_(settings),
      vm_snapshot_(vm_snapshot),
      isolate_snapshot_(isolate_snapshot),
      shared_snapshot_(shared_snapshot) {}
```

### 2.3 DartVM初始化

[-> flutter/runtime/dart_vm.cc]

```Java
DartVM::DartVM(std::shared_ptr<const DartVMData> vm_data,
               std::shared_ptr<IsolateNameServer> isolate_name_server)
    : settings_(vm_data->GetSettings()),
      vm_data_(vm_data),
      isolate_name_server_(std::move(isolate_name_server)),
      //创建ServiceProtocol
      service_protocol_(std::make_shared<ServiceProtocol>()) {
  TRACE_EVENT0("flutter", "DartVMInitializer");
  gVMLaunchCount++;
  {
    TRACE_EVENT0("flutter", "dart::bin::BootstrapDartIo");
    //[见小节2.4]
    dart::bin::BootstrapDartIo();
    if (!settings_.temp_directory_path.empty()) {
      dart::bin::SetSystemTempDirectory(settings_.temp_directory_path.c_str());
    }
  }

  std::vector<const char*> args;
  args.push_back("--ignore-unrecognized-flags"); //忽略无法识别的flags参数

  for (auto* const profiler_flag : ProfilingFlags(settings_.enable_dart_profiling)) {
    args.push_back(profiler_flag);
  }
  PushBackAll(&args, kDartLanguageArgs, arraysize(kDartLanguageArgs));

  if (IsRunningPrecompiledCode()) {
    PushBackAll(&args, kDartPrecompilationArgs, arraysize(kDartPrecompilationArgs));
  }

  bool enable_asserts = !settings_.disable_dart_asserts;
  if (IsRunningPrecompiledCode()) {
    enable_asserts = false; //当为预编译模式，则关闭Dart断言
  }

  if (enable_asserts) {
    PushBackAll(&args, kDartAssertArgs, arraysize(kDartAssertArgs));
  }

  if (settings_.start_paused) {
    PushBackAll(&args, kDartStartPausedArgs, arraysize(kDartStartPausedArgs));
  }

  if (settings_.disable_service_auth_codes) {
    PushBackAll(&args, kDartDisableServiceAuthCodesArgs,
                arraysize(kDartDisableServiceAuthCodesArgs));
  }

  if (settings_.endless_trace_buffer || settings_.trace_startup) {
    //开启无限大小的buffer，保证信息不被丢失
    PushBackAll(&args, kDartEndlessTraceBufferArgs,
                arraysize(kDartEndlessTraceBufferArgs));
  }

  if (settings_.trace_systrace) {
    PushBackAll(&args, kDartSystraceTraceBufferArgs,
                arraysize(kDartSystraceTraceBufferArgs));
    PushBackAll(&args, kDartTraceStreamsArgs, arraysize(kDartTraceStreamsArgs));
  }

  if (settings_.trace_startup) {
    PushBackAll(&args, kDartTraceStartupArgs, arraysize(kDartTraceStartupArgs));
  }

  for (size_t i = 0; i < settings_.dart_flags.size(); i++)
    args.push_back(settings_.dart_flags[i].c_str());

  char* flags_error = Dart_SetVMFlags(args.size(), args.data());
  ...

  DartUI::InitForGlobal();  //[见小节2.8]

  {
    TRACE_EVENT0("flutter", "Dart_Initialize");
    Dart_InitializeParams params = {};
    params.version = DART_INITIALIZE_PARAMS_CURRENT_VERSION;
    params.vm_snapshot_data = vm_data_->GetVMSnapshot().GetData()->GetSnapshotPointer();
    params.vm_snapshot_instructions = vm_data_->GetVMSnapshot().GetInstructionsIfPresent();
    params.create = reinterpret_cast<decltype(params.create)>(
                  DartIsolate::DartIsolateCreateCallback);
    params.shutdown = reinterpret_cast<decltype(params.shutdown)>(
                  DartIsolate::DartIsolateShutdownCallback);
    params.cleanup = reinterpret_cast<decltype(params.cleanup)>(
                  DartIsolate::DartIsolateCleanupCallback);
    params.thread_exit = ThreadExitCallback;
    params.get_service_assets = GetVMServiceAssetsArchiveCallback;
    params.entropy_source = dart::bin::GetEntropy;
    //[见小节2.9]
    char* init_error = Dart_Initialize(&params);

    //应用生命周期中最早的可记录时间戳发送到timeline
    if (engine_main_enter_ts != 0) {
      Dart_TimelineEvent("FlutterEngineMainEnter",
                         engine_main_enter_ts, engine_main_enter_ts,     
                         Dart_Timeline_Event_Duration, 0, nullptr, nullptr                        
      );
    }
  }

  Dart_SetFileModifiedCallback(&DartFileModifiedCallback);

  //允许Dart vm输出端stdout和stderr
  Dart_SetServiceStreamCallbacks(&ServiceStreamListenCallback,
                                 &ServiceStreamCancelCallback);

  Dart_SetEmbedderInformationCallback(&EmbedderInformationCallback);

  if (settings_.dart_library_sources_kernel != nullptr) {
    std::unique_ptr<fml::Mapping> dart_library_sources =
        settings_.dart_library_sources_kernel();
    //设置dart：*库的源代码以进行调试。
    Dart_SetDartLibrarySourcesKernel(dart_library_sources->GetMapping(),
                                     dart_library_sources->GetSize());
  }
}
```

该方法主要功能：

- 根据条件，创建Dart所需要的args信息
- 是否开启assert断言，取决于是否运行预编译代码。只有在debug模式才以JIT模式编译dart代码，对于profile/release都是以AOT模式编译成机器码；

### 2.4 BootstrapDartIo

[-> third_party/dart/runtime/bin/dart_io_api_impl.cc]

```Java
void BootstrapDartIo() {
  TimerUtils::InitOnce();
  //[见小节2.5]
  EventHandler::Start();
}
```

### 2.5 EventHandler::Start

[-> third_party/dart/runtime/bin/eventhandler.cc]

```Java
void EventHandler::Start() {
  ListeningSocketRegistry::Initialize(); //[见小节2.5.1]
  shutdown_monitor = new Monitor();   //[见小节2.5.3]
  event_handler = new EventHandler();  //[见小节2.5.4]
  event_handler->delegate_.Start(event_handler); //[见小节2.6]
}
```

此处delegate_是EventHandlerImplementation对象。

#### 2.5.1 ListeningSocketRegistry::Initialize

[-> third_party/dart/runtime/bin/socket.cc]

```Java
ListeningSocketRegistry* globalTcpListeningSocketRegistry = NULL;

void ListeningSocketRegistry::Initialize() {
  //[见小节2.5.2]
  globalTcpListeningSocketRegistry = new ListeningSocketRegistry();
}
```

初始化全局的socket注册对象，并保存在全局变量globalTcpListeningSocketRegistry中。

#### 2.5.2 ListeningSocketRegistry初始化

[-> third_party/dart/runtime/bin/socket.h]

```Java
class ListeningSocketRegistry {
  ListeningSocketRegistry()
      : sockets_by_port_(SameIntptrValue, kInitialSocketsCount),
        sockets_by_fd_(SameIntptrValue, kInitialSocketsCount),
        mutex_(new Mutex()) {}

  SimpleHashMap sockets_by_port_;
  SimpleHashMap sockets_by_fd_;
  Mutex* mutex_;
}
```

ListeningSocketRegistry有两个重要的成员变量：

- sockets_by_port_：类型为SimpleHashMap，记录以端口号为key的socket集合；
- sockets_by_fd_：类型为SimpleHashMap，记录以fd为key的socket集合；

#### 2.5.3 Monitor初始化

[-> third_party/dart/runtime/bin/thread_android.cc]

```Java
Monitor::Monitor() {
  pthread_mutexattr_t mutex_attr;
  pthread_mutexattr_init(&mutex_attr);
  pthread_mutex_init(data_.mutex(), &mutex_attr);
  pthread_mutexattr_destroy(&mutex_attr);

  pthread_condattr_t cond_attr;
  pthread_condattr_init(&cond_attr);
  pthread_cond_init(data_.cond(), &cond_attr);
  pthread_condattr_destroy(&cond_attr);
}

Monitor::~Monitor() {
  pthread_mutex_destroy(data_.mutex());
  pthread_cond_destroy(data_.cond());
}
```

此处的data_是Monitor类中的数据类型为MonitorData的私有成员变量，其中mutex()和cond()对应如下两个成员变量：

- mutex_：类型为pthread_mutex_t（互斥锁），用于在多线程中对共享变量的保护
- cond_ ：类型为pthread_cond_t（条件变量），一般和pthread_mutex_t配合使用，以防止有可能对共享变量读写出现非预期行为

对于Monitor有Enter/Exit，以及Wait/Notify/NotifyAll方法，内部的实现便是基于以下方法：

- pthread_mutex_lock: 上锁
- pthread_mutex_unlock：解锁
- pthread_cond_wait：阻塞在条件变量
- pthread_cond_timedwait：带超时机制的阻塞
- pthread_cond_signal：唤醒在条件变量阻塞的线程
- pthread_cond_broadcast：唤醒所有在该条件变量上的线程

#### 2.5.4 EventHandler初始化

[-> third_party/dart/runtime/bin/eventhandler.h]

```Java
class EventHandler {
  EventHandler() {}
  //[见小节2.5.5]
  EventHandlerImplementation delegate_;
}
```

#### 2.5.5 EventHandlerImplementation初始化

[-> third_party/dart/runtime/bin/eventhandler_android.h]

```Java
class EventHandlerImplementation {
 public:
  EventHandlerImplementation();

 private:
  SimpleHashMap socket_map_;
  TimeoutQueue timeout_queue_;
  bool shutdown_;
  int interrupt_fds_[2];
  int epoll_fd_;
};
```

### 2.6 EventHandlerImplementation::Start

[-> third_party/dart/runtime/bin/eventhandler_android.cc]

```Java
void EventHandlerImplementation::Start(EventHandler* handler) {
  //[见小节2.7]
  int result = Thread::Start("dart:io EventHandler",
          &EventHandlerImplementation::Poll, reinterpret_cast<uword>(handler));
}
```

通过Thread::Start()来创建一个名为“dart:io EventHandler”的线程，过程如下所示。

#### 2.6.1 Thread::Start

[-> third_party/dart/runtime/bin/thread_android.cc]

```Java
int Thread::Start(const char* name,
                  ThreadStartFunction function,
                  uword parameter) {
  pthread_attr_t attr;
  int result = pthread_attr_init(&attr);
  result = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  result = pthread_attr_setstacksize(&attr, Thread::GetMaxStackSize());

  ThreadStartData* data = new ThreadStartData(name, function, parameter);
  pthread_t tid;
  //通过pthread_create创建线程，然后触发执行Poll，见[小节2.7]
  result = pthread_create(&tid, &attr, ThreadStart, data);
  result = pthread_attr_destroy(&attr);
  return 0;
}
```

通过pthread_create创建线程，然后在线程中执行function，此处等于EventHandlerImplementation对象中的Poll(EventHandler)方法。

### 2.7 Poll

[-> third_party/dart/runtime/bin/eventhandler_android.cc]

```Java
void EventHandlerImplementation::Poll(uword args) {
  ThreadSignalBlocker signal_blocker(SIGPROF);
  static const intptr_t kMaxEvents = 16;  //最多处理16个事件
  struct epoll_event events[kMaxEvents];
  EventHandler* handler = reinterpret_cast<EventHandler*>(args);
  EventHandlerImplementation* handler_impl = &handler->delegate_;

  while (!handler_impl->shutdown_) {
    int64_t millis = handler_impl->GetTimeout();
    intptr_t result = TEMP_FAILURE_RETRY_NO_SIGNAL_BLOCKER(
        //进入epoll的状态等待事件
        epoll_wait(handler_impl->epoll_fd_, events, kMaxEvents, millis));
    if (result != -1) {
      handler_impl->HandleTimeout(); //[见小节2.7.1]
      handler_impl->HandleEvents(events, result); //[见小节2.7.2]
    }
  }
  handler->NotifyShutdownDone(); //[见小节2.7.4]
}
```

一旦收到事件，则执行HandleEvents()方法。

#### 2.7.1 HandleTimeout

[-> third_party/dart/runtime/bin/eventhandler_android.cc]

```Java
void EventHandlerImplementation::HandleTimeout() {
  if (timeout_queue_.HasTimeout()) {
    int64_t millis = timeout_queue_.CurrentTimeout() -
                     TimerUtils::GetCurrentMonotonicMillis();
    if (millis <= 0) {
      //当已超时，则向指定端口号发送一个空消息
      DartUtils::PostNull(timeout_queue_.CurrentPort());
      timeout_queue_.RemoveCurrent();
    }
  }
}
```

#### 2.7.2 HandleEvents

[-> third_party/dart/runtime/bin/eventhandler_android.cc]

```Java
void EventHandlerImplementation::HandleEvents(struct epoll_event* events,
                                              int size) {
  bool interrupt_seen = false;
  for (int i = 0; i < size; i++) {
    if (events[i].data.ptr == NULL) {
      interrupt_seen = true;
    } else {
      DescriptorInfo* di = reinterpret_cast<DescriptorInfo*>(events[i].data.ptr);
      const intptr_t old_mask = di->Mask();
      const intptr_t event_mask = GetPollEvents(events[i].events, di);
      if ((event_mask & (1 << kErrorEvent)) != 0) {
        di->NotifyAllDartPorts(event_mask);
        UpdateEpollInstance(old_mask, di);
      } else if (event_mask != 0) {
        Dart_Port port = di->NextNotifyDartPort(event_mask);
        UpdateEpollInstance(old_mask, di);
        DartUtils::PostInt32(port, event_mask);
      }
    }
  }
  if (interrupt_seen) {
    //执行socket事件后，在处理当前事件之前避免关闭套接字。 [见小节2.7.3]
    HandleInterruptFd();
  }
}
```

#### 2.7.3 HandleInterruptFd

[-> third_party/dart/runtime/bin/eventhandler_android.cc]

```Java
void EventHandlerImplementation::HandleInterruptFd() {
  const intptr_t MAX_MESSAGES = kInterruptMessageSize;
  InterruptMessage msg[MAX_MESSAGES];
  //从interrupt_fds_中读取消息
  ssize_t bytes = TEMP_FAILURE_RETRY_NO_SIGNAL_BLOCKER(
      read(interrupt_fds_[0], msg, MAX_MESSAGES * kInterruptMessageSize));
  for (ssize_t i = 0; i < bytes / kInterruptMessageSize; i++) {
    if (msg[i].id == kTimerId) {
      //当属于定时器消息，则将该消息加入超时消息队列
      timeout_queue_.UpdateTimeout(msg[i].dart_port, msg[i].data);
    } else if (msg[i].id == kShutdownId) {
      //当属于关闭消息，则会停止轮询poll
      shutdown_ = true;
    } else {
      Socket* socket = reinterpret_cast<Socket*>(msg[i].id);
      RefCntReleaseScope<Socket> rs(socket);

      DescriptorInfo* di =
          GetDescriptorInfo(socket->fd(), IS_LISTENING_SOCKET(msg[i].data));
      if (IS_COMMAND(msg[i].data, kShutdownReadCommand)) {
        //关闭socket读取
        VOID_NO_RETRY_EXPECTED(shutdown(di->fd(), SHUT_RD));
      } else if (IS_COMMAND(msg[i].data, kShutdownWriteCommand)) {
        //关闭socket写入
        VOID_NO_RETRY_EXPECTED(shutdown(di->fd(), SHUT_WR));
      } else if (IS_COMMAND(msg[i].data, kCloseCommand)) {
        // 关系socket，释放系统资源，并移动到下一个消息
        ...
        //向端口发送一个销毁的消息
        DartUtils::PostInt32(port, 1 << kDestroyedEvent);
      } else if (IS_COMMAND(msg[i].data, kReturnTokenCommand)) {
        int count = TOKEN_COUNT(msg[i].data);
        intptr_t old_mask = di->Mask();
        di->ReturnTokens(msg[i].dart_port, count);
        UpdateEpollInstance(old_mask, di);
      } else if (IS_COMMAND(msg[i].data, kSetEventMaskCommand)) {
        intptr_t events = msg[i].data & EVENT_MASK;
        intptr_t old_mask = di->Mask();
        di->SetPortAndMask(msg[i].dart_port, msg[i].data & EVENT_MASK);
        UpdateEpollInstance(old_mask, di);
      } else {
        UNREACHABLE();
      }
    }
  }
}
```

#### 2.7.4 NotifyShutdownDone

[-> third_party/dart/runtime/bin/eventhandler.cc]

```Java
void EventHandler::NotifyShutdownDone() {
  MonitorLocker ml(shutdown_monitor);
  ml.Notify(); //唤醒处于等待状态的shutdown_monitor
}
```

唤醒处于等待状态的shutdown_monitor，然后会清理全局注册的socket，见小节[2.7.5]

#### 2.7.4 Stop

[-> third_party/dart/runtime/bin/eventhandler.cc]

```Java
void EventHandler::Stop() {
  {
    MonitorLocker ml(shutdown_monitor);
    event_handler->delegate_.Shutdown();
    ml.Wait(Monitor::kNoTimeout);  //无限等待，直到被唤醒
  }

  // 清理
  delete event_handler;
  event_handler = NULL;
  delete shutdown_monitor;
  shutdown_monitor = NULL;

  //销毁全局注册的socket
  ListeningSocketRegistry::Cleanup();
}
```

到此[小节2.4]BootstrapDartIo方法执行完成，再回到[小节2.3]执行InitForGlobal()方法

### 2.8 DartUI::InitForGlobal

[-> flutter/lib/ui/dart_ui.cc]

```Java
void DartUI::InitForGlobal() {
   //只初始化一次
  if (!g_natives) {
    g_natives = new tonic::DartLibraryNatives(); // [见小节2.8.1]
    Canvas::RegisterNatives(g_natives);
    CanvasGradient::RegisterNatives(g_natives);
    CanvasImage::RegisterNatives(g_natives);
    CanvasPath::RegisterNatives(g_natives);
    CanvasPathMeasure::RegisterNatives(g_natives);
    Codec::RegisterNatives(g_natives);
    DartRuntimeHooks::RegisterNatives(g_natives);  // [见小节2.8.2]
    EngineLayer::RegisterNatives(g_natives);
    FontCollection::RegisterNatives(g_natives);
    FrameInfo::RegisterNatives(g_natives);
    ImageFilter::RegisterNatives(g_natives);
    ImageShader::RegisterNatives(g_natives);
    IsolateNameServerNatives::RegisterNatives(g_natives);
    Paragraph::RegisterNatives(g_natives);
    ParagraphBuilder::RegisterNatives(g_natives);
    Picture::RegisterNatives(g_natives);
    PictureRecorder::RegisterNatives(g_natives);
    Scene::RegisterNatives(g_natives);
    SceneBuilder::RegisterNatives(g_natives);
    SceneHost::RegisterNatives(g_natives);
    SemanticsUpdate::RegisterNatives(g_natives);
    SemanticsUpdateBuilder::RegisterNatives(g_natives);
    Vertices::RegisterNatives(g_natives);
    Window::RegisterNatives(g_natives);

    // 第二个isolates不提供UI相关的APIs
    g_natives_secondary = new tonic::DartLibraryNatives();
    DartRuntimeHooks::RegisterNatives(g_natives_secondary);
    IsolateNameServerNatives::RegisterNatives(g_natives_secondary);
  }
}
```

先创建DartLibraryNatives类型的g_natives，然后利用该对象来注册各种Native方法，这里以DartRuntimeHooks为例来说明[小节2.8.2]

#### 2.8.1 DartLibraryNatives初始化

[-> third_party/tonic/dart_library_natives.h]

```Java
class DartLibraryNatives {
 public:
  DartLibraryNatives();
  ~DartLibraryNatives();

  struct Entry {
    const char* symbol;
    Dart_NativeFunction native_function;
    int argument_count;
    bool auto_setup_scope;
  };

  void Register(std::initializer_list<Entry> entries);

  Dart_NativeFunction GetNativeFunction(Dart_Handle name,
                                        int argument_count,
                                        bool* auto_setup_scope);
  const uint8_t* GetSymbol(Dart_NativeFunction native_function);

 private:
  std::unordered_map<std::string, Entry> entries_;
  std::unordered_map<Dart_NativeFunction, const char*> symbols_;
};
```

来DartLibraryNatives的成员变量entries_和symbols_用于记录NativeFunction和Symbol信息，该类有3个方法：

- Register：注册dart的native方法，用于Dart调用C++代码。
- GetNativeFunction：根据Symbol和参数个数来查找NativeFunction
- GetSymbol：根据NativeFunction来查找Symbol

#### 2.8.2 RegisterNatives

[-> flutter/lib/ui/dart_runtime_hooks.cc]

```Java
void DartRuntimeHooks::RegisterNatives(tonic::DartLibraryNatives* natives) {
  //[见小节2.8.3/ 2.8.4]
  natives->Register({BUILTIN_NATIVE_LIST(REGISTER_FUNCTION)});
}
```

#### 2.8.3 Register

[-> third_party/tonic/dart_library_natives.cc]

```Java
void DartLibraryNatives::Register(std::initializer_list<Entry> entries) {
  for (const Entry& entry : entries) {
    symbols_.emplace(entry.native_function, entry.symbol);
    entries_.emplace(entry.symbol, entry);
  }
}
```

将注册的entry都记录DartLibraryNatives对象的成员变量symbols_和entries_里面。

#### 2.8.4 BUILTIN_NATIVE_LIST

[-> flutter/lib/ui/dart_runtime_hooks.cc]

```Java
#define REGISTER_FUNCTION(name, count) {"" #name, name, count, true},
#define BUILTIN_NATIVE_LIST(V) \
  V(Logger_PrintString, 1)     \
  V(SaveCompilationTrace, 0)   \
  V(ScheduleMicrotask, 1)      \
  V(GetCallbackHandle, 1)      \
  V(GetCallbackFromHandle, 1)
```

这是一个宏定义，REGISTER_FUNCTION的4个参数代表的如下所示的DartLibraryNatives中的Entry结构体

```Java
struct Entry {
  const char* symbol;
  Dart_NativeFunction native_function;
  int argument_count;
  bool auto_setup_scope;
};
```

可知，DartRuntimeHooks中注册了ScheduleMicrotask()等共5个Native方法。也就是说当调用natives.dart带有native标识的方法，最终会调用到dart_runtime_hooks.cc中的ScheduleMicrotask()方法，如下所示的两个相对应的方法。

[-> flutter/lib/ui/natives.dart]

```Java
void _scheduleMicrotask(void callback()) native 'ScheduleMicrotask';
```

[-> flutter/lib/ui/dart_runtime_hooks.cc]

```Java
void ScheduleMicrotask(Dart_NativeArguments args) {
  Dart_Handle closure = Dart_GetNativeArgument(args, 0);
  UIDartState::Current()->ScheduleMicrotask(closure);
}
```

### 2.9 Dart_Initialize

[-> third_party/dart/runtime/vm/dart_api_impl.cc]

```Java
DART_EXPORT char* Dart_Initialize(Dart_InitializeParams* params) {
  ...
  //[见小节2.10]
  return Dart::Init(params->vm_snapshot_data, params->vm_snapshot_instructions,
                    params->create, params->shutdown,
                    params->cleanup, params->thread_exit,
                    params->file_open, params->file_read,
                    params->file_write, params->file_close,
                    params->entropy_source, params->get_service_assets,
                    params->start_kernel_isolate);
}
```

### 2.10 Dart::Init

[-> third_party/dart/runtime/vm/dart.cc]

```Java
char* Dart::Init(const uint8_t* vm_isolate_snapshot,
                 const uint8_t* instructions_snapshot,
                 Dart_IsolateCreateCallback create,
                 Dart_IsolateShutdownCallback shutdown,
                 Dart_IsolateCleanupCallback cleanup,
                 Dart_ThreadExitCallback thread_exit,
                 Dart_FileOpenCallback file_open,
                 Dart_FileReadCallback file_read,
                 Dart_FileWriteCallback file_write,
                 Dart_FileCloseCallback file_close,
                 Dart_EntropySource entropy_source,
                 Dart_GetVMServiceAssetsArchive get_service_assets,
                 bool start_kernel_isolate) {
  const Snapshot* snapshot = nullptr;
  if (vm_isolate_snapshot != nullptr) {
    //创建Snapshot
    snapshot = Snapshot::SetupFromBuffer(vm_isolate_snapshot);
  }

  if (snapshot != nullptr) {
    char* error = SnapshotHeaderReader::InitializeGlobalVMFlagsFromSnapshot(snapshot);
  }
  ...
  FrameLayout::Init();
  //设置dart的线程退出函数、文件操作函数
  set_thread_exit_callback(thread_exit);
  SetFileCallbacks(file_open, file_read, file_write, file_close);
  set_entropy_source_callback(entropy_source);

  OS::Init();
  start_time_micros_ = OS::GetCurrentMonotonicMicros();
  VirtualMemory::Init(); //初始化虚拟内存 见[小节2.10.1]
  OSThread::Init(); //初始化系统线程 见[小节2.10.2]
  Isolate::InitVM(); //初始化Isolate 见[小节2.10.3]
  PortMap::Init(); //初始化PortMap 见[小节2.10.4]
  FreeListElement::Init();
  ForwardingCorpse::Init();
  Api::Init();
  NativeSymbolResolver::Init();
  SemiSpace::Init();
  StoreBuffer::Init();
  MarkingStack::Init();

  predefined_handles_ = new ReadOnlyHandles(); //创建只读handles
  //创建VM isolate，完成虚拟机初始化 见[小节2.10.5]
  thread_pool_ = new ThreadPool();
  {
    const bool is_vm_isolate = true;
    Dart_IsolateFlags api_flags;
    Isolate::FlagsInitialize(&api_flags);
    //[见小节2.11]
    vm_isolate_ = Isolate::InitIsolate("vm-isolate", api_flags, is_vm_isolate);

    Thread* T = Thread::Current();
    StackZone zone(T);
    HandleScope handle_scope(T);
    Object::InitNull(vm_isolate_);
    ObjectStore::Init(vm_isolate_);
    TargetCPUFeatures::Init();
    Object::Init(vm_isolate_);
    ArgumentsDescriptor::Init();
    ICData::Init();
    //根据vm_isolate_snapshot是否为空，以及snapshot的kind类型、编译模式来出现相关流程
    if (vm_isolate_snapshot != NULL) {
      ...
    } else {
      ...
    }

    T->InitVMConstants(); //初始化VM isolate常量
    {
      Object::FinalizeVMIsolate(vm_isolate_);
    }
  }
  Api::InitHandles();
  Thread::ExitIsolate();  //取消注册该线程中的VM isolate
  Isolate::SetCreateCallback(create);
  Isolate::SetShutdownCallback(shutdown);
  Isolate::SetCleanupCallback(cleanup);
  ...
  return NULL;
}
```

根据vm_isolate_snapshot是否则需要进行相关处理，以下3种情况则会直接返回，不再往下执行：

- 当vm_isolate_snapshot不为空的情况时：
  - 当snapshot类型为kFullAOT，且并非处于预编译模式(DART_PRECOMPILED_RUNTIME);
  - 当snapshot类型为kFull，且处于预编译模式(DART_PRECOMPILED_RUNTIME);
  - 当snapshot类型不是kFullAOT或kFullJIT或kFull；
- 当vm_isolate_snapshot等于空的情况时：
  - 当处于预编译模式(DART_PRECOMPILED_RUNTIME)，预编译模式需要预编译的snapshot；

#### 2.10.1 VirtualMemory::Init

[-> third_party/dart/runtime/vm/virtual_memory_posix.cc]

```Java
void VirtualMemory::Init() {
  page_size_ = getpagesize(); //获取页大小
}
```

#### 2.10.2 OSThread::Init

[-> third_party/dart/runtime/vm/os_thread.cc]

```Java
void OSThread::Init() {
  //分配全局OSThread锁
  if (thread_list_lock_ == NULL) {
    thread_list_lock_ = new Mutex();
  }

  //创建线程本地Key
  if (thread_key_ == kUnsetThreadLocalKey) {
    thread_key_ = CreateThreadLocal(DeleteThread);
  }

  //使能虚拟机中的OSThread创建
  EnableOSThreadCreation();

  //创建一个新的OSThread结构体，并赋予TLS
  OSThread* os_thread = CreateOSThread();
  OSThread::SetCurrent(os_thread);
  os_thread->set_name("Dart_Initialize");
}
```

#### 2.10.3 Isolate::InitVM

[-> third_party/dart/runtime/vm/isolate.cc]

```Java
void Isolate::InitVM() {
  create_callback_ = NULL;
  if (isolates_list_monitor_ == NULL) {
    isolates_list_monitor_ = new Monitor();
  }
  EnableIsolateCreation(); //使能Isolate创建
}
```

#### 2.10.4 PortMap::Init

[-> third_party/dart/runtime/vm/port.cc]

```Java
void PortMap::Init() {
  if (mutex_ == NULL) {
    mutex_ = new Mutex();
  }
  prng_ = new Random();

  static const intptr_t kInitialCapacity = 8;
  if (map_ == NULL) {
    map_ = new Entry[kInitialCapacity];
    capacity_ = kInitialCapacity;
  }
  memset(map_, 0, capacity_ * sizeof(Entry));
  used_ = 0;
  deleted_ = 0;
}
```

#### 2.10.5 ThreadPool初始化

[-> third_party/dart/runtime/vm/thread_pool.cc]

```Java
ThreadPool::ThreadPool()
    : shutting_down_(false),
      all_workers_(NULL),
      idle_workers_(NULL),
      count_started_(0),
      count_stopped_(0),
      count_running_(0),
      count_idle_(0),
      shutting_down_workers_(NULL),
      join_list_(NULL) {}
```

### 2.11 Isolate::InitIsolate

[-> third_party/dart/runtime/vm/isolate.cc]

```Java
Isolate* Isolate::InitIsolate(const char* name_prefix,
                              const Dart_IsolateFlags& api_flags,
                              bool is_vm_isolate) {
  //创建Isolate [2.11.1]
  Isolate* result = new Isolate(api_flags);

  bool is_service_or_kernel_isolate = false;
  if (ServiceIsolate::NameEquals(name_prefix)) {
    is_service_or_kernel_isolate = true;
  }
#if !defined(DART_PRECOMPILED_RUNTIME)
  if (KernelIsolate::NameEquals(name_prefix)) {
    KernelIsolate::SetKernelIsolate(result);
    is_service_or_kernel_isolate = true;
  }
#endif
  //初始化堆[见小节2.11.2]
  Heap::Init(result,
             is_vm_isolate ? 0 : FLAG_new_gen_semi_max_size * MBInWords,
             (is_service_or_kernel_isolate ? kDefaultMaxOldGenHeapSize
                                           : FLAG_old_gen_heap_size) * MBInWords);
  // [见小节2.11.3]
  if (!Thread::EnterIsolate(result)) {
    ... //当进入isolate失败，则关闭并删除isolate，并直接返回
    return NULL;
  }

  //创建isolate的消息处理对象 [见小节2.11.4]
  MessageHandler* handler = new IsolateMessageHandler(result);
  result->set_message_handler(handler);

  //创建Dart API状态的对象
  ApiState* state = new ApiState();
  result->set_api_state(state);
  // [见小节2.11.5]
  result->set_main_port(PortMap::CreatePort(result->message_handler()));
  result->set_origin_id(result->main_port());
  result->set_pause_capability(result->random()->NextUInt64());
  result->set_terminate_capability(result->random()->NextUInt64());
  //设置isolate的名称
  result->BuildName(name_prefix);

  //将isolate添加到isolates_list_head_列表
  if (!AddIsolateToList(result)) {
    //当添加失败，则关闭并删除isolate，并直接返回
    ...
  }
  return result;
}
```

该方法主要功能：

- DartVM初始化过程创建的是名为”vm-isolate”的isolate对象，对于isolate的命名方式：
  - 当指定名称name_prefix，则按指定名，比如此处为”vm-isolate”；
  - 当没有指定名称，则为“isolate-xxx”，此处的xxx为main_port端口号；
- 创建Heap，IsolateMessageHandler，ApiState对象，都保存到该isolate对象的成员变量；
- 如果整个过程执行成功，则将新创建的isolate添加到isolates_list_head_链表；如果失败，则会关闭并删除isolate对象。

#### 2.11.1 Isolate初始化

[-> third_party/dart/runtime/vm/isolate.cc]

```Java
Isolate::Isolate(const Dart_IsolateFlags& api_flags)
    : BaseIsolate(),
      user_tag_(0),
      current_tag_(UserTag::null()),
      default_tag_(UserTag::null()),
      ic_miss_code_(Code::null()),
      object_store_(NULL),
      class_table_(),
      single_step_(false),
      store_buffer_(new StoreBuffer()),
      marking_stack_(NULL),
      heap_(NULL),
      isolate_flags_(0),
      background_compiler_(NULL),
      optimizing_background_compiler_(NULL),
      start_time_micros_(OS::GetCurrentMonotonicMicros()),
      thread_registry_(new ThreadRegistry()),
      safepoint_handler_(new SafepointHandler(this)),
      message_notify_callback_(NULL),
      name_(NULL),
      main_port_(0),
      origin_id_(0),
      pause_capability_(0),
      terminate_capability_(0),
      init_callback_data_(NULL),
      environment_callback_(NULL),
      library_tag_handler_(NULL),
      api_state_(NULL),
      random_(),
      simulator_(NULL),
      ... //省略若干metex
      message_handler_(NULL),
      spawn_state_(NULL),
      defer_finalization_count_(0),
      pending_deopts_(new MallocGrowableArray<PendingLazyDeopt>()),
      deopt_context_(NULL),
      tag_table_(GrowableObjectArray::null()),
      deoptimized_code_array_(GrowableObjectArray::null()),
      sticky_error_(Error::null()),
      reloaded_kernel_blobs_(GrowableObjectArray::null()),
      next_(NULL),
      loading_invalidation_gen_(kInvalidGen),
      boxed_field_list_(GrowableObjectArray::null()),
      spawn_count_monitor_(new Monitor()),
      spawn_count_(0),
      handler_info_cache_(),
      catch_entry_moves_cache_(),
      embedder_entry_points_(NULL),
      obfuscation_map_(NULL),
      reverse_pc_lookup_cache_(nullptr) {
  FlagsCopyFrom(api_flags);
  SetErrorsFatal(true);
  set_compilation_allowed(true);
  set_user_tag(UserTags::kDefaultUserTag);
  ... //DartVM不允许混淆符号
  if (FLAG_enable_interpreter) {
    NOT_IN_PRECOMPILED(background_compiler_ = new BackgroundCompiler(this));
  }
  NOT_IN_PRECOMPILED(optimizing_background_compiler_ = new BackgroundCompiler(this));
}
```

#### 2.11.2 Heap::Init

[-> third_party/dart/runtime/vm/heap/heap.cc]

```Java
void Heap::Init(Isolate* isolate,
                intptr_t max_new_gen_words,
                intptr_t max_old_gen_words) {
  //创建堆Heap
  Heap* heap = new Heap(isolate, max_new_gen_words, max_old_gen_words);
  isolate->set_heap(heap);
}
```

#### 2.11.3 Thread::EnterIsolate

[-> third_party/dart/runtime/vm/thread.cc]

```Java
bool Thread::EnterIsolate(Isolate* isolate) {
  const bool kIsMutatorThread = true;
  Thread* thread = isolate->ScheduleThread(kIsMutatorThread);
  if (thread != NULL) {
    thread->task_kind_ = kMutatorTask;
    thread->StoreBufferAcquire();
    if (isolate->marking_stack() != NULL) {
      thread->MarkingStackAcquire();
      thread->DeferredMarkingStackAcquire();
    }
    return true;
  }
  return false;
}
```

#### 2.11.4 IsolateMessageHandler初始化

[-> third_party/dart/runtime/vm/isolate.cc]

```Java
class IsolateMessageHandler : public MessageHandler {
 public:
  explicit IsolateMessageHandler(Isolate* isolate);
}
```

IsolateMessageHandler继承于MessageHandler，MessageHandler中有两个比较重要的成员变量queue_和oob_queue_，用于记录普通消息和oob消息的队列。

#### 2.11.5 PortMap::CreatePort

[-> third_party/dart/runtime/vm/port.cc]

```Java
Dart_Port PortMap::CreatePort(MessageHandler* handler) {
  MutexLocker ml(mutex_);

  Entry entry;
  entry.port = AllocatePort();  //采用随机数生成一个整型的端口号
  entry.handler = handler;
  entry.state = kNewPort;

  intptr_t index = entry.port % capacity_;
  Entry cur = map_[index];
  while (cur.port != 0) {
    index = (index + 1) % capacity_;
    cur = map_[index];
  }

  if (map_[index].handler == deleted_entry_) {
    deleted_--;
  }
  map_[index] = entry;

  used_++;
  MaintainInvariants();
  return entry.port;
}
```

map_是一个记录端口entry的HashMap，每一个entry里面有端口号，handler，以及端口状态。

- 端口号port采用的是用随机数生成一个整型的端口号，
- handler是并记录handler指针；
- 端口状态state有3种类型，包括kNewPort(新分配的端口)，kLivePort(普通端口)，kControlPort(特殊控制类的端口)

## 三、创建Isolate

### 3.1 DartIsolate::CreateRootIsolate

[-> flutter/runtime/dart_isolate.cc]

```Java
std::weak_ptr<DartIsolate> DartIsolate::CreateRootIsolate(
    const Settings& settings,
    fml::RefPtr<const DartSnapshot> isolate_snapshot,
    fml::RefPtr<const DartSnapshot> shared_snapshot,
    TaskRunners task_runners,
    std::unique_ptr<Window> window,
    fml::WeakPtr<SnapshotDelegate> snapshot_delegate,
    fml::WeakPtr<IOManager> io_manager,
    std::string advisory_script_uri,
    std::string advisory_script_entrypoint,
    Dart_IsolateFlags* flags) {
  TRACE_EVENT0("flutter", "DartIsolate::CreateRootIsolate");
  Dart_Isolate vm_isolate = nullptr;
  std::weak_ptr<DartIsolate> embedder_isolate;

  //创建DartIsolate[见小节3.2]
  auto root_embedder_data = std::make_unique<std::shared_ptr<DartIsolate>>(
      std::make_shared<DartIsolate>(
          settings, std::move(isolate_snapshot),
          std::move(shared_snapshot), task_runners,                 
          std::move(snapshot_delegate), std::move(io_manager),        
          advisory_script_uri, advisory_script_entrypoint,    
          nullptr));
  //[见小节3.4]
  std::tie(vm_isolate, embedder_isolate) = CreateDartVMAndEmbedderObjectPair(
      advisory_script_uri.c_str(), advisory_script_entrypoint.c_str(),  
      nullptr, nullptr, flags,                               
      root_embedder_data.get(), true, &error);

  std::shared_ptr<DartIsolate> shared_embedder_isolate = embedder_isolate.lock();
  if (shared_embedder_isolate) {
    //只有root isolates能和window交互
    shared_embedder_isolate->SetWindow(std::move(window));
  }
  root_embedder_data.release();
  return embedder_isolate;
}
```

### 3.2 DartIsolate初始化

[-> flutter/runtime/dart_isolate.cc]

```Java
DartIsolate::DartIsolate(const Settings& settings,
                         fml::RefPtr<const DartSnapshot> isolate_snapshot,
                         fml::RefPtr<const DartSnapshot> shared_snapshot,
                         TaskRunners task_runners,
                         fml::WeakPtr<SnapshotDelegate> snapshot_delegate,
                         fml::WeakPtr<IOManager> io_manager,
                         std::string advisory_script_uri,
                         std::string advisory_script_entrypoint,
                         ChildIsolatePreparer child_isolate_preparer)
    : UIDartState(std::move(task_runners),
                  settings.task_observer_add,
                  settings.task_observer_remove,
                  std::move(snapshot_delegate),
                  std::move(io_manager),
                  advisory_script_uri,
                  advisory_script_entrypoint,
                  settings.log_tag,
                  settings.unhandled_exception_callback,
                  DartVMRef::GetIsolateNameServer()),
      settings_(settings),
      isolate_snapshot_(std::move(isolate_snapshot)),
      shared_snapshot_(std::move(shared_snapshot)),
      //当isolate准备运行的时候，会设置子isolate preparer
      child_isolate_preparer_(std::move(child_isolate_preparer)) {
  phase_ = Phase::Uninitialized;
}
```

该方法说明：

- 这是root isolate，故需要伪造一个父embedder对象；
- isolate生命周期完全由VM管理；
- 将settings的task_observer_add和task_observer_remove传递给UIDartState的add_callback和remove_callback；

### 3.3 UIDartState初始化

[-> flutter/lib/ui/ui_dart_state.cc]

```Java
UIDartState::UIDartState(
    TaskRunners task_runners,
    TaskObserverAdd add_callback,
    TaskObserverRemove remove_callback,
    fml::WeakPtr<SnapshotDelegate> snapshot_delegate,
    fml::WeakPtr<IOManager> io_manager,
    std::string advisory_script_uri,
    std::string advisory_script_entrypoint,
    std::string logger_prefix,
    UnhandledExceptionCallback unhandled_exception_callback,
    std::shared_ptr<IsolateNameServer> isolate_name_server)
    : task_runners_(std::move(task_runners)),
      add_callback_(std::move(add_callback)),
      remove_callback_(std::move(remove_callback)),
      snapshot_delegate_(std::move(snapshot_delegate)),
      io_manager_(std::move(io_manager)),
      advisory_script_uri_(std::move(advisory_script_uri)),
      advisory_script_entrypoint_(std::move(advisory_script_entrypoint)),
      logger_prefix_(std::move(logger_prefix)),
      unhandled_exception_callback_(unhandled_exception_callback),
      isolate_name_server_(std::move(isolate_name_server)) {
  //添加task observer [见小节3.3.1]
  AddOrRemoveTaskObserver(true /* add */);
}

UIDartState::~UIDartState() {
  //移除task observer
  AddOrRemoveTaskObserver(false ;
}
```

在UIDartState对象创建时添加task observer，该对象销毁时移除task observer。

#### 3.3.1 AddOrRemoveTaskObserver

[-> flutter/lib/ui/ui_dart_state.cc]

```Java
void UIDartState::AddOrRemoveTaskObserver(bool add) {
  auto task_runner = task_runners_.GetUITaskRunner();
  ...
  if (add) {
    //[见小节3.3.3]
    add_callback_(reinterpret_cast<intptr_t>(this),
                  [this]() { this->FlushMicrotasksNow(); });
  } else {
    remove_callback_(reinterpret_cast<intptr_t>(this));
  }
}
```

根据[小节3.2]传递的参数，可知add_callback_等于settings.task_observer_add，再来看看settings.task_observer_add到底是什么。

#### 3.3.2 FlutterMain::Init

[-> flutter/shell/platform/android/flutter_main.cc]

```Java
void FlutterMain::Init(...) {
  ...
  //初始化observer的增加和删除方法
  settings.task_observer_add = [](intptr_t key, fml::closure callback) {
    fml::MessageLoop::GetCurrent().AddTaskObserver(key, std::move(callback));
  };

  settings.task_observer_remove = [](intptr_t key) {
    fml::MessageLoop::GetCurrent().RemoveTaskObserver(key);
  };
}
```

在Flutter引擎启动时执行FlutterActivity的onCreate()过程，会调用FlutterMain::Init()方法。由此可见，settings的task_observer_add和task_observer_remove分别对应MessageLoopImpl的AddTaskObserver()和RemoveTaskObserver()方法。

#### 3.3.3 AddTaskObserver

[-> flutter/fml/message_loop_impl.cc]

```Java
void MessageLoopImpl::AddTaskObserver(intptr_t key, fml::closure callback) {
  task_observers_[key] = std::move(callback);
}

void MessageLoopImpl::RemoveTaskObserver(intptr_t key) {
  task_observers_.erase(key);
}
```

task_observers_是一个map类型，以UIDartState实例对象为key，以FlushMicrotasksNow()方法为value。该过程task_observers_中新增了一个FlushMicrotasksNow()方法，用于在MessageLoop过程来消费Microtask。即task_observers_的子项observer.second()对应的是FlushMicrotasksNow()方法。

### 3.4 CreateDartVMAndEmbedderObjectPair

[-> flutter/runtime/dart_isolate.cc]

```Java
std::pair<Dart_Isolate, std::weak_ptr<DartIsolate>>  
DartIsolate::CreateDartVMAndEmbedderObjectPair(
    const char* advisory_script_uri,
    const char* advisory_script_entrypoint,
    const char* package_root,
    const char* package_config,
    Dart_IsolateFlags* flags,
    std::shared_ptr<DartIsolate>* p_parent_embedder_isolate,
    bool is_root_isolate,
    char** error) {
  TRACE_EVENT0("flutter", "DartIsolate::CreateDartVMAndEmbedderObjectPair");

  std::unique_ptr<std::shared_ptr<DartIsolate>> embedder_isolate(p_parent_embedder_isolate);
  if (!is_root_isolate) {
    ...
  }

  // [见小节3.5]
  Dart_Isolate isolate = Dart_CreateIsolate(
      advisory_script_uri, advisory_script_entrypoint,  
      (*embedder_isolate)->GetIsolateSnapshot()->GetData()->GetSnapshotPointer(),
      (*embedder_isolate)->GetIsolateSnapshot()->GetInstructionsIfPresent(),
      (*embedder_isolate)->GetSharedSnapshot()->GetDataIfPresent(),
      (*embedder_isolate)->GetSharedSnapshot()->GetInstructionsIfPresent(),
      flags, embedder_isolate.get(), error);
  ...
  // [见小节3.7]
  if (!(*embedder_isolate)->Initialize(isolate, is_root_isolate)) {
    return {nullptr, {}};
  }
  // [见小节3.8]
  if (!(*embedder_isolate)->LoadLibraries(is_root_isolate)) {
    return {nullptr, {}};
  }
  //获取DartIsolate的弱引用
  auto weak_embedder_isolate = (*embedder_isolate)->GetWeakIsolatePtr();
  ...
  embedder_isolate.release();
  //embedder的所有权由Dart VM控制，因此返回给调用者的是弱引用
  return {isolate, weak_embedder_isolate};
}
```

### 3.5 Dart_CreateIsolate

[-> third_party/dart/runtime/vm/dart_api_impl.cc]

```Java
DART_EXPORT Dart_Isolate
Dart_CreateIsolate(const char* script_uri,
                   const char* name,
                   const uint8_t* snapshot_data,
                   const uint8_t* snapshot_instructions,
                   const uint8_t* shared_data,
                   const uint8_t* shared_instructions,
                   Dart_IsolateFlags* flags,
                   void* callback_data,
                   char** error) {
  API_TIMELINE_DURATION(Thread::Current());
  //[见小节3.6]
  return CreateIsolate(script_uri, name, snapshot_data, snapshot_instructions,
                       shared_data, shared_instructions, NULL, 0, flags,
                       callback_data, error);
}
```

### 3.6 CreateIsolate

[-> third_party/dart/runtime/vm/dart_api_impl.cc]

```Java
static Dart_Isolate CreateIsolate(const char* script_uri,
                                  const char* name,
                                  const uint8_t* snapshot_data,
                                  const uint8_t* snapshot_instructions,
                                  const uint8_t* shared_data,
                                  const uint8_t* shared_instructions,
                                  const uint8_t* kernel_buffer,
                                  intptr_t kernel_buffer_size,
                                  Dart_IsolateFlags* flags,
                                  void* callback_data,
                                  char** error) {
  Dart_IsolateFlags api_flags;
  if (flags == NULL) {
    Isolate::FlagsInitialize(&api_flags);  //初始化flags
    flags = &api_flags;
  }
  // [见小节3.6.1]
  Isolate* I = Dart::CreateIsolate((name == NULL) ? "isolate" : name, *flags);
  ...
  {
    Thread* T = Thread::Current();
    StackZone zone(T);
    HANDLESCOPE(T);
    T->EnterApiScope();
    const Error& error_obj = Error::Handle(Z,
        // [见小节3.6.2]
        Dart::InitializeIsolate(snapshot_data, snapshot_instructions,
                                shared_data, shared_instructions, kernel_buffer,
                                kernel_buffer_size, callback_data));
    if (error_obj.IsNull()) {
      T->ExitApiScope();
      T->set_execution_state(Thread::kThreadInNative);
      T->EnterSafepoint();
      ...
      return Api::CastIsolate(I);
    }
    ...
    T->ExitApiScope();
  }
  Dart::ShutdownIsolate(); //创建错误，则会关闭Isolate
  return reinterpret_cast<Dart_Isolate>(NULL);
}
```

#### 3.6.1 Dart::CreateIsolate

[-> third_party/dart/runtime/vm/dart.cc]

```Java
Isolate* Dart::CreateIsolate(const char* name_prefix,
                             const Dart_IsolateFlags& api_flags) {
  //创建Isolate [见小节2.11]
  Isolate* isolate = Isolate::InitIsolate(name_prefix, api_flags);
  return isolate;
}
```

关于Isolate的创建方法见[小节2.11]，每次创建RuntimeController对象，都会创建相应的Root Isolate。

#### 3.6.2 Dart::InitializeIsolate

[-> third_party/dart/runtime/vm/dart.cc]

```Java
RawError* Dart::InitializeIsolate(const uint8_t* snapshot_data,
                                  const uint8_t* snapshot_instructions,
                                  const uint8_t* shared_data,
                                  const uint8_t* shared_instructions,
                                  const uint8_t* kernel_buffer,
                                  intptr_t kernel_buffer_size,
                                  void* data) {
  Thread* T = Thread::Current();
  Isolate* I = T->isolate();
  StackZone zone(T);
  HandleScope handle_scope(T);
  ObjectStore::Init(I);

  Error& error = Error::Handle(T->zone());
  error = Object::Init(I, kernel_buffer, kernel_buffer_size);

  if ((snapshot_data != NULL) && kernel_buffer == NULL) {
    //读取snapshot，并初始化状态
    const Snapshot* snapshot = Snapshot::SetupFromBuffer(snapshot_data);
    ...
    FullSnapshotReader reader(snapshot, snapshot_instructions, shared_data,
                              shared_instructions, T);
    //读取isolate的Snapshot
    const Error& error = Error::Handle(reader.ReadIsolateSnapshot());
    ReversePcLookupCache::BuildAndAttachToIsolate(I);
  } else {
    ...
  }

  Object::VerifyBuiltinVtables();
  ...

  const Code& miss_code = Code::Handle(I->object_store()->megamorphic_miss_code());
  I->set_ic_miss_code(miss_code);
  I->heap()->InitGrowthControl();
  I->set_init_callback_data(data);
  Api::SetupAcquiredError(I);
  //名为"vm-service"的Isolate 则为ServiceIsolate
  ServiceIsolate::MaybeMakeServiceIsolate(I);
  //发送Isolate启动的消息
  ServiceIsolate::SendIsolateStartupMessage();

  //创建tag表
  I->set_tag_table(GrowableObjectArray::Handle(GrowableObjectArray::New()));
  //设置默认的UserTag
  const UserTag& default_tag = UserTag::Handle(UserTag::DefaultTag());
  I->set_current_tag(default_tag);
  return Error::null();
}
```

到这里Isolate的创建过程便真正完成。

### 3.7 DartIsolate::Initialize

[-> flutter/runtime/dart_isolate.cc]

```Java
bool DartIsolate::Initialize(Dart_Isolate dart_isolate, bool is_root_isolate) {
  ...
  auto* isolate_data = static_cast<std::shared_ptr<DartIsolate>*>(
                                  Dart_IsolateData(dart_isolate));
  SetIsolate(dart_isolate);
  //保存当前的isolate，进入新的scope
  Dart_ExitIsolate();

  tonic::DartIsolateScope scope(isolate());
  //[见小节3.7.1]
  SetMessageHandlingTaskRunner(GetTaskRunners().GetUITaskRunner(),
                               is_root_isolate);

  if (tonic::LogIfError(
          Dart_SetLibraryTagHandler(tonic::DartState::HandleLibraryTag))) {
    return false;
  }
  //更新ui/gpu/io/platform的线程名
  if (!UpdateThreadPoolNames()) {
    return false;
  }

  phase_ = Phase::Initialized;
  return true;
}
```

#### 3.7.1 DartIsolate::SetMessageHandlingTaskRunner

[-> flutter/runtime/dart_isolate.cc]

```Java
void DartIsolate::SetMessageHandlingTaskRunner(
    fml::RefPtr<fml::TaskRunner> runner, bool is_root_isolate) {
  //只有root isolate才会执行该过程
  if (!is_root_isolate || !runner) {
    return;
  }
  message_handling_task_runner_ = runner;

  //[见小节3.7.2]
  message_handler().Initialize([runner](std::function<void()> task) { runner->PostTask(task); });
}
```

这里需要重点注意的是，只有root isolate才会执行Initialize()过程。

#### 3.7.2 DartMessageHandler::Initialize

[-> third_party/tonic/dart_message_handler.cc]

```Java
void DartMessageHandler::Initialize(TaskDispatcher dispatcher) {
  //设置task_dispatcher_
  task_dispatcher_ = dispatcher;
  //设置message_notify_callback
  Dart_SetMessageNotifyCallback(MessageNotifyCallback);
}
```

由此可见：

- task_dispatcher_值等价于UITaskRunner->PostTask()，执行的是向UI线程PostTask的操作；
- message_notify_callback值等价于DartMessageHandler::MessageNotifyCallback；

### 3.8 DartIsolate::LoadLibraries

[-> flutter/runtime/dart_isolate.cc]

```Java
bool DartIsolate::LoadLibraries(bool is_root_isolate) {
  TRACE_EVENT0("flutter", "DartIsolate::LoadLibraries");
  if (phase_ != Phase::Initialized) {
    return false;
  }

  tonic::DartState::Scope scope(this);

  DartIO::InitForIsolate(); //[见小节3.8.1]

  DartUI::InitForIsolate(is_root_isolate);  //[见小节3.8.4]

  const bool is_service_isolate = Dart_IsServiceIsolate(isolate());
    //[见小节3.8.5]
  DartRuntimeHooks::Install(is_root_isolate && !is_service_isolate,
                            GetAdvisoryScriptURI());

  if (!is_service_isolate) {
    class_library().add_provider(
        "ui", std::make_unique<tonic::DartClassProvider>(this, "dart:ui"));
  }

  phase_ = Phase::LibrariesSetup;
  return true;
}
```

#### 3.8.1 DartIO::InitForIsolate

[-> flutter/lib/io/dart_io.cc]

```Java
void DartIO::InitForIsolate() {
  //[见小节3.8.1]
  Dart_Handle result = Dart_SetNativeResolver(
      Dart_LookupLibrary(ToDart("dart:io")),
          dart::bin::LookupIONative, dart::bin::LookupIONativeSymbol);
}
```

来看看Dart_SetNativeResolver和Dart_LookupLibrary的实现。

#### 3.8.2 Dart_SetNativeResolver

[-> third_party/dart/runtime/vm/dart_api_impl.cc]

```Java
DART_EXPORT Dart_Handle
Dart_SetNativeResolver(Dart_Handle library,
                       Dart_NativeEntryResolver resolver,
                       Dart_NativeEntrySymbol symbol) {
  DARTSCOPE(Thread::Current());
  const Library& lib = Api::UnwrapLibraryHandle(Z, library);
  lib.set_native_entry_resolver(resolver);
  lib.set_native_entry_symbol_resolver(symbol);
  return Api::Success();
}
```

#### 3.8.3 Dart_LookupLibrary

[-> third_party/dart/runtime/vm/dart_api_impl.cc]

```Java
DART_EXPORT Dart_Handle Dart_LookupLibrary(Dart_Handle url) {
  DARTSCOPE(Thread::Current());
  const String& url_str = Api::UnwrapStringHandle(Z, url);

  const Library& library = Library::Handle(Z, Library::LookupLibrary(T, url_str));
  if (library.IsNull()) {
    ...
  } else {
    return Api::NewHandle(T, library.raw());
  }
}
```

#### 3.8.4 DartUI::InitForIsolate

[-> flutter/lib/ui/dart_ui.cc]

```Java
void DartUI::InitForIsolate(bool is_root_isolate) {
  auto get_native_function =
      is_root_isolate ? GetNativeFunction : GetNativeFunctionSecondary;
  auto get_symbol = is_root_isolate ? GetSymbol : GetSymbolSecondary;
  Dart_Handle result = Dart_SetNativeResolver(
      Dart_LookupLibrary(ToDart("dart:ui")), get_native_function, get_symbol);
}
```

#### 3.8.5 DartRuntimeHooks::Install

[-> flutter/lib/ui/dart_runtime_hooks.cc]

```Java
void DartRuntimeHooks::Install(bool is_ui_isolate,
                               const std::string& script_uri) {
  Dart_Handle builtin = Dart_LookupLibrary(ToDart("dart:ui"));
  InitDartInternal(builtin, is_ui_isolate);
  InitDartCore(builtin, script_uri);
  InitDartAsync(builtin, is_ui_isolate);
  InitDartIO(builtin, script_uri);
}
```

## 四、运行DartIsolate

### 4.1 DartIsolate::Run

[-> flutter/runtime/dart_isolate.cc]

```Java
bool DartIsolate::Run(const std::string& entrypoint_name, fml::closure on_run) {
  TRACE_EVENT0("flutter", "DartIsolate::Run");
  ...

  tonic::DartState::Scope scope(this);
  //获取用户入口函数，也就是主函数main()
  auto user_entrypoint_function =
      Dart_GetField(Dart_RootLibrary(), tonic::ToDart(entrypoint_name.c_str()));
  //[见小节4.2]
  if (!InvokeMainEntrypoint(user_entrypoint_function)) {
    return false;
  }
  phase_ = Phase::Running;

  if (on_run) {
    on_run();
  }
  return true;
}
```

### 4.2 InvokeMainEntrypoint

[-> flutter/runtime/dart_isolate.cc]

```Java
static bool InvokeMainEntrypoint(Dart_Handle user_entrypoint_function) {
  // [见小节4.2.1]
  Dart_Handle start_main_isolate_function =
      tonic::DartInvokeField(Dart_LookupLibrary(tonic::ToDart("dart:isolate")),
                             "_getStartMainIsolateFunction", {});

  //[见小节4.3]
  if (tonic::LogIfError(tonic::DartInvokeField(
          Dart_LookupLibrary(tonic::ToDart("dart:ui")), "_runMainZoned",
          {start_main_isolate_function, user_entrypoint_function}))) {
    return false;
  }
  return true;
}
```

经过Dart虚拟机最终会调用的Dart层的_runMainZoned()方法，其中参数start_main_isolate_function等于_startIsolate。

#### 4.2.1 _getStartMainIsolateFunction

[-> third_party/dart/runtime/lib/isolate_patch.dart]

```Java
@pragma("vm:entry-point", "call")
Function _getStartMainIsolateFunction() {
  return _startMainIsolate;
}

@pragma("vm:entry-point", "call")
void _startMainIsolate(Function entryPoint, List<String> args) {
  _startIsolate(
      null, // no parent port
      entryPoint,
      args,
      null, // no message
      true, // isSpawnUri
      null, // no control port
      null); // no capabilities
}
```

### 4.3 _runMainZoned

[-> flutter/lib/ui/hooks.dart]

```Java
void _runMainZoned(Function startMainIsolateFunction, Function userMainFunction) {
   //[见小节4.4]
  startMainIsolateFunction((){
    runZoned<Future<void>>(() {
      const List<String> empty_args = <String>[];
      if (userMainFunction is _BinaryFunction) {
        (userMainFunction as dynamic)(empty_args, '');
      } else if (userMainFunction is _UnaryFunction) {
        (userMainFunction as dynamic)(empty_args);
      } else {
        userMainFunction();  //[见小节4.5]
      }
    }, onError: (Object error, StackTrace stackTrace) {
      _reportUnhandledException(error.toString(), stackTrace.toString());
    });
  }, null);
}
```

该方法的startMainIsolateFunction等于_startIsolate，userMainFunction等于main.dart文件中的main()方法，也就是整个Dart业务代码。

### 4.4 _startIsolate

[-> third_party/dart/runtime/lib/isolate_patch.dart]

```Java
@pragma("vm:entry-point", "call")
void _startIsolate(
    SendPort parentPort,
    Function entryPoint,
    List<String> args,
    var message,
    bool isSpawnUri,
    RawReceivePort controlPort,
    List capabilities) {
  //控制端口(也称主isolate端口)不处理任何消息
  if (controlPort != null) {
    controlPort.handler = (_) {};
  }
  ...

  // 将所有用户代码处理延迟到下一次消息循环运行。 这允许拦截事件调度中的某些条件，例如在暂停状态下开始。
  RawReceivePort port = new RawReceivePort();
  port.handler = (_) {
    port.close();

    if (isSpawnUri) {
      if (entryPoint is _BinaryFunction) {
        (entryPoint as dynamic)(args, message);
      } else if (entryPoint is _UnaryFunction) {
        (entryPoint as dynamic)(args);
      } else {
        entryPoint(); //[见小节4.5]
      }
    } else {
      entryPoint(message);
    }
  };
  //确保消息handler已触发
  port.sendPort.send(null);
}
```

此处entryPoint便是runZoned，然后几次调用后，回到_runMainZoned()方法的userMainFunction，而userMainFunction

### 4.5 main

[-> lib/main.dart]

```
void main() => runApp(Widget app);
```

![runzoned](http://gityuan.com/img/flutter_boot/runzoned.png)

也就是说FlutterActivity.onCreate()方法，经过层层调用后开始执行dart层的main()方法，执行runApp()的过程，这便开启执行整个Dart业务代码。

## 附录

```Java
third_party/dart/runtime/vm/
  - dart_api_impl.cc
  - dart.cc
  - port.cc
  - isolate.cc
  - heap/heap.cc
  - thread.cc
  - thread_pool.cc
  - virtual_memory_posix.cc
  - os_thread.cc

third_party/dart/runtime/bin/
  - dart_io_api_impl.cc
  - eventhandler.cc
  - socket.cc
  - socket.h
  - thread_android.cc
  - eventhandler.h
  - eventhandler_android.h
  - eventhandler_android.cc
  - thread_android.cc
  - eventhandler_android.cc
  - eventhandler.cc

third_party/tonic/
  - dart_library_natives.h
  - dart_library_natives.cc

flutter/runtime/
  - dart_isolate.cc
  - dart_vm_lifecycle.cc
  - dart_vm.cc
  - dart_vm_data.cc

flutter/lib/ui/
  - ui_dart_state.cc
  - dart_ui.cc
  - dart_runtime_hooks.cc
  - hooks.dart

third_party/dart/runtime/lib/isolate_patch.dart
flutter/shell/platform/android/flutter_main.cc
flutter/fml/message_loop_impl.cc
flutter/lib/io/dart_io.cc
```