import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  GlobalKey globalKey = GlobalKey();

  //frame
  String? backgroundImageSelectedIndex;

  //font family
  Color selFontColor = Colors.white;
  List<String> fontFamilies = GoogleFonts.asMap().keys.toList();
  late String? selFont = fontFamilies.isNotEmpty ? fontFamilies.first : null;

  //border radius
  double _borderRadius = 0.0;

  void _increaseRadius() {
    setState(() {
      _borderRadius += 10;
    });
  }

  void _decreaseRadius() {
    setState(() {
      if (_borderRadius > 0) {
        _borderRadius -= 10;
      }
    });
  }

  //text alignment
  Alignment _alignment = Alignment.center;
  final Map<Alignment, Offset> _offsetMap = {
    Alignment.centerLeft: Offset(-50, 0),
    Alignment.centerRight: Offset(50, 0),
    Alignment.center: Offset.zero,
  };

  void _moveLeft() {
    setState(() {
      _alignment = Alignment.centerLeft;
    });
  }

  void _moveRight() {
    setState(() {
      _alignment = Alignment.centerRight;
    });
  }

  void _moveCenter() {
    setState(() {
      _alignment = Alignment.center;
    });
  }

  //textfield
  final TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String savedText = "";

  //text color
  Color color = Colors.black;

  String? select;
  double slidervalue = 50;
  double size = 14;

  //color picker
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showAddTextDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Text!'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                    hintText: "Type Somethinking..."
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  savedText = textController.text;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cancle'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //text size
  void increment() {
    setState(() {
      size++;
    });
  }

  void decrement() {
    setState(() {
      if (size > 10) {
        size--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: Text("Edit Poster",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async{
                RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                ByteData? byteData = (await image.toByteData(format: ui.ImageByteFormat.png)) as ByteData?;

                if (byteData != null) {
                  Uint8List pngBytes = byteData.buffer.asUint8List();

                  // save the screenshot
                  final Directory? downloadsDir =await getDownloadsDirectory();

                  File origFile =File("${downloadsDir!.path}/quote.png");

                  origFile.writeAsBytesSync(byteData.buffer.asUint8List());

                  // Share the screenshot
                  await Share.shareXFiles([ XFile(origFile.path),]);
                }
          }, icon: Icon(Icons.download, color: Colors.black)),

          IconButton(onPressed: () {
            setState(() {
              backgroundImageSelectedIndex=null;
              textController.clear();
              selFontColor = Colors.white;
              _borderRadius = 0.0;
              savedText = "";
              color = Colors.black;
            });
          }, icon: Icon(Icons.refresh, color: Colors.black)),

          IconButton(onPressed: () {
            showAddTextDialog();
          }, icon: Icon(Icons.add, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RepaintBoundary(
                key: globalKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            image: (backgroundImageSelectedIndex != null)
                                ? DecorationImage(
                              image: NetworkImage(backgroundImageSelectedIndex!),
                              fit: BoxFit.fill,
                            )
                                : null,
                            borderRadius: BorderRadius.circular(_borderRadius),
                          ),
                        ),

                        SizedBox(height: 20),
                        Transform.translate(
                          offset: _offsetMap[_alignment] ?? Offset.zero,
                          child: Text(savedText,
                              style:GoogleFonts.getFont(selFont!,textStyle: TextStyle(color:currentColor,fontSize: size))
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      backgroundColor: select == "frame"
                          ? Colors.white
                          : Colors.grey.shade300,
                      label: Text(
                        "Frames",
                        style: TextStyle(color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          select = "frame";
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ActionChip(
                      backgroundColor: select == "borderradius"
                          ? Colors.white
                          : Colors.grey.shade300,
                      label: Text(
                        "Border Radius",
                        style: TextStyle(color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          select = "borderradius";
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ActionChip(
                      backgroundColor: select == "textsize"
                          ? Colors.white
                          : Colors.grey.shade300,
                      label: Text(
                        "Text Size",
                        style: TextStyle(color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          select = "textsize";
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ActionChip(
                      backgroundColor: select == "colorpicker"
                          ? Colors.white
                          : Colors.grey.shade300,
                      label: Text(
                        "Color Picker",
                        style: TextStyle(color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          select = "colorpicker";
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ActionChip(
                      backgroundColor: select == "textstyle"
                          ? Colors.white
                          : Colors.grey.shade300,
                      label: Text(
                        "Text Style",
                        style: TextStyle(color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          select = "textstyle";
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ActionChip(
                      backgroundColor: select == "textfamily"
                          ? Colors.white
                          : Colors.grey.shade300,
                      label: Text(
                        "Text Family",
                        style: TextStyle(color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          select = "textfamily";
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Visibility(
                visible: select == "frame",
                child: Column(
                  children: [
                    Text("Frame",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                          data['image'].map<Widget>((e){
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  backgroundImageSelectedIndex = e;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(e),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: select == "borderradius",
                child: Column(
                  children: [
                    Text("Border Radius",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    Slider(
                      value: _borderRadius,
                      max: 100,
                      min: 0,
                      onChanged: (val) {
                        setState(() {
                          Text('Current Radius: ${_borderRadius
                              .toStringAsFixed(1)}');
                          _borderRadius = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: select == "textsize",
                child: Column(
                  children: [
                    Text("Text Size",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            increment();
                          },
                          child: Icon(Icons.add, color: Colors.black),
                        ),
                        SizedBox(width: 10,),
                        Text("${size}",
                          style: TextStyle(fontSize: 18),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            decrement();
                          },
                          child: Icon(Icons.remove, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: select == "colorpicker",
                child: Column(
                  children: [
                    Text("Color Picker",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    FloatingActionButton(
                      child: Icon(Icons.color_lens),
                      onPressed: () {
                        showColorPickerDialog();
                      },
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: select == "textstyle",
                child: Column(
                  children: [
                    Text("Text Style",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _moveLeft,
                          child: Text('Move Left'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _moveRight,
                          child: Text('Move Right'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _moveCenter,
                          child: Text('Center'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: select == "textfamily",
                child: Column(
                  children: [
                    Text("Text Family",
                        style: TextStyle(
                          fontSize: size,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: fontFamilies.map((e) =>
                        (fontFamilies.indexOf(e) <= 20)
                            ? GestureDetector(
                          onTap: () {
                            setState(() {
                              selFont = e;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10, top: 10),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text("Aa",
                              style: GoogleFonts.getFont(e,
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                            : Container())
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
