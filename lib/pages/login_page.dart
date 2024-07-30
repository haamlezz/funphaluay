import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/appcolor.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:testproject/components/headder.dart';
import 'package:testproject/components/menu.dart';
// import 'package:testproject/pages/home.dart';
import 'package:testproject/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.email});
  final String email;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
//Signin function
  Future _signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Menu(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Show error dialog
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ບໍ່ສຳເລັດ'),
            content: const Text('ອີເມວ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ'),
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
    }

    if (_rememberMe) {
      await _savePrefs(email, password, _rememberMe);
    } else {
      await _prefs.remove('email');
      await _prefs.remove('password');
      await _prefs.remove('rememberMe');
    }
  }

//save pref function
  Future<void> _savePrefs(
      String email, String password, bool rememberMe) async {
    await _prefs.setString('email', email);
    await _prefs.setString('password', password);
    await _prefs.setBool('rememberMe', rememberMe);
  }

  //init preferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = _prefs.getString('email') ?? '';
      _passwordController.text = _prefs.getString('password') ?? '';
      _rememberMe = _prefs.getBool('rememberMe') ?? false;
    });
  }

//variables
  final _formKey = GlobalKey<FormBuilderState>();
  late SharedPreferences _prefs;
  bool _rememberMe = false;

  late TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _emailController = TextEditingController(text: widget.email);

    super.initState();

    _initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColors.primaryColor),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
                          "ເຂົ້າສູ່ລະບົບ",
                          style: TextStyle(
                              color: AppColors.primaryColor, fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FormBuilder(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //Email field
                                FormBuilderTextField(
                                  controller: _emailController,
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
                                  controller: _passwordController,
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

                                //Remember me
                                CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.platform,
                                  title: const Text(
                                    'ຈື່ຂ້ອຍໄວ້',
                                    style: TextStyle(
                                        color: AppColors.textPrimaryColor),
                                  ),
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),

                                //login button
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState
                                            ?.saveAndValidate() ??
                                        false) {
                                      final email =
                                          _formKey.currentState?.value['email'];
                                      final password = _passwordController.text;

                                      _signIn(email, password);
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('ບໍ່ສຳເລັດ'),
                                              content:
                                                  const Text('ມີບາງຢ່າງຜິດພາດ'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('ປິດ'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    }
                                  },
                                  child: const Text(
                                    'ເຂົ້າສູ່ລະບົບ',
                                    style: TextStyle(fontSize: 23),
                                  ),
                                ),

                                //register button
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("ຍັງບໍ່ທັນມີບັນຊີ, "),
                                      TextButton(
                                        onPressed: () {
                                          // Navigate to RegisterPage
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const RegisterPage()),
                                          );
                                        },
                                        child: const Text(
                                          'ລົງທະບຽນ',
                                          style: TextStyle(fontSize: 23),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text("ພັດທະນາໂດຍ: ສົມປະສົງ ແລະ ເພັດສະໝອນ"),
                        const Text(
                            "FoE, Master of Software Engineering Gen 11"),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
