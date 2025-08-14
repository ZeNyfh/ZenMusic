import 'package:flutter/material.dart';
import 'package:zenmusic/ui/objects/CustomNavBar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      bottomNavigationBar: CustomNavBar(currentIndex: 0, context: context),
      body: Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: Color(0x1f000000),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: Color(0x4d9e9e9e), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: TextField(
                  controller: TextEditingController(),
                  obscureText: false,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12,
                    color: Color(0xff000000),
                  ),
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide:
                      BorderSide(color: Color(0xff000000), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide:
                      BorderSide(color: Color(0xff000000), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide:
                      BorderSide(color: Color(0xff000000), width: 1),
                    ),
                    labelText: "Search:",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      color: Color(0xff000000),
                    ),
                    filled: true,
                    fillColor: Color(0xfff2f2f3),
                    isDense: false,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    prefixIcon:
                    Icon(Icons.search, color: Color(0xff212435), size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
