@echo off

::WinPEOS 生成工具
::由小模组QZ制作
::版本：1.0.3
::功能强大而齐全
::该版本是生成Win11 24H2的

:;切换到当前目录
if not "%cd%"=="%~dp0" cd "%~dp0"

:;next

::此处是conhost控制台内可以设置的内容
mode con cols=80 lines=25

:;设置WinPEOS生成工具的路径
set "bin=%cd%\bin"
set "files=%cd%\files"
set mount=0
set commit=0
set optimize=0
set set=0
set set1=0
set set2=0
set "label="
set "isoname="
set soft=0
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set arch=arm64
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set arch=x64
if "%PROCESSOR_ARCHITECTURE%"=="X86" set arch=x86

:;输入标题
title WinPEOS 生成工具

:;获取管理员权限
%bin%\IsAdmin.exe
if not ERRORLEVEL 1 (
  cls
  echo 检测到未使用以管理员身份运行
  echo 正在等待验证
  cscript //nologo %bin%\getadmin.vbs "%0" "runas"
  exit /b
)

::首页

:;main
cls
echo -------------------------------------------------------------------------------
echo            欢迎使用WinPEOS Windows 11 24H2 PE生成工具 v1.0.3 (x64)
echo -------------------------------------------------------------------------------
echo.
echo 1.制作WinPEOS
echo 2.编辑WinPEOS
echo 3.给WinPEOS添加软件
echo 4.创建ISO镜像
echo.
echo 5.清除ISO缓存
echo 6.实用工具
echo 7.退出
echo.
set /p set=请选择选项（输入数字）：
if "%set%"=="1" goto ;make
if "%set%"=="2" goto ;edit
if "%set%"=="3" goto ;addsoft
if "%set%"=="4" goto ;iso
if "%set%"=="5" goto ;cleancache
if "%set%"=="6" goto ;tool
if "%set%"=="7" goto ;exit
goto ;main

::制作WinPEOS

:;make
cls
echo -------------------------------------------------------------------------------
echo                             选择要制作的镜像
echo -------------------------------------------------------------------------------
echo.
echo 请选择要制作的镜像
echo 1.Windows 11 24H2 PE 全功能版
echo 2.Windows 11 24H2 PE Lite版
echo.
echo 我们如何选？
echo 全功能版使用了完整的Catalog，原版字体，集成了Chrome浏览器，自带大多数维护工具
echo Lite版适当精简了一些功能，例如浏览器，辅助功能，没有.NET Framework、VC及DirectX运行库
echo Lite版适合2G内存的电脑，osk屏幕键盘更换为虚拟键盘，更换精简的字体文件等
echo Lite版删除了不必要的文件以节约空间
echo 如果你的电脑是4G内存以上的，且能在WinPEOS里面玩游戏，编程代码等，就选全功能版
echo 如果你的电脑是2G内存以上的，且可以基本维护和远程重装，就选Lite版
echo.
if exist "%files%\ISO" (
  echo 检测到ISO缓存，一旦制作，原ISO缓存将被删除，重新生成一个新的ISO缓存
  echo.
)
echo 3.返回
set /p set1=请选择选项（输入数字）：
if "%set1%"=="1" (
  set base=2
  goto ;startmake
)
if "%set1%"=="2" (
  set base=1
  goto ;startmake
)
if "%set1%"=="3" goto ;main
goto ;make

::此时开始制作镜像

:;startmake
cls
echo -------------------------------------------------------------------------------
echo                           正在创建媒体介质
echo -------------------------------------------------------------------------------
echo.
if exist "%files%\ISO" rd /s /q "%files%\ISO"
if exist "%files%\ISO" del /f /q "%files%\ISO"
if not exist "%files%\ISO" mkdir "%files%\ISO"
echo 正在创建引导文件...
"%bin%\%arch%\wimlib-imagex.exe" apply "%files%\base.esd" 3 "%files%\ISO"
echo 正在创建RamDisk引导镜像...
"%bin%\%arch%\wimlib-imagex.exe" export "%files%\base.esd" %base% %files%\ISO\WinPEOS\boot.wim --compress=LZX --boot
echo 创建完成！
echo 你可以做什么？
echo 1.创建ISO（推荐）
echo 2.编辑
echo 3.返回
set /p set2=请选择选项（输入数字）：
if "%set2%"=="1" goto ;iso
if "%set2%"=="2" goto ;edit
if "%set2%"=="3" goto ;main
goto ;main

