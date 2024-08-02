import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.Document> generatePdf(List<Map<String, dynamic>> students) async {
  final pdf = pw.Document();
  final date = DateTime.now();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Asistencia - ${date.toLocal()}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              data: [
                ['Nombre', 'Apellidos'],
                ...students.map(
                    (student) => [student['first_name'], student['last_name']])
              ],
            ),
          ],
        );
      },
    ),
  );

  return pdf;
}
