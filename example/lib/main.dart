import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktp_extractor/ktp_extractor.dart';
import 'package:ktp_extractor/utils/utils.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ImagePicker? _imagePicker;

  File? _ktpImage;
  KtpModel? _ktpModel;

  File? _passportImage;
  PassportModel? _passportModel;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Extractor Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'KTP Scanner', icon: Icon(Icons.credit_card)),
            Tab(text: 'Passport Scanner', icon: Icon(Icons.flight_takeoff)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKtpTab(),
          _buildPassportTab(),
        ],
      ),
    );
  }

  Widget _buildKtpTab() {
    return ListView(
      children: [
        if (_ktpImage != null) ...[
          Image.file(_ktpImage!),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () => _getImageAsset('ktp'),
            child: const Text('From Assets'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            child: const Text('From Gallery'),
            onPressed: () => _getImage(ImageSource.gallery, 'ktp'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            child: const Text('Take a picture'),
            onPressed: () => _getImage(ImageSource.camera, 'ktp'),
          ),
        ),
        if (_ktpModel != null) _buildKtpResult(),
      ],
    );
  }

  Widget _buildPassportTab() {
    return ListView(
      children: [
        if (_passportImage != null) ...[
          Image.file(_passportImage!),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () => _getImageAsset('passport'),
            child: const Text('From Assets'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            child: const Text('From Gallery'),
            onPressed: () => _getImage(ImageSource.gallery, 'passport'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            child: const Text('Take a picture'),
            onPressed: () => _getImage(ImageSource.camera, 'passport'),
          ),
        ),
        if (_passportModel != null) _buildPassportResult(),
      ],
    );
  }

  Widget _buildKtpResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('KTP Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Provinsi : ${_ktpModel!.province ?? '-'}', maxLines: null),
              Text('Kota / Kabupaten : ${_ktpModel!.city ?? '-'}',
                  maxLines: null),
              Text('NIK : ${_ktpModel!.nik ?? '-'}', maxLines: null),
              Text('Nama : ${_ktpModel!.name ?? '-'}', maxLines: null),
              Text('Tempat Lahir : ${_ktpModel!.placeBirth ?? '-'}',
                  maxLines: null),
              Text('Tanggal Lahir : ${_ktpModel!.birthDay ?? '-'}',
                  maxLines: null),
              Text('Alamat : ${_ktpModel!.address ?? '-'}', maxLines: null),
              Text('\t\t\tRT / RW : ${_ktpModel!.rt} / ${_ktpModel!.rw ?? '-'}',
                  maxLines: null),
              Text('\t\t\tKel/Desa : ${_ktpModel!.subDistrict ?? '-'}',
                  maxLines: null),
              Text('\t\t\tKecamatan : ${_ktpModel!.district ?? '-'}',
                  maxLines: null),
              Text('Agama : ${_ktpModel!.religion ?? '-'}', maxLines: null),
              Text('Status Perkawinan : ${_ktpModel!.marital ?? '-'}',
                  maxLines: null),
              Text('Pekerjaan : ${_ktpModel!.occupation ?? '-'}',
                  maxLines: null),
              Text('Kewarganegaraan : ${_ktpModel!.nationality ?? '-'}',
                  maxLines: null),
              Text('Berlaku Hingga : ${_ktpModel!.validUntil ?? '-'}',
                  maxLines: null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassportResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Passport Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Document Type : ${_passportModel!.documentType ?? '-'}',
                  maxLines: null),
              Text('Issuing Country : ${_passportModel!.issuingCountry ?? '-'}',
                  maxLines: null),
              Text('Surname : ${_passportModel!.surname ?? '-'}',
                  maxLines: null),
              Text('Given Names : ${_passportModel!.givenNames ?? '-'}',
                  maxLines: null),
              Text('Passport Number : ${_passportModel!.passportNumber ?? '-'}',
                  maxLines: null),
              Text('Nationality : ${_passportModel!.nationality ?? '-'}',
                  maxLines: null),
              Text('Birth Date : ${_passportModel!.birthDate ?? '-'}',
                  maxLines: null),
              Text('Gender : ${_passportModel!.gender ?? '-'}', maxLines: null),
              Text('Expiry Date : ${_passportModel!.expiryDate ?? '-'}',
                  maxLines: null),
              Text('Personal Number : ${_passportModel!.personalNumber ?? '-'}',
                  maxLines: null),
              const SizedBox(height: 8),
              const Text('MRZ Lines:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Line 1: ${_passportModel!.mrz1 ?? '-'}',
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              Text('Line 2: ${_passportModel!.mrz2 ?? '-'}',
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future _getImage(ImageSource source, String documentType) async {
    if (documentType == 'ktp') {
      setState(() {
        _ktpImage = null;
        _ktpModel = null;
      });
    } else {
      setState(() {
        _passportImage = null;
        _passportModel = null;
      });
    }

    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path, documentType);
    }
  }

  Future _getImageAsset(String documentType) async {
    if (documentType == 'ktp') {
      setState(() {
        _ktpImage = null;
        _ktpModel = null;
      });
    } else {
      setState(() {
        _passportImage = null;
        _passportModel = null;
      });
    }

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) =>
            key.contains('.jpg') ||
            key.contains('.jpeg') ||
            key.contains('.png') ||
            key.contains('.webp'))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select ${documentType.toUpperCase()} image',
                  style: const TextStyle(fontSize: 20),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final path in assets)
                          if ((documentType == 'ktp' &&
                                  (path.contains('ktp') ||
                                      path.contains('KTP'))) ||
                              (documentType == 'passport' &&
                                  (path.contains('passport') ||
                                      path.contains('Passport'))))
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                _processFile(
                                    await getAssetPath(path), documentType);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(path),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _processFile(String path, String documentType) async {
    if (documentType == 'ktp') {
      _ktpImage = await KtpExtractor.cropImageForKtp(File(path));
      _ktpImage ??= File(path);
      _ktpModel = await KtpExtractor.extractKtp(_ktpImage!);
    } else {
      _passportImage = await KtpExtractor.cropImageForPassport(File(path));
      _passportImage ??= File(path);
      _passportModel = await KtpExtractor.extractPassport(_passportImage!);
    }
    setState(() {});
  }
}
