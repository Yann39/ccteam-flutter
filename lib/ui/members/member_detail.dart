import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/ui/members/add_member.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class MemberDetail extends StatefulWidget {
  final Member member;

  const MemberDetail({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberDetailState();
  }
}

enum ConfirmDialogAction { yes, no }

const kExpandedHeight = 216.0;

class _MemberDetailState extends State<MemberDetail> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset > kExpandedHeight - kToolbarHeight;
  }

  /// Method that launches the Edit Member screen and awaits the result from Navigator.pop
  _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMember(member: member)));

    // after the Edit Member Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Display a confirmation popup when trying to delete a member
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text(AppString.confirmation),
        content: new Text(value),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.yes);
            },
            child: new Text(AppString.confirm),
          ),
          new FlatButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.no);
            },
            child: new Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the member deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      final MembersService membersService = new MembersService();
      // delete member
      membersService.deleteMember(widget.member).then((value) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.memberDeleted)));
      }, onError: (error) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.memberDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () => _navigateToEditMemberScreen(context, widget.member),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Delete',
                  onPressed: () => _showConfirmation(context, AppString.memberDeletionAreYouSure),
                )
              ],
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              expandedHeight: kExpandedHeight,
              title: _showTitle ? Text('Chachatte') : null,
              flexibleSpace: _showTitle
                  ? null
                  : FlexibleSpaceBar(
                      title: new Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(widget.member.firstName + ' ' + widget.member.lastName),
                        ],
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.network('https://images.freeimages.com/images/large-previews/e71/frog-1371919.jpg', fit: BoxFit.fitHeight),
                            ],
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, -1.0),
                                end: Alignment(0.0, -0.4),
                                colors: <Color>[Color(0x60000000), Color(0x00000000)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  MergeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    widget.member.bike,
                                    style: TextStyle(color: Colors.white),
                                    textScaleFactor: 1.6,
                                  ),
                                  padding: EdgeInsets.only(left: 16.0),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 72.0, child: IconButton(icon: Icon(Icons.description), color: Colors.white, onPressed: () {}))
                        ],
                      ),
                    ),
                  ),
                  MergeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    widget.member.phone,
                                    style: TextStyle(color: Colors.white),
                                    textScaleFactor: 1.6,
                                  ),
                                  padding: EdgeInsets.only(left: 16.0),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 72.0, child: IconButton(icon: Icon(Icons.phone), color: Colors.white, onPressed: () {}))
                        ],
                      ),
                    ),
                  ),
                  MergeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    widget.member.email,
                                    style: TextStyle(color: Colors.white),
                                    textScaleFactor: 1.6,
                                  ),
                                  padding: EdgeInsets.only(left: 16.0),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 72.0, child: IconButton(icon: Icon(Icons.mail), color: Colors.white, onPressed: () {}))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[300], Colors.green[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
