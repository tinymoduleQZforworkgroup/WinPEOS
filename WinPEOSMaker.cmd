@echo off

::WinPEOS ���ɹ���
::��Сģ��QZ����
::�汾��1.0.3
::����ǿ�����ȫ
::�ð汾������Win11 24H2��

:;�л�����ǰĿ¼
if not "%cd%"=="%~dp0" cd "%~dp0"

:;next

::�˴���conhost����̨�ڿ������õ�����
mode con cols=80 lines=25

:;����WinPEOS���ɹ��ߵ�·��
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

:;�������
title WinPEOS ���ɹ���

:;��ȡ����ԱȨ��
%bin%\IsAdmin.exe
if not ERRORLEVEL 1 (
  cls
  echo ��⵽δʹ���Թ���Ա�������
  echo ���ڵȴ���֤
  cscript //nologo %bin%\getadmin.vbs "%0" "runas"
  exit /b
)

::��ҳ

:;main
cls
echo -------------------------------------------------------------------------------
echo            ��ӭʹ��WinPEOS Windows 11 24H2 PE���ɹ��� v1.0.3 (x64)
echo -------------------------------------------------------------------------------
echo.
echo 1.����WinPEOS
echo 2.�༭WinPEOS
echo 3.��WinPEOS������
echo 4.����ISO����
echo.
echo 5.���ISO����
echo 6.ʵ�ù���
echo 7.�˳�
echo.
set /p set=��ѡ��ѡ��������֣���
if "%set%"=="1" goto ;make
if "%set%"=="2" goto ;edit
if "%set%"=="3" goto ;addsoft
if "%set%"=="4" goto ;iso
if "%set%"=="5" goto ;cleancache
if "%set%"=="6" goto ;tool
if "%set%"=="7" goto ;exit
goto ;main

::����WinPEOS

:;make
cls
echo -------------------------------------------------------------------------------
echo                             ѡ��Ҫ�����ľ���
echo -------------------------------------------------------------------------------
echo.
echo ��ѡ��Ҫ�����ľ���
echo 1.Windows 11 24H2 PE ȫ���ܰ�
echo 2.Windows 11 24H2 PE Lite��
echo.
echo �������ѡ��
echo ȫ���ܰ�ʹ����������Catalog��ԭ�����壬������Chrome��������Դ������ά������
echo Lite���ʵ�������һЩ���ܣ�������������������ܣ�û��.NET Framework��VC��DirectX���п�
echo Lite���ʺ�2G�ڴ�ĵ��ԣ�osk��Ļ���̸���Ϊ������̣���������������ļ���
echo Lite��ɾ���˲���Ҫ���ļ��Խ�Լ�ռ�
echo �����ĵ�����4G�ڴ����ϵģ�������WinPEOS��������Ϸ����̴���ȣ���ѡȫ���ܰ�
echo �����ĵ�����2G�ڴ����ϵģ��ҿ��Ի���ά����Զ����װ����ѡLite��
echo.
if exist "%files%\ISO" (
  echo ��⵽ISO���棬һ��������ԭISO���潫��ɾ������������һ���µ�ISO����
  echo.
)
echo 3.����
set /p set1=��ѡ��ѡ��������֣���
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

::��ʱ��ʼ��������

:;startmake
cls
echo -------------------------------------------------------------------------------
echo                           ���ڴ���ý�����
echo -------------------------------------------------------------------------------
echo.
if exist "%files%\ISO" rd /s /q "%files%\ISO"
if exist "%files%\ISO" del /f /q "%files%\ISO"
if not exist "%files%\ISO" mkdir "%files%\ISO"
echo ���ڴ��������ļ�...
"%bin%\%arch%\wimlib-imagex.exe" apply "%files%\base.esd" 3 "%files%\ISO"
echo ���ڴ���RamDisk��������...
"%bin%\%arch%\wimlib-imagex.exe" export "%files%\base.esd" %base% %files%\ISO\WinPEOS\boot.wim --compress=LZX --boot
echo ������ɣ�
echo �������ʲô��
echo 1.����ISO���Ƽ���
echo 2.�༭
echo 3.����
set /p set2=��ѡ��ѡ��������֣���
if "%set2%"=="1" goto ;iso
if "%set2%"=="2" goto ;edit
if "%set2%"=="3" goto ;main
goto ;main

::�˴��Ǳ༭WinPEOS����

