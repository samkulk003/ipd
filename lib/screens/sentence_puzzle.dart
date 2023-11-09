import 'package:flutter/material.dart';
import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class SentencePuzzle extends StatefulWidget {
  @override
  _SentencePuzzleState createState() => _SentencePuzzleState();
}

class _SentencePuzzleState extends State<SentencePuzzle> {
  bool showTimer = false;
  var currentTimeConsumed;
  List<String> originalSentences = [];

  CountDownController _controller = CountDownController();

  @override
  void initState() {
    super.initState();
    originalSentences = List.from(sentences);
    startTimer();
    // Initialize currentTimeConsumed to 0 when the widget is created
    currentTimeConsumed = 0;
  }

  List<String> sentences = [
    "Hi, What are you! doing today?",
    "Hello! How do you do?",
    "What is your name?",
    "Where do you live?",
    "How old are you?",
  ];
  String getHintForPunctuation(String punctuation) {
    switch (punctuation) {
      case ',':
        return "Remember, commas are used to separate items in a list or to set off introductory phrases and non-essential information. Check if the comma placement matches one of these purposes in the sentence.";
      case '?':
        return "Question marks should only be used at the end of sentences that ask a direct question. Double-check if the sentence is indeed posing a question. If not, consider using a different punctuation mark.";
      case '!':
        return "Exclamation marks should convey strong emotions or emphasis. Make sure the content in the sentence justifies the use of this punctuation mark. Is there excitement, surprise, or urgency present?";
      case '.':
        return "Periods mark the end of a complete thought or statement. Ensure that the sentence is logically structured, and a period is appropriately placed at the end. If it seems lengthy, think about breaking it into shorter sentences.";
      default:
        return '';
    }
  }

  int currentSentenceIndex = 0;
  List<String> draggablePunctuations = [',', '.', '!', '?', ';', ':'];
  Map<String, Color> caughtColor = {};

  Map<String, Color> punctuationColor = {
    ',': Colors.red,
    '.': Colors.green,
    '!': Colors.blue,
    '?': Colors.yellow,
    ';': Colors.orange,
    ':': Colors.purple,
  };

  Map<String, bool> isCorrect = {};
  String feedback = '';

  int totalAttempts = 0; // Variable to store total attempts for drag and drop
  Map<String, int> attemptsPerPunctuation = {
    ',': 0,
    '.': 0,
    '!': 0,
    '?': 0,
    ';': 0,
    ':': 0,
  }; // Map to store attempts per punctuation

  List<int> attemptsPerQuestion =
      List.filled(5, 0); // List to store attempts per question

  void resetAttempts() {
    totalAttempts = 0;
    attemptsPerPunctuation = {
      ',': 0,
      '.': 0,
      '!': 0,
      '?': 0,
      ';': 0,
      ':': 0,
    };
  }

  int totalTimePerQuestion = 60; // Total time per question in seconds
  int currentTimeLeft = 60; // Current time left for the question in seconds
  Timer? timer; // Timer to track time per question

