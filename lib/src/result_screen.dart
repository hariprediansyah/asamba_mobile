import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double appBarHeight = AppBar().preferredSize.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: MediaQuery.of(context).size.height - appBarHeight,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Lottie.asset("assets/lottie/success.json",
                      width: 200, height: 200, repeat: false),
                  SizedBox(
                    height: 16,
                  ),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Submit Success!",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Color.fromARGB(255, 71, 71, 71),
                            ),
                          ),
                          Text(
                            "Your application has been successfully submitted.",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 18, 18, 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Details",
                              textAlign: TextAlign.start,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 18, 18, 18),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Company",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 112, 112, 112),
                                ),
                              ),
                              Text(
                                "Comany Name",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 51, 51, 51),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Employee Code",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 112, 112, 112),
                                ),
                              ),
                              Text(
                                "Employee Code",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 51, 51, 51),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Employee Name",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 112, 112, 112),
                                ),
                              ),
                              Text(
                                "Employee Name",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 51, 51, 51),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Type",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 112, 112, 112),
                                ),
                              ),
                              Text(
                                "Type",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 31, 31, 31),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 10,
            left: 10,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                    60,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  )),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(
                "Back to Home",
                style: GoogleFonts.rubik(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
