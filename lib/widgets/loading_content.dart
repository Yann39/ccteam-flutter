import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/material.dart';

class LoadingContent extends StatelessWidget {
  const LoadingContent({Key key, this.emptyText, this.child, this.loadingStatus}) : super(key: key);

  final String emptyText;
  final Widget child;
  final LoadingStatus loadingStatus;

  static final Widget _loader = Center(
    child: SizedBox(
      child: CircularProgressIndicator(),
      height: 20.0,
      width: 20.0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return loadingStatus == LoadingStatus.notLoaded ? Text(emptyText) : loadingStatus == LoadingStatus.loading ? _loader : child;
  }
}