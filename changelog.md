# changelog

## 本次定制目标
- 内置自有 RustDesk 服务配置，避免首次运行再手动输入。
- 彻底关闭客户端更新检查、自动更新和前端更新入口。
- 允许 GitHub Actions workflow 上传构建产物。
- 让当前定制版与官方版尽量可在同机并存安装，重点处理 Windows / Android / macOS 的安装级标识。

## 已实现变更

### 1. 内置服务器与 Key
文件：
- `src/common.rs`
- `src/rendezvous_mediator.rs`

实现：
- 默认 ID 服务器：`rustdesk.90dao.com`
- 默认 Relay 服务器：`rustdesk.90dao.com`
- 默认 API 服务器：`https://rustdesk.90dao.com`
- 默认 Key：`krZWQxrPsK0hEnUm7XxiBIi6ht1MERr3y7iYvXy6tmk=`

说明：
- 当用户未手动配置时，程序会回落到以上内置值。
- 保留用户手动配置优先级；只有为空时才使用内置值。

### 2. 禁用更新
文件：
- `src/common.rs`
- `flutter/lib/common.dart`
- `flutter/lib/desktop/pages/desktop_setting_page.dart`
- `flutter/lib/mobile/pages/connection_page.dart`
- `flutter/lib/mobile/pages/settings_page.dart`

实现：
- Rust 侧 `check_software_update()` 直接清空更新 URL。
- Rust 侧 `do_check_software_update()` 直接返回，不再请求官方更新接口。
- Flutter 侧 `checkUpdate()` 置空，不再注册更新事件，也不再触发查询。
- 桌面端和移动端更新入口、启动检查入口已移除。

### 3. Workflow 上传产物
文件：
- `.github/workflows/flutter-ci.yml`

实现：
- `upload-artifact: false` 改为 `upload-artifact: true`

### 4. 同机并存安装：安装级标识调整

#### Android
文件：
- `flutter/android/app/build.gradle`
- `flutter/android/app/src/main/AndroidManifest.xml`
- `flutter/android/app/src/main/kotlin/com/carriez/flutter_hbb/BootReceiver.kt`

实现：
- `applicationId` 改为 `com.kdesk.remote`
- 自定义开机广播 action 改为 `com.kdesk.remote.DEBUG_BOOT_COMPLETED`

说明：
- Manifest 的源码 package 仍保留原值，避免影响 Kotlin 现有类路径解析。
- 但真正影响安装共存的是 `applicationId`，因此已满足与官方 Android 包并存安装。

#### macOS
文件：
- `flutter/macos/Runner/Configs/AppInfo.xcconfig`
- `flutter/macos/Runner/Info.plist`
- `flutter/macos/Runner.xcodeproj/project.pbxproj`
- `flutter/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `src/platform/privileges_scripts/agent.plist`
- `src/platform/privileges_scripts/daemon.plist`
- `src/platform/privileges_scripts/install.scpt`
- `src/platform/privileges_scripts/uninstall.scpt`
- `src/platform/privileges_scripts/update.scpt`

实现：
- Bundle ID 改为 `com.kdesk.desktop`
- 应用产物名改为 `KDesk.app`
- `CFBundleDisplayName` 保持为 `RustDesk`
- `CFBundleURLName` 改为 `com.kdesk.desktop`
- LaunchAgent / LaunchDaemon label 与 plist 文件名改为 `com.kdesk.desktop_*`
- 自更新、安装、卸载脚本中的 `/Applications/RustDesk.app` 改为 `/Applications/KDesk.app`

说明：
- 这样可以避免与官方 `RustDesk.app`、原 bundle id、原 launchctl label 冲突。
- 显示名仍保留 `RustDesk`，但应用包名改为 `KDesk.app` 以支持并存安装。

#### Windows
文件：
- `flutter/windows/CMakeLists.txt`
- `flutter/windows/runner/Runner.rc`
- `res/msi/preprocess.py`

实现：
- Windows 可执行文件名改为 `kdesk.exe`
- PE 资源中的 `InternalName` / `OriginalFilename` 改为 `kdesk`
- MSI 预处理默认 `--app-name` 改为 `KDesk`

说明：
- `res/msi/preprocess.py` 中 UpgradeCode 基于 `app_name + ".exe"` 生成；改默认 `app-name` 后，MSI UpgradeCode 会自动与官方版分离。
- 这样官方版与当前定制版不会互相覆盖升级。

## 本次检查结论
已补齐当前与“并存安装”直接相关的主要标识：
- Android：applicationId
- macOS：bundle id、app bundle 名、launch agent/daemon label、安装/更新脚本路径
- Windows：exe 文件名、MSI app-name / UpgradeCode 来源

## 当前有意未改项
以下内容当前未改，因为它们不属于本次“安装共存”的核心冲突点：
- URI scheme 仍为 `rustdesk://`
- Flutter host method channel 仍为 `org.rustdesk.rustdesk/host`
- iOS bundle id 未处理
- 若干注释、文案、外链中仍存在 `RustDesk` 字样

如果下次需要继续做更彻底的白标或协议隔离，可再处理：
- URI scheme
- iOS bundle id
- Flutter/macOS/windows host channel 名称
- 更完整的品牌字样收敛

## 下次升级代码时建议优先检查的文件
- `src/common.rs`
- `src/rendezvous_mediator.rs`
- `flutter/lib/common.dart`
- `flutter/lib/desktop/pages/desktop_setting_page.dart`
- `flutter/lib/mobile/pages/connection_page.dart`
- `flutter/lib/mobile/pages/settings_page.dart`
- `flutter/android/app/build.gradle`
- `flutter/macos/Runner/Configs/AppInfo.xcconfig`
- `flutter/macos/Runner/Info.plist`
- `flutter/macos/Runner.xcodeproj/project.pbxproj`
- `flutter/windows/CMakeLists.txt`
- `flutter/windows/runner/Runner.rc`
- `src/platform/privileges_scripts/*`
- `res/msi/preprocess.py`
- `.github/workflows/flutter-ci.yml`
