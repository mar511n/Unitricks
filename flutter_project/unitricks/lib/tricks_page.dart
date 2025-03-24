import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:unitricks/trick_widget.dart';
import 'backend.dart';

class TricksPage extends StatefulWidget {
  const TricksPage({super.key});
  @override
  State<StatefulWidget> createState() => _TricksPage();
}

class _TricksPage extends State<TricksPage>{
  SortableSearchableTrickList trickList = SortableSearchableTrickList(
    items: [],
    onItemSelected: (item) {},
  );
  UnicycleTrickWidget trickInfo = UnicycleTrickWidget(name: '', tags: [], description: '', proposedBy: '', videoLinks: [], startPositions: [], endPositions: []);
  bool _showTrickInfo = false;

  void updateList() async {
    final resp = await callDbFunction('GetTrickNamesForUser', [username]);
    if (resp.body.startsWith("ERROR")) {
      // TODO: make popup for error handling
      print('Error in GetTrickNamesForUser: ${resp.body}');
      return;
    }
    final List imtms = jsonDecode(resp.body);
    final List<Item> items = [];
    for (var i = 0; i < imtms.length; i++) {
      items.add(Item(text: imtms[i]["name"], icon: imtms[i]["landed"]==1 ? Icons.check : Icons.close));
    }
    setState(() {
      trickList = SortableSearchableTrickList(
        items: items,
        onItemSelected: (item) {
          showTrickDetails(item.text);
        },
      );
    });
  }

  void showTrickDetails(String trickname) async {
    final resp = await callDbFunction('GetGlobalTrick', [trickname]);
    if (resp.body.startsWith("ERROR")) {
      // TODO: make popup for error handling
      print('Error in GetGlobalTrick: ${resp.body}');
      return;
    }
    final dynamic trick = jsonDecode(resp.body);
    if (trick is Map) {
      final resp = await callDbFunction('GetUsername', [trick['proposed_by']]);
      if (resp.body.startsWith("ERROR")) {
        // TODO: make popup for error handling
        print('Error in GetUsername: ${resp.body}');
        return;
      }
      setState(() {
        _showTrickInfo = true;

        List<String> vls = [];
        final vlsjson = jsonDecode(trick['videolinks']).values.toList();
        for (var i = 0; i < vlsjson.length; i++) {
          vls.add(vlsjson[i]);
        }

        trickInfo = UnicycleTrickWidget(
          name: trick['name'],
          tags: trick['tags'].split(','),
          description: trick['description'],
          proposedBy: resp.body,
          videoLinks: vls,
          startPositions: trick['startPositions'].split(','),
          endPositions: trick['endPositions'].split(',')
        );
      });
    }
  }

  @override
  void initState() {
    updateList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        trickList,
        if (_showTrickInfo) ...[
          Align(
            alignment: Alignment.bottomRight,
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.green, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: trickInfo,
                  ),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showTrickInfo = false;
                        });
                      },
                    ),
                  ),
                ],
              ) 
            )
          ),
        ],
      ]
    );
  }
}

class Item {
  final String text;
  final IconData icon;

  Item({required this.text, required this.icon});
}

class SortableSearchableTrickList extends StatefulWidget {
  final List<Item> items;
  final Function(Item) onItemSelected;

  const SortableSearchableTrickList({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<StatefulWidget> createState() => _SortableSearchableTrickListState();
}

enum SortOrder { ascending, descending }
enum ShowTrickValues {all, landed, notlanded}

class _SortableSearchableTrickListState extends State<SortableSearchableTrickList> {
  List<Item> _filteredItems = [];
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.ascending;
  ShowTrickValues showTricks = ShowTrickValues.all;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items; // Initialize with all items
  }

  @override
  void didUpdateWidget(covariant SortableSearchableTrickList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.items != widget.items) {
      //_searchQuery = ''; // Clear search if needed
      _filterAndSort(); // Reapply current search and sort
    }
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filterAndSort();
    });
  }

  void _filterAndSort() {
    // Filter items based on search query
    List<Item> filtered = widget.items.where((item) {
      if (showTricks == ShowTrickValues.landed && item.icon != Icons.check) {
        return false;
      }
      if (showTricks == ShowTrickValues.notlanded && item.icon != Icons.close) {
        return false;
      }
      return item.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort the filtered list
    filtered.sort((a, b) {
      int comparison = a.text.compareTo(b.text);
      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    setState(() {
      _filteredItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search for a trick',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _updateSearch,
                ),
              ),
              Text('Show:'),
              DropdownButton<ShowTrickValues>(
                value: showTricks,
                items: ShowTrickValues.values.map((sval) {
                  return DropdownMenuItem(
                    value: sval,
                    child: Text(sval == ShowTrickValues.all ? "all" : sval == ShowTrickValues.landed ? "landed" : "not landed"),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      showTricks = value;
                      _filterAndSort();
                    });
                  }
                },
              ),
              Text('Sort:'),
              DropdownButton<SortOrder>(
                value: _sortOrder,
                items: SortOrder.values.map((order) {
                  return DropdownMenuItem(
                    value: order,
                    child: Text(
                      order == SortOrder.ascending ? 'A-Z' : 'Z-A',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOrder = value;
                      _filterAndSort();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.text),
                onTap: () => widget.onItemSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }
}