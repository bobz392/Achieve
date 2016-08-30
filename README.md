## 依赖

- Fabric
  - 运行前需要先安装 [Fabric](https://get.fabric.io)
  - 安装好后需要添加一个子账号并以子账号登陆
-  使用 [Carthage](https://github.com/Carthage/Carthage) 管理依赖库
  - 由于所有依赖库都能够通过 `Cartfile.resolved` 来保证版本，`Carthage` 目录中的内容已经被加入了 `.gitignore`
  - 运行前，需要在项目根目录运行 `carthage update --platform ios --no-use-binaries`
    - 或者直接运行 `make carthage`
  - 如果需要添加依赖库
    - 先在 `Cartfile` 中添加所需要的依赖库
    - 然后运行 `carthage update --platform ios --no-use-binaries`
      - 或者直接运行 `make carthage`
      - `--platform ios` 表示只编译 iOS 的 Framework
      - `--no-use-binaries` 表示不使用预先编译的 binary，因为 Xcode 有一个 [Bug](https://forums.developer.apple.com/thread/20889)，使用这类 binary 可能导致 Xcode 在断点处 crash
    - 将 `./Carthage/Build/iOS/` 中编译好的 `.framework` 拖入到工程中（引用即可，不需要 Copy）
    - 在 `shimo` Target 的 `Build Phases` 中的 `Copy Carthage Frameworks` 中加入编译好的 `.framework`
      - 如果有必要，还需要删除 `Embedded Binary` 中的 `.framework`，因为 `Copy Carthage Frameworks` 会 strip 掉 `i386` 和 `x86_64` 等不能提交到 App Store 的 `arch`
      - 如果需要让 crash log 自动解析 symbol，还需要将对应的 `.dSYM` 添加到 `Build Phases` 中的 `Copy Carthage dSYMs` 中


