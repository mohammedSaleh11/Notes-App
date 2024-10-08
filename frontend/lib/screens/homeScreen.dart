import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/EditorScreen.dart';
import 'package:frontend/NoteServices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService noteService = NoteService();
  List notes = [];

  bool loading = true;
  bool isSearching = false; // State for tracking search mode
  String? searchTitle; // State for storing search query
 

  int currentPage = 1; // Current page number for pagination
  int limit = 10; // Number of notes per page
  bool isLoadMore=false;

  ScrollController scrollController = ScrollController();


  final List<Color> brightColors = [
    const Color(0xFF91F48F),
    const Color(0xFF9EFFFF),
    const Color(0xFFFFF599),
    const Color(0xFFB69CFF),
    const Color(0xFFFF9E9E),
    const Color(0xFFFFC1E3),
    const Color(0xFFFFD966),
    const Color(0xFF98FB98),
    const Color(0xFFAFEEEE),
    const Color(0xFFFFA07A),
  ];

  @override
  void initState() {
    super.initState();
        fetchNotes();

     scrollController.addListener(() async {
      if(isLoadMore) return;
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoadMore) {
      setState(() {
        
        isLoadMore = true; // Prevent further loading until complete
      });

      // Fetch more notes
      currentPage++;
      if(searchTitle!=null){
      await fetchNotes(searchText: searchTitle);
      }else
      {
       await fetchNotes();
      }

 setState(() {
        
        isLoadMore = false; // Prevent further loading until complete
      });

    }
  });
  }

  Future<void> fetchNotes({String? searchText, bool reset = false}) async {
  if (reset) {
    currentPage = 1;
    notes.clear();
  }
  try {
    final response = await noteService.fetchNotes(searchText: searchText, page: currentPage, limit: limit);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['data']['data'] as List;
    
      
 
      final List<Map<String, dynamic>> newNotes = json.map((note) {
        return {
          'id': note['_id'],
          'title': note['title'],
          'content': note['content'],
          'isDeleteVisible': false,
        };
      }).toList();
      

      if (newNotes.isEmpty) {
        print('No more notes to fetch');
        setState(() {
          isLoadMore = false; 
         
        });
        return; // Exit the function if no new notes are fetched
      }


   
      setState(() {
        notes.addAll(newNotes);
        loading = false;
        isLoadMore = false;
      });

      print('Notes fetched');
    } else {
      print('Failed to load notes');
    }
  } catch (error) {
    print('Error fetching notes: $error');
    setState(() {
      loading = false;
      isLoadMore = false;
    });
  }
}
  

  Future<void> deleteNote(final id) async {
    final response = await noteService.deleteNote(id);
    try {
      if (response.statusCode == 200) {
        print('Note deleted successfully!');
      } else {
        print('Failed to delete note: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting note: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252525),
        title: isSearching
            ? Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              color: Colors.white,
              onPressed: () async {
               await fetchNotes(reset:true);
                setState(() {
                  
                  isSearching = false;
                  searchTitle = null;
                   // Refresh the notes list when exiting search
                });
              },
            ),
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    searchTitle = value;
                  });
                  fetchNotes(
                    searchText: searchTitle,
                    reset: true
                  ); // Trigger search when text changes
                },
                decoration: const InputDecoration(
                  hintText: 'Search Notes...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style:  TextStyle(
                    color: Colors.white, fontSize: screenWidth * 0.05),
              ),
            ),
          ],
        )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B3B3B),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        child:  IconButton(
                          icon: Icon(isSearching ? Icons.close : Icons.search),
                          onPressed: () {
                            setState(() {
                              isSearching = !isSearching;
                              if (!isSearching) {
                                searchTitle = null;
                                // Reset search text when search is closed
                                fetchNotes(reset:true); // Refresh notes
                              }
                            });
                          },
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
      body: GestureDetector(
        onTap: () {
          if(notes.isEmpty)
                          return;
          setState(() {
            // Reset visibility for all notes when tapping outside
                    
            if(isSearching==true && !notes.isEmpty){
            fetchNotes(reset:true);
           isSearching=false;
            }
            
            for (var note in notes) {
              note['isDeleteVisible'] = false;
            }
          });
        },
        child: Stack(
          children: [
            loading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isSearching
                                  ? Container(
                                      color: const Color(
                                          0xFF252525), // Set the background color
                                      child: Image(
                                        image: const AssetImage('images/sad3.png'),
                                        width: screenWidth * 0.75,
                                      ),
                                    )
                                  : Image(
                                      image: const AssetImage('images/firstNote.png'),
                                      width: screenWidth * 0.75,
                                    ),
                              Text(
                                isSearching
                                    ? 'no notes found matching your search'
                                    : 'Create your first note!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                      controller: scrollController,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        itemCount: isLoadMore? notes.length+1 : notes.length,
                        itemBuilder: (context, index) {
                       
              
                         if(index>=notes.length){
                          return Center(child: CircularProgressIndicator(),);
                         }else{
                                                    final note = notes[index];

                           return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                // Update visibility only for the long-pressed note
                                notes[index]['isDeleteVisible'] = true;
                              });
                            },
                            onTap: () async {
                              if (note['isDeleteVisible'] == true) {
    await deleteNote(note['id']); // Delete the note
   fetchNotes(reset:true); // Refresh the notes list
    return; // Exit the function after deletion
  }
                              final bool? isNoteUpdated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditorScreen(
                                    id: note['id'],
                                    title: note['title'] ?? '',
                                    content: note['content'] ?? '',
                                  ),
                                ),
                              );
                              if (isNoteUpdated == true) {
                                fetchNotes(reset: true);
                              }
                            },
                            child: Card(
                              color: note['isDeleteVisible']
                                  ? const Color(0xFFFF0000)
                                  : brightColors[index % brightColors.length],
                              margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.06,
                                    horizontal: screenWidth * 0.1),
                                child: note['isDeleteVisible']
                                    ? const Center(
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        note['title'] ?? 'No Title',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: screenWidth * 0.06,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          );
                         }
                        },
                      ),
            Positioned(
              bottom: screenHeight * 0.05,
              right: screenWidth * 0.05,
              child: Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(screenWidth * 0.075),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final bool? isNoteCreated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EditorScreen(id: null, title: '', content: ''),
                        ));
              
                    if (isNoteCreated == true) {
                     fetchNotes(reset:true);
                    }
                  },
                  color: Colors.white,
                  iconSize: screenWidth * 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
