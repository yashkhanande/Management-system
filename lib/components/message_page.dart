import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/controller/profile_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';

class MessagePage extends StatelessWidget {
  final String projectId = Get.arguments;
  final TextEditingController messageController = TextEditingController();
  final _taskController = Get.find<TaskController>();
  final _profileController = Get.find<ProfileController>();
  final ScrollController scrollController = ScrollController();

  Future<String> getProjectName() async {
    final Task task = await _taskController.getTaskById(projectId);
    return task.title;
  }

  @override
  Widget build(BuildContext context) {
    _taskController.fetchRemarks(projectId);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.scaffoldBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: getProjectName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(strokeWidth: 1, value: 0.0);
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            Text(
              "Team Messages",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// 💬 MESSAGE LIST
            Expanded(
              child: Obx(() {
                final remarks = _taskController.remarkList;

                if (remarks.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet 🚀",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(12),
                  itemCount: remarks.length,
                  itemBuilder: (context, index) {
                    final remark = remarks[index];

                    final isMe =
                        remark.senderId == _profileController.member.value!.id;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              remark.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${remark.senderName}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            /// ✍️ INPUT BAR (LIKE WHATSAPP)
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextfield(
                      label: "Message",
                      controller: messageController,
                      hint: "Type a message...",
                    ),
                  ),

                  SizedBox(width: 8),

                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (messageController.text.trim().isEmpty) return;

                        _taskController.addRemark(
                          _profileController.member.value!.id!,
                          projectId,
                          messageController.text.trim(),
                        );

                        messageController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
