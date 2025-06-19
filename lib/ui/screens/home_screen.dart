import 'package:flutter/material.dart';
import 'package:newsapp/ui/screens/news/AllNews.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> options = [
    'All',
    'Olahraga',
    'Fashion',
    'Politcs',
    'Bro',
    'ThisMe',
  ];

  final List<Widget> pages = [
    AllNews(),
    Center(child: Text('Olahraga')),
    Center(child: Text('Fashion')),
    Center(child: Text('Politcs')),
    Center(child: Text('Bro')),
    Center(child: Text('ThisMe')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DefaultTabController(
          length: options.length,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.onPrimary,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: 'Enter a Search News',
                    hintStyle: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    height: 1,
                    fontSize: 16,
                  ),
                ),
              ),
              TabBar(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelColor: theme.colorScheme.onPrimary,
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                dividerColor: Colors.transparent,
                tabs: options.map((label) => Tab(text: label)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  children: pages
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
