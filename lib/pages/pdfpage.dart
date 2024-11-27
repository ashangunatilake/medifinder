import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/drugs_model.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:pdfx/pdfx.dart';
import '../models/user_model.dart';
import '../models/invoice_model.dart';
import '../models/pharmacy_model.dart';
import '../services/exception_handling_services.dart';
import '../services/pdf_invoice.dart';
import '../snackbars/snackbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../strings.dart';
import 'package:uuid/uuid.dart';

class PDFViewer extends StatefulWidget {
  const PDFViewer({super.key});

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  String? _pdfPath;
  late PdfController _pdfController;
  late DocumentSnapshot<Map<String, dynamic>> pharmacyDoc;
  late DocumentSnapshot<Map<String, dynamic>> userOrderDoc;
  late UserModel customer;
  late PharmacyModel pharmacy;
  late UserOrder userOrder;
  late DrugsModel drug;
  bool loading = false;

  var uuid = const Uuid();

  Future<double> getRouteDistance(LatLng origin, LatLng destination, String apiKey) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'key=$apiKey&'
          'mode=driving',  //(driving, bicycling, etc.)
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          final distance = (leg['distance']['value'] as num).toDouble();

          return distance;
        } else {
          throw Exception('No route found');
        }
      } else if (data['status'] == 'ZERO_RESULTS') {
        print('No route found between the locations.');
        return 0;
      } else {
        //(e.g., INVALID_REQUEST, OVER_QUERY_LIMIT, etc.)
        print('Error from Directions API: ${data['status']}');
        throw Exception('Failed to fetch directions: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch directions: HTTP ${response.statusCode}');
    }
  }


  @override
  void initState() {
    super.initState();
    initializePDFData();
    _generateAndDisplayPDF();
  }

  Future<void> initializePDFData() async {
    setState(() {
      loading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _userDatabaseServices.getCurrentUserDoc() as DocumentSnapshot<Map<String, dynamic>>;
      customer = UserModel.fromSnapshot(userDoc);
      print(customer.name);
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null)
      {
        print(args['pharmacy']);
        pharmacy = args['pharmacy'].data();
        print(pharmacy.address);
        print(args['userOrder']);
        DocumentSnapshot<Map<String, dynamic>> userOrderDoc = args['userOrder'] as DocumentSnapshot<Map<String, dynamic>>;
        userOrder = UserOrder.fromSnapshot(userOrderDoc);
        print(userOrder.drugName);
      }
      else {
        throw ErrorException();
      }
      await _generateAndDisplayPDF();
    } catch (e) {
      if (e is UserLoginException) {
        Snackbars.errorSnackBar(message: e.message, context: context);
      }
      print("Errors fetching user data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _generateAndDisplayPDF() async {
    // Generate the invoice and save the path
    final DocumentSnapshot<Map<String, dynamic>> drugsDoc =   await _pharmacyDatabaseServices.getDrugById(userOrder.did, pharmacy.id) as DocumentSnapshot<Map<String, dynamic>>;
    final DrugsModel drug = DrugsModel.fromSnapshot(drugsDoc);
    final date = DateTime.now();

    final invoiceInfo = InvoiceInfo(
      description: 'Purchase of medical drugs...',
      number: '${DateTime.now().year}-0001', //uuid.v4()
      date: date,
    );

    final items = [
      InvoiceItem(
        description: userOrder.drugName,
        date: date,
        quantity: userOrder.quantity,
        unitPrice: drug.price,
      )
    ];

    final invoice = Invoice(
      info: invoiceInfo,
      pharmacy: pharmacy,
      customer: customer,
      items: items,
    );

    final LatLng pharmacyLocation = LatLng(pharmacy.position.latitude, pharmacy.position.longitude);
    final location = userOrder.location;
    late File pdfFile;
    if (location != null) {
      final LatLng customerLocation = LatLng(location.latitude, location.longitude);
      final double distance = await getRouteDistance(pharmacyLocation, customerLocation, apiKey);
      pdfFile = await PdfInvoiceApi.generateDeliverPdf(invoice, pharmacyLocation, customerLocation, distance/1000);
    } else {
      pdfFile = await PdfInvoiceApi.generateNonDeliverPdf(invoice, pharmacyLocation);
    }
    setState(() {
      _pdfPath = pdfFile.path;
      _pdfController = PdfController(
        document: PdfDocument.openFile(_pdfPath!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Invoice PDF'),
      ),
      body: _pdfPath == null
          ? const Center(child: CircularProgressIndicator())
          : PdfView(
        controller: _pdfController,
      ),
    );
  }
}
