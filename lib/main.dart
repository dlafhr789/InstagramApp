import 'package:flutter/material.dart';
// import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c) => Store1()),
          ChangeNotifierProvider(create: (c) => Store2()),
        ],
        child: MaterialApp(
            // theme : style.theme,
            home : MyApp()
        ),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var tab = 0;  // 0이면 home, 1이면 shop
  var dataNum = 3;
  var data = [];
  var userimage;
  var userContent;

  saveData() async {
    var storage = await SharedPreferences.getInstance();

    var map = {'age' : 20};
    storage.setString('map', jsonEncode(map));
    var result = storage.getString("map") ?? "없는데요";
    print(jsonDecode(result));
  }

  addMyData(){
    var myData = {'id' : data.length, 'image' : userimage, 'likes' : 881, 'date' : 'August 13', 'content' : userContent, 'liked' : false, 'user' : 'HyeonJe Jang'};
    setState(() {
      data.insert(0, myData);
      print(data);
    });
  }

  setUserContent(text){
    setState(() {
      userContent = text;
    });
  }

  getdata() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if(result.statusCode == 200){
      print('서버 통신 성공');
    } else {
      print('서버 통신 실패');
    }
    var result2 = jsonDecode(result.body);
    print(result2);
    setState(() {
      data = result2;
    });
  }

  adddata() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more2.json'));
    if(result.statusCode == 200){
      print('서버 통신 성공');
      print(jsonDecode(result.body));
      setState(() {
        dataNum = 4;
        data.add(jsonDecode(result.body));
      });
    }
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getdata();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text('Instagram', style: TextStyle(color: Colors.black, fontSize: 23),),
        actions: [
          IconButton(onPressed: () async {
            var picker = ImagePicker();
            var image = await picker.pickImage(source: ImageSource.gallery);
            if(image != null) {
              setState(() {
                userimage = File(image.path);
              });
            }
            Navigator.push(context,
              MaterialPageRoute(builder: (c) => upload(userimage : userimage, setUserContent : setUserContent, addMyData : addMyData))
            );
          }, icon: Icon(Icons.add_box_outlined), iconSize: 30, color: Colors.black87,),
      ],),
      body: [homePage(data : data, dataNum : dataNum, adddata : adddata) ,Text('샵페이지')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i){
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.black54,),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.black54,),
            label: 'shoppingbag'
          )
        ],
      ),

    );
  }
}

class homePage extends StatefulWidget {
  const homePage({super.key, this.data, this.dataNum, this.adddata});
  final data;
  final dataNum;
  final adddata;

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {

  var scroll = ScrollController();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scroll.addListener(() {
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        print('같음.');
        widget.adddata();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if(widget.data.isNotEmpty){
      return ListView.builder(itemCount: widget.dataNum, controller: scroll, itemBuilder: (c, i){
        return Column(
          children: [
            widget.data[i]['image'].runtimeType == String
                ? Image.network(widget.data[i]['image'])
                : Image.file(widget.data[i]['image']),
            Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(onTap: (){
                    Navigator.push(context,
                      CupertinoPageRoute(builder: (c) => Profile())
                    );
                  }, child: Text(widget.data[i]['user']),),
                  Text('좋아요 ${widget.data[i]['likes']}',style: TextStyle(color: Colors.black),),
                  Text(widget.data[i]['content'],style: TextStyle(color: Colors.black),),
                  Text(widget.data[i]['date'],style: TextStyle(color: Colors.black),),
                ],
              ),
            )
          ],
        );
      });
    } else {
      return Text('loading...');
    }

  }
}

class upload extends StatelessWidget {
  const upload({super.key, this.userimage, this.setUserContent, this.addMyData});
  final userimage;
  final addMyData;
  final setUserContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('사진 업로드', style: TextStyle(color: Colors.black, fontSize: 23),),
        actions: [
          IconButton(onPressed: (){
            addMyData();
            Navigator.pop(context);
          }, icon: Icon(Icons.send, color: Colors.black, size: 25,))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.black,
            height: 70,
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Flexible(child: Image.file(userimage), flex: 2,),
                Flexible(child: Container(
                  child: TextField(
                    onChanged: (text){setUserContent(text);},
                    decoration: InputDecoration(
                    hintText: '문구 입력..',
                    enabledBorder: InputBorder.none,

                  ),),
                  padding: EdgeInsets.all(10),
                ), flex: 8, ),
              ],
            ),
          ),
          SizedBox(
            child: Divider(color: Colors.grey, thickness: 1.0,),
          ),
          SizedBox(
            child: Text('어쩌고 저쩌고 블라블라...'),
          )
        ],
      ),
    );
  }
}


class Store1 extends ChangeNotifier {
  var follower = 0;
  var followed = false;
  var followText = '팔로우';
  var profileImage = [];

  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    notifyListeners();
  }

  addFollower(){
    !followed ? (follower++, followed = true, followText = '언팔로우') : (follower--, followed = false, followText = '팔로우');
    print(followed);
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier {
  var name = 'john kim';
  changeName(){
    name = 'john park';
    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<Store2>().name, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ElevatedButton(onPressed: (){
          //   context.read<Store1>().changeName();
          //   }, child: Text('changName')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.circle, color: Colors.grey, size: 70,),
              Center(child: Text('팔로워 ${context.watch<Store1>().follower}명')),
              ElevatedButton(onPressed: (){
                context.read<Store1>().addFollower();
              }, child: Center(child: Text(context.read<Store1>().followText))),
              ElevatedButton(onPressed: (){
                context.read<Store1>().getData();
              }, child: Center(child: Text('사진 가져오기'))),
            ],
          )
        ],
      ),

    );
  }
}
