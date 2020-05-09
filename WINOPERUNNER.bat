@echo off

set ROOTEXEDIR=%~dp0
 
:TOP
 
echo *****************************************************************
echo * yamlファイルの実行開始ポイントを指定値(x-x)で選択
echo *                                                              
echo *   1-1: 1-1_AMIToEC2Make.yaml
echo *   1-2: 1-2_EC2GetAdminInitPass.yaml
echo *   1-3: 1-3_EC2AdminInitPassChg.yaml
echo *   1-4: 1-4_ServerInitSettings.yaml
echo *   1-5: 1-5_DomainJoin.yaml
echo *   2-1: 2-1_GetMaterial.yaml
echo *   2-2: 2-2_AddVolume.yaml
echo *   2-3: 2-3_AttachVolume.yaml
echo *   2-4: 2-4_AddDirectory.yaml
echo *   2-5: 2-5_ModDirectoryACL.yaml
echo *   2-6: 2-6_AddWindowsFWRule.yaml
echo *   2-7: 2-7_MemoryRelatedSettings.yaml
echo *   3-1: 3-1_Install_IIS.yaml
echo *   3-2: 3-2_Install_MSI_WindowsBeat.yaml
echo *   4-1-1: 4-1-1_Prepare_Download_OracleDatabase19c.yaml
echo *   4-1-2: 4-1-2_Prepare_Expand_OracleDatabase19c.yaml
echo *   4-2: 4-2_Setup_ENV_OracleDatabase19c.yaml
echo *   4-3: 4-3_Install_OracleDatabase19c.yaml
echo *   4-4: 4-4_Make_Instance_OracleDatabase19c.yaml
echo *   4-5: 4-5_Make_Listener_OracleDatabase19c.yaml
echo *   99-1: 99-1_EC2Del.yaml
echo *   0:終了
echo *                                                              
echo *****************************************************************
 
:MENUSTART

set USR_INPUT_STR=
set /P USR_INPUT_STR="番号を入力してください: "
 
if %USR_INPUT_STR%==1-1 (
  goto 1-1_AMIToEC2Make
) else if %USR_INPUT_STR%==1-2 (
  goto 1-2_EC2GetAdminInitPass
) else if %USR_INPUT_STR%==1-3 (
  goto 1-3_EC2AdminInitPassChg
) else if %USR_INPUT_STR%==1-4 (
  goto 1-4_ServerInitSettings
) else if %USR_INPUT_STR%==1-5 (
  goto 1-5_DomainJoin 
) else if %USR_INPUT_STR%==2-1 (
  goto 2-1_GetMaterial
) else if %USR_INPUT_STR%==2-2 (
  goto 2-2_AddVolume 
) else if %USR_INPUT_STR%==2-3 (
  goto 2-3_AttachVolume
) else if %USR_INPUT_STR%==2-4 (
  goto 2-4_AddDirectory
) else if %USR_INPUT_STR%==2-5 (
  goto 2-5_ModDirectoryACL
) else if %USR_INPUT_STR%==2-6 (
  goto 2-6_AddWindowsFWRule 
) else if %USR_INPUT_STR%==2-7 (
  goto 2-7_MemoryRelatedSettings 
) else if %USR_INPUT_STR%==3-1 (
  goto 3-1_Install_IIS 
) else if %USR_INPUT_STR%==3-2 (
  goto 3-2_Install_MSI_WindowsBeat 
) else if %USR_INPUT_STR%==4-1-1 (
  goto 4-1-1_Prepare_Download_OracleDatabase19c
) else if %USR_INPUT_STR%==4-1-2 (
  goto 4-1-2_Prepare_Expand_OracleDatabase19c 
) else if %USR_INPUT_STR%==4-2 (
  goto 4-2_Setup_ENV_OracleDatabase19c 
) else if %USR_INPUT_STR%==4-3 (
  goto 4-3_Install_OracleDatabase19c 
) else if %USR_INPUT_STR%==4-4 (
  goto 4-4_Make_Instance_OracleDatabase19c 
) else if %USR_INPUT_STR%==4-5 (
  goto 4-5_Make_Listener_OracleDatabase19c 
) else if %USR_INPUT_STR%==99-1 (
  goto 99-1_EC2Del
) else if %USR_INPUT_STR%==0 (
  goto EXITTRAP
) else (
  echo メニューにその番号はありません。
  echo.
  goto MENUSTART
)

