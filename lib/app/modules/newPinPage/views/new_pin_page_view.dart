import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../controllers/new_pin_page_controller.dart';

class NewPinPageView extends GetView<NewPinPageController> {
  final _formKey = GlobalKey<FormState>();
  NewPinPageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Generate Pin'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            SizedBox(
              height: Get.height * 0.3,
            ),
            TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone Number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                } else if (value.length != 10) {
                  return 'Please enter valid phone number';
                }
                return null;
              },
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    
                    controller.sendOtp();
                  }
                },
                child: const Text("Send Pin"))
          ]),
        ),
      ),
    );
  }
}
