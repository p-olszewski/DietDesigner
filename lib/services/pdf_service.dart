import 'dart:io';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PDFService {
  static Future<void> generatePDFForNutritionPlan(NutritionPlan nutritionPlan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(nutritionPlan.date, style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Meals:', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            for (final meal in nutritionPlan.meals) pw.Text('- ${meal.title}', style: const pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    final outputDir = await getExternalStorageDirectory();
    if (outputDir == null) return;
    final outputFile = File('${outputDir.path}/nutrition_plan.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    await OpenFile.open(outputFile.path);
  }
}
