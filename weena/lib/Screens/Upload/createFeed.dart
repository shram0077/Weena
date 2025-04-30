import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Widgets/widget.dart';

class CreateFeed extends StatefulWidget {
  final String currentUserId;
  final List<XFile> imagefiles;
  const CreateFeed(
      {super.key, required this.currentUserId, required this.imagefiles});

  @override
  State<CreateFeed> createState() => _CreateFeedState();
}

class _CreateFeedState extends State<CreateFeed> {
  String? _productType;
  List<String> listOFtypeProduct = [
    'ئامێری ئەلیکترۆنی',
    'پۆشاک و کەمالیات',
    'کاتژمێر',
  ];
  // parts
// Electronic Product
  String? _electronicProduct;
  List<String> listOFelectronicProduct = [
    'کۆمپیوتەر',
    'هێڵی ئینتەرنێت',
    'مۆبایل',
    'کاتژمێری زیرەک',
    'تابلێت / ئایپاد',
    'کـــــــامیرە',
    'جۆریتر ',
  ];
  // Clothing and groceries
  String? _clothingProduct;
  List<String> listOFclothingProduct = [
    'جل و بەرگ ',
    'بابەتی جوانکاری',
    'بابەتی خانمان',
    'بابەتی پیاوان',
  ];
  // Watches
  String? _watchesProduct;
  List<String> listOFwatchesProduct = [
    'کاتژمێری پیاوان',
    'کاتژمێری ئافرەتان',
  ];
  bool _isLoading = false;
  String? _description;
  final int _likes = 0;
  final int _dislikes = 0;
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  final TextEditingController _descriptionController = TextEditingController();
  pickImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      imagefiles = pickedfiles;
      setState(() {});
    } catch (e) {
      print("error while picking file.");
    }
  }

// upload to Cloud Storage
  Future<List<String>> uploadImagesToCloudStorage(List<XFile> images) async {
    List<String> imagesUrls = [];
    var postuid = const Uuid().v4();
    images.forEach((image) async {
      setState(() {
        _isLoading = true;
      });
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('Feeds/Feeds OF ${widget.currentUserId}/$postuid.jpg');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      await uploadTask;

      imagesUrls.add(await storageReference.getDownloadURL());
      // upload to cloud Firestore
      post(imagesUrls, postuid);
      setState(() {
        _isLoading = false;
        imagefiles = null;
      });
    });

    print(imagesUrls);
    return imagesUrls;
  }

