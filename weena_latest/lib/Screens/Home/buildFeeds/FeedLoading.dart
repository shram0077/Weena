import 'package:flutter/material.dart';
import 'package:weena_latest/Constant/constant.dart';

class FeedLoading extends StatefulWidget {
  const FeedLoading({Key? key}) : super(key: key);

  @override
  State<FeedLoading> createState() => _FeedLoadingState();
}

class _FeedLoadingState extends State<FeedLoading> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  color: shadowColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 25,
                          decoration: BoxDecoration(
                              color: shadowColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Container(
                              width: 30,
                              height: 25,
                              decoration: BoxDecoration(
                                  color: shadowColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6)),
                            )),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(
                          5.0,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 25,
                          decoration: BoxDecoration(
                              color: shadowColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6)),
                        )),
                    Material(
                      color: appBarColor,
                      borderRadius: BorderRadius.circular(10.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(),
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                height: 250,
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(159, 40, 39, 39),
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
