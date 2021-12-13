# 【Flutter】错误汇总

### 1、ambiguous argument 'HEAD': unknown revision or path not in the working tree.

```csharp
fatal: ambiguous argument 'HEAD': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
```

- 解决方式 : 在flutter目录下 : git commit --allow-empty -n -m "Initial commit"

### 2、The Flutter directory is not a clone of the GitHub project.

```bash
Error: The Flutter directory is not a clone of the GitHub project.
       The flutter tool requires Git in order to operate properly;
       to set up Flutter, run the following command:
       git clone -b stable https://github.com/flutter/flutter.git
```

- 解决方式 : 在flutter目录下 : `git clone -b stable https://github.com/flutter/flutter.git`