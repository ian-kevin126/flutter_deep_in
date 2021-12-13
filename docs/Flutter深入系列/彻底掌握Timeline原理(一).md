# 彻底掌握Timeline原理(一)

## 一、概述

### 1.1 Timeline事件总览

![img](https://gitee.com/ian_kevin126/picturebed/raw/master/windows/img/timeline_method.png)

- C++引擎层层采用的是采用的是Embedder Stream；
- Dart应用层采用的是Dart Stream;
- DartVM采用的API Stream；

### 1.2 C++层Timeline用法

#### 1.2.1 C++同步事件

```Java
#include "flutter/fml/trace_event.h"
#define TRACE_EVENT0(category_group, name)           
#define TRACE_EVENT1(category_group, name, arg1_name, arg1_val)
#define TRACE_EVENT2(category_group, name, arg1_name, arg1_val, arg2_name, arg2_val)   
#define FML_TRACE_EVENT(category_group, name, ...)                 
fml::tracing::TraceEvent0(category_group, name);
fml::tracing::TraceEventEnd(name);

//示例：
TRACE_EVENT0("flutter", "PipelineConsume");
TRACE_EVENT2("flutter", "Framework Workload",
                "mode", "basic", "frame", FrameParity());
```

#### 1.2.2 C++异步事件

```Java
#include "flutter/fml/trace_event.h"
#define TRACE_EVENT_ASYNC_BEGIN0(category_group, name, id)
#define TRACE_EVENT_ASYNC_END0(category_group, name, id)
#define TRACE_EVENT_ASYNC_BEGIN1(category_group, name, id, arg1_name, arg1_val)
#define TRACE_EVENT_ASYNC_END1(category_group, name, id, arg1_name, arg1_val)
void TraceEventAsyncComplete(TraceArg category_group, TraceArg name,
                             TimePoint begin, TimePoint end)
//示例：
TRACE_EVENT_ASYNC_BEGIN0("flutter", "Frame Request Pending", frame_number);
TRACE_EVENT_ASYNC_END0("flutter", "Frame Request Pending", frame_number_++);
```

另外，这里还有一种比较特别的异步事件，事件的开始和结束都是可以手动指定的，TraceEventAsyncComplete 等于TRACE_EVENT_ASYNC_BEGIN0 + TRACE_EVENT_ASYNC_END0， 如下所示：

```Java
void TraceEventAsyncComplete(TraceArg category_group, TraceArg name,
                             TimePoint begin, TimePoint end);
```

#### 1.2.3 C++事件流

```Java
#include "flutter/fml/trace_event.h"
#define TRACE_FLOW_BEGIN(category, name, id)
#define TRACE_FLOW_STEP(category, name, id)
#define TRACE_FLOW_END(category, name, id)

//示例：
TRACE_FLOW_BEGIN("flutter", "PipelineItem", trace_id_)
TRACE_FLOW_STEP("flutter", "PipelineItem", trace_id_)
TRACE_FLOW_END("flutter", "PipelineItem", trace_id_)
```

#### 1.2.4 DartVM事件

```Java
#define API_TIMELINE_DURATION(thread)   
#define API_TIMELINE_BEGIN_END(thread)  

// 示例：
#define T (thread())
API_TIMELINE_DURATION(T);
API_TIMELINE_BEGIN_END(T);
```

### 1.3 dart层Timeline用法

#### 1.3.1 dart同步事件

```Java
import 'dart:developer';
Timeline.startSync(String name, {Map arguments, Flow flow});
Timeline.finishSync();

//示例：
Timeline.startSync('Warm-up frame');  //静态方法
Timeline.finishSync();
```

#### 1.3.2 dart异步事件

```Java
import 'dart:developer';
TimelineTask.start(String name, {Map arguments});
TimelineTask.finish();

//示例：
final TimelineTask timelineTask = TimelineTask();  //普通方法，需要实例化
timelineTask.start('Warm-up shader');
timelineTask.finish();
```

#### 1.3.3 dart事件流

```Java
Timeline.timeSync('flow_test', () {
  doSomething();
}, flow: flow);

Timeline.timeSync('flow_test', () {
  doSomething();
}, flow: Flow.step(flow.id));

Timeline.timeSync('flow_test', () {
  doSomething();
}, flow: Flow.end(flow.id));
```

### 1.4 TimelineEventRecorder总览

![img](http://gityuan.com/img/flutter_timeline/TimelineRecorder.png)

TimelineEventRingRecorder默认大小为32KB，也就是说该Recorder共有512个TimelineEventBlock(事件块)，每个TimelineEventBlock有64个TimelineEvent(事件)。

1）TimelineEventRecorder：主要还有以下四种：ring, endless, startup, systrace

- TimelineEventRingRecorder：这是默认的记录器，其父类TimelineEventFixedBufferRecorder有固定缓存区，
  - capacity_: 记录当前缓存区可记录的事件总数，默认值为32KB个；
  - num_blocks_: 记录事件块的数量，默认值为512个，其中每个事件块能记录64个事件；
- TimelineEventEndlessRecorder：用于记录无上限的trace
- TimelineEventStartupRecorder：用于记录有限缓存，且记录满则不再记录trace
- TimelineEventSystraceRecorder：systrace_fd_记录的是/sys/kernel/debug/tracing/trace_marker的文件描述符；

2）TimelineEventBlock

- length_：记录该事件块已记录的事件个数，每一次StartEvent()则执行加1操作，上限为64；
- block_index_：记录当前事件块的索引ID，用于无限缓存大小的记录器；

另外关于时间计数，以Android为例，此处调用的是clock_gettime()系统方法，精确到纳秒，这里有CLOCK_MONOTONIC和CLOCK_THREAD_CPUTIME_ID两种不同的参数，Timeline最终记录的事件事件信息单位是微秒。

- _start：采用参数CLOCK_MONOTONIC，记录从系统启动开始的计时时间点；
- _startCpu: 采用参数CLOCK_THREAD_CPUTIME_ID，记录当前线程执行代码所花费的CPU时间；

## 二、c++层Timeline

所有的这些最终都调用Dart_TimelineEvent()方法。

### 2.1 事件类型

#### 2.1.1 同步事件

[-> flutter/fml/trace_event.cc]

```Java
#define TRACE_EVENT0(category_group, name)           \
  ::fml::tracing::TraceEvent0(category_group, name); \  //事件开始
  __FML__AUTO_TRACE_END(name)

#define __FML__AUTO_TRACE_END(name)                                  \
  ::fml::tracing::ScopedInstantEnd __FML__TOKEN_CAT__2(__trace_end_, __LINE__)(name);

class ScopedInstantEnd {
 public:
  ScopedInstantEnd(const char* str) : label_(str) {}
  ~ScopedInstantEnd() { TraceEventEnd(label_); }  //事件结束

 private:
  const char* label_;
};
void TraceEvent0(TraceArg category_group, TraceArg name) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),
                    Dart_TimelineGetMicros(), 0,   
                    Dart_Timeline_Event_Begin, 0,
                    nullptr,  nullptr);
}

void TraceEventEnd(TraceArg name) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),
                    Dart_TimelineGetMicros(), 0,   
                    Dart_Timeline_Event_End, 0,
                    nullptr,  nullptr);
}
```

#### 2.1.2 异步事件

[-> flutter/fml/trace_event.cc]

```Java
void TraceEventAsyncBegin0(TraceArg category_group, TraceArg name, TraceIDArg id) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),
                    Dart_TimelineGetMicros(), id,   
                    Dart_Timeline_Event_Async_Begin, 0,
                    nullptr,  nullptr);
}

void TRACE_EVENT_ASYNC_END0(TraceArg category_group, TraceArg name, TraceIDArg id) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),
                    Dart_TimelineGetMicros(), id,   
                    Dart_Timeline_Event_Async_End, 0,
                    nullptr,  nullptr);
}
void TraceEventAsyncComplete(TraceArg category_group, TraceArg name,
                             TimePoint begin, TimePoint end) {
  auto identifier = TraceNonce();
  if (begin > end) {
    std::swap(begin, end);
  }

  Dart_TimelineEvent(DCHECK_LITERAL(name),                  
                     begin.ToEpochDelta().ToMicroseconds(), identifier,                    
                     Dart_Timeline_Event_Async_Begin, 0,                               
                     nullptr, nullptr);

  Dart_TimelineEvent(DCHECK_LITERAL(name),                  
                     begin.ToEpochDelta().ToMicroseconds(), identifier,                    
                     Dart_Timeline_Event_Async_End, 0,                               
                     nullptr, nullptr);
}
```

#### 2.1.3 流事件

[-> flutter/fml/trace_event.cc]

```Java
void TraceEventFlowBegin0(TraceArg category_group, TraceArg name, TraceIDArg id) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),           
                     Dart_TimelineGetMicros(), id,                             
                     Dart_Timeline_Event_Flow_Begin, 0,                             
                     nullptr, nullptr);
}

void TraceEventFlowStep0(TraceArg category_group, TraceArg name, TraceIDArg id) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),           
                     Dart_TimelineGetMicros(), id,                             
                     Dart_Timeline_Event_Flow_Step, 0,                             
                     nullptr, nullptr);
}

void TraceEventFlowEnd0(TraceArg category_group, TraceArg name, TraceIDArg id) {
  Dart_TimelineEvent(DCHECK_LITERAL(name),           
                     Dart_TimelineGetMicros(), id,                             
                     Dart_Timeline_Event_Flow_End, 0,                             
                     nullptr, nullptr);
}
```

可见，所有这些事件最终都是调用Dart_TimelineEvent，不同的主要在事件类型：

- Dart_Timeline_Event_Begin：同步事件开始
- Dart_Timeline_Event_End：同步事件结束
- Dart_Timeline_Event_Async_Begin：同步事件开始
- Dart_Timeline_Event_Async_End：同步事件结束
- Dart_Timeline_Event_Flow_Begin：流事件开始

时间戳的获取除了TraceEventAsyncComplete()是直接传递的时间参数，其他都是通过Dart_TimelineGetMicros()命令获取执行该命令当下的时间戳，单位是微秒。

#### Dart_TimelineGetMicros

```
DART_EXPORT int64_t Dart_TimelineGetMicros() {
  return OS::GetCurrentMonotonicMicros();
}

//以Android为例
int64_t OS::GetCurrentMonotonicMicros() {
  int64_t ticks = GetCurrentMonotonicTicks();
  return ticks / kNanosecondsPerMicrosecond;
}

int64_t OS::GetCurrentMonotonicTicks() {
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
    return 0;
  }
  int64_t result = ts.tv_sec;
  result *= kNanosecondsPerSecond;
  result += ts.tv_nsec;
  return result;
}
```

通过clock_gettime系统调用获取CLOCK_MONOTONIC类型的时间，也就是系统从启动到现在的时间戳；

### 2.2 Dart_TimelineEvent

[-> third_party/dart/runtime/vm/dart_api_impl.cc]

```Java
DART_EXPORT void Dart_TimelineEvent(const char* label,
                                    int64_t timestamp0,
                                    int64_t timestamp1_or_async_id,
                                    Dart_Timeline_Event_Type type,
                                    intptr_t argument_count,
                                    const char** argument_names,
                                    const char** argument_values) {
#if defined(SUPPORT_TIMELINE)
  //采用的是Embedder Stream
  TimelineStream* stream = Timeline::GetEmbedderStream();
  //[见小节2.3.1]
  TimelineEvent* event = stream->StartEvent();

  switch (type) {
    case Dart_Timeline_Event_Begin:
      event->Begin(label, timestamp0); //[见小节2.3.3]
      break;
    case Dart_Timeline_Event_End:
      event->End(label, timestamp0);
      break;
    case Dart_Timeline_Event_Instant:
      event->Instant(label, timestamp0);
      break;
    case Dart_Timeline_Event_Duration:
      event->Duration(label, timestamp0, timestamp1_or_async_id);
      break;
    case Dart_Timeline_Event_Async_Begin:
      event->AsyncBegin(label, timestamp1_or_async_id, timestamp0);
      break;
    case Dart_Timeline_Event_Async_End:
      event->AsyncEnd(label, timestamp1_or_async_id, timestamp0);
      break;
    case Dart_Timeline_Event_Async_Instant:
      event->AsyncInstant(label, timestamp1_or_async_id, timestamp0);
      break;
    case Dart_Timeline_Event_Counter:
      event->Counter(label, timestamp0);
      break;
    case Dart_Timeline_Event_Flow_Begin:
      event->FlowBegin(label, timestamp1_or_async_id, timestamp0);
      break;
    case Dart_Timeline_Event_Flow_Step:
      event->FlowStep(label, timestamp1_or_async_id, timestamp0);
      break;
    case Dart_Timeline_Event_Flow_End:
      event->FlowEnd(label, timestamp1_or_async_id, timestamp0);
      break;
    default:
      FATAL("Unknown Dart_Timeline_Event_Type");
  }
  event->SetNumArguments(argument_count);
  for (intptr_t i = 0; i < argument_count; i++) {
    event->CopyArgument(i, argument_names[i], argument_values[i]);
  }
  // [见小节2.3.4]
  event->Complete();  
#endif
}
```

先以目前timeline的默认记录器TimelineEventRingRecorder来展开说明。

### 2.3 ring类型记录器

#### 2.3.1 StartEvent

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
TimelineEvent* TimelineEventFixedBufferRecorder::StartEvent() {
  return ThreadBlockStartEvent();  //【见下方】
}
TimelineEvent* TimelineEventRecorder::ThreadBlockStartEvent() {
  OSThread* thread = OSThread::Current();
  Mutex* thread_block_lock = thread->timeline_block_lock();
  thread_block_lock->Lock();   //这个锁会一直持有，直到调用CompleteEvent()

  TimelineEventBlock* thread_block = thread->timeline_block();
  if ((thread_block != NULL) && thread_block->IsFull()) {
    MutexLocker ml(&lock_); //加锁，保证每次只有一个线程申请新的事件块
    thread_block->Finish();  //该事件块已满【见小节2.3.5】
    thread_block = GetNewBlockLocked(); //分配新的事件块
    thread->set_timeline_block(thread_block);
  } else if (thread_block == NULL) {
    MutexLocker ml(&lock_);
    thread_block = GetNewBlockLocked(); //没有事件块，则创建事件块
    thread->set_timeline_block(thread_block);
  }
  if (thread_block != NULL) {
    //持锁状态退出该函数  见下方】
    TimelineEvent* event = thread_block->StartEvent();
    return event;
  }
  thread_block_lock->Unlock(); //没有任何事件，则释放锁
  return NULL;
}
TimelineEvent* TimelineEventBlock::StartEvent() {
  return &events_[length_++];
}
```

说明：

1. 如果当前线程中的thread_block为空，则创建新的事件块，并将当前线程id记录到该事件块，同时将该事件块再记录其成员变量timeline_block_事件块；
2. 如果当前线程中的thread_block已满，则先将该事件块finish，再创建新的事件块；
3. 从当前线程的事件块中分配一个可用的TimelineEvent事件；

#### 2.3.2 GetNewBlockLocked

```Java
TimelineEventBlock* TimelineEventRingRecorder::GetNewBlockLocked() {
  if (block_cursor_ == num_blocks_) {
    block_cursor_ = 0;
  }
  TimelineEventBlock* block = &blocks_[block_cursor_++];
  block->Reset(); //事件重置
  block->Open(); // [见下文]
  return block;
}

void TimelineEventBlock::Open() {
  OSThread* os_thread = OSThread::Current();
  //将当前线程id记录到该事件块中的thread_id_
  thread_id_ = os_thread->trace_id();
  in_use_ = true;
}
```

OSThread对象里面有一个TimelineEventBlock指针，记录着当前正在操作的事件块。事件块里面有一个events_，记录着TimelineEvent数组，大小为kBlockSize=64。

#### 2.3.3 TimelineEvent::Begin

```Java
void Begin(const char* label,
           int64_t micros = OS::GetCurrentMonotonicMicros(),
           int64_t thread_micros = OS::GetCurrentThreadCPUMicros());
void AsyncBegin(const char* label,
    int64_t async_id,
    int64_t micros = OS::GetCurrentMonotonicMicros());
```

事件定义过程会设置默认值，同步与异步的区别是异步事件会记录async_id，同步事件会记录当前线程的cpu运行时间戳。

```Java
void TimelineEvent::Begin(const char* label,
                          int64_t micros,
                          int64_t thread_micros) {
  Init(kBegin, label);
  set_timestamp0(micros);  //系统启动后运行的时间戳
  set_thread_timestamp0(thread_micros); //该线程CPU运行的时间戳
}

void TimelineEvent::End(const char* label,
                        int64_t micros,
                        int64_t thread_micros) {
  Init(kEnd, label);
  set_timestamp0(micros); //系统启动后运行的时间戳
  set_thread_timestamp0(thread_micros);//该线程CPU运行的时间戳
}

void TimelineEvent::AsyncBegin(const char* label,
                               int64_t async_id,
                               int64_t micros) {
  Init(kAsyncBegin, label);
  set_timestamp0(micros);
  set_timestamp1(async_id); //async_id记录到timestamp1_
}

void TimelineEvent::AsyncEnd(const char* label,
                             int64_t async_id,
                             int64_t micros) {
  Init(kAsyncEnd, label);
  set_timestamp0(micros);
  set_timestamp1(async_id); //async_id记录到timestamp1_
}
void TimelineEvent::Init(EventType event_type, const char* label) {
  state_ = 0;
  timestamp0_ = 0;
  timestamp1_ = 0;
  thread_timestamp0_ = -1;
  thread_timestamp1_ = -1;
  OSThread* os_thread = OSThread::Current();
  thread_ = os_thread->trace_id();  //记录线程id
  Isolate* isolate = Isolate::Current();
  if (isolate != NULL) {
    isolate_id_ = isolate->main_port(); //记录isolate端口号
  } else {
    isolate_id_ = ILLEGAL_PORT;
  }
  label_ = label; //事件标签名
  arguments_.Free();
  set_event_type(event_type); //事件类型，比如kBegin，kEnd
  set_pre_serialized_args(false);
  set_owns_label(false);
}
```

#### 2.3.4 Complete

```Java
void TimelineEvent::Complete() {
  TimelineEventRecorder* recorder = Timeline::recorder();
  if (recorder != NULL) {
    recorder->CompleteEvent(this); //[见下文]
  }
}
void TimelineEventFixedBufferRecorder::CompleteEvent(TimelineEvent* event) {
  ThreadBlockCompleteEvent(event);  //[见下文]
}
void TimelineEventRecorder::ThreadBlockCompleteEvent(TimelineEvent* event) {
  OSThread* thread = OSThread::Current();
  Mutex* thread_block_lock = thread->timeline_block_lock();
  thread_block_lock->Unlock(); //释放同步锁
}
```

当OSThread的thread_block写满，则需要执行Finish()，将该事件块的数据发送给ServiceIsolate来处理，如下所示。

#### 2.3.5 TimelineEventBlock::Finish

```Java
void TimelineEventBlock::Finish() {
  in_use_ = false;
#ifndef PRODUCT
  if (Service::timeline_stream.enabled()) {
    ServiceEvent service_event(NULL, ServiceEvent::kTimelineEvents);
    service_event.set_timeline_event_block(this);
    Service::HandleEvent(&service_event); //[见下文]
  }
#endif
}
```

#### 2.3.6 Service::HandleEvent

[-> third_party/dart/runtime/vm/service.cc]

```Java
void Service::HandleEvent(ServiceEvent* event) {
  if (event->stream_info() != NULL && !event->stream_info()->enabled()) {
    return; //当没有地方监听事件流，则忽略
  }
  if (!ServiceIsolate::IsRunning()) {
    return; //当ServiceIsolate没有运行，则停止
  }
  JSONStream js;
  const char* stream_id = event->stream_id();
  {
    JSONObject jsobj(&js);
    jsobj.AddProperty("jsonrpc", "2.0");
    jsobj.AddProperty("method", "streamNotify");
    JSONObject params(&jsobj, "params");
    params.AddProperty("streamId", stream_id);
    params.AddProperty("event", event);
  }
  //此处isoalte为空，[见小节]
  PostEvent(event->isolate(), stream_id, event->KindAsCString(), &js);

  if (event->stream_info() != nullptr &&
      event->stream_info()->consumer() != nullptr) {
    auto length = js.buffer()->length();
    event->stream_info()->consumer()(
        reinterpret_cast<uint8_t*>(js.buffer()->buf()), length);
  }
}
```

可通过Dart_SetNativeServiceStreamCallback()来设置Dart_NativeStreamConsumer回调方法。

#### 2.3.7 Service::PostEvent

[-> third_party/dart/runtime/vm/service.cc]

```Java
void Service::PostEvent(Isolate* isolate,
                        const char* stream_id,
                        const char* kind,
                        JSONStream* event) {
  //消息格式[<stream id>, <json string>]
  Dart_CObject list_cobj;
  Dart_CObject* list_values[2];
  list_cobj.type = Dart_CObject_kArray;
  list_cobj.value.as_array.length = 2;
  list_cobj.value.as_array.values = list_values;

  Dart_CObject stream_id_cobj;
  stream_id_cobj.type = Dart_CObject_kString;
  stream_id_cobj.value.as_string = const_cast<char*>(stream_id); //stream_id
  list_values[0] = &stream_id_cobj;

  Dart_CObject json_cobj;
  json_cobj.type = Dart_CObject_kString;
  json_cobj.value.as_string = const_cast<char*>(event->ToCString()); //event
  list_values[1] = &json_cobj;

  auto thread = Thread::Current();
  if (thread != nullptr) {
    TransitionVMToNative transition(thread);
    //向service isolate发送事件
    Dart_PostCObject(ServiceIsolate::Port(), &list_cobj);
  } else {
    Dart_PostCObject(ServiceIsolate::Port(), &list_cobj);
  }
}
```

#### 2.3.8 Dart_PostCObject

```Java
DART_EXPORT bool Dart_PostCObject(Dart_Port port_id, Dart_CObject* message) {
  return PostCObjectHelper(port_id, message);
}

static bool PostCObjectHelper(Dart_Port port_id, Dart_CObject* message) {
  ApiMessageWriter writer;
  Message* msg = writer.WriteCMessage(message, port_id, Message::kNormalPriority);
  if (msg == NULL) {  
    return false;
  }
  return PortMap::PostMessage(msg);
}
```

最终会把数据传递给ServiceIsolate来进行处理。

### 2.4 systrace类型记录器

#### 2.4.1 StartEvent

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
TimelineEvent* TimelineEventPlatformRecorder::StartEvent() {
  TimelineEvent* event = new TimelineEvent();
  return event;
}
```

#### 2.4.2 TimelineEvent初始化

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
TimelineEvent::TimelineEvent()
    : timestamp0_(0),
      timestamp1_(0),
      thread_timestamp0_(-1),
      thread_timestamp1_(-1),
      state_(0),
      label_(NULL),
      stream_(NULL),
      thread_(OSThread::kInvalidThreadId),
      isolate_id_(ILLEGAL_PORT) {}
```

#### 2.4.3 TimelineEvent::Begin

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
void TimelineEvent::Begin(const char* label,
                          int64_t micros,
                          int64_t thread_micros) {
  Init(kBegin, label);
  set_timestamp0(micros);  //系统启动后运行的时间戳
  set_thread_timestamp0(thread_micros); //该线程CPU运行的时间戳
}
```

#### 2.4.4 Complete

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
void TimelineEvent::Complete() {
  TimelineEventRecorder* recorder = Timeline::recorder();
  if (recorder != NULL) {
    recorder->CompleteEvent(this); //[见下文]
  }
}
void TimelineEventPlatformRecorder::CompleteEvent(TimelineEvent* event) {
  OnEvent(event);
  delete event;
}
```

#### 2.4.5 OnEvent

[-> third_party/dart/runtime/vm/timeline_android.cc]

```Java
void TimelineEventSystraceRecorder::OnEvent(TimelineEvent* event) {
  const intptr_t kBufferLength = 1024;
  char buffer[kBufferLength];
  //[小节2.4.6]
  const intptr_t event_length = PrintSystrace(event, &buffer[0], kBufferLength);
  if (event_length > 0) {
    ssize_t result;
    do {
      result = write(systrace_fd_, buffer, event_length);
    } while ((result == -1L) && (errno == EINTR));
  }
}
```

此处的systrace_fd_是指/sys/kernel/debug/tracing/trace_marker，也就是ftrace的buffer。

其中PrintSystrace过程如下所示：

#### 2.4.6 PrintSystrace

```Java
intptr_t TimelineEventSystraceRecorder::PrintSystrace(TimelineEvent* event,
                                                      char* buffer,
                                                      intptr_t buffer_size) {
  buffer[0] = '\0';
  intptr_t length = 0;
  int64_t pid = OS::ProcessId();
  switch (event->event_type()) {
    case TimelineEvent::kBegin: {
      length = Utils::SNPrint(buffer, buffer_size, "B|%" Pd64 "|%s", pid,
                              event->label());
      break;
    }
    case TimelineEvent::kEnd: {
      length = Utils::SNPrint(buffer, buffer_size, "E");
      break;
    }
    case TimelineEvent::kCounter: {
      if (event->arguments_length() > 0) {
        length = Utils::SNPrint(buffer, buffer_size, "C|%" Pd64 "|%s|%s", pid,
                                event->label(), event->arguments()[0].value);
      }
      break;
    }
    default:
      break;
  }
  return length;
}
```

可见kBegin、kEnd、kCounter记录的信息如下所示：

```
B|pid|name
E
C|pid|name|count
```

### 2.5 小结

每一个Timeline时间的执行流程：

- 通过StartEvent来获取TimelineEvent；
- 根据不同事件类型来填充相应event；
- 最后执行Complete；

ring和endless、startup记录器实现方式非常相近，都需要ServiceIsolate才能工作，其核心区别是GetNewBlockLocked()中buffer分配的方式。ring和startup都是采用的是固定大小，ring是在buffer已满的情况下循环写；startup则是写满buffer则不再写入；endless采用的是无上限的buffer空间。 systrace实现方式则跟前三者完全不同，systrace依赖的是linux底层的ftrace，无需额外开辟buffer。

## 三、dart层Timeline

### 3.1 同步事件类型

#### 3.1.1 Timeline.startSync

[-> third_party/dart/sdk/lib/developer/timeline.dart]

```Java
class Timeline {
  static final List<_SyncBlock> _stack = new List<_SyncBlock>();

  static void startSync(String name, {Map arguments, Flow flow}) {
    if (!_hasTimeline) return;
    if (!_isDartStreamEnabled()) {
      _stack.add(null);
      return;
    }
    //创建同步块
    var block = new _SyncBlock._(name, _getTraceClock(), _getThreadCpuClock());
    if (arguments != null) {
      block._arguments = arguments;
    }
    if (flow != null) {
      block.flow = flow;
    }
    _stack.add(block);
  }
}
```

- 该过程如果出现_stack列表为空，则会抛出异常，说明调用startSync/finishSync不是成对出现；
- 调用finishSync()过程，从列表弹出最近加入的一个数据然后调用其finish()方法；
- 每一条timeline都是通过创建_SyncBlock对象来记录，并保存到_stack列表。其中_hasTimeline是通过判断dart.developer.timeline值来决定，默认为true。

关于时间的两个方法如下所示：

```Java
DEFINE_NATIVE_ENTRY(Timeline_getTraceClock, 0, 0) {
  return Integer::New(OS::GetCurrentMonotonicMicros(), Heap::kNew);
}

DEFINE_NATIVE_ENTRY(Timeline_getThreadCpuClock, 0, 0) {
  return Integer::New(OS::GetCurrentThreadCPUMicros(), Heap::kNew);
}
```

#### 3.1.2 _SyncBlock初始化

```Java
class _SyncBlock {
  final String category = 'Dart';
  final String name;
  Map _arguments;
  final int _start;  //启动运行时间戳
  final int _startCpu; //该线程CPU运行时间戳

  Flow _flow;

  _SyncBlock._(this.name, this._start, this._startCpu);
}
```

#### 3.1.3 Timeline.finishSync

[-> third_party/dart/sdk/lib/developer/timeline.dart]

```Java
class Timeline {

  static void finishSync() {
    if (!_hasTimeline) {
      return;
    }
    if (_stack.length == 0) {
      throw new StateError('Uneven calls to startSync and finishSync');
    }
    var block = _stack.removeLast();
    block.finish();  //[见小节]
  }
}
```

#### 3.1.4 _SyncBlock.finish

[-> third_party/dart/sdk/lib/developer/timeline.dart]

```Java
class _SyncBlock {

  void finish() {
    // [见小节]
    _reportCompleteEvent(
        _start, _startCpu, category, name, _argumentsAsJson(_arguments));
    if (_flow != null) {
      _reportFlowEvent(_start, _startCpu, category, name, _flow._type, _flow.id,
          _argumentsAsJson(null));
    }
  }
}
```

#### 3.1.5 _reportCompleteEvent

[-> third_party/dart/runtime/lib/timeline.cc]

```Java
DEFINE_NATIVE_ENTRY(Timeline_reportCompleteEvent, 0, 5) {
#if defined(SUPPORT_TIMELINE)
  GET_NON_NULL_NATIVE_ARGUMENT(Integer, start, arguments->NativeArgAt(0));
  GET_NON_NULL_NATIVE_ARGUMENT(Integer, start_cpu, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(String, category, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(String, name, arguments->NativeArgAt(3));
  GET_NON_NULL_NATIVE_ARGUMENT(String, args, arguments->NativeArgAt(4));

  TimelineEventRecorder* recorder = Timeline::recorder();
  //获取TimelineEvent对象
  TimelineEvent* event = Timeline::GetDartStream()->StartEvent();
  //见小节
  DartTimelineEventHelpers::ReportCompleteEvent(
      thread, event, start.AsInt64Value(), start_cpu.AsInt64Value(),
      category.ToCString(), name.ToMallocCString(), args.ToMallocCString());
#endif
  return Object::null();
}
```

#### 3.1.6 ReportCompleteEvent

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
void DartTimelineEventHelpers::ReportCompleteEvent(Thread* thread,
                                                   TimelineEvent* event,
                                                   int64_t start,
                                                   int64_t start_cpu,
                                                   const char* category,
                                                   char* name,
                                                   char* args) {
  const int64_t end = OS::GetCurrentMonotonicMicros();
  const int64_t end_cpu = OS::GetCurrentThreadCPUMicros();
  //将四个时间戳记录到TimelineEvent
  event->Duration(name, start, end, start_cpu, end_cpu);
  event->set_owns_label(true);
  // 见小节
  event->CompleteWithPreSerializedArgs(args);
}
void TimelineEvent::Duration(const char* label,
                             int64_t start_micros,
                             int64_t end_micros,
                             int64_t thread_start_micros,
                             int64_t thread_end_micros) {
  Init(kDuration, label);
  set_timestamp0(start_micros);
  set_timestamp1(end_micros);
  set_thread_timestamp0(thread_start_micros);
  set_thread_timestamp1(thread_end_micros);
}
```

将名字记录到TimelineEvent的成员变量label_，将四个时间戳记录到TimelineEvent的相应成员变量。

#### 3.1.7 CompleteWithPreSerializedArgs

[-> third_party/dart/runtime/vm/timeline.cc]

```Java
void TimelineEvent::CompleteWithPreSerializedArgs(char* args_json) {
  set_pre_serialized_args(true);
  SetNumArguments(1);
  SetArgument(0, "Dart Arguments", args_json);
  Complete();
}
```

接着执行Complete()，根据不同的recorder回到了前面已介绍[小节2.3.4]/[小节2.4.4]过程。

### 3.2 异步事件类型

#### 3.2.1 TimelineTask.start

```Java
class TimelineTask {
  final int _taskId;
  final List<_AsyncBlock> _stack = [];

  //需要先初始化
  TimelineTask() : _taskId = _getNextAsyncId() {}

  void start(String name, {Map arguments}) {
    if (!_hasTimeline) return;
    var block = new _AsyncBlock._(name, _taskId);
    if (arguments != null) {
      block._arguments = arguments;
    }
    _stack.add(block);
    block._start();  //[见小节]
  }
}
```

#### 3.2.2 _AsyncBlock._start

```Java
class _AsyncBlock {
  final String category = 'Dart';
  final String name;
  final int _taskId;
  Map _arguments;

  void _start() {
    _reportTaskEvent(
        _getTraceClock(), _taskId, 'b', category, name, _argumentsAsJson(null));
  }
}
```

_AsyncBlock相比_SyncBlock少了，少了两个时间相关的成员变量，多了一个记录taskid的成员变量

#### 3.2.3 TimelineTask.finish

```Java
class TimelineTask {

  void finish() {
    if (!_hasTimeline) {
      return;
    }
    var block = _stack.removeLast();
    block._finish(); //[见小节]
  }
}
```

#### 3.2.4 _AsyncBlock._finish

```Java
class TimelineTask {

  void _finish() {
    _reportTaskEvent(_getTraceClock(), _taskId, 'e', category, name,
        _argumentsAsJson(_arguments));
  }
}
```

#### 3.2.5 _reportTaskEvent

```Java
DEFINE_NATIVE_ENTRY(Timeline_reportTaskEvent, 0, 6) {
#if defined(SUPPORT_TIMELINE)
  GET_NON_NULL_NATIVE_ARGUMENT(Integer, start, arguments->NativeArgAt(0));
  GET_NON_NULL_NATIVE_ARGUMENT(Integer, id, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(String, phase, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(String, category, arguments->NativeArgAt(3));
  GET_NON_NULL_NATIVE_ARGUMENT(String, name, arguments->NativeArgAt(4));
  GET_NON_NULL_NATIVE_ARGUMENT(String, args, arguments->NativeArgAt(5));

  TimelineEventRecorder* recorder = Timeline::recorder();
  //获取TimelineEvent对象
  TimelineEvent* event = Timeline::GetDartStream()->StartEvent();
  //见小节
  DartTimelineEventHelpers::ReportTaskEvent(
      thread, event, start.AsInt64Value(), id.AsInt64Value(), phase.ToCString(),
      category.ToCString(), name.ToMallocCString(), args.ToMallocCString());
#endif  // SUPPORT_TIMELINE
  return Object::null();
}
```

#### 3.2.6 ReportTaskEvent

```Java
void DartTimelineEventHelpers::ReportTaskEvent(Thread* thread,
                                               TimelineEvent* event,
                                               int64_t start,
                                               int64_t id,
                                               const char* phase,
                                               const char* category,
                                               char* name,
                                               char* args) {
  switch (phase[0]) {
    case 'n':
      event->AsyncInstant(name, id, start);
      break;
    case 'b':
      event->AsyncBegin(name, id, start);
      break;
    case 'e':
      event->AsyncEnd(name, id, start);
      break;
    default:
      UNREACHABLE();
  }
  event->set_owns_label(true);
  event->CompleteWithPreSerializedArgs(args);
}
```

#### 3.2.7 CompleteWithPreSerializedArgs

```Java
void TimelineEvent::CompleteWithPreSerializedArgs(char* args_json) {
  set_pre_serialized_args(true);
  SetNumArguments(1);
  SetArgument(0, "Dart Arguments", args_json);
  Complete();
}
```

接着执行Complete()，根据不同的recorder回到了前面已介绍[小节2.3.4]/[小节2.4.4]过程。

## 四、dart虚拟机Timeline

这两个宏目前主要用于dart_api_impl.cc文件

```Java
#define API_TIMELINE_DURATION(thread)                                          \
  TimelineDurationScope api_tds(thread, Timeline::GetAPIStream(), CURRENT_FUNC)
#define API_TIMELINE_BEGIN_END(thread)                                         \
  TimelineBeginEndScope api_tbes(thread, Timeline::GetAPIStream(), CURRENT_FUNC)
```

### 4.1 API_TIMELINE_DURATION

#### 4.1.1 TimelineDurationScope初始化

```Java
TimelineDurationScope::TimelineDurationScope(Thread* thread,
                                             TimelineStream* stream,
                                             const char* label)
    : TimelineEventScope(thread, stream, label) {
  if (!enabled()) {
    return;
  }
  timestamp_ = OS::GetCurrentMonotonicMicros();
  thread_timestamp_ = OS::GetCurrentThreadCPUMicros();
}
```

该timeline事件的标签名为CURRENT_FUNC，也就是函数名；

#### 4.1.2 TimelineDurationScope析构

```Java
TimelineDurationScope::~TimelineDurationScope() {
  if (!ShouldEmitEvent()) {
    return;
  }
  TimelineEvent* event = stream()->StartEvent();
  if (event == NULL) {
    return;
  }
  //创建事件
  event->Duration(label(), timestamp_, OS::GetCurrentMonotonicMicros(),
                  thread_timestamp_, OS::GetCurrentThreadCPUMicros());
  StealArguments(event);
  //事件完成
  event->Complete();
}
```

### 4.2 API_TIMELINE_BEGIN_END

#### 4.1.1 TimelineBeginEndScope

```Java
TimelineBeginEndScope::TimelineBeginEndScope(Thread* thread,
                                             TimelineStream* stream,
                                             const char* label)
    : TimelineEventScope(thread, stream, label) {
  EmitBegin();
}

TimelineBeginEndScope::~TimelineBeginEndScope() {
  EmitEnd();
}
```

该timeline事件的标签名为CURRENT_FUNC，也就是函数名

#### 4.1.2 EmitBegin

```Java
void TimelineBeginEndScope::EmitBegin() {
  if (!ShouldEmitEvent()) {
    return;
  }
  TimelineEvent* event = stream()->StartEvent();
  if (event == NULL) {
    set_enabled(false);
    return;
  }
  event->Begin(label());  //事件开始
  event->Complete();
}
```

#### 4.1.3 EmitEnd

```Java
void TimelineBeginEndScope::EmitEnd() {
  if (!ShouldEmitEvent()) {
    return;
  }
  TimelineEvent* event = stream()->StartEvent();
  if (event == NULL) {
    set_enabled(false);
    return;
  }
  event->End(label());  //事件结束
  StealArguments(event);
  event->Complete();
}
```

对于timeline来说功能是一致的，但对于systrace则不同，因为事件的方式不同，建议时候用API_TIMELINE_BEGIN_END，不推荐使用API_TIMELINE_DURATION。

## 五、总结

TimelineEventRecorder：主要还有以下四种：ring, endless, startup, systrace，本身timeline是能够转换为systrace的，但是在转换过程中有很多坑，需要去解决，下一篇文章再进一步讲解如何解决对systrace更友好的支持。

**附录：**

```
flutter/fml/trace_event.cc
third_party/dart/sdk/lib/developer/timeline.dart
third_party/dart/runtime/lib/timeline.cc

third_party/dart/runtime/vm/
  - dart_api_impl.cc
  - timeline.cc
  - timeline_android.cc
  - service.cc
```