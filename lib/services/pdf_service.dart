import 'dart:io';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/services/firestore_service.dart';
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
                    'DietDesigner®',
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
    saveAndOpenFile(pdf, 'nutrition_plan_${formatDate(nutritionPlan.date)}');
  }

  static Future<void> generatePDFForShoppingList(String listName, String listId) async {
    final pdf = pw.Document();
    final products = await getShoppingListElements(listId);
    const productsPerPage = 60;

    for (var pageIndex = 0; pageIndex < products.length; pageIndex += productsPerPage) {
      final pageProducts = products.skip(pageIndex).take(productsPerPage).toList();
      final rows = <pw.Widget>[];

      for (var i = 0; i < pageProducts.length; i += 2) {
        final productRow = pw.Row(
          children: [
            _shoppingListItem(pageProducts, i),
          ],
        );
        if (i + 1 < pageProducts.length) {
          productRow.children.add(
            _shoppingListItem(pageProducts, i + 1),
          );
        }

        rows.add(productRow);
        rows.add(pw.SizedBox(height: 5));
      }

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
                    'DietDesigner®',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '$listName (${products.length} pcs.)',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.SizedBox(height: 5),
              pw.Column(
                children: rows,
              ),
            ],
          ),
        ),
      );
    }
    saveAndOpenFile(pdf, 'shopping_list_$listName');
  }

  static pw.Expanded _shoppingListItem(List<String> pageProducts, int i) {
    return pw.Expanded(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Container(
            width: 10,
            height: 10,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(width: 1),
                right: pw.BorderSide(width: 1),
                bottom: pw.BorderSide(width: 1),
                left: pw.BorderSide(width: 1),
              ),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            pageProducts[i],
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  static saveAndOpenFile(pdf, fileName) async {
    final outputDir = await getExternalStorageDirectory();
    if (outputDir == null) return;
    final outputFile = File('${outputDir.path}/$fileName.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    await OpenFile.open(outputFile.path);
  }
}
