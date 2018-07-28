import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nmbrz/dialogs.dart';
import 'package:nmbrz/fact.dart';
import 'package:nmbrz/logo.dart';
import 'package:nmbrz/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  FactType _selectedFactType;
  Fact _fact;
  FactRepository _factRepository;
  bool _isLoading;
  StreamSubscription<Fact> subscription;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _isLoading = false;
    _selectedFactType = FactType.values[_tabController.index];
    _factRepository = FactRepository();
    _chooseRandomFact();
    //_isLoading = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    final newlySelectedFactType = FactType.values[_tabController.index];
    if (_selectedFactType != newlySelectedFactType) {
      _changeFactType(newlySelectedFactType);
    }
  }

  _changeFactType(FactType newType) {
    setState(() {
      _selectedFactType = newType;
      _isLoading = false;
    });
    subscription?.cancel();
    _tryLoadingFact(_factRepository.previous(newType));
  }

  _shareFact() {
    print('sharing fact');
  }

  _chooseNextFact() {
    if (_selectedFactType == FactType.date) {
      showDialog<Map<String, int>>(
        context: context,
        child: DayPickerDialog(),
      ).then((map) {
        if(map == null) return;
        _tryLoadingFact(_factRepository.date(map['day'], map['month']));
      });
    } else {
      var title =
          _selectedFactType == FactType.year ? "Pick a year" : "Pick a number";
      showDialog<int>(
        context: context,
        child: NumberPickerDialog(
          title: title,
        ),
      ).then((number) {
        if(number == null) return;
        // ignore: missing_enum_constant_in_switch
        switch(_selectedFactType) {
          case FactType.trivia:
            _tryLoadingFact(_factRepository.trivia(number));
            break;
          case FactType.math:
            _tryLoadingFact(_factRepository.math(number));
            break;
          case FactType.year:
            _tryLoadingFact(_factRepository.year(number));
            break;
        }
      });
    }
  }

  _chooseRandomFact() {
    if (_isLoading) return;
    _tryLoadingFact(_factRepository.random(_selectedFactType));
  }

  _tryLoadingFact(Future<Fact> factFuture) {
    setState(() {
      _isLoading = true;
    });
    subscription = factFuture
        .asStream()
        .listen(_successLoadingFact, onError: _errorLoadingFact, onDone: () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  _successLoadingFact(Fact fact) {
    setState(() {
      _fact = fact;
    });
  }

  _errorLoadingFact(error) {
    print(error);
    _fact = Fact(type: FactType.trivia, number: 1, text: "1 Error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildHeader(),
            _buildTabBar(),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          NmbrzLogo(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
          ),
          Text(
            appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56.0),
      child: TabBar(
        controller: _tabController,
        tabs: _tabTitles
            .map((tabTitle) => Tab(
                  text: tabTitle,
                ))
            .toList(),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
        indicator: _CustomTabIndicator(),
      ),
    );
  }

  _buildContentSection() {
    var factContent;
    if (_isLoading) {
      var progressIndicator = Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(value: null),
        ),
      );
      if (_fact == null) {
        factContent = progressIndicator;
      } else {
        factContent = Column(
          children: <Widget>[
            FactWidget(
              fact: _fact,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
            ),
            progressIndicator,
          ],
        );
      }
    } else {
      factContent = FactWidget(
        fact: _fact,
      );
    }

    // TabBarView wants to expand as much as possible.
    // But because it is a child of column, it must be wrapped with Flexible
    // such that it is only allowed to fill the remaining main-axis space.
    // https://github.com/flutter/flutter/issues/6169
    return Flexible(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 68.0,
                    vertical: 16.0,
                  ),
                  child: factContent,
                ),
                TabBarView(
                  controller: _tabController,
                  children: _tabTitles.map((title) => _TabViewDummy()).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: FactInputControls(
              onShare: _shareFact,
              onChooseNext: _chooseNextFact,
              onRandom: _chooseRandomFact,
            ),
          ),
        ],
      ),
    );
  }
}

final _tabTitles = FactType.values.map(_parseFactType);

String _parseFactType(FactType type) {
  switch (type) {
    case FactType.trivia:
      return "TRIVIA";
    case FactType.math:
      return "MATH";
    case FactType.year:
      return "YEAR";
    case FactType.date:
      return "DATE";
  }
  throw Exception("unknown fact type");
}

class _CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TabIndicatorPainter();
  }
}

class _TabIndicatorPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // offset is the top-left position from where rendering should begin
    // together with configuration.size it forms a rect wherein rendering
    // should happen.
    final Rect rect = offset & configuration.size;
    final paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth = 3.0;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(rect.center + const Offset(-10.0, 16.0),
        rect.center + const Offset(10.0, 16.0), paint);
  }
}

class _TabViewDummy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
    );
  }
}
