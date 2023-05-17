import 'dart:io';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PDFService {
  static Future<void> generatePDFForNutritionPlan(NutritionPlan nutritionPlan) async {
    const maxMealsPerPage = 2;
    final pdf = pw.Document();
    final meals = nutritionPlan.meals;

    for (var pageIndex = 0; pageIndex < meals.length; pageIndex += maxMealsPerPage) {
      final pageMeals = meals.skip(pageIndex).take(maxMealsPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'DietDesigner',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    formatDate(nutritionPlan.date),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 60),
              for (final meal in pageMeals) ...[
                pw.Text(
                  meal.title,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '${meal.calories.round()} kcal, ${meal.proteins.round()}g protein, ${meal.fats.round()}g fats, ${meal.carbs.round()}g carbohydrates',
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Ingredients:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  meal.ingredients!.map((ingredient) => '${ingredient['name']} (${ingredient['amount']} ${ingredient['unit']})').join(', '),
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Steps:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  meal.steps!.join(' '),
                  style: const pw.TextStyle(fontSize: 12),
                ),
                if (meal != pageMeals.last) pw.Divider(thickness: 1, height: 60, color: PdfColors.black),
              ],
            ],
          ),
        ),
      );
    }

    final outputDir = await getExternalStorageDirectory();
    if (outputDir == null) return;
    final outputFile = File('${outputDir.path}/nutrition_plan_${nutritionPlan.date}.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    await OpenFile.open(outputFile.path);
  }
}
