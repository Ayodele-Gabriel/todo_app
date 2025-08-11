import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/todo_notifier.dart';
import '../utilities/todo_filter.dart';
import '../utilities/todo_item.dart';
import '../utilities/todo_stats.dart';

class TodoScreen extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final stats = ref.watch(todoStatsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (newContext) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Enter a new todo...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) => _addTodo(ref, value, newContext),
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          onPressed: () => _addTodo(ref, _controller.text, newContext),
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchAnchor.bar(
              barHintText: 'Search for todo...',
              barLeading: Icon(Icons.search),
              barElevation: const WidgetStatePropertyAll(0.0),
              barShape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              viewLeading: const SizedBox(),
              isFullScreen: false,
              viewHintText: 'Search',
              shrinkWrap: false,
              suggestionsBuilder: (context, controller) {
                ref.read(searchQueryProvider.notifier).state = controller.text;
                return [
                  Consumer(
                    builder: (context, ref, _) {
                      final filtered = ref.watch(searchedTodosProvider);

                      return Column(
                        children: filtered.isNotEmpty
                            ? filtered.map((todo) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TodoItem(todo: todo),
                          );
                        }).toList()
                            : [
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: const Center(child: Text("No related todo found")),
                          ),
                        ],
                      );
                    },
                  ),
                ];
              },
              onSubmitted: (val) {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          TodoStats(),
          TodoFilters(),
          SizedBox(height: 10.0),
          Expanded(
            child:
                filteredTodos.isEmpty
                    ? Center(
                      child: Text(
                        'No todos yet!\nAdd one above to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                    : Column(
                      children: [
                        if (stats.completed > 0)
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                ref.read(todoListProvider.notifier).clearCompleted();
                              },
                              child: Text('Clear Completed'),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredTodos.length,
                            itemBuilder: (context, index) {
                              final todo = filteredTodos[index];
                              return TodoItem(todo: todo);
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  void _addTodo(WidgetRef ref, String title, BuildContext context) {
    if (title.trim().isNotEmpty) {
      ref.read(todoListProvider.notifier).addTodo(title);
      _controller.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New Todo Added!', style: TextStyle(fontSize: 24.0)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
