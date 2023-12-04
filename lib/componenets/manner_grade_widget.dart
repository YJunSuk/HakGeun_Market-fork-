import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:hakgeun_market/models/user.dart';
import 'package:hakgeun_market/service/userService.dart';

class MannerGrade extends StatefulWidget {
  final double mannergrade;
  MannerGrade({super.key, required this.mannergrade}) {}

  @override
  State<MannerGrade> createState() => _MannerGradeState();
}

class _MannerGradeState extends State<MannerGrade> {
  late double mannertemp;
  late int level;
  final List<String>_rating = ["-4", "-2", "0", "2", "4"];
  String? _select = "0";

  void _calcTempLevel() {
    setState(() {
      if (1 >= mannertemp) {
        level = 0;
      } else if (1 < mannertemp && 1.5 >= mannertemp) {
        level = 1;
      } else if (1.5 < mannertemp && 2.0 >= mannertemp) {
        level = 2;
      } else if (2.0 < mannertemp && 3.0 >= mannertemp) {
        level = 3;
      } else if (3.0 < mannertemp && 4.0 >= mannertemp) {
        level = 4;
      } else if (4.0 < mannertemp) {
        level = 5;
      }
    });
  }

  final List<Color> gradeColors = [
    Color(0xff072038),
    Color(0xff0d3a65),
    Color(0xff186ec0),
    Color(0xff37b24d),
    Color(0xffffad13),
    Color(0xfff76707),
  ];

  @override
  void initState() {
    // 위젯이 생성될 때 Firebase에서 데이터를 가져옴.(상태초기화)
    super.initState();
    mannertemp = 3.0;
    _calcTempLevel();
  }

  void _updateMannerTemp(String selectedValue) {
    setState(() {
      _select = selectedValue;
      mannertemp += double.parse(selectedValue) / 4.5;
      if(mannertemp < 0){
        mannertemp = 0;
      }
      else if(mannertemp > 4.5){
        mannertemp = 4.5;
      }
      _calcTempLevel();
    });
    updateTemperature();
  }


  void updateTemperature() async {
  String userId = '양준석';
  double newTemperature = mannertemp; // 새로운 매너 온도 값

  try {
    await UserService().updateUserMannerTemperature(userId as UserModel, newTemperature);
    print('매너 온도가 성공적으로 업데이트되었습니다.');
  } catch (e) {
    print('매너 온도 업데이트 중 오류 발생: $e');
  }
  }

  Widget _temp(final select) {
  return TextButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text("평가하기"),
                content: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: <Widget>[
                    Text("상품거래의 만족도를 표현해주세요!"),
                    DropdownButton<String>(
                      value: null,
                      hint: Text("5개의 평가 중 하나를 골라주세요!"),
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      onChanged: (String? value) {
                        setState(() {
                          _select = value!;
                        });
                      },
                      items: _rating.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ]
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("확인"),
                    onPressed: () {
                      _updateMannerTemp(_select!);
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                  ),
                ],
              );
            },
          );
        }
      );
    },
    child: Container(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "매너온도: ${mannertemp.toInt()}",
            style: TextStyle(
              color: gradeColors[level],
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 6,
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  Container(
                    height: 6,
                    width: 70 / 4.5 * mannertemp,
                    color: gradeColors[level]
                  ),
                ],
              )
            )
          )
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _temp(_select),
              SizedBox(width: 7),
              _tempIcon(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tempIcon() {
    return Container(
      width: 30,
      height: 30,
      child: Image.asset("assets/images/level-${level}.jpg"),
    );
  }
}