:;edit
cls
echo -------------------------------------------------------------------------------
echo                           �༭WinPEOS����
echo -------------------------------------------------------------------------------
echo.
if not exist %files%\ISO (
  echo ��⵽û��ISO���棬�༭�����޷�����
  pause
  goto ;main
)
if not exist %files%\ISO\bootmgr (
  echo ��⵽ISO�����𻵣���Ҫ��������WinPEOS
  pause
  goto ;main
)
if not exist %files%\ISO\bootmgr.efi (
  echo ��⵽ISO�����𻵣���Ҫ��������WinPEOS
  pause
  goto ;main
)
if not exist %files%\ISO\WinPEOS\boot.wim (
  echo ��⵽ISO�����𻵣���Ҫ��������WinPEOS
  pause
  goto ;main
)
echo ���ڹ��ؾ���...
if not exist "%~dp0\Mount" mkdir "%~dp0\Mount"
"%bin%\%arch%\imagex.exe" /mount "%files%\ISO\WinPEOS\boot.wim" 1 "%~dp0\Mount"
if not "%errorlevel%"=="0" (
  echo ����ʧ��
  echo �༭�޷�����
  pause
  goto ;main
)
set mount=1
:;editmgr
cls
echo -------------------------------------------------------------------------------
echo                           �༭WinPEOS����
echo -------------------------------------------------------------------------------
echo.
echo 1.�򿪾������Ŀ¼
echo 2.��WinPEOS������
echo 3.�༭PECMD.INI
echo 4.���澵�񲢷���
echo 5.�����澵��
echo 6.�������Ĳ�����
set /p mouset=��ѡ��ѡ��������֣���
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
  echo                              ���ڱ��澵��
  echo -------------------------------------------------------------------------------
  echo.
  echo ���ڱ��澵��...
  "%bin%\%arch%\imagex.exe" /commit "%~dp0\Mount"
  if not "%errorlevel%"=="0" (
    echo ����ʧ�ܣ�������
    pause
    goto ;editmgr
  )
  echo ������ϣ�
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
if "%commit%"=="1" echo                              ���ڱ��澵��
if "%commit%"=="0" echo                              ����ж�ؾ���
echo -------------------------------------------------------------------------------
echo.
if "%commit%"=="1" (
  echo ���ڱ��澵��...
  "%bin%\%arch%\imagex.exe" /commit "%~dp0\Mount"
  if not "%errorlevel%"=="0" (
    echo ����ʧ�ܣ�������
    pause
    goto ;editmgr
  )
  set commit=0
  set optimize=1
  goto ;back
)
echo ����ж�ؾ���...
"%bin%\%arch%\imagex.exe" /unmount "%~dp0\Mount"
if not "%errorlevel%"=="0" (
  echo ж��ʧ�ܣ�������
  pause
  goto ;back
)
set mount=0
if "%optimize%"=="1" (
  echo �����Ż�����...
  "%bin%\%arch%\wimlib-imagex.exe" optimize "%files%\ISO\WinPEOS\boot.wim"
  set optimize=0
)
rd /s /q "%~dp0\Mount"
if "soft"=="1" (
  echo ��������ɣ�
  set soft=0
  pause
)
goto ;main

::��������

:;addsoft
cls
echo -------------------------------------------------------------------------------
echo                           ��WinPEOS������
echo -------------------------------------------------------------------------------
echo.
if not exist %files%\ISO (
  echo ��⵽û��ISO���棬�������޷�����
  pause
  goto ;main
)
:;soft
set /p software=��ѡ��Ҫ��װ�����������Ϊȡ������
if "%software%"=="" if "mount"=="1" goto ;editmgr
if "%software%"=="" goto ;main
if not exist %software% (
  echo ����������ڣ�������
  goto ;soft
)
set soft=1
if "mount"=="0" (
  echo ���ڹ��ؾ���...
  if not exist "%~dp0\Mount" mkdir "%~dp0\Mount"
  "%bin%\%arch%\imagex.exe" /mount "%files%\ISO\WinPEOS\boot.wim" 1 "%~dp0\Mount"
  echo ����������...
  "%bin%\%arch%\wimlib-imagex.exe" apply %software% 1 "%~dp0\Mount"
  set commit=1
  goto ;back
)
if "mount"=="1" (
  echo ����������...
  "%bin%\%arch%\wimlib-imagex.exe" apply %software% 1 "%~dp0\Mount"
  echo ��������ɣ�
  set soft=0
  pause
  goto ;editmgr
)

:;cleancache
cls
echo -------------------------------------------------------------------------------
echo                             ��� ISO ����
echo -------------------------------------------------------------------------------
echo.
if not exist "%files%\ISO" (
  echo ��ǰû��ISO����
  pause
  goto ;main
)
echo ���棺�˴���ISO���棬���¹�����Ҫ����ISO����
echo �༭WinPEOS����
echo ��WinPEOS������
echo ����ISO����
echo �˲��������棬����������Ĺ��ܲ�������ʹ�ã���Ҫ��������WinPEOS���ʣ�Ҫ������
set set=0
set /p set=(Y/N)��
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

::����һ��ISO����

:;iso
cls
echo -------------------------------------------------------------------------------
echo                             ���� ISO ����
echo -------------------------------------------------------------------------------
echo.
if not exist "%files%\ISO" (
  echo ��⵽û��ISO���棬�����޷�����
  pause
  goto ;main
)
:;label
set /p label=�������꣨��Ϊȡ������
if "%label%"=="" goto ;main
:;isoname
set /p isoname=������ISO�ļ�������Ϊȡ������
if "%isoname%"=="" goto ;main
echo ���ڴ���ISO�ļ�...
"%bin%\%arch%\oscdimg.exe" -bootdata:2#p0,e,b"%files%\ISO\boot\etfsboot.com"#pEF,e,b"%files%\ISO\efi\Microsoft\boot\efisys_noprompt.bin" -o -m -u2 -udfver102 -t03/08/2025,15:20:00 -l"%label%" "%files%\ISO" "%isoname%.iso"
if exist "%~dp0\%isoname%.iso" echo ������ɣ�
if not exist "%~dp0\%isoname%.iso" echo ����ʧ�ܣ�
set "label="
set "isoname="
pause
goto ;main

:;tool
cls
echo -------------------------------------------------------------------------------
echo                                   ʵ�ù���
echo -------------------------------------------------------------------------------
echo.
echo 1.Rufus
echo 2.Ventoy
echo 3.GImageX
echo 4.����
set /p set=��ѡ��ѡ��������֣���
if "%set%"=="1" start %bin%\%arch%\rufus-4.6.exe"
if "%set%"=="2" start %bin%\Ventoy\Ventoy2Disk.exe"
if "%set%"=="3" start %bin%\%arch%\GImageX.exe"
if "%set%"=="4" goto ;main
goto ;tool

;exit
cls
echo WinPEOS ���ɹ������˳�
exit /b