::此处是编辑WinPEOS镜像

:;edit
cls
echo -------------------------------------------------------------------------------
echo                           编辑WinPEOS镜像
echo -------------------------------------------------------------------------------
echo.
if not exist %files%\ISO (
  echo 检测到没有ISO缓存，编辑镜像无法继续
  pause
  goto ;main
)
if not exist %files%\ISO\bootmgr (
  echo 检测到ISO缓存损坏，需要重新制作WinPEOS
  pause
  goto ;main
)
if not exist %files%\ISO\bootmgr.efi (
  echo 检测到ISO缓存损坏，需要重新制作WinPEOS
  pause
  goto ;main
)
if not exist %files%\ISO\WinPEOS\boot.wim (
  echo 检测到ISO缓存损坏，需要重新制作WinPEOS
  pause
  goto ;main
)
echo 正在挂载镜像...
if not exist "%~dp0\Mount" mkdir "%~dp0\Mount"
"%bin%\%arch%\imagex.exe" /mount "%files%\ISO\WinPEOS\boot.wim" 1 "%~dp0\Mount"
if not "%errorlevel%"=="0" (
  echo 挂载失败
  echo 编辑无法继续
  pause
  goto ;main
)
set mount=1
:;editmgr
cls
echo -------------------------------------------------------------------------------
echo                           编辑WinPEOS镜像
echo -------------------------------------------------------------------------------
echo.
echo 1.打开镜像挂载目录
echo 2.给WinPEOS添加软件
echo 3.编辑PECMD.INI
echo 4.保存镜像并返回
echo 5.仅保存镜像
echo 6.丢弃更改并返回
set /p mouset=请选择选项（输入数字）：
if "%mouset%"=="1" start %~dp0\Mount
if "%mouset%"=="2" goto ;addsoft
if "%mouset%"=="3" start notepad "%~dp0\Mount\Windows\System32\Pecmd.ini"
if "%mouset%"=="4" (
  set commit=1
  goto ;back
)
if "%mouset%"=="5" (
  cls
  echo -------------------------------------------------------------------------------
  echo                              正在保存镜像
  echo -------------------------------------------------------------------------------
  echo.
  echo 正在保存镜像...
  "%bin%\%arch%\imagex.exe" /commit "%~dp0\Mount"
  if not "%errorlevel%"=="0" (
    echo 保存失败，请重试
    pause
    goto ;editmgr
  )
  echo 保存完毕！
  pause
  goto ;editmgr
)
if "%mouset%"=="6" (
  set commit=0
  goto ;back
)
goto ;editmgr

:;back
cls
echo -------------------------------------------------------------------------------
if "%commit%"=="1" echo                              正在保存镜像
if "%commit%"=="0" echo                              正在卸载镜像
echo -------------------------------------------------------------------------------
echo.
if "%commit%"=="1" (
  echo 正在保存镜像...
  "%bin%\%arch%\imagex.exe" /commit "%~dp0\Mount"
  if not "%errorlevel%"=="0" (
    echo 保存失败，请重试
    pause
    goto ;editmgr
  )
  set commit=0
  set optimize=1
  goto ;back
)
echo 正在卸载镜像...
"%bin%\%arch%\imagex.exe" /unmount "%~dp0\Mount"
if not "%errorlevel%"=="0" (
  echo 卸载失败，请重试
  pause
  goto ;back
)
set mount=0
if "%optimize%"=="1" (
  echo 正在优化镜像...
  "%bin%\%arch%\wimlib-imagex.exe" optimize "%files%\ISO\WinPEOS\boot.wim"
  set optimize=0
)
rd /s /q "%~dp0\Mount"
if "soft"=="1" (
  echo 软件添加完成！
  set soft=0
  pause
)
goto ;main

::添加软件包

