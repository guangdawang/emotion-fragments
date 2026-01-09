# Docker 构建指南

本项目支持使用 Docker 进行构建，这样可以确保构建环境的一致性。

## 本地构建

### 构建 Docker 镜像

```bash
docker build -t godot-builder .
```

### 构建 Windows 版本

```bash
docker run --rm -v $(pwd):/workspace godot-builder godot --headless --export-release "Windows Desktop" emotional-fragments.exe
```

### 构建 Web 版本

```bash
docker run --rm -v $(pwd):/workspace godot-builder godot --headless --export-release "HTML5" emotional-fragments.html
```

## GitHub Actions 构建

项目配置了 GitHub Actions 工作流，会在以下情况下自动构建：

1. 推送带有 `v` 前缀的标签（例如 `v1.0.0`）
2. 手动触发工作流

工作流会：
1. 构建 Docker 镜像并推送到 GitHub Container Registry
2. 使用 Docker 容器构建 Windows 和 Web 版本
3. 创建 GitHub Release 并上传构建产物

## 手动触发构建

1. 进入 GitHub 仓库的 Actions 页面
2. 选择 "Build with Docker" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支并点击 "Run workflow" 按钮

## 优势

使用 Docker 构建有以下优势：

1. **环境一致性**：确保所有构建使用相同的环境和依赖
2. **可重复性**：相同的 Docker 镜像会产生相同的构建结果
3. **隔离性**：构建过程与主机环境隔离
4. **可移植性**：可以在任何支持 Docker 的平台上构建
5. **缓存**：利用 Docker 层缓存加速构建过程
