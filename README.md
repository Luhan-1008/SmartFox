# SmartFox

北航软工课设-灵狐智验实验平台

## 本地运行

### 1. 环境要求

- Node.js 22+
- npm 10+
- Python 3.11+
- Windows PowerShell

### 2. 初始化依赖

在项目根目录执行：

```powershell
.\scripts\setup.ps1
```

如果你更习惯双击，也可以直接运行：

```powershell
.\scripts\setup.bat
```

这个脚本会自动完成：

- 安装前端依赖
- 创建后端虚拟环境 `backend/.venv`
- 安装后端依赖

### 3. 一键启动项目

推荐先使用 SQLite 模式启动，这样不用先配置 MySQL：

```powershell
.\scripts\run-dev.ps1
```

或者：

```powershell
.\scripts\run-dev.bat
```

启动后默认地址：

- 前端：`http://localhost:5173`
- 后端：`http://127.0.0.1:8000`

脚本会自动：

- 执行 Django 数据库迁移
- 启动后端服务
- 启动前端服务

### 4. 如果你要使用 MySQL

如果你本地已经按照 `backend/server/settings.py` 配好了 MySQL，可以这样启动：

```powershell
.\scripts\run-dev.ps1 -UseMySQL
```

### 5. 单独启动

#### 前端

```powershell
cd .\frontend
npm install
npm run dev
```

#### 后端

先初始化虚拟环境后：

```powershell
cd .\backend
.\.venv\Scripts\python manage.py migrate
$env:DJANGO_SETTINGS_MODULE='server.settings_test'
.\.venv\Scripts\python manage.py runserver
```

如果要改回 MySQL 模式，去掉 `DJANGO_SETTINGS_MODULE` 即可。

## 前端 GUI 测试

项目现在统一使用 `Cypress` 作为前端 GUI / E2E 测试框架。

### 目录说明

- `frontend/cypress/e2e/`：项目实际的 GUI 测试用例
- `frontend/cypress/fixtures/`：测试数据和上传文件
- `frontend/cypress/support/`：Cypress 全局初始化

### 运行前准备

先分别启动前后端：

- 前端：`http://127.0.0.1:5173`
- 后端：`http://127.0.0.1:8000`

如果端口不同，可以通过环境变量覆盖：

```powershell
$env:CYPRESS_BASE_URL='http://127.0.0.1:5173'
$env:CYPRESS_API_BASE_URL='http://127.0.0.1:8000'
```

### 打开交互式测试界面

```powershell
cd .\frontend
npm run test:gui:open
```

### 命令行运行 GUI 测试

```powershell
cd .\frontend
npm run test:gui
```

### 当前测试文件状态

- `frontend_test.cy.ts`：完整流程测试
- `forum_test.cy.ts`：论坛模块测试
- `notice_test.cy.ts`：公告模块测试
- `material_test.cy.ts`：资料模块测试骨架，当前内容未完善

说明：项目中原本存在 Playwright 模板测试和 Cypress 官方示例测试，已清理，避免和项目真实 GUI 测试混淆。
