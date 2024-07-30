import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:testproject/appcolor.dart';

// import 'package:permission_handler/permission_handler.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numbersController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _mainNumbersController = TextEditingController();
  final TextEditingController _imageNameController = TextEditingController();
  // File? _imageFile;
  // String? _imageUrl;
  // Uint8List? _imageBytes;
  // int? _handle;
  // String? _fileExtension;

  bool _isEditMode = false;
  String? _currentDocumentId;

  Future<void> _addOrUpdateAnimal() async {
    String name = _nameController.text;
    String imageName = _imageNameController.text;
    List<int> numbers = _numbersController.text
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();
    List<String> keywords =
        _keywordsController.text.split(',').map((e) => e.trim()).toList();
    List<int> mainNumbers = _mainNumbersController.text
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();

    // if (_imageFile != null) {
    // String fileExtension = _imageFile!.path.split('.').last;
    // String imagePath =
    //     'images/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    // await FirebaseStorage.instance.ref(imagePath).putFile(_imageFile!);

    // String imagePath = await _uploadImageToFirebase();

    // _imageUrl = await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
    // }

    Map<String, dynamic> animalData = {
      'name': name,
      'numbers': numbers,
      'searchCount': 0,
      'keywords': keywords,
      'mainNumbers': mainNumbers,
      'imageUrl': imageName,
    };

    if (_isEditMode && _currentDocumentId != null) {
      await FirebaseFirestore.instance
          .collection('animals')
          .doc(_currentDocumentId)
          .update(animalData);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal updated successfully')),
      );
    } else {
      await FirebaseFirestore.instance.collection('animals').add(animalData);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal added successfully')),
      );
    }

    // Clear the input fields
    _nameController.clear();
    _numbersController.clear();
    _keywordsController.clear();
    _mainNumbersController.clear();
    _imageNameController.clear();
    // _imageFile = null;
    // _imageUrl = null;

    setState(() {
      _isEditMode = false;
      _currentDocumentId = null;
    });
  }

  Future<void> _showAddOrEditDialog([DocumentSnapshot? document]) async {
    if (document != null) {
      _nameController.text = document['name'];
      _numbersController.text = document['numbers'].join(', ');
      _keywordsController.text = document['keywords'].join(', ');
      _mainNumbersController.text = document['mainNumbers'].join(', ');
      _imageNameController.text = document['imageUrl'];
      // _imageUrl = document['imageUrl'];

      setState(() {
        _isEditMode = true;
        _currentDocumentId = document.id;
      });
    } else {
      _nameController.clear();
      _numbersController.clear();
      _keywordsController.clear();
      _mainNumbersController.clear();
      _imageNameController.clear();
      // _imageFile = null;
      // _imageUrl = null;

      setState(() {
        _isEditMode = false;
        _currentDocumentId = null;
      });
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? 'Edit Animal' : 'Add Animal'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _addOrUpdateAnimal();
                },
                child: Text(_isEditMode ? 'Update' : 'Add'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'ຊື່ໂຕສັດ',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _numbersController,
                    decoration: const InputDecoration(
                      labelText: 'ເລກປະຈຳ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _keywordsController,
                    decoration: const InputDecoration(
                      labelText: 'ຄຳຄົ້ນຫາ',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _mainNumbersController,
                    decoration: const InputDecoration(
                      labelText: 'ເລກຫຼັກ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _imageNameController,
                    decoration: const InputDecoration(
                      labelText: 'ໃສ່ຊື່ຮູບ',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  // GestureDetector(
                  //   onTap: _pickImage,
                  //   child: Container(
                  //     width: double.infinity,
                  //     height: 200,
                  //     color: Colors.grey[200],
                  //     child: _imageFile != null
                  //         ? Image.file(_imageFile!, fit: BoxFit.cover)
                  //         : _imageUrl != null
                  //             ? Image.network(_imageUrl!, fit: BoxFit.cover)
                  //             : const Icon(Icons.add_a_photo,
                  //                 size: 100, color: Colors.grey),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Future<void> _upload image To Firebase method
  // Future<String> _uploadImageToFirebase() async {
  //   String imagePath =
  //       'images/${DateTime.now().millisecondsSinceEpoch}.$_fileExtension';
  //   switch (_handle) {
  //     case 0:
  //       await FirebaseStorage.instance.ref(imagePath).putData(_imageBytes!);
  //       break;

  //     case 1:
  //       await FirebaseStorage.instance.ref(imagePath).putFile(_imageFile!);
  //       break;
  //   }

  //   return imagePath;
  // }

  // Future<void> _pickImage() async {
  //   //WEB
  //   if (kIsWeb) {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.image,
  //     );

  //     if (result != null) {
  //       Uint8List? fileBytes = result.files.first.bytes;
  //       PlatformFile file = result.files.first;

  //       setState(() {
  //         _handle = 0;
  //         _fileExtension = file.extension;
  //         _imageBytes = fileBytes;
  //       });
  //     }
  //     //ANDROID
  //   } else {
  //     final pickedFile =
  //         await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       setState(() {
  //         _handle = 1;
  //         _fileExtension = pickedFile.path.split('.').last;
  //         _imageFile = File(pickedFile.path);
  //       });
  //     }
  //   }
  // }

  Future<void> _deleteAnimal(String id) async {
    await FirebaseFirestore.instance.collection('animals').doc(id).delete();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Animal deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Data'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('animals')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((document) {
                      return ListTile(
                        leading: Image.asset(
                            'assets/images/animal/' + document['imageUrl']),
                        title: Text(document['name']),
                        subtitle:
                            Text('Numbers: ${document['numbers'].join(', ')}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddOrEditDialog(document),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteAnimal(document.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
