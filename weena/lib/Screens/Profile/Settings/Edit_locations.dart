import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/widget.dart';

class EditLocation extends StatefulWidget {
  final UserModell userModell;

  const EditLocation({super.key, required this.userModell});
  @override
  State<EditLocation> createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _country;
  late String _cityorTown;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _country = widget.userModell.country;
    _cityorTown = widget.userModell.cityorTown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: Text(
            'ناونیشان'.tr,
            style: GoogleFonts.lato(fontSize: 20, color: Colors.black),
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: whiteColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
        ),
        body: ListView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        text(
                            "تێبینی:- تکایە ژمارەی دوکان لەبیر مەکە.",
                            const Color.fromARGB(255, 158, 158, 158),
                            15,
                            FontWeight.normal,
                            TextDirection.rtl),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 4),
                        child: TextFormField(
                          maxLength: 500,
                          initialValue: _cityorTown,
                          style: GoogleFonts.lato(fontSize: 19),
                          onChanged: (value) {
                            _cityorTown = value;
                          },
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'ناونیشان',
                            hintStyle: GoogleFonts.lato(fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        text(
                            "نموونە:- ماجدی مۆڵ/ژ١٢",
                            const Color.fromARGB(255, 158, 158, 158),
                            15,
                            FontWeight.normal,
                            TextDirection.rtl),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                          color: const Color.fromARGB(200, 71, 68, 68),
                          splashColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("CANCEL".tr,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: whiteColor)),
                        ),
                        MaterialButton(
                          splashColor: const Color.fromARGB(0, 255, 214, 64),
                          onPressed: () {
                            saveProfile();
                          },
                          color: moviePageColor,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "SAVE".tr,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? CircleProgressIndicator()
                        : const SizedBox.shrink()
                  ],
                ),
              )
            ]));
  }

  Future saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    UserModell user = UserModell(
        pushToken: widget.userModell.pushToken,
        username: widget.userModell.username,
        activeTime: widget.userModell.activeTime,
        cityorTown: _cityorTown,
        country: _country,
        coverPicture: widget.userModell.coverPicture,
        admin: widget.userModell.admin,
        id: widget.userModell.id,
        name: widget.userModell.name,
        profilePicture: widget.userModell.profilePicture,
        bio: widget.userModell.profilePicture,
        email: widget.userModell.email,
        verification: widget.userModell.verification,
        joinedAt: widget.userModell.joinedAt,
        isVerified: widget.userModell.isVerified,
        type: widget.userModell.type);
    DatabaseServices.updateCountryorCity(user);
    Navigator.pop(context);
  }
}
