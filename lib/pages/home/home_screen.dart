import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';


// Controller: Handles the counter logic
class CounterController extends GetxController {
  var count = 0.obs; // "obs" makes the variable observable (reactive)

  void increment() {
    count++; // Increases the count
  }
}


class CounterScreen extends StatelessWidget {
  CounterScreen({super.key});

  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetX Counter Example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Obx(() => Text(
                  'Count: ${controller.count}',
                  style: const TextStyle(fontSize: 24),
                )),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.second),
              child: const Text('Go to Second Screen'),
            ),

          ],

        ),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),

    );
  }
}