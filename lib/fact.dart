import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nmbrz/constants.dart';
import 'package:http/http.dart';
import 'dart:core';

enum FactType { trivia, math, year, date }

class Fact {
  final FactType type;
  final num number;
  final String text;

  // date and year are optional
  final String date;
  final int year;

  Fact(
      {@required this.type,
      @required this.number,
      @required this.text,
      this.date,
      this.year});

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      type: _parseFactType(json['type']),
      number: json['number'],
      text: json['text'],
      year: json.containsKey('year') ? json['year'] : null,
      date: json.containsKey('date') ? json['date'] : null,
    );
  }
}

FactType _parseFactType(String type) {
  switch (type) {
    case "trivia":
      return FactType.trivia;
    case "math":
      return FactType.math;
    case "year":
      return FactType.year;
    case "date":
      return FactType.date;
  }
  throw Exception("unknown fact type: $type");
}

class FactRepository {
  static const _ok = 200;
  static const _baseUrl = "http://numbersapi.com";
  static final instance = FactRepository._();

  Map<FactType, Fact> previousFacts = {};

  FactRepository._();

  factory FactRepository() => instance;

  Future<Fact> trivia(int number) {
    var url = _jsonify(_baseUrl + "/$number/trivia");
    return _loadFromUrl(url);
  }

  Future<Fact> math(int number) {
    var url = _jsonify(_baseUrl + "/$number/math");
    return _loadFromUrl(url);
  }

  Future<Fact> year(int year) {
    var url = _jsonify(_baseUrl + "/$year/year");
    return _loadFromUrl(url);
  }

  Future<Fact> date(int day, int month) {
    var url = _jsonify(_baseUrl + "/$month/$day/date");
    return _loadFromUrl(url);
  }

  Future<Fact> random([FactType type = FactType.trivia]) {
    var url = _jsonify(_endpoint(type));
    return _loadFromUrl(url);
  }

  Future<Fact> previous(FactType type) {
    if (previousFacts.containsKey(type)) {
      return Future.value(previousFacts[type]);
    } else {
      return random(type);
    }
  }

  Future<Fact> _loadFromUrl(String url) async {
    var response = await get(url);
    if (response.statusCode == _ok) {
      var fact = Fact.fromJson(json.decode(response.body));
      previousFacts[fact.type] = fact;
      return fact;
    } else {
      return Future.error(null);
    }
  }

  String _endpoint(FactType type) {
    var baseRandomUrl = _baseUrl + "/random";
    switch (type) {
      case FactType.trivia:
        return baseRandomUrl + "/trivia";
      case FactType.math:
        return baseRandomUrl + "/math";
      case FactType.year:
        return baseRandomUrl + "/year";
      case FactType.date:
        return baseRandomUrl + "/date";
    }
    throw Exception("unknown fact type: $type");
  }

  String _jsonify(String baseUrl) => baseUrl + "?json";
}

class FactWidget extends StatelessWidget {
  FactWidget({@required this.fact});

  final Fact fact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _factTitle(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
        ),
        Text(
          _factBody(),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18.0,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _factTitle() {
    if (fact.type == FactType.date) {
      var date = fact.text
          .substring(0, fact.text.indexOf(" ", fact.text.indexOf(" ", 0) + 1));
      var dateParts = date.split(" ");
      var month =
          dateParts[0].length > 3 ? dateParts[0].substring(0, 3) : dateParts[0];
      var day = dateParts[1];
      return "$month $day";
    } else {
      return fact.number.toString();
    }
  }

  String _factBody() {
    var startIndex = fact.text.indexOf(" ");
    if (fact.type == FactType.date) {
      return fact.text.substring(fact.text.indexOf(" ", startIndex + 1) + 1);
    } else {
      return fact.text.substring(startIndex + 1);
    }
  }
}

class FactInputControls extends StatelessWidget {
  FactInputControls({this.onShare, this.onChooseNext, this.onRandom});

  final VoidCallback onShare;
  final VoidCallback onChooseNext;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FloatingActionButton(
          onPressed: onShare,
          child: Icon(
            Icons.share,
            color: primaryColor,
          ),
          backgroundColor: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
        ),
        SizedBox(
          width: 80.0,
          height: 80.0,
          child: FloatingActionButton(
            onPressed: onRandom,
            child: Icon(
              Icons.replay,
              color: primaryColor,
              size: 42.0,
            ),
            backgroundColor: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
        ),
        FloatingActionButton(
          onPressed: onChooseNext,
          child: Icon(
            Icons.search,
            color: primaryColor,
          ),
          backgroundColor: Colors.white,
        ),
      ],
    );
  }
}
