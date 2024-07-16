import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';

class excel extends StatefulWidget {
  const excel({super.key});

  @override
  State<excel> createState() => _excelState();
}

class _excelState extends State<excel> {
  int countOfProcess =0;
  int lastIndex =0;
  ex.Sheet? sheet;
  bool isHidden=true;
  List<Map<dynamic,dynamic>> dataInformation=[];
  List<Map<dynamic,dynamic>> answer=[];
  // Map<dynamic,dynamic> answersData={
  //   1:1,
  //   2:1,
  //   3:,
  //   4:,
  //   5:,
  //   6:,
  //   7:,
  //   8:,
  //   9:,
  //   10:,
  //   11:,
  //   12:,
  //   13:,
  //   14:,
  //   15:,
  //   16:,
  //   17:,
  //   18:,
  //   19:,
  //   20:,
  //   21:,
  //   22:,
  //   23:,
  //   24:,
  //   25:,
  //   26:,
  //   27:,
  //   28:,
  //   29:,
  //   30:,
  //   31:,
  //   32:,
  //   33:,
  //   34:,
  //   35:,
  //   36:,
  //   37:,
  //   38:,
  //   39:,
  //   40:,
  //   41:,
  //   42:,
  //   43:,
  //   44:,
  //   45:,
  //   46:,
  //   47:,
  //   48:,
  //   49:,
  //   50:,
  //   51:,
  //   52:,
  //   53:,
  //   54:,
  //   55:,
  //   56:,
  //   57:,
  //   58:,
  //   59:,
  //   60:,
  //   61:,
  //   62:,
  //   63:,
  //   64:,
  //   65:,
  //   66:,
  //   67:,
  //   68:,
  //   69:,
  //   70:,
  //   71:,
  //   72:,
  //   73:,
  //   74:,
  //   75:,
  //   76:,
  //   77:,
  //   78:,
  //   79:,
  //   80:,
  //   81:,
  //   82:,
  //   83:,
  //   84:,
  //   85:,
  //   86:,
  //   87:,
  //   88:,
  //   89:,
  //   90:,
  // };


  // answerStrcture{
  // "question_option_id": key,
  // "pationt_answer": value
  // }

