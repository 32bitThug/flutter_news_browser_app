// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/rss_news/grpahql/graphql_requests.dart';
import 'package:flutter_browser/rss_news/models/device_model.dart';
import 'package:flutter_browser/rss_news/utils/show_snackbar.dart';

class RegisterDeviceWidget extends StatefulWidget {
  const RegisterDeviceWidget({super.key});

  @override
  State<RegisterDeviceWidget> createState() => _RegisterDeviceWidgetState();
}

class _RegisterDeviceWidgetState extends State<RegisterDeviceWidget> {
  Future<void> showAddingDilog() async {
    {
      String deviceName = "";
      // String? groupId;
      // String? profileId;
      TextEditingController deviceNameController =
          TextEditingController(text: deviceName);
      // TextEditingController groupIDController = TextEditingController();
      // TextEditingController profileIDController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Add your device"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                onChanged: (value) => deviceName = value,
                controller: deviceNameController,
                decoration: const InputDecoration(labelText: "Device Name"),
              ),
              // TextField(
              //   onChanged: (value) => groupId = value,
              //   controller: groupIDController,
              //   decoration: const InputDecoration(labelText: "Group ID"),
              // ),
              // TextField(
              //   onChanged: (value) => profileId = value,
              //   controller: profileIDController,
              //   decoration: const InputDecoration(labelText: "Profile ID"),
              // ),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Device device = Device(
                    deviceId: deviceId,
                    deviceName: deviceName,
                    // defulat ids
                    groupId: "67289da09753666bcf4cf78a",
                    profileId: "67289ee59753666bcf4cf7db",
                  );
                  final op = await GraphQLRequests().createDevice(device);

                  /// use this _id to perform update mutation
                  if (op != null) {
                    device.id = op["_id"];
                    await HiveDBHelper.createDevice(device);
                    debugPrint("///sdfdsfssdf/${HiveDBHelper.getDevice()}");
                  }
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              )
            ]),
      );
    }
  }

  void showEditDilog(Device device) async {
    final res = await GraphQLRequests().getDeviceById(device.id!);
    if (res != null) {
      String deviceName = device.deviceName;
      TextEditingController deviceNameController =
          TextEditingController(text: deviceName);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Edit Device Name"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              onChanged: (value) => deviceName = value,
              controller: deviceNameController,
              decoration: const InputDecoration(labelText: "Device Name"),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                device.deviceName = deviceName;
                await GraphQLRequests().updateDevice(device);
                await HiveDBHelper.updateDevice(deviceName);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        ),
      );
    } else {
      showSnackBar(message: "Device not rigistered");
    }
  }

  @override
  Widget build(BuildContext context) {
    Device? device = HiveDBHelper.getDevice();
    final flag = device == null;
    return Column(
      children: [
        ListTile(
          // dense: true,
          // contentPadding: EdgeInsets.z,
          title:
              Text(flag ? 'Register Your Device' : "Device Is Being monitored"),
          subtitle: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: deviceId));
            },
            child: Row(
              children: [
                Text(
                  'Your id $deviceId',
                ),
                SizedBox(
                  height: 25,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy Device ID',
                      // iconSize: 100,
                      // padding: EdgeInsets.all(10),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: deviceId));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          trailing: Wrap(
            spacing: 12,
            children: [
              if (flag)
                IconButton(
                    onPressed: showAddingDilog,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    )),
              if (!flag)
                IconButton(
                    onPressed: () => showEditDilog(device),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ))
            ],
          ),
        ),
      ],
    );
  }
}
