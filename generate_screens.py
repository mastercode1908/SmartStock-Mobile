import os

pickup_dir = r"lib\features\inventory\screens\pickup"
count_dir = r"lib\features\inventory\screens\count"

os.makedirs(pickup_dir, exist_ok=True)
os.makedirs(count_dir, exist_ok=True)

def write_screen(dir_path, file_name, class_name, title, next_file_name, next_class_name):
    is_last = not next_file_name
    nav = "Navigator.of(context).popUntil((route) => route.isFirst);" if is_last else f"Navigator.push(context, MaterialPageRoute(builder: (_) => const {next_class_name}()));"
    btn_text = "Hoàn thành" if is_last else "Tiếp tục"
    import_next = "" if is_last else f"import '{next_file_name}';"
    
    content = f"""import 'package:flutter/material.dart';
{import_next}

class {class_name} extends StatelessWidget {{
  const {class_name}({{Key? key}}) : super(key: key);

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{title}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('{title}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {{
                {nav}
              }},
              child: const Text('{btn_text}'),
            )
          ],
        ),
      ),
    );
  }}
}}
"""
    with open(os.path.join(dir_path, file_name), 'w', encoding='utf-8') as f:
        f.write(content)

# PickUp
write_screen(pickup_dir, 'pickup_list_screen.dart', 'PickUpListScreen', 'Danh sách Nhặt hàng', 'pickup_step1_screen.dart', 'PickUpStep1Screen')
write_screen(pickup_dir, 'pickup_step1_screen.dart', 'PickUpStep1Screen', 'Nhặt hàng - Bước 1', 'pickup_step2_screen.dart', 'PickUpStep2Screen')
write_screen(pickup_dir, 'pickup_step2_screen.dart', 'PickUpStep2Screen', 'Nhặt hàng - Bước 2', 'pickup_step3_screen.dart', 'PickUpStep3Screen')
write_screen(pickup_dir, 'pickup_step3_screen.dart', 'PickUpStep3Screen', 'Nhặt hàng - Bước 3', 'pickup_step4_screen.dart', 'PickUpStep4Screen')
write_screen(pickup_dir, 'pickup_step4_screen.dart', 'PickUpStep4Screen', 'Nhặt hàng - Bước 4', 'pickup_step5_screen.dart', 'PickUpStep5Screen')
write_screen(pickup_dir, 'pickup_step5_screen.dart', 'PickUpStep5Screen', 'Nhặt hàng - Bước 5', '', '')

# Count
write_screen(count_dir, 'count_list_screen.dart', 'CountListScreen', 'Danh sách Kiểm kê', 'count_step1_screen.dart', 'CountStep1Screen')
write_screen(count_dir, 'count_step1_screen.dart', 'CountStep1Screen', 'Kiểm kê - Bước 1', 'count_step2_screen.dart', 'CountStep2Screen')
write_screen(count_dir, 'count_step2_screen.dart', 'CountStep2Screen', 'Kiểm kê - Bước 2', 'count_step3_screen.dart', 'CountStep3Screen')
write_screen(count_dir, 'count_step3_screen.dart', 'CountStep3Screen', 'Kiểm kê - Bước 3', 'count_step4_screen.dart', 'CountStep4Screen')
write_screen(count_dir, 'count_step4_screen.dart', 'CountStep4Screen', 'Kiểm kê - Bước 4', 'count_step5_screen.dart', 'CountStep5Screen')
write_screen(count_dir, 'count_step5_screen.dart', 'CountStep5Screen', 'Kiểm kê - Bước 5', '', '')