  // Map<String, dynamic> storeDate = {
  // "advicor_id": CacheHelper.getData(key: 'id'),
  // "pationt_id": widget.pationt_data['pationt']['id'],
  // "need_other_session": needOtherSession,
  // "consultation_service_id": selected_consultation_service,
  // "comments": advicorComment.text,
  // "date":_selectedDate?.toString() ?? '',
  // "answers": lastAnswers
  // };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: (){
                  _openFilePicker().then((value) {
                    sheet = value;
                    countOfProcess = int.parse((sheet!.maxRows/50).ceil().toString());
                    setState(() {
                      isHidden=false;
                    });
                  });
                },
                child: Text("read")
            ),
        isHidden? SizedBox():Expanded(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10.0, // Space between columns
                mainAxisSpacing: 10.0, // Space between rows
                childAspectRatio: 1.0, // Aspect ratio of each tile
              ),
              itemCount: countOfProcess, // Number of items in the grid
              itemBuilder: (context, index) {
                return ElevatedButton(onPressed: (){
                  try {
                    if(index == 0){
                      form(2, 50);

                    }
                    else{
                      form(index * 50+1, (index * 50) + 50);
                    }
                    //index = x+1 ,
                    //index = 1 , start = 50,end = 100
                    //index =  2, start = 101,end = 150
                    //index =  3, start = 151,end = 200
                    //index =  4, start = 201,end = 250


                  }catch(e){
                    form(index * 50+1,sheet?.maxRows);

                  }}, child: Text("number #$index "));
          
              }
                ),
        ),
            ElevatedButton(
                onPressed: (){
                   dataInformation.forEach(
                      (element) {
                        print(element);
                      }
                    );
                },
                child: Text("Print")
            )
          ],
        ),
      ),
    );
  }

  Future<ex.Sheet?> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'], // Limit to Excel files
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!;
      print('===========>${file.path}');
      // Now you have the file path, proceed to read the Excel file
      return _readExcel(filePath);
    }
    else{
      return null;
    }
  }

  Future<ex.Sheet> _readExcel(String filePath) async {
    // Open the Excel file
    var bytes = File(filePath).readAsBytesSync();
    // var bytes = File("/data/user/0/com.example.uploaddata/cache/file_picker/1719663025693/ملف حالات 2023.xlsx").readAsBytesSync();
    var excelFile = ex.Excel.decodeBytes(bytes);

    // Get the first sheet
    var table = excelFile.tables.keys.first;
    var sheet = excelFile.tables[table];

    print(sheet!.maxColumns);
    print(sheet.maxRows);

    return sheet;
  }

  void form(start, end) {
    // Access rows and cells
    for (var row in sheet!.rows.getRange(start, end)) {
      Map<dynamic,dynamic> temp = {};
      List<Map<dynamic,dynamic>> allAnswers = [];
      int counter = 0;
      temp.addAll({
        "answers":[]
      });
      for (var cell in row) {
        if(counter==4){temp.addAll({"advicor_id":cell?.value});}
        //****** Note id
        if(counter==4){temp.addAll({"pationt_id":cell?.value});}
        if(counter==88){temp.addAll({"need_other_session":cell?.value});}
        //****** Note consultationSelected
        if(counter==89){temp.addAll({"consultation_service_id":cell?.value});}
        if(counter==85){temp.addAll({"comments":cell?.value});}
        if(counter==5){temp.addAll({"date":cell?.value});}
        //******answers
        if(counter==11){
          allAnswers.add(
              {
                "question_option_id": 169,
                "pationt_answer": cell?.value,
              }
          );
        }

        if(counter==12){
          allAnswers.add(
              {
                "question_option_id": 171,
                "pationt_answer": cell?.value,
              }
          );
        }

        if(counter==13){
          allAnswers.add(
              {
                "question_option_id": 170,
                "pationt_answer": cell?.value,
              }
          );
        }

        if(counter==14){
          allAnswers.add(
              {
                "question_option_id": 172,
                "pationt_answer": cell?.value,
              }
          );
        }

        //  نعم = 1 && لا=0
        if(counter==15){
          allAnswers.add(
              {
                "question_option_id": 177,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==16){
          allAnswers.add(
              {
                "question_option_id": 178,
                "pationt_answer": cell?.value,
              }
          );
        }

        if(counter==17){
          allAnswers.add(
              {
                "question_option_id": 180,
                "pationt_answer": cell?.value,
              }
          );
        }


        if(counter==18){
          allAnswers.add(
              {
                "question_option_id": 181,
                "pationt_answer": cell?.value,
              }
          );
        }


        if(counter==19){
          allAnswers.add(
              {
                "question_option_id": 182,
                "pationt_answer": cell?.value,
              }
          );
        }


        if(counter==20){
          if(cell?.value==0){
            allAnswers.add(
                {
                  "question_option_id": 184,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==1){
            allAnswers.add(
                {
                  "question_option_id": 185,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==2){
            allAnswers.add(
                {
                  "question_option_id": 186,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==3){
            allAnswers.add(
                {
                  "question_option_id": 187,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==4){
            allAnswers.add(
                {
                  "question_option_id": 188,
                  "pationt_answer": cell?.value,
                }
            );
          }

        }
        if(counter==21){
          if(cell?.value==0){
            allAnswers.add(
                {
                  "question_option_id": 189,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==1){
            allAnswers.add(
                {
                  "question_option_id": 190,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==2){
            allAnswers.add(
                {
                  "question_option_id": 191,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==3){
            allAnswers.add(
                {
                  "question_option_id": 192,
                  "pationt_answer": cell?.value,
                }
            );
          }
          if(cell?.value==4){
            allAnswers.add(
                {
                  "question_option_id": 193,
                  "pationt_answer": cell?.value,
                }
            );
          }

        }

        if(counter==24){
          allAnswers.add(
              {
                "question_option_id": 195,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==25){
          allAnswers.add(
              {
                "question_option_id": 194,
                "pationt_answer": cell?.value,
              }
          );
        }


        if(counter==27){
          if(cell?.value!=null)
            allAnswers.add(
                {
                  "question_option_id": 200,
                  "pationt_answer": cell?.value,
                }
            );

        }
        if(counter==28){
          if(cell?.value==1&&(cell?.value!=null)){
           allAnswers.add(
               {
                 "question_option_id": 198,
                 "pationt_answer": cell?.value,
               }
           );
         }
         else if(cell?.value==0&&(cell?.value!=null)){
           allAnswers.add(
               {
                 "question_option_id": 199,
                 "pationt_answer": cell?.value,
               }
           );
         }
        }


        if(counter==29){
          allAnswers.add(
              {
                "question_option_id": 201,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==30){
          allAnswers.add(
              {
                "question_option_id": 202,
                "pationt_answer": cell?.value,
              }
          );
        }


        if(counter==31){
          allAnswers.add(
              {
                "question_option_id": 203,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==32){
          allAnswers.add(
              {
                "question_option_id": 204,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==33){
          allAnswers.add(
              {
                "question_option_id": 205,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==34&&cell?.value!= null){

          allAnswers.add(
              {
                "question_option_id": 208,
                "pationt_answer": cell?.value,
              }
          );
        }
        if(counter==35&&cell?.value!= null){
          if(cell?.value==1) {
            allAnswers.add(
                {
                  "question_option_id": 206,
                  "pationt_answer": cell?.value,
                }
            );
          }else{
            allAnswers.add(
                {
                  "question_option_id": 207,
                  "pationt_answer": cell?.value,
                }
            );

          }
        }


        if(counter==38&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 209,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==39&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 210,
                  "pationt_answer": cell?.value,
                }
            );
        }


        if(counter==40&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 211,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==41&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 212,
                  "pationt_answer": cell?.value,
                }
            );
        }


        if(counter==42&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 218,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==43&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 219,
                  "pationt_answer": cell?.value,
                }
            );
        }


        if(counter==44&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 213,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==45&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 214,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==46&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 215,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==47&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 216,
                  "pationt_answer": cell?.value,
                }
            );
        }
        //دين شخصي
        if(counter==49&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 217,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==50&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 223,
                  "pationt_answer": cell?.value,
                }
            );
        }


        if(counter==50&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 223,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==51&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 224,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==52&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 225,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==53&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 226,
                  "pationt_answer": cell?.value,
                }
            );
        }


        if(counter==54&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 229,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==55&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 230,
                  "pationt_answer": cell?.value,
                }
            );
        }
        //كم عامل وكم يكلفك المفروض سؤالين
        if(counter==56&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 232,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==57&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 234,
                  "pationt_answer": cell?.value,
                }
            );
        }
        if(counter==59&&cell?.value!= null){

            allAnswers.add(
                {
                  "question_option_id": 233,
                  "pationt_answer": cell?.value,
                }
            );
        }





        // print(cell?.value);
        // temp.addAll({
        //   counter:cell?.value,
        // });
        counter++;
      }
      dataInformation.add(temp);
      temp={};
      counter=0;
      setState(() {

      });
    }
  }
   store(Map<String, dynamic> storeData) async {
     final Dio dio = Dio();
    try {
      print('Request Data: $storeData');
      final response = await dio.post(
        '/api/advicor/form',
        data: storeData,
        options: Options(
            headers: {
              "api-password": "",
              "token": "",
            }
        ),
      );
      print('Response Data: ${response.data}');
      return response;
    } on DioError catch (e) {
      print('Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

}
