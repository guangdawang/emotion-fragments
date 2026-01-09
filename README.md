
# 情绪碎片

## 项目简介

《情绪碎片》是一款探索情感体验的互动艺术游戏，使用 **Godot Engine** 开发。通过操控漂浮的碎片，玩家将经历"压抑→混乱→重构"的情感旅程，体验从束缚到自由的心理转变过程。

## 游戏玩法

### 核心机制

游戏围绕四个核心情绪维度展开：

- **压抑** - 代表束缚感和限制
- **焦虑** - 代表混乱和不确定性
- **能动性** - 代表控制力和行动能力
- **希望** - 代表成长和重建的可能性

### 游戏阶段

#### 1. 秩序阶段（压抑）

- 碎片呈现有序排列，运动规律。
- 玩家感受到环境的束缚。
- 通过尝试移动和创造来积累希望值。
- 触碰秩序核心将触发阶段转换。

#### 2. 混乱阶段（焦虑）

- 碎片开始无序运动，环境变得不稳定。
- 玩家需要使用脉冲技能来增强控制力。
- 避免碎片碰撞以控制焦虑值。
- 当焦虑值足够高且具备足够控制力时，进入重构阶段。

#### 3. 重构阶段（希望）

- 碎片开始相互吸引，形成新的秩序。
- 玩家可以放置碎片，创造新的模式。
- 通过创造和重组来积累希望值。
- 最终完成心理重建。

### 玩家操作

- **移动** - 鼠标跟随 或 键盘方向键/WASD 控制移动。
- **创造** - 鼠标左键 尝试创造新的碎片或模式。
- **脉冲** - 空格键 在混乱阶段使用，增强控制力。
- **放置** - Shift + 左键 在重构阶段放置碎片。
- **R 键** - 重新开始游戏。

## 项目结构

Godot 项目结构相比 Unity 更加简洁直观，核心逻辑均为文本文件。

```
项目根目录/
├── project.godot                  # 项目配置文件（等同于 Unity 的 ProjectSettings）
├── export_presets.cfg             # 导出配置（用于 GitHub Actions 自动打包）
├── Scenes/                        # 游戏场景目录
│   ├── MainScene.tscn             # 主场景
│   └── Fragment.tscn              # 碎片场景（包含其脚本和资源引用）
├── Scripts/                       # 脚本目录
│   ├── GameManager.gd             # 游戏主控与单例
│   ├── EmotionStateMachine.gd     # 情绪状态机逻辑
│   ├── FragmentManager.gd         # 碎片生成与对象池管理
│   ├── FragmentMotion.gd          # 单个碎片的运动控制
│   ├── PlayerController.gd        # 玩家输入与移动
│   ├── VisualEffects.gd           # 视觉反馈与粒子特效
│   └── AudioManager.gd            # 音频管理（支持动态流式加载）
├── Shaders/                       # 着色器目录
│   └── EmotionFragment.gdshader   # 碎片情感可视化着色器
├── Assets/                        # 资源目录
│   ├── textures/                  # 图片素材
│   └── audio/                     # 音频文件
├── .gitignore                     # Git 忽略文件配置
└── README.md                      # 项目说明文档
```

## 目录说明

### 必须保留的文件/目录

- **project.godot** - 项目的身份证，包含了引擎版本、渲染设置等核心信息。
- **Scenes/** - 包含 `.tscn` 文件。这是 Godot 的场景文件，本质是可读的文本，记录了节点树结构。
- **Scripts/** - 包含 `.gd` 文件。所有游戏逻辑的核心，建议使用 Git 进行严格版本控制。
- **Shaders/** - 包含 `.gdshader` 文件。实现“情绪碎片”独特视觉效果的关键。
- **Assets/** - 所有的美术和音频原始素材。

### 不需要包含的目录 (在 .gitignore 中配置)

- **.godot/** - Godot 编辑器生成的缓存（类似 Unity 的 Library），绝对不要提交到 Git。
- **import/** - 资源导入缓存，换电脑或 CI 环境时会自动重新生成。
- **.tmp/** - 临时文件。

## 快速开始

### 环境要求

- **Godot Engine 4.x** (推荐 4.2 或以上版本)。
- 代码编辑器 (VS Code 配合 Godot 插件 是最佳选择)。
- (可选) Docker / GitHub Actions 用于自动化部署。

### 打开项目

1. 下载并解压 Godot 4 编辑器。
2. 双击运行 Godot.exe (或 Linux 下的 Godot 二进制文件)。
3. 点击 "导入" 按钮，选择项目根目录下的 `project.godot` 文件。
4. 项目即打开，Godot 会自动扫描并导入资源。

### 运行游戏

1. 在编辑器左下角文件系统中找到 `Scenes/MainScene.tscn`。
2. 双击打开场景。
3. 按下 **F6** (运行当前场景) 或 右上角的播放按钮。

## 游戏系统实现

### 情绪系统

核心由 `EmotionStateMachine.gd` 管理，使用枚举定义状态：

```gdscript
enum EmotionState {
    ORDER,      # 秩序/压抑
    CHAOS,      # 混乱/焦虑
    REFACTOR    # 重构/希望
}
```

通过信号机制通知全局变量变化，驱动 UI 和音乐系统的响应。

### 碎片系统

`FragmentManager.gd` 负责碎片的生命周期：

- **生成**：根据当前情绪维度调整碎片的生成速率和初始位置。
- **行为**：碎片实例化时挂载 `FragmentMotion.gd`，根据全局状态机改变物理行为（如从规则运动变为布朗运动）。
- **优化**：建议使用 Godot 内置的 `MultiplayerSpawner` 或简单的对象池数组来复用节点，避免频繁创建销毁导致卡顿。

### 视觉系统

- **Shader (VisualShader 或 .gdshader)**：利用 `uniform` 变量将情绪值传递给显卡，实时改变碎片的颜色、噪点抖动程度和发光强度。
- **CanvasLayer**：用于 UI 和后处理特效，确保浮于游戏画面之上。

### 音频系统

Godot 拥有强大的内置音频系统，无需像 Unity 那样依赖重型第三方中间件：

- **AudioStreamPlayer**：播放背景音乐，通过 `pitch_scale` 属性根据“焦虑值”实时改变音调，制造紧张感。
- **AudioStreamPlayer2D**：跟随玩家位置的音效（如脉冲声）。

## 开发说明

### 代码规范

- **语言**：GDScript 2.0 (Godot 4)。
- **风格**：使用 `snake_case` 命名变量和函数（Godot 官方推荐）。
- **类型提示**：尽量指定类型，例如 `var health: int = 100`，以获得更好的代码补全。
- **单例**：将 `GameManager` 设为 Autoload (单例)，这样在任何脚本中都可以通过 `GameManager.some_value` 访问全局状态。

### CI/CD (GitHub Actions)

由于你已有服务器经验，推荐配置 Godot 的 GitHub Action：

1. 构建：使用 `barichello/godot-action` 自动导出 HTML5 或 Windows 版本。
2. 部署：构建成功后，利用 SSH 将 HTML5 包上传至你的阿里云服务器 Nginx 目录。

### 注意事项

- **不要提交 .godot 文件夹**：这是最大的坑，会导致 Git 仓库极度臃肿。
- **坐标系统**：Godot 的 Y 轴是向下的，与 Unity 不同（Y 轴向上），做运动计算时请注意方向。
- **性能**：碎片数量建议设置上限（如 500-1000 个），移动端可通过 `Project Settings -> Rendering -> Limit` 进行性能限制。

## 许可证

MIT License
