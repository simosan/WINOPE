#/*
#The MIT License (MIT)
#
#Copyright (c) 2020 m.simosan.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#*/

# (注意1) 本AP実行元はWindowsのみに対応
# (注意2) 読み込ませるyamlについてOperationに記載する各コマンドは冪等性を担保できるコマンドを利用すること。上書きオプションとか
# (注意3) yamlでは、以下オペレーションに対応。
#           localope（ローカルWindowsコマンド実行）
#           remoteope（リモートWindowsコマンド実行）
#           psdscope（PowershellDSC実行）
# (注意4) yaml内の環境変数(_${XXX})をOSに設定した環境変数に置換可能。置換したい場合はOSの環境変数を事前に設定しておくこと。
#        $_{HOGE}というyaml環境変数はpowershellでは$env:HOGE="AAA"，DOSではset HOGE="AAA"
#        といった具合に事前設定しておくと，passwd等をベタ書きにしなくてよい。
#        _${XXX}のXXXはa-zA-Z0-9内の文字にすること。特殊文字,2バイト文字はNG
# (注意5) yamlに設定する環境変数(_${XXX})にパスワードを仕込む場合は，必ず，$_{~PASSWD}という形式にすること。
#        この形式に沿わないと，実行時コマンドの標準出力にパスワードが表示されてしまう（マスキングされない）。
# (注意6) yamlのxxopeのエラーハンドリングは標準エラー出力でみている。途中で処理を停止したい場合は標準エラー出力をだすこと。
#        リターンコードは見ていないので注意すること。
#        標準エラー出力はでてしまうが，処理を継続したい場合はWINOPE.pyと同一階層にERREXCEPTLIST.confを配置し，
#        インラインでエラー出力メッセージ（部分一致可）を定義しておけば，処理が途中で落ちることはない。
# (注意7) yamlのhostnameに複数ホスト指定可能。カンマで区切る。
# (注意8）各オペレーションでConParmの指定方法が違う。
#         localope  hostnameだけ。適当にlocalhostとか指定しておけばよい。
#         remoteope hostname(必須,複数指定可),userid(任意),passwd(任意)。useridとpasswdを省略すると実行元アカウント権限で実行
#         psdscope  hostname(必須,1ホストのみ),userid(任意),passwd(任意)。useridとpasswdを省略するとLocalSystemで実行
# (注意9) EC2の初期パスワードを取得する場合，passwdパラメータの書式は"EC2INITPASSWD|_${各ホスト名環境変数}"とすること。
#        AWSコンソールからパスワードを自動取得し，一時ファイルに出力。そのファイルを読込む処理。
#        要は，_${WORKDIR}\_${ホスト名環境変数}_tmpps.txtを読み込みたいという意味.
# (注意10) PowershellDSCを使う場合，リソースファイル(mof生成用ps1)で指定するノード名とyamlに指定するhostnameは一致させること。
#         一方がホスト名で片方がIPアドレスだと処理が異常終了する。
# (注意11) 本ツールからPowershelDSCを操作する場合、本ツールの仕様上、PowershellDSCのリソースファイルに指定するNodeは
#         "$env:TARGETHOSTNAME"とする必要がある。"TARGETHOSTNAME"にhostnameの値を代入する。
# (注意12) PowershellDSCを使う場合(psdscope)、yamlのhostnameは(注意10)の理由から１ホストに限定すること。
# (注意13) EC2初期パスワードをAWSコンソールから自動取得可能とするため取得した一時パスワードはWORKDIRに一時的に保存する。
#         そのパスワードを使いログインし任意のパスワードに変更するため、passwdは"EC2INITPASSWD|_${対象ホスト名変数}"と定義すること。
import sys
import yaml
import os
import re
import subprocess
import ctypes


# ターミナルに出力するクラス（OSプラットフォーム判定処理を元に緑 or 赤処理を定義）