  void startTimer() {
    currentTimeConsumed = 0;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentTimeConsumed < 60) {
          currentTimeConsumed++;
        } else {
          // Time is up, reset attempts and move to the next question
          //timer.cancel();
          //resetAttempts();
          nextSentence();
          checkAndUpdateSentence();
        }
      });
    });
  }

  void storeAttempts() {
    attemptsPerQuestion[currentSentenceIndex] = totalAttempts;
    // Store attempts per punctuation in a list (per question)
    List<Map<String, int>> attemptsPerQuestionList = List.filled(
        sentences.length,
        {}); // Initialize a list with empty maps for each question
    for (int i = 0; i < sentences.length; i++) {
      attemptsPerQuestionList[i] = {...attemptsPerPunctuation};
    }
    //final timeRemaining = totalTimePerQuestion - currentTimeLeft;
    print(
        'Time Consumed for Question $currentSentenceIndex: $currentTimeConsumed seconds');
    // Now, attemptsPerQuestionList contains attempts per punctuation for each question
    print('Total Attempts for Question $currentSentenceIndex: $totalAttempts');
    print(
        'Attempts per Punctuation for Question $currentSentenceIndex: $attemptsPerPunctuation');
  }

  void checkAndUpdateSentence() {
    // Get the unique punctuations in the current sentence
    Set<String> uniquePunctuationsInSentence = Set.from(
        sentences[currentSentenceIndex]
            .split('')
            .where((element) => draggablePunctuations.contains(element)));

    // Check if all unique punctuations have been exhausted
    bool allPunctuationsExhausted = uniquePunctuationsInSentence.every(
      (punctuation) => (attemptsPerPunctuation[punctuation] ?? 0) >= 3,
    );

    if (allPunctuationsExhausted) {
      // Show the dialog only if all unique punctuations' attempts are exhausted
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('The correct sentence is:'),
            content: Text(originalSentences[currentSentenceIndex]),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  nextSentence();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void updateFeedback(String punctuation) {
    int attempts = attemptsPerPunctuation[punctuation] ?? 0;
    if (attempts == 1) {
      feedback = 'Please recollect the guidelines; you are using it wrong.';
    } else if (attempts == 2) {
      feedback = getHintForPunctuation(punctuation);
    } else {
      feedback = 'Wrong!';
    }
  }

  List<Widget> buildSentence(String sentence) {
    List<Widget> sentenceParts = [];
    sentence.split('').forEach((part) {
      if ('?,.!;:'.contains(part)) {
        sentenceParts.add(buildPunctuationDragTarget(part));
      } else {
        sentenceParts.add(Text(
          part,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ));
      }
    });
    return sentenceParts;
  }

  bool justAccepted = false;

  Widget buildPunctuationDragTarget(String punctuation) {
    return isCorrect[punctuation] ?? false
        ? Text(
            punctuation,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          )
        : DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Opacity(
                opacity: 0.0,
                child: Container(
                  height: 28,
                  width: 20,
                  color: candidateData.isNotEmpty &&
                          candidateData.first == punctuation
                      ? punctuationColor[punctuation]?.withOpacity(1)
                      : punctuationColor[punctuation]?.withOpacity(1),
                  child: Center(
                    child: Text(
                      isCorrect[punctuation] ?? false ? 'Correct' : 'Wrong',
                    ),
                  ),
                ),
              );
            },
            onWillAccept: (data) {
              return data == punctuation &&
                  (attemptsPerPunctuation[punctuation] ?? 0) < 3;
            },
            onAccept: (data) {
              print('onAccept called with data: $data');
              if (data == punctuation) {
                setState(() {
                  //justAccepted = true;
                  caughtColor[punctuation] = punctuationColor[punctuation]!;
                  isCorrect[punctuation] = true;
                  feedback = 'Correct!';
                  totalAttempts++;
                  attemptsPerPunctuation[data] =
                      (attemptsPerPunctuation[data] ?? 0) + 1;
                  sentences[currentSentenceIndex] =
                      sentences[currentSentenceIndex]
                          .replaceFirst(data, punctuation);
                  //checkAndUpdateSentence();
                });
                //justAccepted = false;
                checkAndUpdateSentence();
              }
            },
            onLeave: (data) {
              print('onLeave called with data: $data');
              if (data == punctuation && !(isCorrect[punctuation] ?? false)) {
                setState(() {
                  caughtColor[punctuation] = Colors.grey;
                  updateFeedback(punctuation);
                  totalAttempts++;
                  final nonNullableData = data ?? '';
                  attemptsPerPunctuation[nonNullableData] =
                      (attemptsPerPunctuation[nonNullableData] ?? 0) + 1;
                  //checkAndUpdateSentence();
                });
              }
            },
          );
  }

  void nextSentence() {
    timer?.cancel();
    resetAttempts(); // Reset attempts when moving to the next sentence
    //storeAttempts(); // Store attempts when moving to the next sentence
    draggablePunctuations.forEach((key) {
      caughtColor[key] = Colors.blue;
    });
    if (currentSentenceIndex < sentences.length - 1) {
      setState(() {
        currentSentenceIndex = currentSentenceIndex + 1;
        //print(currentSentenceIndex);
        feedback = '';
        isCorrect = {};
        startTimer();
        //checkAndUpdateSentence();
        _controller.restart(duration: totalTimePerQuestion);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('You have completed all sentences.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    // Dispose of the timer to avoid memory leaks
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drag and drop'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              spacing: 2.0,
              children: [...buildSentence(sentences[currentSentenceIndex])],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: sentences[currentSentenceIndex]
                  .split('')
                  .where((element) => draggablePunctuations.contains(element))
                  .toSet()
                  .map((punctuation) {
                bool canDrag = (attemptsPerPunctuation[punctuation] ?? 0) < 3;
                return Draggable<String>(
                  data: punctuation,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color:
                          canDrag ? punctuationColor[punctuation] : Colors.grey,
                      child: Text(
                        punctuation,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  feedback: canDrag
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color: punctuationColor[punctuation],
                            child: Text(
                              punctuation,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  childWhenDragging: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.transparent,
                      child: Text(
                        punctuation,
                        style: TextStyle(
                            fontSize: 20, color: Colors.black.withOpacity(0.0)),
                      ),
                    ),
                  ),
                  onDraggableCanceled: (velocity, offset) {
                    print('onAccept called with data:');
                    // Increment the attempt count when draggable is canceled (dropped outside of a DragTarget)
                    if (canDrag) {
                      setState(() {
                        attemptsPerPunctuation[punctuation] =
                            (attemptsPerPunctuation[punctuation] ?? 0) + 1;
                        print(
                            'Attempts for $punctuation: ${attemptsPerPunctuation[punctuation]}');
                        updateFeedback(punctuation);
                        totalAttempts++;
                        //checkAndUpdateSentence();
                      });

                      checkAndUpdateSentence();
                    }
                  },
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                // Store the time consumed and move to the next question
                storeAttempts();
                nextSentence();
                setState(() {
                  showTimer = true; // Show the timer again
                });
                _controller.restart(
                  duration: totalTimePerQuestion,
                );
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            Text(
              'Total Attempts: $totalAttempts',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Attempts per Punctuation:\n $attemptsPerPunctuation',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            CircularCountDownTimer(
              // Add CircularCountDownTimer widget
              duration: totalTimePerQuestion,
              initialDuration: 0,
              controller: _controller,
              width: 100,
              height: 100,
              ringColor: Colors.grey,
              ringGradient: null,
              fillColor: Colors.blue,
              fillGradient: null,
              backgroundColor: Colors.blue[100],
              backgroundGradient: null,
              strokeWidth: 5.0,
              strokeCap: StrokeCap.round,
              textStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: false,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: true, // Start the timer automatically
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: feedback.contains('Correct!')
                    ? Colors.green[100]
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color:
                      feedback.contains('Correct!') ? Colors.green : Colors.red,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Text(
                feedback,
                style: TextStyle(
                  fontSize: 20,
                  color:
                      feedback.contains('Correct!') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SentencePuzzle(),
  ));
}
