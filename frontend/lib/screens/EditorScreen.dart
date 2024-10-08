import 'package:flutter/material.dart';
import 'package:frontend/NoteServices.dart';

class EditorScreen extends StatefulWidget {
  final String? id; // Nullable ID to handle both create and update scenarios
  final String title;
  final String content;

  const EditorScreen({super.key, this.id, required this.title, required this.content});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  final NoteService noteService = NoteService();

  bool isSaved = false;
  bool isTitleEmpty = true;
  bool isContentEmpty = true;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the values passed from the home screen
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);

    titleController.addListener(() {
      setState(() {
        isTitleEmpty = titleController.text.isEmpty;
      });
    });
    contentController.addListener(() {
      setState(() {
        isContentEmpty = contentController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> createNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isNotEmpty) {
      final response = await noteService.createNote(title, content);

      if (response.statusCode == 201) {
        print('Note saved successfully!');
      } else {
        print('Failed to save note: ${response.statusCode}');
      }
    } else {
      print('Title and content cannot be empty!');
    }
  }

  Future<void> updateNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final id = widget.id;

    if (title.isNotEmpty && id != null) {
      final response = await noteService.updateNote(id, title, content);

      if (response.statusCode == 200) {
        print('Note updated successfully!');
      } else {
        print('Failed to update note: ${response.statusCode}');
      }
    } else {
      print('Title, content, or ID cannot be empty!');
    }
  }

  void showSaveDialog(String title, String saving, bool isReturn) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor: const Color(0xff252525),
          titlePadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.05,
          ),
          title: Column(
            children: [
              Icon(
                Icons.info,
                color: const Color(0xff606060),
                size: screenWidth * 0.08,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xffCFCFCF),
                  fontSize: screenWidth * 0.05,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.1,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      backgroundColor: const Color(0xffFF0000),
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.04),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isReturn) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Discard',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.1),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      backgroundColor: const Color(0xff30BE71),
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.04),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      {
                        if (widget.id !=
                            null) //if there is an already made note with an id then update
                        {
                          await updateNote();
                          isSaved = true;
                        } else {
                          await createNote();
                          isSaved = true;
                        }
                      }
                      if (saving == 'keep' &&
                          isSaved ==
                              true) // if the icon button is chevros back then pop and fetch notesxs
                      {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text(
                      saving,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF252525),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B3B3B),
                borderRadius: BorderRadius.circular(15),
              ),
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  if (((widget.title != titleController.text ||
                          widget.content != contentController.text) &&
                      isSaved ==
                          true)) // if one of the title or content has been modified and saved before pressing on back then fetch notes on pop
                  {
                    Navigator.of(context).pop(true);
                  } else if ((widget.title == titleController.text &&
                      widget.content ==
                          contentController
                              .text)) //if nothing has been updated or created just pop without fetching
                  {
                    print('test');
                    Navigator.of(context).pop();
                  } else if(mounted)//if something has been modified or created without pressing on save before
                  {
                    showSaveDialog(
                        'Are you sure you want to discard your changes?',
                        'keep',
                        true);
                  }
                },
                color: Colors.white,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B3B3B),
                borderRadius: BorderRadius.circular(15),
              ),
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              child: IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  if(mounted){
                  if (widget.title != titleController.text ||
                      widget.content !=
                          contentController
                              .text) //if something has een created or modified then show the showSaveDialog
                  {
                    showSaveDialog('Save changes?', 'Save', false);
                  }}
                },
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: isTitleEmpty ? 'Title' : null,
                    hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: screenWidth * 0.1046,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff9A9A9A),
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: screenWidth * 0.08,
                    color: const Color(0xffFFFFFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: contentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: isContentEmpty ? 'Type something...' : null,
                    hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff9A9A9A),
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: screenWidth * 0.05,
                    color: const Color(0xffFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

