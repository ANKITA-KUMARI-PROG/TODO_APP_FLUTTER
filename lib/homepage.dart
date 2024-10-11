import 'package:flutter/material.dart';
import 'package:todolist/dbpart/dblist/db_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO LIST"),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(allNotes[index][DbHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DbHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 60,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            titleController.text =
                                allNotes[index][DbHelper.COLUMN_NOTE_TITLE];
                            descController.text =
                                allNotes[index][DbHelper.COLUMN_NOTE_DESC];
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return getBottomSheetWidget(
                                      isUpdate: true,
                                      sno: allNotes[index]
                                          [DbHelper.COLUMN_NOTE_SNO]);
                                });
                          },
                          child: const Icon(Icons.edit),
                        ),
                        InkWell(
                          onTap: () async {
                            bool check = await dbRef!.deleteNote(
                                sno: allNotes[index][DbHelper.COLUMN_NOTE_SNO]);
                            if (check) {
                              getNotes();
                            }
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text("No Notes Yet!!"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleController.clear();
          descController.clear();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return getBottomSheetWidget();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 +
          MediaQuery.of(context).viewInsets.bottom,
      padding: EdgeInsets.only(
        top: 16,
        right: 16,
        left: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isUpdate ? "Update Note" : "Add Note",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    String title = titleController.text;
                    String desc = descController.text;

                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check = isUpdate
                          ? await dbRef!.updateNote(
                              title: title, desc: desc, sno: sno)
                          : await dbRef!.addNote(
                              title: title, desc: desc);
                      if (check) {
                        getNotes();
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields!"),
                        ),
                      );
                    }
                  },
                  child: Text(isUpdate ? "Update Note" : "Add Note"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
