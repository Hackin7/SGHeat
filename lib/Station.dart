import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:core';
import 'package:charts_flutter/flutter.dart' as charts;

class Station extends StatefulWidget {
  Station({Key key, this.index, this.data, this.date}) : super(key: key);
  int index; //Information about the station, like latitude
  String date;
  Map<String, dynamic> data; //Readings about data
  @override
  StationState createState() => StationState();
}

class StationState extends State<Station>{
  	final List<String> entries = <String>['A', 'B', 'C'];
	final List<int> colorCodes = <int>[600, 500, 100];
	
	bool displaymode = false;//24 hour mode
	double _la=0,_lg=0;
	String _name="", _id = "-";
	int noRead=0;
	List<String> _timings;
	List<String> _readings;
	List<int> _shown;
	List<TemperatureValue> _graphData;
	
	void initState(){ogvalues();}
	void ogvalues(){
		setState(() {
			_name = widget.data['metadata']['stations'][widget.index]['name'];
			_la=widget.data['metadata']['stations'][widget.index]['location']['latitude'];
			_lg=widget.data['metadata']['stations'][widget.index]['location']['longitude'];
			_id = widget.data['metadata']['stations'][widget.index]['id'];
			
			_shown = new List<int>();
			_timings = new List<String>();
			_readings = new List<String>();
			_graphData = List<TemperatureValue>();
			noRead = 0;
			var counter = 0;
			for (var i=widget.data['items'].length-1;i>=0;--i){
				var item = widget.data['items'][i];
				String timestamp = item['timestamp'];
				
				DateTime timing = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(timestamp.substring(0,19));
				if (!displaymode){timestamp = DateFormat('hh:mm a').format(timing);}
				else{timestamp = DateFormat('HH:mm').format(timing);}
				
				String temp = "";
				for (var read in item['readings']){
					if (read['station_id'] == _id){temp = read['value'].toString();}
				}
				if (temp != ""){
					_timings.add(timestamp);
					_readings.add(temp);
					_graphData.add(new TemperatureValue(timing, double.parse(temp)));
					_shown.add(counter);counter++;
					noRead++;
				}
			}
		});
	}
  ///////////////////////////////////////////////////////////////////
  
  ////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context){
	var seriesList = [
      new charts.Series<TemperatureValue, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureValue v , _) => v.time,
        measureFn: (TemperatureValue v, _) => v.temp,
        data: _graphData,
      )
    ];
	Widget chart = new charts.TimeSeriesChart(
      seriesList,
      animate: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("$_name"),
      ),
      body: Container(padding: const EdgeInsets.all(8),
			child:Column(
			crossAxisAlignment: CrossAxisAlignment.start,
		  children: <Widget>[
			Container(
				padding: const EdgeInsets.all(8),
				child: Text('Latitude: ${_la}, Longitude: ${_lg}', 
					textAlign: TextAlign.left,style:TextStyle(fontSize: 15,)),
			),
			Container(
				padding: const EdgeInsets.all(8),
				child: Text('ID: ${_id}, Date: ${widget.date}', 
				textAlign: TextAlign.left,style:TextStyle(fontSize: 15,)),
			),
			Container(
				height: MediaQuery.of(context).size.height/3 ,
				child:chart,
			),
			////////////////////////////////////////////
			Container(
				height: MediaQuery.of(context).size.height/2 - 100 ,
				child: ListView.builder(
				  //padding: const EdgeInsets.all(8),
				  itemCount: noRead,
				  itemBuilder: (BuildContext context, int index) {
					return Container(
					  height: 50,
					  //color: Colors.amber[colorCodes[index]],
					  child: InkWell(
						onTap:(){},
						child:ListTile(
							//leading: FlutterLogo(),
							title: Text('${_timings[index]}'),
							trailing: Text('${_readings[index]}°C'),
						  ),
						),
					);
				  }
				)
			)
			/////////////////////////////////////////////
			
		],))
	);
  }

}

class TemperatureValue{
	double temp;
	DateTime time;
  TemperatureValue(this.time,this.temp);
}