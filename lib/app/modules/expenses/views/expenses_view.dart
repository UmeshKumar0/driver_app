import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/expenses_controller.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () {
            Get.defaultDialog(
              title: "Add Expense",
              content: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Amount",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      controller.amount = int.parse(value);
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Description",
                    ),
                    onChanged: (value) {
                      controller.description.text = value;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      controller.pickImage();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          "+ Add Image",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => Text("Image: ${controller.imageName.value}")),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        controller.addExpense();
                      },
                      child: const Text("Submit"))
                ],
              ),
            ).then((value) => {
                  controller.getExpenses(),
                  controller.img64.value = '',
                  controller.imageName.value = '',
                  controller.amount = 0,
                  controller.description.text = ''
                });
          },
          label: const Text("Expense"),
          icon: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('My Expenses'),
          centerTitle: true,
        ),
        body: Obx(
          () => controller.isLoading.isTrue
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: controller.expenses.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.defaultDialog(
                              title: "Expense Details",
                              content: Column(
                                children: [
                                  Text(
                                      "Amount: ₹${controller.expenses[index].amount.toString()}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "Description: ${controller.expenses[index].description.toString()}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "Date: ${DateTime.fromMillisecondsSinceEpoch(controller.expenses[index].date ?? 0).toString().substring(0, 10).split("-").reversed.join("-")}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "Status: ${controller.expenses[index].approved.toString()}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                
                                  SizedBox(
                                    height: 300,
                                    child: Image(image:NetworkImage("https://vehicle-backend.spideyworld.co.in/images/${controller.expenses[index].image}") ))
                                ],
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(controller.expenses[index].description
                                  .toString()),
                              subtitle: Row(
                                children: [
                                  Text(
                                      "₹${controller.expenses[index].amount.toString()}"),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    controller.expenses[index].approved ?? "",
                                    style: TextStyle(
                                        color:
                                            controller.expenses[index].approved ==
                                                    "pending"
                                                ? Colors.orange
                                                : Colors.green),
                                  )
                                ],
                              ),
                              trailing: Text(DateTime.fromMillisecondsSinceEpoch(
                                      controller.expenses[index].date ?? 0)
                                  .toString()
                                  .substring(0, 10)
                                  .split("-")
                                  .reversed
                                  .join("-")),
                            ),
                          ),
                        );
                      }),
                )
              : const Center(
                  child: CircularProgressIndicator(
                  color: Colors.red,
                )),
        ));
  }
}
