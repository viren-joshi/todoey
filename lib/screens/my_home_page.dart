import 'package:flutter/material.dart';
import 'package:todo/service/data_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String newTodo = "";
  final _todoTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              bottom: 15.0,
              top: 50.0,
            ),
            child: Text(
              "TO DO App",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50.0,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.8),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(
                                0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _todoTextFieldController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 0.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          hintText: 'Type Something here...',
                        ),
                        onChanged: (value) {
                          newTodo = value;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 15.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 35.0,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        // size: 30.0,
                      ),
                      onPressed: () {
                        if (newTodo != "") {
                          DataHelper.addTask(newTodo).then((value) {
                            setState(() {
                              _todoTextFieldController.clear();
                              newTodo = "";
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Task Added!"),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FutureBuilder(
                future: DataHelper.getData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    List<Map<String, dynamic>> data = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return CardWidget(
                          id: data[index]['id'],
                          text: data[index]['text'],
                          isDone: data[index]['isDone'],
                          callbackOnDelete: () => setState(() {}),
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _todoTextFieldController.dispose();
    super.dispose();
  }
}

class CardWidget extends StatefulWidget {
  final String id;
  final bool isDone;
  final String text;
  final Function callbackOnDelete;

  CardWidget({
    super.key,
    required this.isDone,
    required this.text,
    required this.id,
    required this.callbackOnDelete,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isDone = false, isEditing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    isDone = widget.isDone;
    _controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 5.0,
          ),
          child: Row(
            children: [
              Checkbox(
                visualDensity:
                    const VisualDensity(horizontal: -2, vertical: -2),
                side: const BorderSide(color: Colors.black, width: 1.5),
                // fillColor: MaterialStateProperty.all(Colors.white),
                activeColor: Colors.white,
                checkColor: Colors.black,
                shape: const CircleBorder(
                  eccentricity: 0.5,
                ),
                value: isDone,
                onChanged: (value) async {
                  await DataHelper.updateTaskState(widget.id, value!);
                  setState(() {
                    isDone = value;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  enabled: isEditing,
                  controller: _controller,
                  onChanged: (value) {
                  },
                  style: TextStyle(
                    fontSize: 20.0,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  decoration: const InputDecoration(
                    disabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              if (!isDone)
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.done : Icons.edit,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                    if(!isEditing) {
                      DataHelper.updateTaskText(widget.id, _controller.text);
                    }
                  },
                ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                onPressed: () async {
                  DataHelper.deleteTask(widget.id);
                  widget.callbackOnDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