class Termout:

    # グリーンメッセージ用
    @staticmethod
    def greenmsgout(msg):
        # 色つけのためにWindows APIハンドルの設定いろいろ
        STD_OUTPUT_HANDLE = -11
        FOREGROUND_GREEN = 0x0002 | 0x0008  # 緑色/背景黒
        # ターミナル色付け用のハンドル取得
        handle = ctypes.windll.kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
        reset = Termout.get_csbi_attributes(handle)
        # メッセージを緑
        ctypes.windll.kernel32.SetConsoleTextAttribute(handle, FOREGROUND_GREEN)
        print(msg)
        # 色をもとに戻す
        ctypes.windll.kernel32.SetConsoleTextAttribute(handle, reset)

    # エラーメッセージ用
    @staticmethod
    def errmsgout(msg):
        # 色つけのためにWindows APIハンドルの設定いろいろ
        STD_OUTPUT_HANDLE = -11
        FOREGROUND_RED = 0x0004 | 0x0008  # 赤色/背景黒
        # ターミナル色付け用のハンドル取得
        handle = ctypes.windll.kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
        reset = Termout.get_csbi_attributes(handle)
        # エラーメッセージを赤
        ctypes.windll.kernel32.SetConsoleTextAttribute(handle, FOREGROUND_RED)
        print(msg)
        # 色をもとに戻す
        ctypes.windll.kernel32.SetConsoleTextAttribute(handle, reset)
    
    # ターミナルバッファクリア（色戻す）
    @staticmethod
    def get_csbi_attributes(handle):
        import struct
        csbi = ctypes.create_string_buffer(22)
        res = ctypes.windll.kernel32.GetConsoleScreenBufferInfo(handle, csbi)
        assert res

        (bufx, bufy, curx, cury, wattr,
         left, top, right, bottom, maxx, maxy) = struct.unpack("hhhhHhhhhhh",
                                                               csbi.raw)
        return wattr


# 標準エラー出力エラーリスト格納オブジェクト


class ErrList:

    def __init__(self):
        # 本APと同一階層に標準エラー出力除外リスト（ERREXCEPTLIST.CONF）があれば読み込む
        try:
            with open(os.path.join(os.path.abspath(os.path.dirname(__file__)),
                      "ERREXCEPTLIST.conf"),
                      encoding="utf-8") as efile:
                elist = [str.replace("\n", "") for str in list(efile)]
                self.__errlst = elist
        except FileNotFoundError:
            print("ERREXCEPTLIST.CONFが存在しないため除外処理は行いません")

    @property
    def errlst(self):
        return self.__errlst

    @errlst.setter
    def errlst(self, lst):
        self.__errlst = lst

# 共通処理クラス


class CommonCls:

    # yamlの環境変数を展開(_${XXX}のXXXを展開)
    @staticmethod
    def envvarexpansion(var):
        # _${XXXXXX}はマスキングのため即リターン
        if var == '_${XXXXXX}':
            return var
        # 先頭が_$か本yamlの仕様どおり$_かチェック
        if var[0:2] == "_$":
            # 正規表現で環境変数文字列（_${XXX}）を抽出
            pattern = '_\${?(.*)}'
            result = re.match(pattern, var)
            if result:
                envstr = result.group(1)
                # OS環境変数を取得
                # import pdb; pdb.set_trace()
                try:
                    varrtn = os.environ[envstr]
                except KeyError:
                    Termout.errmsgout(var + "の値が設定されていません")
                    sys.exit(255)
            else:
                Termout.errmsgout("環境変数の設定ルールに誤りがあります（正：_${XXX})")
                sys.exit(255)
        else:
            Termout.errmsgout("環境変数の設定ルールに誤りがあります（正：_${XXX})")
            sys.exit(255)
        return varrtn

    # ope内の環境変数（_${XXX}）を値に置換
    @staticmethod
    def replacevar(opestr):
        # 正規表現で環境変数文字列（_${XXX}）を抽出
        pattern = '(_\${[a-zA-Z0-9]+})'
        result = re.findall(pattern, opestr)
        # マッチした環境変数のリストをenvvarexpansionで値取得
        # import pdb;pdb.set_trace()
        replaceopestr = opestr
        for i in result:
            tmpvar = CommonCls.envvarexpansion(i)
            replaceopestr = replaceopestr.replace(i, tmpvar)
        return replaceopestr

    # ope内のコマンドを標準出力（環境変数も展開）
    # ope内の環境変数にPASSWDが含まれていたら，XXXXXXでマスキングして標準出力
    @staticmethod
    def opeprint(opestr):
        #import pdb;pdb.set_trace()
        # 正規表現で環境変数文字列にPASSWD(で終わる）が含まれているかを抽出(例)_${XXXPASSWD})
        patternpass = '.*_\$\{?(.*PASSWD)}'
        resultpass = re.findall(patternpass, opestr)
        replaceopepassstr = opestr
        # PASSWDが含まれていたらXXXXXXで置換
        for i in resultpass:
            replaceopepassstr = replaceopepassstr.replace(i, "XXXXXX")
        # 正規表現で環境変数文字列（_${XXX}）を抽出
        pattern = '(_\${[a-zA-Z0-9]+})'
        result = re.findall(pattern, replaceopepassstr)
        # マッチした環境変数のリストをenvvarexpansionで値取得
        replaceopestr = replaceopepassstr
        for i in result:
            tmpvar = CommonCls.envvarexpansion(i)
            replaceopestr = replaceopestr.replace(i, tmpvar)

        print(replaceopestr)

    # EC2初期化パスワードが格納された一時ファイルを読み込む
    @staticmethod
    def getinitpasswd(strline):
        v = CommonCls.replacevar(strline.split('|')[1])
        # WORKDIRのパスを環境変数から取得
        try:
            workdir = os.environ['WORKDIR']
        except KeyError:
            Termout.errmsgout("WORKDIRの環境変数値が設定されていません")
            sys.exit(255)

        pspath = workdir + '\\' + v + '_tmpps.txt'
        try:
            with open(pspath, encoding='utf-16') as lines:
                for line in lines:
                    pstext = line.rstrip('\r\n')
        except IOError:
            Termout.errmsgout(pspath + "が存在しません")
            sys.exit(255)
        return pstext


