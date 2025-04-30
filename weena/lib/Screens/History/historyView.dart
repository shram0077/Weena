import 'package:flutter/material.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/HistoryModel.dart';
import 'package:weena/Screens/History/History_cardView.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/widget.dart';

class HistoryView extends StatefulWidget {
  final String currentUserId;
  const HistoryView({
    super.key,
    required this.currentUserId,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<HistoryModel> _history = [];

  setUpHistory() async {
    List<HistoryModel> history =
        await DatabaseServices.getHistoryViews(widget.currentUserId);
    if (mounted) {
      setState(() {
        _history = history.toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: backButton(context, 20),
        backgroundColor: whiteColor,
        title: text("بینراوەکان", Colors.black, 18, FontWeight.normal,
            TextDirection.rtl),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
          child: _history.isEmpty
              ? Center(
                  child: text("هیج بینراوێک نییە.", Colors.black, 17,
                      FontWeight.w500, TextDirection.rtl),
                )
              : GridView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) => HistoryCardView(
                    currentUserId: widget.currentUserId,
                    historyModel: _history[index],
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 1),
                )),
    );
  }
}
