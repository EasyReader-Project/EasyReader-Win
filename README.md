# EasyReader-Win

跨平台阅读器 EasyReader Project 的 **Windows 桌面端实现**。

基于 **契约先行 (Specs First)** 原则开发，严格遵循 [EasyReader-Specs](https://github.com/your-org/EasyReader-Specs) 仓库定义的数据结构与常量规范，确保与 Android 端数据互通。

---

## 📐 整体架构数据流

本项目采用 **Electron 壳 + 本地 Spring Boot 服务** 的经典桌面应用架构。前端 Vue3 与后端 Java 通过 HTTP 协议进行本地通信，彻底避开 Node.js 原生模块编译带来的复杂问题。

```mermaid
graph TD
    subgraph Electron 主进程
        A[Main Process] -->|spawn| B[Java 子进程]
        A -->|检测端口 & IPC 传递| C[Vue3 渲染进程]
    end

    subgraph Spring Boot 后端服务
        D[Controller 层]
        E[Service 业务层]
        F[MyBatis-Plus DAO 层]
        G[(SQLite 本地数据库)]
    end

    subgraph Vue3 前端界面
        H[用户交互操作]
        I[Axios HTTP 客户端]
    end

    H -->|触发| I
    I -->|RESTful API 调用 localhost:动态端口| D
    D --> E --> F --> G
    G --> F --> E --> D --> I --> H

    C -.->|包含| H
    C -.->|包含| I
    A -.->|启动后传递端口号| C