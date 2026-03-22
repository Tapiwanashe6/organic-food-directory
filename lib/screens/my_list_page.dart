import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:organic_food_directory/bloc/lists/lists_bloc.dart';
import 'package:organic_food_directory/bloc/lists/lists_event.dart';
import 'package:organic_food_directory/bloc/lists/lists_state.dart';
import 'package:organic_food_directory/models/list_model.dart';
import 'package:organic_food_directory/screens/list_detail_page.dart';

class MyListPage extends StatefulWidget {
  const MyListPage({super.key});

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ListsBloc>().add(LoadListsEvent());
    }
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateListDialog(onListCreated: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('List created!'), backgroundColor: Color(0xFF2E7D32)),
        );
      }),
    );
  }

  void _openEditDialog(ListModel list) {
    showDialog(
      context: context,
      builder: (context) => _EditListDialog(
        list: list,
        onListUpdated: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('List updated!'), backgroundColor: Color(0xFF2E7D32)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your lists')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        tooltip: 'Add new list',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ListsBloc, ListsState>(
        builder: (context, state) {
          // Show loading state only on initial load
          if (state is ListsInitial || state is ListsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show error if one occurs
          if (state is ListsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          // Handle stream-based state
          if (state is ListsStreamLoaded) {
            return StreamBuilder<List<ListModel>>(
              stream: state.listingsStream,
              builder: (context, snapshot) {
                // Show loading while waiting for first data
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final myLists = snapshot.data!;
                if (myLists.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('You have no lists yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Tap the + button to create your first one!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ListsBloc>().add(LoadListsEvent());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: myLists.length,
                    itemBuilder: (context, index) {
                      final list = myLists[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDetailPage(list: list),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2E7D32),
                              child: Text(
                                list.title.isNotEmpty ? list.title[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(list.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${list.items.length} items'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _openEditDialog(list),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete List'),
                                        content: Text('Are you sure you want to delete "${list.title}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                            onPressed: () {
                                              context.read<ListsBloc>().add(DeleteListEvent(list.id));
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('List deleted'), backgroundColor: Colors.red),
                                              );
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}

class _CreateListDialog extends StatefulWidget {
  final VoidCallback onListCreated;
  const _CreateListDialog({required this.onListCreated});

  @override
  State<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<_CreateListDialog> {
  late TextEditingController listNameController;

  @override
  void initState() {
    super.initState();
    listNameController = TextEditingController();
  }

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
  }

  void _createList() {
    if (listNameController.text.trim().isNotEmpty) {
      context.read<ListsBloc>().add(CreateListEvent(listNameController.text.trim()));
      widget.onListCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: listNameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'List name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.list_alt),
              ),
              onSubmitted: (_) => _createList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    onPressed: _createList,
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditListDialog extends StatefulWidget {
  final ListModel list;
  final VoidCallback onListUpdated;
  const _EditListDialog({required this.list, required this.onListUpdated});

  @override
  State<_EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<_EditListDialog> {
  late TextEditingController listNameController;
  late TextEditingController itemController;
  late List<String> items;

  @override
  void initState() {
    super.initState();
    listNameController = TextEditingController(text: widget.list.title);
    itemController = TextEditingController();
    items = List.from(widget.list.items);
  }

  @override
  void dispose() {
    listNameController.dispose();
    itemController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (itemController.text.trim().isNotEmpty) {
      setState(() {
        items.add(itemController.text.trim());
        itemController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _updateList() {
    if (listNameController.text.trim().isNotEmpty) {
      final updatedList = widget.list.copyWith(
        title: listNameController.text.trim(),
        items: items,
        updatedAt: DateTime.now(),
      );
      context.read<ListsBloc>().add(UpdateListEvent(updatedList));
      widget.onListUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: listNameController,
                decoration: InputDecoration(
                  hintText: 'List name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.list_alt),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: itemController,
                      decoration: InputDecoration(
                        hintText: 'Add item...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _addItem,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: index < items.length - 1
                              ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                items[index],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeItem(index),
                              child: const Icon(Icons.close, color: Colors.red, size: 20),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No items yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      onPressed: _updateList,
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}