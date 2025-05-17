import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Stack(
        children: [
          list(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 20,
              ), // Move button up from the bottom
              child: addButton(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.green[300],
      title: Text(
        'Home Made',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> list() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getRecipesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recipes found'));
        }
        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 20, top: 20),
              child: Text(
                'Recipes List',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 680,
              child: ListView.separated(
                itemCount: docs.length,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(left: 10, right: 10),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Container(
                    height: 80,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.restaurant_menu, size: 30, color: Colors.green[300]),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            data['name'] ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        alterButton(context, data, docs[index].id),
                        deleteButton(docs[index].id),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  GestureDetector deleteButton(String docId) {
    return GestureDetector(
      onTap: () async {
        NotificationService.createNotification(
          id: 5,
          title: 'Delete Recipe',
          body: 'Are you sure you want to delete this recipe?',
          payload: {'docID': docId},
          actionButtons: [
            NotificationActionButton(
              key: 'delete_button',
              label: 'Confirm Delete',
              actionType: ActionType.Default,
            )
          ],
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Icon(Icons.delete_outline, color: Colors.red[300], size: 26),
          ),
        ),
      ),
    );
  }

  Padding alterButton(BuildContext context, Map<String, dynamic> data, String docId) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: GestureDetector(
        onTap: () {
          TextEditingController nameController = TextEditingController(
            text: data['name'] ?? '',
          );
          TextEditingController textController = TextEditingController(
            text: data['recipe'] ?? '',
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "Edit recipe name",
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: textController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Edit recipe details",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      NotificationService.createNotification(
                        id: 1,
                        title: 'Update Recipe',
                        body: 'Cancelled update recipe',
                        summary: 'Cancelled',
                      );
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await firestoreService.updateRecipe(
                        docId,
                        nameController.text,
                        textController.text,
                      );
                      Navigator.of(context).pop(); // Close the dialog
                      NotificationService.createNotification(
                        id: 1,
                        title: 'Update Recipe',
                        body: 'Successful update recipe',
                        summary: 'Recipe updated',
                      );
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(color: Colors.blue[300]),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Icon(Icons.edit, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Padding addButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green[200]?.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          onTap: () {
            TextEditingController nameController = TextEditingController();
            TextEditingController textController = TextEditingController();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    'Add Recipe',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Enter recipe name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: textController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Enter recipe details",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        NotificationService.createNotification(
                          id: 1,
                          title: 'Add Recipe',
                          body: 'Cancelled adding recipe',
                          summary: 'Cancelled',
                        );
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        firestoreService.addRecipe(
                          nameController.text,
                          textController.text,
                        );

                        nameController.clear();
                        textController.clear();

                        Navigator.pop(context); // Close the dialog
                        NotificationService.createNotification(
                          id: 1,
                          title: 'Add Recipe',
                          body: 'Successful adding recipe',
                          summary: 'Recipe added',
                        );
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.blue[300]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Center(child: Icon(Icons.add, size: 40, color: Colors.white)),
        ),
      ),
    );
  }
}