:1-1_AMIToEC2Make
echo 1-1_AMIToEC2Make Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\1-1_AMIToEC2Make.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 1-2_EC2GetAdminInitPass
 
:1-2_EC2GetAdminInitPass
echo 1-2_EC2GetAdminInitPass Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\1-2_EC2GetAdminInitPass.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 1-3_EC2AdminInitPassChg
 
:1-3_EC2AdminInitPassChg
echo 1-3_EC2AdminInitPassChg Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\1-3_EC2AdminInitPassChg.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 1-4_ServerInitSettings
 
:1-4_ServerInitSettings
echo 1-4_ServerInitSettings Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\1-4_ServerInitSettings.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 1-5_DomainJoin
 
:1-5_DomainJoin
echo 1-5_DomainJoin Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\1-5_DomainJoin.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-1_GetMaterial
 
:2-1_GetMaterial
echo 2-1_GetMaterial Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-1_GetMaterial.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-2_AddVolume
 
:2-2_AddVolume
echo 2-2_AddVolume Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-2_AddVolume.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-3_AttachVolume
 
:2-3_AttachVolume
echo 2-3_AttachVolume Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-3_AttachVolume.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-4_AddDirectory
 
:2-4_AddDirectory
echo 2-4_AddDirectory Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-4_AddDirectory.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-5_ModDirectoryACL

:2-5_ModDirectoryACL
echo 2-5_ModDirectoryACL Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-5_ModDirectoryACL.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-6_AddWindowsFWRule

:2-6_AddWindowsFWRule
echo 2-6_AddWindowsFWRule Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-6_AddWindowsFWRule.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 2-7_MemoryRelatedSettings 

:2-7_MemoryRelatedSettings
echo 2-7_MemoryRelatedSettings Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\2-7_MemoryRelatedSettings.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 3-1_Install_IIS

:3-1_Install_IIS
echo 3-1_Install_IIS Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\3-1_Install_IIS.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 3-2_Install_MSI_WindowsBeat

:3-2_Install_MSI_WindowsBeat
echo 3-2_Install_MSI_WindowsBeat Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\3-2_Install_MSI_WindowsBeat.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 4-1-1_Prepare_Download_OracleDatabase19c

:4-1-1_Prepare_Download_OracleDatabase19c
echo 4-1-1_Prepare_Download_OracleDatabase19c Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\4-1-1_Prepare_Download_OracleDatabase19c.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 4-1-2_Prepare_Expand_OracleDatabase19c

:4-1-2_Prepare_Expand_OracleDatabase19c
echo 4-1-2_Prepare_Expand_OracleDatabase19c Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\4-1-2_Prepare_Expand_OracleDatabase19c.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 4-2_Setup_ENV_OracleDatabase19c

:4-2_Setup_ENV_OracleDatabase19c
echo 4-2_Setup_ENV_OracleDatabase19c Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\4-2_Setup_ENV_OracleDatabase19c.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 4-3_Install_OracleDatabase19c

:4-3_Install_OracleDatabase19c
echo 4-3_Install_OracleDatabase19c Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\4-3_Install_OracleDatabase19c.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 4-4_Make_Instance_OracleDatabase19c

:4-4_Make_Instance_OracleDatabase19c
echo 4-4_Make_Instance_OracleDatabase19c Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\4-4_Make_Instance_OracleDatabase19c.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto 4-5_Make_Listener_OracleDatabase19c

:4-5_Make_Listener_OracleDatabase19c
echo 4-5_Make_Listener_OracleDatabase19c Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\4-5_Make_Listener_OracleDatabase19c.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto EXITTRAP

:99-1_EC2Del
echo 99-1_EC2Del Start!
python %ROOTEXEDIR%\WINOPE.py %ROOTEXEDIR%\yaml_webdbsampl\99-1_EC2Del.yaml
if %ERRORLEVEL% == 255 exit /B 255
goto EXITTRAP

:EXITTRAP
echo.
echo 終了します。
pause