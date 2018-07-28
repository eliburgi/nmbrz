import 'package:flutter/material.dart';
import 'package:nmbrz/constants.dart';

class NumberPickerDialog extends StatefulWidget {
  final String title;

  NumberPickerDialog({@required this.title});

  @override
  _NumberPickerDialogState createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  int _number;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: _buildContent(),
      actions: <Widget>[
        FlatButton(
            textColor: Colors.grey,
            onPressed: () => Navigator.of(context).pop(null),
            child: Text("Cancel")),
        FlatButton(
          textColor: primaryColor,
          onPressed: () => _onDone(),
          child: Text("Done"),
        ),
      ],
    );
  }

  _buildContent() {
    return Form(
      key: _formKey,
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(),
        validator: (value) {
          var number = int.tryParse(value);
          if (number == null || number < 0) {
            return 'Please enter a positive integer';
          } else {
            _number = number;
          }
        },
      ),
    );
  }

  _onDone() {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop(_number);
    }
  }
}

class DayPickerDialog extends StatefulWidget {
  DayPickerDialog();

  @override
  DayPickerDialogState createState() => DayPickerDialogState();
}

class DayPickerDialogState extends State<DayPickerDialog> {
  int _month;
  int _day;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pick a day"),
      content: _buildContent(),
      actions: <Widget>[
        FlatButton(
            textColor: Colors.grey,
            onPressed: () => Navigator.of(context).pop(null),
            child: Text("Cancel")),
        FlatButton(
          textColor: primaryColor,
          onPressed: () => _onDone(),
          child: Text("Done"),
        ),
      ],
    );
  }

  _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(hintText: "Month (1 - 12)"),
            keyboardType: TextInputType.numberWithOptions(),
            validator: (value) {
              var month = int.tryParse(value);
              if (month == null || month < 1 || month > 12) {
                return 'Please enter a month (1 - 12)';
              } else {
                _month = month;
              }
            },
          ),
          Padding(padding: const EdgeInsets.only(top: 16.0)),
          TextFormField(
            decoration: InputDecoration(hintText: "Day (1 - 31)"),
            keyboardType: TextInputType.numberWithOptions(),
            validator: (value) {
              var day = int.tryParse(value);
              if (day == null || day < 1 || day > 31) {
                return 'Please enter a day (1 - 31)';
              } else {
                _day = day;
              }
            },
          ),
        ],
      ),
    );
  }

  _onDone() {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop({'month': _month, 'day': _day});
    }
  }
}
