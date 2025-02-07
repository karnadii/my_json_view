import 'package:flutter/material.dart';
import 'package:my_json_view/my_json_view.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSON Viewer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter JSON Viewer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = MyJsonViewController();
  final _style = MyJsonViewStyle.fromHighlightTheme(atomOneDarkTheme);

  final dynamic _jsonData = {
    "company": "Acme Corp",
    "founded": 1950,
    "nullValue": null,
    "booleanValue": true,
    "emptyObject": {},
    "emptyArray": [],
    "departments": [
      {
        "name": "Engineering",
        "employees": [
          {
            "name": "John Doe",
            "age": 35,
            "skills": ["C++", "Python", "JavaScript"],
            "projects": [
              {"name": "Project Alpha", "status": "In Progress"},
              {"name": "Project Beta", "status": "Completed"}
            ]
          },
          {
            "name": "Jane Smith",
            "age": 28,
            "skills": ["Java", "Kotlin", "Android"],
            "projects": [
              {"name": "Project Gamma", "status": "Planning"},
              {"name": "Project Delta", "status": "In Progress"}
            ]
          }
        ]
      },
      {
        "name": "Marketing",
        "employees": [
          {
            "name": "Peter Jones",
            "age": 42,
            "skills": ["SEO", "Social Media", "Content Marketing"],
            "campaigns": [
              {"name": "Campaign X", "budget": 10000},
              {"name": "Campaign Y", "budget": 15000}
            ]
          },
          {
            "name": "Mary Green",
            "age": 31,
            "skills": ["Email Marketing", "PPC", "Analytics"],
            "campaigns": [
              {"name": "Campaign Z", "budget": 12000},
              {"name": "Campaign W", "budget": 8000}
            ]
          },
          {
            "name": "Mary Green",
            "age": 31,
            "skills": ["Email Marketing", "PPC", "Analytics"],
            "campaigns": [
              {"name": "Campaign Z", "budget": 12000},
              {"name": "Campaign W", "budget": 8000}
            ]
          }
        ]
      },
      {
        "name": "Sales",
        "employees": [
          {
            "name": "David Brown",
            "age": 45,
            "skills": ["Salesforce", "Negotiation", "Closing"],
            "deals": [
              {"client": "Client A", "value": 50000},
              {"client": "Client B", "value": 75000}
            ]
          },
          {
            "name": "Sarah White",
            "age": 29,
            "skills": ["CRM", "Lead Generation", "Presentation"],
            "deals": [
              {"client": "Client C", "value": 60000},
              {"client": "Client D", "value": 90000},
              {"client": "Client E", "value": 120000}
            ]
          }
        ]
      }
    ],
    "locations": [
      {"city": "New York", "country": "USA"},
      {"city": "London", "country": "UK"},
      {"city": "Tokyo", "country": "Japan"},
      {"city": "Sydney", "country": "Australia"},
      {"city": "Paris", "country": "France"},
    ],
    "products": [
      {
        "name": "Product 1",
        "price": 29.99,
        "features": ["Feature A", "Feature B"]
      },
      {
        "name": "Product 2",
        "price": 49.99,
        "features": ["Feature C", "Feature D", "Feature E"]
      },
      {
        "name": "Product 3",
        "price": 99.99,
        "features": ["Feature F", "Feature G", "Feature H", "Feature I"]
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => _controller.expandAll(),
            tooltip: 'Expand All',
            icon: const Icon(Icons.expand),
          ),
          IconButton(
            onPressed: () => _controller.collapseAll(),
            tooltip: 'Collapse All',
            icon: const Icon(Icons.compress),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _controller.filter(value);
                });
              },
            ),
          ),
          Expanded(
            child: MyJsonView(
              style: _style.copyWith(
                alwaysShowObjectCount: true,
                objectInfoStyle: ObjectInfoStyle.annotated,
                showStartAndEndBrackets: true,
                showIndentGuide: true,
              ),
              controller: _controller,
              json: _jsonData,
            ),
          ),
        ],
      ),
    );
  }
}
