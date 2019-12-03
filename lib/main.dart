import 'package:flutter/material.dart';
import 'package:SGHeat/Station.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'dart:convert';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGHeat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SGHeat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now()); //"Not Set";
  Map<String, dynamic> retrievedData;
  List<String> _stationsList = new List<String>();
  int _noStations=0;
  //JSON Data Retrieved
  
  void getData(){
	notify("Retrieving Data");
	String url = "https://api.data.gov.sg/v1/environment/air-temperature?date="+_date;//2019-12-03"
	_makeGetRequest(url);
  }
  _makeGetRequest(String url) async{
	  // make GET request
	  Response response = await get(url);
	  // sample info available in response
	  int statusCode = response.statusCode;
	  Map<String, String> headers = response.headers;
	  String contentType = headers['content-type'];
	  String jsonString = response.body;
	  print(jsonString);
	  if (statusCode!=200){}
	  // convert json to object...
	  retrievedData = jsonDecode(jsonString);
	  updateData();
	}
  void updateData(){
	setState(() {
		_stationsList.clear();
		_noStations = retrievedData['metadata']['stations'].length;
		for (var i = 0; i < retrievedData['metadata']['stations'].length; i++) {
			_stationsList.add(retrievedData['metadata']['stations'][i]['name']);
		}
    });
	//try {stationsList.clear();}on Exception {print("Clearing List Failed");}
	
	print(retrievedData['metadata']['stations'][0]['name']);
  }
  
  BuildContext _scaffoldContext;
  void notify(String val) {
	  print(val);
    Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
      content: new Text(val),
      duration: new Duration(seconds: 5),
    ));
  }
  
  @override
  Widget build(BuildContext context) {
	  //https://stackoverflow.com/questions/51304568/scaffold-of-called-with-a-context-that-does-not-contain-a-scaffold
	  //Widget DateChanger = Text("DateChanger Placeholder");
	//Widget DateChanger = 
	return Scaffold(
	  appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  new Builder(builder: (BuildContext context) { _scaffoldContext = context;
			return Container(padding: const EdgeInsets.all(8),
			child:Column(
			crossAxisAlignment: CrossAxisAlignment.start,
		  children: <Widget>[
			Container(
				padding: const EdgeInsets.all(8),
				child: Text('Stations', 
					textAlign: TextAlign.left,style:TextStyle(fontSize: 20,)),
			),
			//////////////////////////////////////////
			RaisedButton(
		shape: RoundedRectangleBorder(
			borderRadius: BorderRadius.circular(5.0)),
		elevation: 4.0,
		onPressed: () {
		  DatePicker.showDatePicker(context,
			  theme: DatePickerTheme(containerHeight: 210.0, ),
			  showTitleActions: true,
			  minTime: DateTime(2000, 1, 1),
			  maxTime: DateTime.now(), onConfirm: (date) {
			//_date = '${date.year}-${date.month}-${date.day}';//
			_date = DateFormat('yyyy-MM-dd').format(date);
			setState(() {});
			getData();
			/*
			Scaffold.of(context).showSnackBar(new SnackBar(
			  content: new Text("Loading"),
			  duration: new Duration(seconds: 5),
			));*/
		  }, currentTime: DateTime.now(), locale: LocaleType.en);
		},
		child: Container(
		  alignment: Alignment.center,
		  height: 50.0,
		  child: Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: <Widget>[
			  Row(
				children: <Widget>[
				  Container(
					child: Row(
					  children: <Widget>[
						Icon(
						  Icons.date_range,
						  size: 18.0,
						  color: Colors.teal,
						),
						Text(
						  " $_date",
						  style: TextStyle(
							  color: Colors.teal,
							  fontWeight: FontWeight.bold,
							  fontSize: 18.0),
						),
					  ],
					),
				  )
				],
			  ),
			  Text(
				"  Change",
				style: TextStyle(
					color: Colors.teal,
					fontWeight: FontWeight.bold,
					fontSize: 18.0),
			  ),
			],
		  ),
		),
		color: Colors.white,
	  ),
			//////////////////////////////////////////
			Container(
				height: MediaQuery.of(context).size.height-200,
				child: ListView.builder(
				  //padding: const EdgeInsets.all(8),
				  itemCount: _noStations,
				  itemBuilder: (BuildContext context, int index) {
					return Container(
					  height: 50,
					  //color: Colors.amber[colorCodes[index]],
					  child: InkWell(
						onTap:(){
							Navigator.push(context,MaterialPageRoute(builder: (context) =>
							Station(index:index, data:retrievedData, date:_date)));
						},
						child:ListTile(
							//leading: FlutterLogo(),
							title: Text('${_stationsList[index]}'),
							//trailing: Text('${entries[0]}'),
						  ),
						),
					);
				  }
				)
			)
			/////////////////////////////////////////////
	  ],));
	  }),
	  );
  }
}
