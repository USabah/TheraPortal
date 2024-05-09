import 'dart:async';
import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class ExerciseSelector extends StatefulWidget {
  final List<Exercise> fullExerciseList;
  final List<ExerciseAssignment> patientExerciseAssignmentList;
  final TheraportalUser therapist;
  final TheraportalUser patient;

  const ExerciseSelector({
    super.key,
    required this.fullExerciseList,
    required this.patientExerciseAssignmentList,
    required this.therapist,
    required this.patient,
  });

  @override
  _ExerciseSelectorState createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  String? _selectedFilterField;
  String? _selectedFilterValue;
  late List<Exercise> createdExercises;
  List<Exercise>? filteredList;
  late TextEditingController _searchController;
  int totalAllExercises = 0;
  int totalMyExercises = 0;
  bool allExercisesTabSelected = true; //flag for which tab is selected
  bool isLoading = false;
  bool hasSearched = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    createdExercises = widget.fullExerciseList
        .where((exercise) => exercise.creator?.id == widget.therapist.id)
        .toList();
    _searchController = TextEditingController();
    totalAllExercises = widget.fullExerciseList.length;
    totalMyExercises = createdExercises.length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _search() {
    final searchText = _searchController.text.trim().toLowerCase();
    if (searchText == "") {
      return;
    }
    setState(() {
      isLoading = true;
    });

    List<Exercise> startingList =
        (filteredList == null) ? widget.fullExerciseList : filteredList!;

    //perform search considering entire phrase
    List<Map<String, dynamic>> entirePhraseResults =
        _searchByEntirePhrase(startingList, searchText);

    //perform search considering each word individually
    List<Map<String, dynamic>> individualWordsResults =
        _searchByIndividualWords(startingList, searchText);

    //,erge the results from both searches
    List<Exercise> mergedResults =
        _mergeLists(entirePhraseResults, individualWordsResults);

    setState(() {
      if (allExercisesTabSelected) {
        totalAllExercises = mergedResults.length;
      } else {
        totalMyExercises = mergedResults.length;
      }
      filteredList = mergedResults;
      isLoading = false;
      hasSearched = true;
    });
  }

  List<Map<String, dynamic>> _searchByEntirePhrase(
      List<Exercise> startingList, String searchText) {
    List<Map<String, dynamic>> results = [];

    for (Exercise exercise in startingList) {
      int score = 0;
      if (exercise.name.toLowerCase().contains(searchText)) {
        score += 6;
      }
      if (exercise.bodyPart.toLowerCase().contains(searchText) ||
          exercise.targetMuscle.toLowerCase().contains(searchText) ||
          (exercise.equipment?.toLowerCase().contains(searchText) ?? false)) {
        score += 4;
      }
      if (exercise.exerciseDescription.toLowerCase().contains(searchText) ||
          exercise.targetMuscle.toLowerCase().contains(searchText)) {
        score += 2;
      }
      if (score > 0) {
        results.add({'exercise': exercise, 'score': score});
      }
    }

    return results;
  }

  List<Map<String, dynamic>> _searchByIndividualWords(
      List<Exercise> startingList, String searchText) {
    List<Map<String, dynamic>> results = [];

    List<String> searchWords = searchText.split(' ');

    for (String word in searchWords) {
      for (Exercise exercise in startingList) {
        int score = 0;
        if (exercise.name.toLowerCase().contains(word)) {
          score += 3;
        }
        if (exercise.bodyPart.toLowerCase().contains(word) ||
            exercise.targetMuscle.toLowerCase().contains(word) ||
            (exercise.equipment?.toLowerCase().contains(word) ?? false)) {
          score += 2;
        }
        if (exercise.exerciseDescription.toLowerCase().contains(word) ||
            exercise.targetMuscle.toLowerCase().contains(word)) {
          score += 1;
        }
        if (score > 0) {
          results.add({'exercise': exercise, 'score': score});
        }
      }
    }

    return results;
  }

  List<Exercise> _mergeLists(
      List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    List<Exercise> mergedList = [];

    //combine the lists
    List<Map<String, dynamic>> combinedList = [...list1, ...list2];
    combinedList.sort((a, b) => b['score'].compareTo(a['score']));
    //extract only exercises
    mergedList = combinedList
        .map((item) => item['exercise'] as Exercise)
        .toSet()
        .toList();

    return mergedList;
  }

  void _clearFilters() {
    setState(() {
      _selectedFilterField = null;
      _selectedFilterValue = null;
      _searchController.clear();
      filteredList = null;
      //reset totalResultsFound and totalMyExercises when filters are cleared
      totalAllExercises = widget.fullExerciseList.length;
      totalMyExercises = createdExercises.length;
      hasSearched = false;
    });
  }

  void _applyFilter() {
    if (_selectedFilterValue != null) {
      setState(() {
        isLoading = true;
      });
      filteredList =
          (filteredList == null) ? widget.fullExerciseList : filteredList;
      filteredList = filteredList!.where((exercise) {
        switch (_selectedFilterField) {
          case 'Body Part':
            return exercise.bodyPart == _selectedFilterValue;
          case 'Equipment':
            return exercise.equipment == _selectedFilterValue;
          case 'Target Muscle':
            return exercise.targetMuscle == _selectedFilterValue;
          default:
            return false;
        }
      }).toList();

      setState(() {
        if (allExercisesTabSelected) {
          totalAllExercises = filteredList!.length;
        } else {
          totalMyExercises = filteredList!.length;
        }
        isLoading = false;
      });
    }
  }

  List<String>? _getFilterItems() {
    switch (_selectedFilterField) {
      case 'Body Part':
        return ExerciseConstants.bodyParts;
      case 'Equipment':
        return ExerciseConstants.equipment;
      case 'Target Muscle':
        return ExerciseConstants.targetMuscles;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Exercise'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Styles.beige,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Styles.beige,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Styles.beige,
                    ), // Change icon color
                    onPressed: (isLoading)
                        ? null
                        : () {
                            _searchController.clear();
                          },
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FieldWidget(
              label: 'Filter by Category',
              value: _selectedFilterField != null
                  ? _selectedFilterField!
                  : 'Select Here',
              onPressed: (isLoading)
                  ? null
                  : () async {
                      String? prevFieldValue = _selectedFilterField;
                      await _showOptionPopup(
                        ['Body Part', 'Equipment', 'Target Muscle'],
                        _selectedFilterField,
                        'Filter by',
                      );
                      if (prevFieldValue != _selectedFilterField &&
                          filteredList != null) {
                        _selectedFilterValue = null;
                        filteredList = null;
                        if (hasSearched) {
                          _search();
                        } else if (allExercisesTabSelected) {
                          totalAllExercises = widget.fullExerciseList.length;
                        } else {
                          totalMyExercises = widget.fullExerciseList.length;
                        }
                        setState(() {});
                      }
                    },
            ),
          ),

          if (_selectedFilterField != null) ...[
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FieldWidget(
                label: 'Select Filter Value',
                value: _selectedFilterValue != null
                    ? _selectedFilterValue!
                    : 'Select Here',
                onPressed: (isLoading)
                    ? null
                    : () async {
                        String? prevSelectedValue = _selectedFilterValue;
                        await _showOptionPopup(
                          _getFilterItems() ?? [],
                          _selectedFilterValue,
                          'Select filter value',
                        );
                        if (_selectedFilterValue != prevSelectedValue &&
                            prevSelectedValue != null) {
                          //need to reset filter
                          filteredList = null;
                          _applyFilter();
                          //check if we need to do a search again
                          if (_searchController.text != "" && hasSearched) {
                            _search();
                          }
                        } else if (_selectedFilterValue != prevSelectedValue) {
                          _applyFilter();
                        }
                      },
              ),
            ),
          ],
          const SizedBox(
            height: 15,
          ),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: (isLoading) ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.beige,
                    ),
                    child: const Text('Search'), // Change button color
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: (isLoading) ? null : _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.beige,
                    ),
                    child: const Text('Clear'), // Change button color
                  ),
                ),
              ),
            ],
          ),
          // Exercise tabs
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    unselectedLabelColor: Colors.white,
                    onTap: (isLoading)
                        ? null
                        : (index) {
                            // Reset filteredList when switching tabs
                            setState(() {
                              filteredList = null;
                              allExercisesTabSelected = index == 0;
                              _clearFilters();
                            });
                          },
                    tabs: const [
                      Tab(text: 'All Exercises'),
                      Tab(text: 'My Exercises'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        //All Exercises Tab
                        _buildAllExercisesTab(),
                        //My Exercises Tab
                        _buildMyExercisesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllExercisesTab() {
    return (isLoading)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              _buildTotalResultsText(totalAllExercises),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // Attach ScrollController here
                  itemCount:
                      filteredList?.length ?? widget.fullExerciseList.length,
                  itemBuilder: (context, index) {
                    return ExerciseCard(
                      exercise: filteredList?[index] ??
                          widget.fullExerciseList[index],
                      instructions: null,
                      therapist: widget.therapist,
                      patient: widget.patient,
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildMyExercisesTab() {
    return (isLoading)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              _buildTotalResultsText(totalMyExercises),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // Attach ScrollController here
                  itemCount: createdExercises.length,
                  itemBuilder: (context, index) {
                    return ExerciseCard(
                      exercise: createdExercises[index],
                      instructions: null,
                      therapist: widget.therapist,
                      patient: widget.patient,
                    );
                  },
                ),
              ),
            ],
          );
  }

  Future<void> _showOptionPopup(
      List<String> options, String? selectedValue, String label) async {
    Completer<void> completer = Completer<void>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[800],
          ),
          child: AlertDialog(
            title: Text(
              'Select $label',
              style: const TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.8,
              child: ListView.builder(
                itemCount: options.length, // Exclude "Select Here" option
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (label == 'Filter by') {
                        setState(() {
                          _selectedFilterField = options[index];
                        });
                      } else if (label == 'Select filter value') {
                        setState(() {
                          _selectedFilterValue = options[index];
                        });
                      }
                      Navigator.of(context).pop();
                      completer.complete(); // Resolve the Future
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        options[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  completer.complete(); // Resolve the Future
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
    return completer.future; // Return the Future
  }

  Widget _buildTotalResultsText(int totalResults) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Results Found: $totalResults',
            style: const TextStyle(color: Colors.white, fontSize: 21),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.045,
            width: MediaQuery.of(context).size.width * 0.1,
            decoration: BoxDecoration(
              color: Styles.beige,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward, color: Colors.black),
              onPressed: () {
                // Scroll to the top of the page
                _scrollController.animateTo(
                  0.0,
                  duration: const Duration(
                      milliseconds: 300), // Adjust duration as needed
                  curve: Curves.easeInOut, // Adjust curve as needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// void _search() {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final searchText = _searchController.text.trim().toLowerCase();
  //   List<Exercise> startingList =
  //       (filteredList == null) ? widget.fullExerciseList : filteredList!;

  //   // perform search considering entire phrase
  //   _searchByEntirePhrase(startingList, searchText);

  //   //perform search considering each word individually
  //   _searchByIndividualWords(startingList, searchText);

  //   setState(() {
  //     if (allExercisesTabSelected) {
  //       totalAllExercises = filteredList!.length;
  //     } else {
  //       totalMyExercises = filteredList!.length;
  //     }
  //     isLoading = false;
  //     hasSearched = true;
  //   });
  // }

  // void _searchByEntirePhrase(String searchText) {
  //   filteredList =
  //       (filteredList == null) ? widget.fullExerciseList : filteredList;
  //   filteredList = filteredList!.where((exercise) {
  //     int score = 0;
  //     if (exercise.name.toLowerCase().contains(searchText)) {
  //       score += 3;
  //     }
  //     if (exercise.bodyPart.toLowerCase().contains(searchText) ||
  //         exercise.targetMuscle.toLowerCase().contains(searchText) ||
  //         (exercise.equipment?.toLowerCase().contains(searchText) ?? false)) {
  //       score += 2;
  //     }
  //     if (exercise.exerciseDescription.toLowerCase().contains(searchText) ||
  //         exercise.targetMuscle.toLowerCase().contains(searchText)) {
  //       score += 1;
  //     }
  //     return score > 0; // Include exercise if it has a non-zero score
  //   }).toList();
  // }

  // void _searchByIndividualWords(String searchText) {
  //   List<String> searchWords = searchText.split(' ');
  //   List<Exercise> tempFilteredList = [];
  //   filteredList =
  //       (filteredList == null) ? widget.fullExerciseList : filteredList;
  //   for (String word in searchWords) {
  //     tempFilteredList.addAll(filteredList!.where((exercise) {
  //       int score = 0;
  //       if (exercise.name.toLowerCase().contains(word)) {
  //         score += 3;
  //       }
  //       if (exercise.bodyPart.toLowerCase().contains(word) ||
  //           exercise.targetMuscle.toLowerCase().contains(word) ||
  //           (exercise.equipment?.toLowerCase().contains(word) ?? false)) {
  //         score += 2;
  //       }
  //       if (exercise.exerciseDescription.toLowerCase().contains(word) ||
  //           exercise.targetMuscle.toLowerCase().contains(word)) {
  //         score += 1;
  //       }
  //       return score > 0; // Include exercise if it has a non-zero score
  //     }));
  //   }
  //   // Filter out duplicate exercises
  //   filteredList = tempFilteredList.toSet().toList();
  // }