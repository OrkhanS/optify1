import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MyItemScreenInfo extends StatefulWidget {
  var id, description, image;
  var title, owner, destination, source, date, weight, price;
  MyItemScreenInfo({
    this.id,
    this.date,
    this.destination,
    this.weight,
    this.price,
    this.owner,
    this.title,
    this.description,
    this.source,
    this.image,
  });
  static const routeName = '/orders';
  @override
  _MyItemScreenInfoState createState() => _MyItemScreenInfoState();
}

class _MyItemScreenInfoState extends State<MyItemScreenInfo> {
  @override
  void initState() {
    super.initState();
  }

  List _sugesstions = [];
  bool isLoading = false;

  Future fetchAndSetSugesstions(id) async {
    String url = "http://briddgy.herokuapp.com/api/trips/" + id.toString() + "/suggestions/";
    http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _sugesstions = dataOrders["results"];
          isLoading = false;
        },
      );
    });
  }

  //widget.myObject.toString()
  static const routeName = '/orders/item';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.title.toString(), //Todo: item name
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    child: Image.network(
                      'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 24.0,
                    child: Image(
                      image: NetworkImage(
                          // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                          "https://picsum.photos/250?image=9"), //Todo,
                    ),
                  ),

                  Text(
                    widget.owner["first_name"].toString() + " " + widget.owner["last_name"].toString(),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          size: 15,
                          color: Colors.white,
                        ),
                        Text(
                          widget.owner["rating"].toString(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
//                  RatingBar(
//                    initialRating: 3,
//                    direction: Axis.horizontal,
//                    allowHalfRating: true,
//                    itemCount: 5,
//                    glowColor: Colors.amber,
//                    ratingWidget: RatingWidget(
//                      full: Icon(Icons.star),
//                      half: Icon(Icons.star_half),
//                      empty: Icon(Icons.star_border),
//                    ),
//                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                    onRatingUpdate: (rating) {
//                      print(rating);
//                    },
//                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Text(
                "Item Details",
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    dense: true,
                    title: Text(
                      "Departure city:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      widget.source.toString(), //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Arrival city:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      widget.destination["city_ascii"].toString(), //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Request date:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      widget.date.toString(), //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Weight:",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      widget.weight.toString(), //todo: data
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  // ListTile(
                  //   dense: true,
                  //   title: Text(
                  //     "Dimensions:",
                  //     style: TextStyle(
                  //       fontSize: 17,
                  //       color: Colors.grey[600],
                  //     ),
                  //   ),
                  //   trailing: Text(
                  //     '25x17x20', //todo: data
                  //     style: TextStyle(fontSize: 18),
                  //   ),
                  // ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Item cost:", //todo: data
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      widget.price.toString() + ' \$',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ), //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Text(
                "Description",
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 40),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.description.toString(),
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
