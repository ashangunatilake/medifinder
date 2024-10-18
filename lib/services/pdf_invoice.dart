import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../models/invoice_model.dart';
import '../strings.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;

Future<String> getAddressFromCoordinates(double latitude, double longitude, String apiKey) async {
  String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        String formattedAddress = data['results'][0]['formatted_address'];
        print('Formatted Address: $formattedAddress');
        return formattedAddress;
      } else {
        print('No results found');
        throw Exception();
      }
    } else {
      print('Error: ${response.statusCode}');
      throw Exception();
    }
  } catch (e) {
    return 'Error fetching address: $e';
  }
}

class PdfInvoiceApi {
  static Future<File> generateDeliverPdf(Invoice invoice, LatLng pharmacyLocation, LatLng customerLocation, double distance) async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final pharmacyAddress = await getAddressFromCoordinates(pharmacyLocation.latitude, pharmacyLocation.longitude, apiKey);
    final customerAddress = await getAddressFromCoordinates(customerLocation.latitude, customerLocation.longitude, apiKey);

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        buildDeliverHeader(invoice, pharmacyAddress, customerAddress, fontBold, fontRegular),
        pw.SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice, fontBold, fontRegular),
        buildInvoice(invoice, fontRegular, fontBold),
        pw.Divider(),
        buildDeliverTotal(invoice, fontBold, distance),
      ],
      footer: (context) => buildFooter(invoice, pharmacyAddress, fontRegular, fontBold),
    ));

    return saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static Future<File> generateNonDeliverPdf(Invoice invoice, LatLng pharmacyLocation) async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final pharmacyAddress = await getAddressFromCoordinates(pharmacyLocation.latitude, pharmacyLocation.longitude, apiKey);

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        buildNonDeliverHeader(invoice, pharmacyAddress, fontBold, fontRegular),
        pw.SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice, fontBold, fontRegular),
        buildInvoice(invoice, fontRegular, fontBold),
        pw.Divider(),
        buildNonDeliverTotal(invoice, fontBold),
      ],
      footer: (context) => buildFooter(invoice, pharmacyAddress, fontRegular, fontBold),
    ));

    return saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static pw.Widget buildDeliverHeader(Invoice invoice, String pharmacyAddress, String customerAddress, pw.Font fontBold, pw.Font fontRegular) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 1 * PdfPageFormat.cm),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          buildSupplierAddress(invoice.pharmacy, pharmacyAddress, fontBold, fontRegular),
          // pw.Container(
          //   height: 50,
          //   width: 50,
          //   child: pw.BarcodeWidget(
          //     barcode: pw.Barcode.qrCode(),
          //     data: invoice.info.number,
          //   ),
          // ),
        ],
      ),
      pw.SizedBox(height: 1 * PdfPageFormat.cm),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          buildDeliverCustomerAddress(invoice.customer, customerAddress, fontBold, fontRegular),
          buildInvoiceInfo(invoice.info, fontRegular, fontBold),
        ],
      ),
    ],
  );

  static pw.Widget buildNonDeliverHeader(Invoice invoice, String pharmacyAddress, pw.Font fontBold, pw.Font fontRegular) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 1 * PdfPageFormat.cm),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          buildSupplierAddress(invoice.pharmacy, pharmacyAddress, fontBold, fontRegular),
          // pw.Container(
          //   height: 50,
          //   width: 50,
          //   child: pw.BarcodeWidget(
          //     barcode: pw.Barcode.qrCode(),
          //     data: invoice.info.number,
          //   ),
          // ),
        ],
      ),
    ],
  );

  static pw.Widget buildDeliverCustomerAddress(UserModel customer, String customerAddress, pw.Font fontBold, pw.Font fontRegular) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(customer.name, style: pw.TextStyle(font: fontBold)),
      pw.Container(
        width: 200,
        child: pw.Text(customerAddress, style: pw.TextStyle(font: fontRegular), maxLines: null, softWrap: true, overflow: pw.TextOverflow.visible)
      )
    ],
  );

  static pw.Widget buildInvoiceInfo(InvoiceInfo info, pw.Font fontRegular, pw.Font fontBold) {
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
    ];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, font: fontRegular, width: 200, titleStyle: pw.TextStyle(font: fontBold));
      }),
    );
  }

  static pw.Widget buildSupplierAddress(PharmacyModel pharmacy, String pharmacyAddress, pw.Font fontBold, pw.Font fontRegular) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(pharmacy.name, style: pw.TextStyle(font: fontBold)),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      pw.Container(
        width: 200,
        child: pw.Text(pharmacyAddress, style: pw.TextStyle(font: fontRegular), maxLines: null, softWrap: true, overflow: pw.TextOverflow.visible),
      )
  ],
  );

  static pw.Widget buildTitle(Invoice invoice, pw.Font fontBold, pw.Font fontRegular) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'INVOICE',
        style: pw.TextStyle(font: fontBold, fontSize: 24),
      ),
      pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
      pw.Text(invoice.info.description, style: pw.TextStyle(font: fontRegular)),
      pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
    ],
  );

  static pw.Widget buildInvoice(Invoice invoice, pw.Font fontRegular, pw.Font fontBold) {
    final headers = [
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'Total'
    ];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity;

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        'LKR ${item.unitPrice}',
        'LKR ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(font: fontBold, fontWeight: pw.FontWeight.bold), // Bold table headers
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget buildDeliverTotal(Invoice invoice, pw.Font fontBold, double distance) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    //const serviceFee = 150.0 * 0.18;
    final deliveryFee = distance * 51.20;
    final total = netTotal + deliveryFee; // + serviceFee

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 4),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  font: fontBold,
                  unite: true,
                ),
                // buildText(
                //   title: 'Service fee (VAT included)',
                //   value: Utils.formatPrice(serviceFee),
                //   font: fontBold,
                //   unite: true,
                // ),
                buildText(
                  title: 'Delivery fee (VAT included)',
                  value: Utils.formatPrice(deliveryFee),
                  font: fontBold,
                  unite: true,
                ),
                pw.Divider(),
                buildText(
                  title: 'Amount charged',
                  value: Utils.formatPrice(total),
                  font: fontBold,
                  unite: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget buildNonDeliverTotal(Invoice invoice, pw.Font fontBold) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    //const serviceFee = 150.0 * 0.18;
    final total = netTotal; // + serviceFee

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 4),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  font: fontBold,
                  unite: true,
                ),
                // buildText(
                //   title: 'Service fee (VAT included)',
                //   value: Utils.formatPrice(serviceFee),
                //   font: fontBold,
                //   unite: true,
                // ),
                pw.Divider(),
                buildText(
                  title: 'Amount charged',
                  value: Utils.formatPrice(total),
                  font: fontBold,
                  unite: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget buildFooter(Invoice invoice, String pharmacyAddress, pw.Font fontRegular, pw.Font fontBold) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Divider(),
      pw.SizedBox(height: 2 * PdfPageFormat.mm),
      buildSimpleText(title: 'Address', value: pharmacyAddress, font: fontRegular, titleStyle: pw.TextStyle(font: fontBold)),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'Payment', value: 'Cash', font: fontRegular, titleStyle: pw.TextStyle(font: fontBold)),
    ],
  );

  static pw.Widget buildSimpleText({
    required String title,
    required String value,
    required pw.Font font,
    pw.TextStyle? titleStyle,
  }) {
    final style = titleStyle ?? pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value, style: pw.TextStyle(font: font)),
      ],
    );
  }

  static pw.Widget buildText({
    required String title,
    required String value,
    required pw.Font font,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : pw.TextStyle(font: font)),
        ],
      ),
    );
  }

  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    return file.writeAsBytes(await pdf.save());
  }
}
