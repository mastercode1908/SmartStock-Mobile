import 'dart:io';

void main() {
  final pickupDir = Directory('lib/features/inventory/screens/pickup');
  pickupDir.createSync(recursive: true);
  
  final countDir = Directory('lib/features/inventory/screens/count');
  countDir.createSync(recursive: true);

  void writeScreen(String dir, String fileName, String className, String title, String nextFileName, String nextClassName) {
    bool isLast = nextFileName.isEmpty;
    String nav = isLast ? "Navigator.of(context).popUntil((route) => route.isFirst);" : "Navigator.push(context, MaterialPageRoute(builder: (_) => const \$nextClassName()));";
    String btnText = isLast ? "Hoàn thành" : "Tiếp tục";
    String importNext = isLast ? "" : "import '\$nextFileName';";
    
    String content = '''
import 'package:flutter/material.dart';
\$importNext

class \$className extends StatelessWidget {
  const \$className({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\$title')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('\$title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                \$nav
              },
              child: const Text('\$btnText'),
            )
          ],
        ),
      ),
    );
  }
}
'''.replaceAll('\\\$', '\$');
    File('\${dir}/\$fileName').writeAsStringSync(content);
  }

  // PickUp Flow
  writeScreen(pickupDir.path, 'pickup_list_screen.dart', 'PickUpListScreen', 'Danh sách Nhặt hàng', 'pickup_step1_screen.dart', 'PickUpStep1Screen');
  writeScreen(pickupDir.path, 'pickup_step1_screen.dart', 'PickUpStep1Screen', 'Nhặt hàng - Bước 1', 'pickup_step2_screen.dart', 'PickUpStep2Screen');
  writeScreen(pickupDir.path, 'pickup_step2_screen.dart', 'PickUpStep2Screen', 'Nhặt hàng - Bước 2', 'pickup_step3_screen.dart', 'PickUpStep3Screen');
  writeScreen(pickupDir.path, 'pickup_step3_screen.dart', 'PickUpStep3Screen', 'Nhặt hàng - Bước 3', 'pickup_step4_screen.dart', 'PickUpStep4Screen');
  writeScreen(pickupDir.path, 'pickup_step4_screen.dart', 'PickUpStep4Screen', 'Nhặt hàng - Bước 4', 'pickup_step5_screen.dart', 'PickUpStep5Screen');
  writeScreen(pickupDir.path, 'pickup_step5_screen.dart', 'PickUpStep5Screen', 'Nhặt hàng - Bước 5', '', '');

  // Count Flow
  writeScreen(countDir.path, 'count_list_screen.dart', 'CountListScreen', 'Danh sách Kiểm kê', 'count_step1_screen.dart', 'CountStep1Screen');
  writeScreen(countDir.path, 'count_step1_screen.dart', 'CountStep1Screen', 'Kiểm kê - Bước 1', 'count_step2_screen.dart', 'CountStep2Screen');
  writeScreen(countDir.path, 'count_step2_screen.dart', 'CountStep2Screen', 'Kiểm kê - Bước 2', 'count_step3_screen.dart', 'CountStep3Screen');
  writeScreen(countDir.path, 'count_step3_screen.dart', 'CountStep3Screen', 'Kiểm kê - Bước 3', 'count_step4_screen.dart', 'CountStep4Screen');
  writeScreen(countDir.path, 'count_step4_screen.dart', 'CountStep4Screen', 'Kiểm kê - Bước 4', 'count_step5_screen.dart', 'CountStep5Screen');
  writeScreen(countDir.path, 'count_step5_screen.dart', 'CountStep5Screen', 'Kiểm kê - Bước 5', '', '');
}
