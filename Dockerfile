FROM ubuntu:22.04

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# 安装 Godot 4.2.1
RUN wget -q https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip -O /tmp/godot.zip \
    && unzip -q /tmp/godot.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/Godot_v4.2.1-stable_linux.x86_64 \
    && ln -s /usr/local/bin/Godot_v4.2.1-stable_linux.x86_64 /usr/local/bin/godot \
    && rm /tmp/godot.zip

# 安装导出模板
RUN mkdir -p /root/.local/share/godot/export_templates \
    && wget -q https://github.com/godotengine/godot/releases/download/4.2.1-stable/Godot_v4.2.1-stable_export_templates.tpz -O /tmp/templates.tpz \
    && unzip -q /tmp/templates.tpz -d /root/.local/share/godot/export_templates \
    && rm /tmp/templates.tpz

# 设置工作目录
WORKDIR /workspace

# 验证安装
RUN godot --version