// Upload to Cloud Firestore
  Future<void> post(List<String> imageUrls, String postId) async {
    if (imageUrls.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      if (_description == null) {
        setState(() {
          _description = '';
        });
      } else {
        _description = _description;
      }
      await feedsRef
          .doc(widget.currentUserId)
          .collection('Feeds')
          .doc(postId)
          .set({
        "description": _description,
        "images": [],
        "likes": _likes,
        "timestamp": Timestamp.now(),
        "postId": postId,
        "ownerId": widget.currentUserId,
        "type": ""
      }).whenComplete(() {
        _isLoading = false;
        Navigator.pop(context);
        print('Feeded!');
      });
    } else {
      if (_description == null) {
        setState(() {
          _description = '';
        });
      } else {
        _description = _description;
      }
      setState(() {
        _isLoading = true;
      });
      await feedsRef
          .doc(widget.currentUserId)
          .collection('Feeds')
          .doc(postId)
          .set({
        "description": _description,
        "images": [],
        "likes": _likes,
        "timestamp": Timestamp.now(),
        "postId": postId,
        "ownerId": widget.currentUserId,
        "type": ""
      }).whenComplete(() {
        _isLoading = false;
        Navigator.pop(context);
        print('Feeded!');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
            actions: [
              _descriptionController.text.isEmpty
                  ? const SizedBox()
                  : _isLoading
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              var postuid = const Uuid().v4();

                              if (imagefiles == null) {
                                post([], postuid);
                              } else {
                                uploadImagesToCloudStorage(imagefiles!);
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: moviePageColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: Text(
                                  "پۆست",
                                  style: GoogleFonts.barlow(
                                      fontSize: 20,
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        )
            ],
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: backButton(context, 23),
            backgroundColor: moviePageColor,
            title: text("دانانی کاڵای نوێ", whiteColor, 21, FontWeight.normal,
                TextDirection.rtl)),
        body: ListView(
          children: [
            _isLoading
                ? const LinearProgressIndicator(
                    backgroundColor: whiteColor,
                    color: moviePageColor,
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'جۆری کاڵا هەڵبژێرە',
                          style: GoogleFonts.barlow(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  // Product Type
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: moviePageColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8)),
                        isExpanded: true,
                        value: _productType,
                        dropdownColor: moviePageColor,
                        iconEnabledColor: Colors.white,
                        focusColor: Colors.white,
                        hint: const Text(
                          'جۆری کاڵا هەڵبژێرە',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.white),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _productType = value;
                            listOFtypeProduct = listOFtypeProduct;
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _productType = value;
                            listOFtypeProduct = listOFtypeProduct;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Type can't empty";
                          } else {
                            return null;
                          }
                        },
                        items: listOFtypeProduct.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),_productType!=null?const Divider(
                    color: Colors.grey,
                    thickness: 0.1,
                    indent: 3,
                    endIndent: 3,
                  ):const SizedBox(),
                  _productType!=null?   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'بەش هەڵبژێرە',
                        style: GoogleFonts.barlow(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ):const SizedBox(),
                  const SizedBox(height: 13,),
                  // Electronic Product Part
                  _productType != 'ئامێری ئەلیکترۆنی'
                      ? const SizedBox()
                      : Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: moviePageColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8)),
                              isExpanded: true,
                              value: _electronicProduct,
                              dropdownColor: moviePageColor,
                              iconEnabledColor: Colors.white,
                              focusColor: Colors.white,
                              hint: const Text(
                                'بەش هەڵبژێرە',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(color: Colors.white),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _electronicProduct = value;
                                  listOFtypeProduct = listOFtypeProduct;
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _electronicProduct = value;
                                  listOFtypeProduct = listOFtypeProduct;
                                });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Type can't empty";
                                } else {
                                  return null;
                                }
                              },
                              items: listOFelectronicProduct.map((String val) {
                                return DropdownMenuItem(
                                  value: val,
                                  child: Text(
                                    val,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                  // Poshaku Kamlyat
                  _productType != 'پۆشاک و کەمالیات'
                      ? const SizedBox()
                      : Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: moviePageColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8)),
                        isExpanded: true,
                        value: _clothingProduct,
                        dropdownColor: moviePageColor,
                        iconEnabledColor: Colors.white,
                        focusColor: Colors.white,
                        hint: const Text(
                          'بەش هەڵبژێرە',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.white),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _clothingProduct = value;
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _clothingProduct = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Type can't empty";
                          } else {
                            return null;
                          }
                        },
                        items: listOFclothingProduct.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Watches
                  _productType != 'کاتژمێر'
                      ? const SizedBox()
                      : Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: moviePageColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8)),
                        isExpanded: true,
                        value: _watchesProduct,
                        dropdownColor: moviePageColor,
                        iconEnabledColor: Colors.white,
                        focusColor: Colors.white,
                        hint: const Text(
                          'بەش هەڵبژێرە',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.white),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _watchesProduct = value;
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _watchesProduct = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Type can't empty";
                          } else {
                            return null;
                          }
                        },
                        items: listOFwatchesProduct.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  widget.imagefiles != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'وێنەکان',
                              style: GoogleFonts.barlow(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      : const SizedBox(),
                  widget.imagefiles != null
                      ? const Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 3,
                          endIndent: 3,
                        )
                      : const SizedBox(),
                  widget.imagefiles != null
                      ? Wrap(
                          children: widget.imagefiles.map((imageone) {
                            return Container(
                                child: Card(
                              child: SizedBox(
                                height: 120,
                                width: 120,
                                child: Image.file(File(imageone.path),
                                    fit: BoxFit.cover),
                              ),
                            ));
                          }).toList(),
                        )
                      : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
