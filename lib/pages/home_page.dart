import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:patterns_setstate/pages/create_page.dart';
import 'package:patterns_setstate/service/https_service.dart';
import 'package:patterns_setstate/service/log_service.dart';

import '../model/post_model.dart';

class HomePage extends StatefulWidget {
  static final String id = "home_page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  List<Post> items = [];
  var titleController = TextEditingController();
  var bodyController = TextEditingController();

  void _apiPostList() async {
    setState(() {
      isLoading = true;
    });
    var response = await Network.GET(Network.API_LIST, Network.paramsEmpty());
    setState(() {
      isLoading = false;
      if (response != null) {
        items = Network.parsePostList(response);
      } else {
        items = [];
      }
    });
  }

  void _apiPostDelete(Post post) async {
    setState(() {
      isLoading = true;
    });

    Network.DELETE(
            Network.API_DELETE + post.id.toString(), Network.paramsEmpty())
        .then((response) => {_apiLoadList(response)});
  }

  _apiLoadList(String? response) {
    LogService.e(response.toString());

    setState(() {
      LogService.e("response.toString()");
      if (response != null) {
        _apiPostList();
      } else {
        isLoading = false;
        items = [];
      }
    });
  }

  _updatePost(Post post) {
    var title = titleController.text.toString();
    var body = bodyController.text.toString();
    if (title.isNotEmpty) {
      post.title = title;
    }
    if (body.isNotEmpty) {
      post.body = body;
    }

    Network.PUT(
            Network.API_UPDATE + post.id.toString(), Network.paramsUpdate(post))
        .then((response) =>
            {LogService.i(response.toString()), _apiLoadList(response)});
  }

  @override
  void initState() {
    super.initState();
    _apiPostList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              return itemOfPost(items[index]);
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CreatePage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget itemOfPost(Post post) {
    return Slidable(
      startActionPane: ActionPane(
        motion: ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {},
        ),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              openAlertBox(post);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: "Update",
          )
        ],
      ),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {},
        ),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              _apiPostDelete(post);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: "Delete",
          )
        ],
      ),
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          children: [
            Text(post.title!.toUpperCase()),
            SizedBox(
              height: 5,
            ),
            Text(post.body!)
          ],
        ),
      ),
    );
  }

  openAlertBox(Post post) {
    titleController.text  = post!.title!;
    bodyController.text  = post!.body!;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 250.0,
              height: 350,
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter Title',
                        hintText: 'Enter Your Title'),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextField(
                    controller: bodyController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: post.body),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  new MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    elevation: 5.0,
                    minWidth: 200.0,
                    height: 35,
                    color: Colors.blue,
                    child: new Text("Update post",
                        style: new TextStyle(fontSize: 16.0, color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      _updatePost(post);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

    customAlert(Post post, BuildContext context) {
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return Container(
            height: 200,
            width: 150,
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Enter Title',
                      hintText: 'Enter Your Title'),
                ),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: post.body),
                ),
                SizedBox(
                  height: 50,
                ),
                new MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  elevation: 5.0,
                  minWidth: 200.0,
                  height: 35,
                  color: Colors.blue,
                  child: new Text(post.title!,
                      style: new TextStyle(fontSize: 16.0, color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _updatePost(post);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
}