:;addsoft
cls
echo -------------------------------------------------------------------------------
echo                           给WinPEOS添加软件
echo -------------------------------------------------------------------------------
echo.
if not exist %files%\ISO (
  echo 检测到没有ISO缓存，添加软件无法继续
  pause
  goto ;main
)
:;soft
set /p software=请选择要安装的软件包（空为取消）：
if "%software%"=="" if "mount"=="1" goto ;editmgr
if "%software%"=="" goto ;main
if not exist %software% (
  echo 软件包不存在，请重试
  goto ;soft
)
set soft=1
if "mount"=="0" (
  echo 正在挂载镜像...
  if not exist "%~dp0\Mount" mkdir "%~dp0\Mount"
  "%bin%\%arch%\imagex.exe" /mount "%files%\ISO\WinPEOS\boot.wim" 1 "%~dp0\Mount"
  echo 正在添加软件...
  "%bin%\%arch%\wimlib-imagex.exe" apply %software% 1 "%~dp0\Mount"
  set commit=1
  goto ;back
)
if "mount"=="1" (
  echo 正在添加软件...
  "%bin%\%arch%\wimlib-imagex.exe" apply %software% 1 "%~dp0\Mount"
  echo 软件添加完成！
  set soft=0
  pause
  goto ;editmgr
)

:;cleancache
cls
echo -------------------------------------------------------------------------------
echo                             清除 ISO 缓存
echo -------------------------------------------------------------------------------
echo.
if not exist "%files%\ISO" (
  echo 当前没有ISO缓存
  pause
  goto ;main
)
echo 警告：此处是ISO缓存，以下功能需要依赖ISO缓存
echo 编辑WinPEOS镜像
echo 给WinPEOS添加软件
echo 创建ISO镜像
echo 此操作不可逆，清除后依赖的功能不能正常使用，需要重新制作WinPEOS介质，要继续吗？
set set=0
set /p set=(Y/N)：
if "%set%"=="Y" (
  rd /s /q "%files%\ISO"
  if exist "%files%\ISO" del /f /q "%files%\ISO"
  goto ;main
)
if "%set%"=="y" (
  rd /s /q "%files%\ISO"
  if exist "%files%\ISO" del /f /q "%files%\ISO"
  goto ;main
)
if "%set%"=="N" goto ;main
if "%set%"=="n" goto ;main
goto ;cleancache

::创建一个ISO镜像

:;iso
cls
echo -------------------------------------------------------------------------------
echo                             创建 ISO 镜像
echo -------------------------------------------------------------------------------
echo.
if not exist "%files%\ISO" (
  echo 检测到没有ISO缓存，创建无法继续
  pause
  goto ;main
)
:;label
set /p label=请输入卷标（空为取消）：
if "%label%"=="" goto ;main
:;isoname
set /p isoname=请输入ISO文件名（空为取消）：
if "%isoname%"=="" goto ;main
echo 正在创建ISO文件...
"%bin%\%arch%\oscdimg.exe" -bootdata:2#p0,e,b"%files%\ISO\boot\etfsboot.com"#pEF,e,b"%files%\ISO\efi\Microsoft\boot\efisys_noprompt.bin" -o -m -u2 -udfver102 -t03/08/2025,15:20:00 -l"%label%" "%files%\ISO" "%isoname%.iso"
if exist "%~dp0\%isoname%.iso" echo 创建完成！
if not exist "%~dp0\%isoname%.iso" echo 创建失败！
set "label="
set "isoname="
pause
goto ;main

:;tool
cls
echo -------------------------------------------------------------------------------
echo                                   实用工具
echo -------------------------------------------------------------------------------
echo.
echo 1.Rufus
echo 2.Ventoy
echo 3.GImageX
echo 4.返回
set /p set=请选择选项（输入数字）：
if "%set%"=="1" start %bin%\%arch%\rufus-4.6.exe"
if "%set%"=="2" start %bin%\Ventoy\Ventoy2Disk.exe"
if "%set%"=="3" start %bin%\%arch%\GImageX.exe"
if "%set%"=="4" goto ;main
goto ;tool

;exit
cls
echo WinPEOS 生成工具已退出
exit /b
