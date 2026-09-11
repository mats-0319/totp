# totp

一个符合RFC 6238标准的计算TOTP Code的应用（可以用于github 2fa登录验证）

## AI修改意见

1. TOTP key明文落盘：我希望导出可读的实例列表明文，这是为了方便修改
2. 未屏蔽TOTP Code：了解如何实现flag secure
3. 计时器性能问题：详细介绍如何实现全部实例共用一个计时器、如何将每秒修改倒计时和每0.1秒修改进度条区分开
   以及如何将每次更新时的重建范围压缩到最小；如果考虑未来可能兼容30秒、60秒等不同时间步长，还能使用同一个计时器吗
4. 不支持`otpauth://`标准二维码：考虑支持，了解标准以及dart如何解析
5. 识别成功后摄像头应暂停：了解如何实现
6. totp code计算出错时显示错误文本：计划修改为外部函数处理错误
7. 模型层拆分，把UI相关拆走：进一步了解后处理
8. 单例+Provider双重真相：进一步了解后处理
9. 启动流程，应编写全局统一的错误处理以及兜底，避免出现全屏白屏：进一步了解后处理
10. 删除大尺寸素材：不修改
    - 2048像素logo还在考虑是否使用，暂时不删除
    - `totp_design.png`实际上是在技术文档中引用的，它就是要那样写，不确定是flutter还是这个库的要求
11. 本地的`totp_key.json`加密保存：计划添加，同时添加`android:allowBackup="false"`、flag secure

## 设计图

![设计图](assets/totp_design.png)

## 版本

```txt
Flutter 3.47.2 • channel stable • https://github.com/flutter/flutter.git
Framework • revision d3b14c8769 (11 天前) • 2026-08-26 16:07:51 -0700
Engine • hash 1cf1c4773fb941c4c74a7f8bb144a8837596c0f4 (revision a804b26164) (12
days ago) • 2026-08-26 18:46:13.000Z
Tools • Dart 3.13.2 • DevTools 2.60.0
```

项目启动依赖很多环境，例如：`flutter`/`java`/`gradle`/`AGP`/`AGP plugin`/`kotlin`，它们当中只要有一个不兼容，
程序就无法运行。所以不建议单独升级某一个环境，而是交给flutter统一管理，想要升级也是升级flutter、创建新项目然后合并。

## 常用命令

设置国内镜像：`android/gradle/wrapper/gradle-wrapper.properties`文件，
`distributionUrl`的值修改为：`https\://mirrors.cloud.tencent.com/gradle/gradle-9.3.1-all.zip`

- `flutter create --platforms=android`
- `flutter clean`
- `flutter pub get` 下载依赖
- `flutter run -v`
- `flutter build apk --split-per-abi` 打包
- `flutter install --use-application-binary=build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
    - 这里要具体指到对应架构的包，不然flutter会安装成示例代码；或者打包时不区分架构也行

ADB:

- `adb shell getprop | grep cpu` 查看手机cpu架构（需要手机开启usb调试）
- `adb shell ls -l /sdcard/Download/` 列举模拟器指定目录的文件
- `adb push ./message.txt /sdcard/Download/` 向模拟器发送文件
- `adb pull /sdcard/Download/ .` 从模拟器下载文件
