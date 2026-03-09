import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'dart:math' as math;
// import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';

class AdminDashboard extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = TaskController().tasks;
    final statusData = <_StatusData>[
      const _StatusData(label: 'Done', count: 8, color: Colors.green),
      const _StatusData(
        label: 'Not Started',
        count: 6,
        color: Color(0xFFD3D3D3),
      ),
      const _StatusData(label: 'In Progress', count: 5, color: Colors.blue),
      const _StatusData(label: 'Review', count: 3, color: Colors.orange),
    ];
    final totalStatusCount = statusData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color.fromARGB(223, 57, 27, 255),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 220,
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(223, 57, 27, 255),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "Manthan Agrawal",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              "Sunday, 22 Jan 2026",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            authController.logout();
                          },
                          icon: Icon(Icons.logout, color: Colors.white),
                        ),
                      ],
                    ),

                    Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 135, 111, 231),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Text(
                              "Stats 2",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 135, 111, 231),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Text(
                              "Stats 2",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 135, 111, 231),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Text(
                              "Stats 3",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 135, 111, 231),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Text(
                              "Stats 4",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //Task overview
              Padding(
                padding: EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Task Overview",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Analytics",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 170,
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: CustomPaint(
                                      painter: _DonutChartPainter(statusData),
                                      child: Center(
                                        child: Text(
                                          '$totalStatusCount\nTasks',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: statusData
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: item.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${item.label}: ${item.count}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // if (tasks.isEmpty)
                        //   const Text("No tasks available")
                        // else
                        //   Column(
                        //     children: tasks
                        //         .take(3)
                        //         .map(
                        //           (task) => Card(
                        //             margin: const EdgeInsets.only(bottom: 8),
                        //             child: ListTile(
                        //               dense: true,
                        //               title: Text(task.title),
                        //               subtitle: Text(task.priority),
                        //             ),
                        //           ),
                        //         )
                        //         .toList(),
                        //   ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      "All Tasks",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text("See all"),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
              ProjectCard(title: "Project 1"),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      "Upcoming Deadlines",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text("See all"),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusData {
  final String label;
  final int count;
  final Color color;

  const _StatusData({
    required this.label,
    required this.count,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_StatusData> segments;

  _DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, item) => sum + item.count);
    if (total == 0) return;

    final strokeWidth = size.width * 0.20;
    final radius = (math.min(size.width, size.height) / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle = (segment.count / total) * (2 * math.pi);
      paint.color = segment.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