# Windowsターミナルコマンド（ローカル or リモート）実行クラス
# yamlのTargetCon毎にインスタンスが生成される。

class WinCommandExec:

    def __init__(self, hostdt, hstnm):
        # 初期化
        self.h = ""
        self.u = ""
        self.p = ""

        for idx in hostdt:
            for k, v in idx.items():
                if k == 'hostname':
                    self.h = hstnm
                elif k == 'userid':
                    self.u = v
                elif k == 'passwd':
                    # EC2の初期化パスワードフラグの場合
                    if 'EC2INITPASSWD' in v:
                        self.p = CommonCls.getinitpasswd(v)
                    else:
                        self.p = CommonCls.envvarexpansion(v)

    # TargetConのOperationを処理
    def serverope(self, oped):

        rtn = ''
        for idx in oped:
            # k=localope or remoteope or psdscope，v=操作
            # for~elseのelseはループが終了したら処理（上位のループに戻るという意味）
            # 当該ループでbreakが実行されたら，elseはスキップ。
            # つまり，エラーが発生したら，全ループから一気に抜ける。
            for k, v in idx.items():
                # import pdb; pdb.set_trace()
                # keyがope:じゃなかったらエラーでブレイク
                # ope内のコマンドを実際のコマンド文字列として表示（passwdはマスキング）
                CommonCls.opeprint(v)
                # ope内に環境変数があるかをチェック,あれば値に置換したopeに変更
                v = CommonCls.replacevar(v)
                if k == "localope":
                    self.localexec(v)
                    rtn = True
                elif k == "remoteope":
                    self.remoteexec(v)
                    rtn = True
                elif k == "psdscope":
                    self.dscexec(v)
                    rtn = True
                else:
                    Termout.errmsgout('指定不可能なope文字列を使用しています k=' + k)
                    rtn = False
                    break
            else:
                continue
            break

        return rtn

    def localexec(self, cmdline):
        # コマンド実行
        self.doscmd(cmdline)

    def remoteexec(self, rmtcmdline):
        # Windowsリモートコマンド（Powershellコマンドレット）
        # useridとpasswdが設定されていればPowershellにcredentialを設定
        if len(self.u) != 0:
            if len(self.p) == 0:
                Termout.errmsgout('useridが設定されている場合はpasswdは空にできません!')
                sys.exit(255)
            pscmd = 'powershell -c "$pass=ConvertTo-SecureString -AsPlainText \'' + self.p + '\' -Force;' + \
                    '$credential=New-Object System.Management.Automation.PSCredential \'' + self.u + '\', $pass;' + \
                    'Invoke-Command -ComputerName ' + self.h + ' -Credential $credential ' + \
                    ' -ScriptBlock {' + rmtcmdline + '}"'
        else:
            pscmd = 'powershell -c "Invoke-Command -ComputerName ' + self.h + \
                ' -ScriptBlock {' + rmtcmdline + '}"'
        # コマンド実行
        self.doscmd(pscmd)

    def dscexec(self, bldcmd):

        # コンフィグレーションをビルド（コンフィグレーションファイルのnodeにhostname変数を渡す）
        dsccmd = 'powershell -c "$env:TARGETHOSTNAME=\'' +  self.h + '\';' + bldcmd + ";\""
        self.doscmd(dsccmd)

        if len(self.u) != 0:
            if len(self.p) == 0:
                Termout.errmsgout('useridが設定されている場合はpasswdは空にできません!')
                sys.exit(255)
            # PoweshellDSCをリモートホストにPUSH
            # userid,passwd指定の場合
            pushdsccmd = 'powershell -c "$pass=ConvertTo-SecureString \'' + self.p + '\' -AsPlainText -Force;' + \
                         '$credential=New-Object System.Management.Automation.PSCredential \'' + self.u + '\', $pass;' + \
                         '$cimsession=New-CimSession -ComputerName ' + self.h + ' -Credential $credential;' + \
                         'Start-DscConfiguration -Wait -Verbose -Path ' + bldcmd + ' -Force -CimSession $cimsession;'
        else:
            # PoweshellDSCをリモートホストにPUSH
            # localsystemで実行する場合
            pushdsccmd = 'powershell -c "Start-DscConfiguration -Wait -Verbose' + \
                ' -Path ' + bldcmd + ' -Force"'

        self.doscmd(pushdsccmd)

    def doscmd(self, cmdline):
        try:
            # コマンドの標準出力 Or 標準エラー出力を捕捉
            child = subprocess.Popen(cmdline, shell=True,
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdout, stderr = child.communicate()
            if self.stderrchk(stderr) is True:
                Termout.errmsgout('Cmdline Error!')
                sys.exit(255)

            self.stdoutread(stdout)

        except subprocess.SubprocessError as e:
            Termout.errmsgout('CommandException Error!')
            Termout.errmsgout(str(e))
            sys.exit(255)

    # 標準エラー出力のバッファが空かどうかチェック,空でなければエラーとして即リターン
    def stderrchk(self, err):
        # 標準エラー出力除外リストのチェック
        oErr = ErrList()
        flg = "nohit"
        # エラーリストが空であれば、プロパティ属性（_ErrList__errlst）は空でFalse
        if hasattr(oErr, '_ErrList__errlst'):
            for ls in oErr.errlst:
                # 除外リストに該当しているかチェック
                if ls in err.decode('shift_jis'):
                    flg = "hit"
        # エラーバッファが存在し，除外リストにない場合はエラー
        if len(err) > 0 and flg == "nohit":
            Termout.errmsgout(err.decode('shift_jis'))
            return True
        else:
            # 除外エラーでも一応プリント
            print(err.decode('shift_jis'))
            return False

    # 標準出力をバッファから取り出しコンソール出力
    def stdoutread(self, out):
        print(out.decode('shift_jis'))


if __name__ == '__main__':

    args = sys.argv
    if 2 != len(args):
        Termout.errmsgout("引数エラー: python スクリプト yamlパス")
        sys.exit(255)

    # yaml(定義)を読み込む
    with open(args[1], encoding="utf-8") as file:
        data = yaml.load(file, Loader=yaml.SafeLoader)
        for indx, val in enumerate(data):
            TRGT = 'TargetCon' + str(indx+1)
            # ConnParm-hostname複数指定があればループ
            hostlist = data[TRGT]['ConnParm'][0].get("hostname").split(',')
            for host in hostlist:
                Termout.greenmsgout("=" * 8 + TRGT + "-" + host + "=" * 8)
                objWin = WinCommandExec(data[TRGT]['ConnParm'], host)
                rtn = objWin.serverope(data[TRGT]['Operation'])
                if rtn is False:
                    Termout.errmsgout("serverope Error!")
                    sys.exit(255)
    Termout.greenmsgout("処理が完了しました")
