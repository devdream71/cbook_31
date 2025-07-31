import 'package:flutter/material.dart';

class DemoText extends StatelessWidget {
  const DemoText({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'cBook',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // ← makes back icon white
          ),
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      ),
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      ),
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      ),
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      ),
                      Image.asset(
                        "assets/image/image_color.png",
                        width: 4,
                        height: 16,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 360.00555419921875,
                    height: 0,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/image 1.png",
                                width: 63,
                                height: 63,
                              ),
                              const Text("YouTube",
                                  style: TextStyle(
                                    fontSize: 24,
                                    // fontWeight: FontWeith.w700,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "assets/image/image_color.png",
                                width: 25,
                                height: 16.66666603088379,
                              ),
                              Image.asset(
                                "assets/image/image_color.png",
                                width: 24.998170852661133,
                                height: 25.00244140625,
                              ),
                              Image.asset(
                                "assets/Ellipse 1.png",
                                width: 25,
                                height: 25,
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 360,
                        height: 0,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 360.005859375,
                    height: 0,
                  ),
                  const Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              Text("All",
                                  style: TextStyle(
                                    fontSize: 14,
                                    // fontWeight: FontWeith.w400,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              Text("Cricket",
                                  style: TextStyle(
                                    fontSize: 14,
                                    //fontWeight: FontWeith.w400,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              Text("Comedy Movies",
                                  style: TextStyle(
                                    fontSize: 14,
                                    // fontWeight: FontWeith.w400,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              Text("Meditation Music",
                                  style: TextStyle(
                                    fontSize: 14,
                                    //fontWeight: FontWeith.w400,
                                  ))
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/image 2.png",
                        width: 363,
                        height: 201,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/Ellipse 1.png",
                            width: 33,
                            height: 33,
                          ),
                          const Column(
                            children: [
                              Text(
                                  "A great love Best romantic moments in Yemin- The promise Reyhan vs Emir ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    //fontWeight: FontWeith.w400,
                                  )),
                              Text("VIMA • 34k views • 2 months ago",
                                  style: TextStyle(
                                    fontSize: 13,
                                    // fontWeight: FontWeith.w400,
                                  ))
                            ],
                          ),
                          Image.asset(
                            "assets/image/image_color.png",
                            width: 4,
                            height: 16,
                          )
                        ],
                      )
                    ],
                  ),
                  const Text("Stories",
                      style: TextStyle(
                        fontSize: 16,
                        //fontWeight: FontWeith.w400,
                      )),
                  Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/image/image_color.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                  const Text("Home",
                                      style: TextStyle(
                                        fontSize: 10,
                                        // fontWeight: FontWeith.w400,
                                      ))
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/image/image_color.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                  const Text("Trending",
                                      style: TextStyle(
                                        fontSize: 10,
                                        //fontWeight: FontWeith.w400,
                                      ))
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/image/image_color.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                  const Text("Subscriptions",
                                      style: TextStyle(
                                        fontSize: 10,
                                        //fontWeight: FontWeith.w400,
                                      ))
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/image/image_color.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                  const Text("Inbox",
                                      style: TextStyle(
                                        fontSize: 10,
                                        //fontWeight: FontWeith.w400,
                                      ))
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/image/image_color.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                  const Text("Library",
                                      style: TextStyle(
                                        fontSize: 10,
                                        //fontWeight: FontWeith.w400,
                                      ))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      Image.asset(
                        "assets/Ellipse 2.png",
                        width: 10,
                        height: 10,
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/Polygon 1.png",
                            width: 20,
                            height: 20,
                          ),
                          const Stack(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                              )
                            ],
                          ),
                          Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: const Color(0xffd9d9d9)))
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Stack(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(
                            width: 8.333333015441895,
                            height: 5,
                          )
                        ],
                      ),
                      const Stack(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                          ),
                          SizedBox(
                            width: 15.519999504089355,
                            height: 12.333333969116211,
                          )
                        ],
                      ),
                      const Text(" ",
                          style: TextStyle(
                            fontSize: 24,
                            //fontWeight: FontWeith.w700,
                          )),
                      const Text("12:10",
                          style: TextStyle(
                            fontSize: 14,
                            //fontWeight: FontWeith.w700,
                          )),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Stack(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width: 12,
                                    height: 12.666666984558105,
                                  )
                                ],
                              ),
                              const Stack(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width: 13.258000373840332,
                                    height: 13.460000991821289,
                                  )
                                ],
                              ),
                              Image.asset(
                                "assets/image/image_color.png",
                                width: 16,
                                height: 16,
                              ),
                              Image.asset(
                                "assets/image/image_color.png",
                                width: 14,
                                height: 14,
                              ),
                              Image.asset(
                                "assets/image/image_color.png",
                                width: 14,
                                height: 14,
                              ),
                              Image.asset(
                                "assets/image/image_color.png",
                                width: 10,
                                height: 16,
                              )
                            ],
                          )
                        ],
                      ),
                      const Text("59%",
                          style: TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeith.w700,
                          ))
                    ],
                  )
                ],
              )
            ],
          ),
        )

        //const Text("cBook"),
        );
  }
}
