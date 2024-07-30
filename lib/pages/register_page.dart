import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/appcolor.dart';
import 'package:testproject/components/headder.dart';
import 'package:testproject/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //signup function
  Future _signup(String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateProfile(displayName: displayName);
      await userCredential.user?.reload();

      print(userCredential.user);

      Navigator.of(context).pop();
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LoginPage(email: email)));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Duplicate email error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ສຳເລັດບໍ່ສຳເລັດ'),
              content: const Text('ອີເມວນີ້ຖືກລົງທະບຽນແລ້ວ'),
              actions: <Widget>[
                TextButton(
                  child: const Text('ປິດ'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Other Firebase Auth errors
        print('Error: ${e.message}');
      }
    }
  }

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              decoration: const BoxDecoration(color: AppColors.primaryColor),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            top: -80,
            right: -250,
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.secondaryColor),
              width: 500,
              height: 500,
            ),
          ),
          SingleChildScrollView(
              child: Column(
            children: [
              const Headder(),
              // const Spacer(),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "ລົງທະບຽນ",
                        style: TextStyle(
                            color: AppColors.primaryColor, fontSize: 30),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FormBuilder(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //Name field
                              FormBuilderTextField(
                                name: 'displayName',
                                decoration: const InputDecoration(
                                  labelText: 'ຊື່ຜູ້ໃຊ້',
                                ),
                                validator: FormBuilderValidators.compose(
                                  [
                                    FormBuilderValidators.required(
                                        errorText: 'ກະລຸນາປ້ອນຊື່ໃຊ້'),
                                  ],
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),

                              //Email field
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'email',
                                decoration: const InputDecoration(
                                  labelText: 'ອີເມວ',
                                ),
                                validator: FormBuilderValidators.compose(
                                  [
                                    FormBuilderValidators.required(
                                        errorText: 'ກະລຸນາປ້ອນອິເມວ'),
                                    FormBuilderValidators.email(
                                        errorText: 'ອີເມວບໍ່ຖືກຕ້ອງ'),
                                  ],
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),

                              //Password field
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'password',
                                decoration: const InputDecoration(
                                  labelText: 'ລະຫັດຜ່ານ',
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText: 'ກະລຸນາປ້ອນລະຫັດຜ່ານ'),
                                  FormBuilderValidators.minLength(6,
                                      errorText:
                                          'ລະຫັດຜ່ານຄວນຢ່າງຫນ້ອຍ 6 ຕົວອັກສອນ'),
                                ]),
                                obscureText: true,
                              ),

                              //register button
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState
                                          ?.saveAndValidate() ??
                                      false) {
                                    final email =
                                        _formKey.currentState?.value['email'];
                                    final password = _formKey
                                        .currentState?.value['password'];
                                    final displayName = _formKey
                                        .currentState?.value['displayName'];
                                    // Handle login logic here
                                    print('Email: $email, Password: $password');
                                    _signup(email, password, displayName);
                                  } else {
                                    print('Validation failed');
                                  }
                                },
                                child: const Text(
                                  'ລົງທະບຽນ',
                                  style: TextStyle(fontSize: 23),
                                ),
                              ),

                              //login button
                              const Padding(padding: EdgeInsets.only(top: 20)),
                              const Text("ຍັງບໍ່ທັນມີບັນຊີ, "),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to RegisterPage
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'ເຂົ້າສູ່ລະບົບ',
                                  style: TextStyle(fontSize: 23),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}
