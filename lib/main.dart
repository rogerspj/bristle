import 'dart:convert'; // Needed to parse JSON responses from the API
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Needed to make network requests

void main() {
  runApp(const BristleApp());
}

// ─── App root ───────────────────────────────────────────────────────────────

class BristleApp extends StatelessWidget {
  const BristleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bristle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Home screen ────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The base URL of your FastAPI server. Update this if your IP changes.
  static const _apiBase = 'http://18.144.144.119';

  // Tips loaded from the API. Null means we haven't loaded them yet.
  // Once loaded it looks like: {"Passwords": ["tip1", "tip2"], "Phishing": [...], ...}
  Map<String, List<String>>? _tipsByCategory;

  // True while the network request is in flight.
  bool _isLoading = true;

  // If the API call fails, this holds a friendly message to show the user.
  // Null means no error.
  String? _errorMessage;

  // Which category chip is currently highlighted.
  // Nullable because we don't know the first category until the data loads.
  String? _selectedCategory;

  // Index of the tip currently shown within the selected category.
  int _tipIndex = 0;

  // Whether the user has tapped anything yet. False = show the welcome prompt.
  bool _started = false;

  // A handy getter so we can write _categories anywhere without repeating this logic.
  List<String> get _categories => _tipsByCategory?.keys.toList() ?? [];

  // initState runs once when the widget is first created — perfect for startup work.
  @override
  void initState() {
    super.initState();
    _loadTips(); // Kick off the network request immediately on startup
  }

  // Fetches all tips from GET /tips and stores them in state.
  // Also called by the "Try Again" button when there's an error.
  Future<void> _loadTips() async {
    // Show the spinner and clear any previous error before (re)trying.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Make the GET request. Uri.parse turns the string into a proper URL object.
      final response = await http.get(Uri.parse('$_apiBase/tips'));

      if (response.statusCode == 200) {
        // response.body is a raw JSON string. jsonDecode turns it into a Dart Map.
        // The API returns: {"Passwords": ["tip1", ...], "Phishing": [...], ...}
        final rawJson = jsonDecode(response.body) as Map<String, dynamic>;

        // Convert each value from List<dynamic> to List<String> so Dart is happy.
        final loaded = rawJson.map(
          (category, tips) => MapEntry(
            category,
            (tips as List).map((t) => t.toString()).toList(),
          ),
        );

        setState(() {
          _tipsByCategory = loaded;
          _selectedCategory = loaded.keys.first; // default chip on first category
          _isLoading = false;
        });
      } else {
        // The server responded but with an unexpected status code (e.g. 500).
        setState(() {
          _errorMessage =
              'The server returned an error (status ${response.statusCode}).\nPlease try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // A network exception: no connection, DNS failure, timeout, etc.
      setState(() {
        _errorMessage =
            'Could not reach the server.\nCheck your connection and try again.';
        _isLoading = false;
      });
    }
  }

  // Called when the user taps a category chip.
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _tipIndex = 0;
      _started = true; // show tip[0] for the new category immediately
    });
  }

  // Called when the user taps the back (left) arrow.
  void _goBack() {
    final tips = _tipsByCategory![_selectedCategory!]!;
    setState(() {
      if (!_started) {
        // First interaction via back: jump to the last tip.
        _started = true;
        _tipIndex = tips.length - 1;
      } else {
        // Wrap from tip 0 back to the last tip.
        _tipIndex = (_tipIndex - 1 + tips.length) % tips.length;
      }
    });
  }

  // Called when the user taps the forward (right) arrow.
  void _goForward() {
    final tips = _tipsByCategory![_selectedCategory!]!;
    setState(() {
      if (!_started) {
        // First interaction via forward: show tip 0.
        _started = true;
        _tipIndex = 0;
      } else {
        // Wrap from the last tip back to tip 0.
        _tipIndex = (_tipIndex + 1) % tips.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── State 1: Loading ───────────────────────────────────────────────────
    // Show a spinner while the API call is in flight.
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Bristle'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading tips...'),
            ],
          ),
        ),
      );
    }

    // ── State 2: Error ─────────────────────────────────────────────────────
    // Show a friendly message and a retry button — never crash.
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Bristle'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadTips, // tap to retry the API call
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── State 3: Loaded ────────────────────────────────────────────────────
    // Data is ready — show the normal UI exactly as before.

    // Total tips in the currently selected category (used for the counter).
    final tipCount = _tipsByCategory![_selectedCategory!]!.length;

    // The text shown in the tip card.
    final tipText = _started
        ? _tipsByCategory![_selectedCategory!]![_tipIndex]
        : 'Pick a category above,\nthen tap an arrow to browse tips!';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Bristle'),
        centerTitle: true,
      ),

      // SingleChildScrollView lets the page scroll on very small screens.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          // stretch makes children fill the full width so chips stay centred.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Mascot ──────────────────────────────────────────────────────
            Center(
              child: Image.asset(
                'assets/bristle_mascot.png',
                height: 160,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Hi, I\'m Bristle!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Category chips ───────────────────────────────────────────────
            // _categories is now derived from the API response, not hardcoded.
            Center(
              child: Text(
                'Choose a category:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    // showCheckmark: false prevents the chip width from changing
                    // on selection, which would cause the row to shift.
                    showCheckmark: false,
                    onSelected: (_) => _selectCategory(category),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Tip card ─────────────────────────────────────────────────────
            // Fixed height so the buttons below never jump around.
            Card(
              elevation: 4,
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Text(
                      tipText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Navigation: back arrow | counter | forward arrow ─────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Back button
                IconButton.filled(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Previous tip',
                ),

                // Counter — shows "2 / 6" once interaction has started.
                // Fixed width prevents the arrows from shifting as the number changes.
                SizedBox(
                  width: 64,
                  child: Text(
                    _started ? '${_tipIndex + 1} / $tipCount' : '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                // Forward button
                IconButton.filled(
                  onPressed: _goForward,
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Next tip',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
