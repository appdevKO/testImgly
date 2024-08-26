import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限检查及请求
///
/// 外部可通过此方法来进行权限的检查和请求，将自动跳转到`PermissionRequestPage`页面。
///
/// 传入 `Permission` 以及对应的权限名称 `permissionTypeStr`，如果有权限则返回 `Future true`
///
/// `isRequiredPermission` 如果为 `true`,则 "取消" 按钮将执行 "退出app" 的操作
Future<bool> permissionCheckAndRequest(
    BuildContext context, Permission permission, String permissionTypeStr,
    {bool isRequiredPermission = false}) async {
  // print('123123123ppppp');
  // print('123123123ppppp${await permission.status}');
  if (!await permission.status.isGranted) {
    if (Platform.isIOS && await permission.status.isLimited) {
      return true;
    }
    await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: ((context, animation, secondaryAnimation) {
          return PermissionRequestPage(permission, permissionTypeStr,
              isRequiredPermission: isRequiredPermission);
        })));
  } else {
    return true;
  }
  return false;
}

class PermissionRequestPage extends StatefulWidget {
  PermissionRequestPage(this.permission, this.permissionTypeStr,
      {this.isRequiredPermission = false});

  final Permission permission;
  final String permissionTypeStr;
  bool isRequiredPermission;

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage>
    with WidgetsBindingObserver {
  bool _isGoSetting = false;
  bool _isPermanentlyDenied = false;
  bool _isLimited = false;
  late final List<String> msgList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    msgList = [
      "${widget.permissionTypeStr}功能需要獲取您設備的${widget.permissionTypeStr}權限，否則可能無法正常工作。\n是否申請${widget.permissionTypeStr}權限？",
      "${widget.permissionTypeStr}權限不全，是否重新申請權限？",
      "没有${widget.permissionTypeStr}權限，您可以手動開啟權限",
      widget.isRequiredPermission ? "退出應用程式" : "取消"
    ];
    checkPermission(widget.permission);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 监听 app 从后台切回前台
    if (state == AppLifecycleState.resumed && _isGoSetting) {
      print('回前台');
      checkPermission(widget.permission);
    }
  }

  /// 校验权限
  void checkPermission(Permission permission) async {
    print('check permission');
    final status = await permission.status;

    if (status.isGranted) {
      print('甲1111');
      _popPage();
      setState(() {});
      return;
    }

    // 还未申请权限或之前拒绝了权限(在 iOS 上为首次申请权限，拒绝后将变为 `永久拒绝权限`)
    if (status.isDenied) {
      print('甲2222');
      _isGoSetting = true;
      if (Platform.isIOS) {
        print('ios');
        await permission.request();
      } else {
        await permission.request();
      }
    }
    // 权限已被永久拒绝
    if (status.isPermanentlyDenied) {
      print('甲3333');
      _isGoSetting = true;
      _isPermanentlyDenied = true;
      showAlert(
          permission, msgList[2], msgList[3], _isGoSetting ? "前往設定" : "確定");
    }
    // 拥有部分权限
    if (status.isLimited) {
      print('甲4444');
      _isLimited = true;
      if (Platform.isIOS || Platform.isMacOS) {
        _popPage();
        setState(() {});
        return;
      } else {
        showAlert(
            permission, msgList[1], msgList[3], _isGoSetting ? "前往設定" : "確定");
      }
    }
    // 拥有部分权限(仅限 iOS)
    if (status.isRestricted) {
      print('甲5555');
      if (Platform.isIOS || Platform.isMacOS) _isGoSetting = true;
      showAlert(
          permission, msgList[1], msgList[3], _isGoSetting ? "前往應用中心" : "確定");
    }
  }

  void showAlert(Permission permission, String message, String cancelMsg,
      String confirmMsg) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("提示"),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                  child: Text(cancelMsg),
                  onPressed: () {
                    // widget.isRequiredPermission
                    //     ? _quitApp()
                    //     :
                    _popDialogAndPage(context);
                  }),
              CupertinoDialogAction(
                  child: Text(confirmMsg),
                  onPressed: () {
                    if (Platform.isIOS) {
                      if (_isPermanentlyDenied || _isLimited) {
                        openAppSettings();
                        _isGoSetting = true;
                      } else {
                        requestPermisson(permission);
                      }
                    } else {
                      if (_isGoSetting) {
                        print('89999444');
                        openAppSettings();
                        _isGoSetting = true;
                      } else {
                        print('899995555');
                        requestPermisson(permission);
                      }
                    }
                    _popDialog(context);
                  })
            ],
          );
        });
  }

  /// 申请权限
  void requestPermisson(Permission permission) async {
    print('request $permission');
    // 申请权限
    await permission.request();
    // 再次校验
    checkPermission(permission);
  }

  // void requestPermisson2(Permission permission) async {
  //   print('request2 $permission');
  //   // 申请权限
  //   await permission.request();
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  /// 退出应用程序
  void _quitApp() {
    SystemChannels.platform.invokeMethod("SystemNavigator.pop");
  }

  /// 关闭整个权限申请页面
  void _popDialogAndPage(BuildContext dialogContext) {
    _popDialog(dialogContext);
    _popPage();
  }

  /// 关闭弹窗
  void _popDialog(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
  }

  /// 关闭透明页面
  void _popPage() {
    Navigator.of(context).pop();
  }
}
