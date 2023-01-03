import 'package:flutter/material.dart';

class Template extends StatefulWidget {
  const Template({Key? key}) : super(key: key);

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  List<int> count = [1,2];
  @override
  Widget build(BuildContext context) {

    return Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: count.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('Parent'),
                          ),
                          ListView.builder(
                              itemCount: count[index],
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index2) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //print('clicked');
                                    },
                                    child: const Text('Add', style: TextStyle(fontSize: 16),),
                                  ),
                                );
                              }),
                        ],
                      );
                    }),
              )
            ],
          ),
        ),
      );
  }
}
