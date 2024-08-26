import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testimgly/permissionCheck.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'myprovider.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MyProvider>(create: (context) => MyProvider()),
        ],
        child: MaterialApp(
          title: 'Imgly Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Choose Your Video',
            ),
            Consumer<MyProvider>(
              builder: (context, value, child) {
                return Column(
                  children: [
                    Container(
                      height: ((MediaQuery.of(context).size.width - 30) - 40),
                      width: MediaQuery.of(context).size.width - 20,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text('尚未選擇影片')),
                    ),
                    value.waiting_upload_video != true
                        ? ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              showModalBottomSheet<void>(
                                  isScrollControlled: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                  ),
                                  builder: (BuildContext bottomsheet_context) {
                                    return Container(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      height: 50,
                                                      child: Center(
                                                          child: Text('打開相機')),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.of(
                                                              bottomsheet_context)
                                                          .pop();

                                                      bool result =
                                                          await permissionCheckAndRequest(
                                                              context,
                                                              Permission.camera,
                                                              "相機");
                                                      if (result) {
                                                        await value
                                                            .take_video_camara()
                                                            .then(
                                                                (load_video_value) async {
                                                          print(
                                                              '選到檔案回傳$load_video_value');
                                                          if (load_video_value ==
                                                              '超過') {
                                                            Future.delayed(
                                                                Duration(
                                                                    seconds: 1),
                                                                () async {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          '超過限制大小500MB請重新選取或拍攝'),
                                                                    );
                                                                  });
                                                            });
                                                          } else if (load_video_value ==
                                                              '成功選到') {
                                                            //進入美化
                                                            value
                                                                .upload_action_video2(
                                                                    2);
                                                          }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: Colors.grey,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      height: 50,
                                                      child: Center(
                                                          child:
                                                              Text('從相簿裡選擇')),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.of(
                                                              bottomsheet_context)
                                                          .pop();
                                                      if (Platform.isAndroid) {
                                                        DeviceInfoPlugin
                                                            deviceinfo =
                                                            DeviceInfoPlugin();
                                                        AndroidDeviceInfo
                                                            androidInfo =
                                                            await deviceinfo
                                                                .androidInfo;
                                                        if (androidInfo.version
                                                                .sdkInt <=
                                                            32) {
                                                          bool result =
                                                              await permissionCheckAndRequest(
                                                                  context,
                                                                  Permission
                                                                      .storage,
                                                                  "儲存空間");
                                                          if (result) {
                                                            await value
                                                                .load_video()
                                                                .then(
                                                                    (load_video_value) async {
                                                              print(
                                                                  '選到檔案回傳$load_video_value');
                                                              if (load_video_value ==
                                                                  '超過') {
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                    () async {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('超過限制大小500MB請重新選取或拍攝'),
                                                                        );
                                                                      });
                                                                });
                                                              } else if (load_video_value ==
                                                                  '成功選到') {
                                                                print(
                                                                    '成功選到檔案${value.waiting_download_music}');

                                                                //進入美化
                                                                value
                                                                    .upload_action_video2(
                                                                        1);
                                                              }
                                                            });
                                                          }
                                                        } else {
                                                          print('android 13');
                                                          await value
                                                              .load_video()
                                                              .then(
                                                                  (load_video_value) async {
                                                            print(
                                                                '選到檔案回傳$load_video_value');
                                                            if (load_video_value ==
                                                                '超過') {
                                                              Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                                  () async {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            '超過限制大小500MB請重新選取或拍攝'),
                                                                      );
                                                                    });
                                                              });
                                                            } else if (load_video_value ==
                                                                '成功選到') {
                                                              print(
                                                                  '成功選到檔案${value.waiting_download_music}');

                                                              //進入美化
                                                              value
                                                                  .upload_action_video2(
                                                                      1);
                                                            }
                                                          });
                                                        }
                                                      } else {
                                                        bool result =
                                                            await permissionCheckAndRequest(
                                                                context,
                                                                Permission
                                                                    .photos,
                                                                "相簿");
                                                        if (result) {
                                                          await value
                                                              .load_video()
                                                              .then(
                                                                  (load_video_value) async {
                                                            print(
                                                                '選到檔案回傳$load_video_value');
                                                            if (load_video_value ==
                                                                '超過') {
                                                              Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                                  () async {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            '超過限制大小500MB請重新選取或拍攝'),
                                                                      );
                                                                    });
                                                              });
                                                            } else if (load_video_value ==
                                                                '成功選到') {
                                                              print(
                                                                  '成功選到檔案${value.waiting_download_music}');

                                                              //進入美化
                                                              value
                                                                  .upload_action_video2(
                                                                      1);
                                                            }
                                                          });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: GestureDetector(
                                                child: Container(
                                                  height: 50,
                                                  child:
                                                      Center(child: Text('取消')),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Text('Choose Your Video'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                Text('正在上傳中，請稍候'),
                                Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            ),
                          ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
