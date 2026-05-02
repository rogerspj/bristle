import 'dart:math'; // For picking a random tip
import 'package:flutter/material.dart';

void main() {
  runApp(const BristleApp());
}

// ─── App root ───────────────────────────────────────────────────────────────

// BristleApp sets up the overall theme and launches the home screen.
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

// ─── Cybersecurity tips ──────────────────────────────────────────────────────

// Add or remove tips here to grow Bristle's knowledge base.
const List<String> _tips = [
  'Use a unique password for every account — a password manager makes this easy.',
  'Turn on two-factor authentication (2FA) wherever it is offered.',
  'Keep your operating system and apps up to date; updates often patch security holes.',
  'Never click links in unexpected emails or texts — go directly to the website instead.',
  'Use a VPN on public Wi-Fi to keep your traffic private.',
  'Lock your phone and computer with a PIN, password, or biometrics.',
  'Back up your important files regularly — at least one copy should be offline.',
  'Be careful what you share on social media; attackers use personal details to guess passwords.',
  'Check that websites use HTTPS (the padlock icon) before entering sensitive information.',
  'Log out of accounts when you are done, especially on shared computers.',
];

// ─── Home screen ────────────────────────────────────────────────────────────

// HomeScreen is "stateful" because it needs to remember which tip is showing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // _currentTip holds the tip text displayed on screen.
  // Starts as a friendly greeting rather than a blank card.
  String _currentTip = 'Tap the button below\nto get your first hygiene tip!';

  final _random = Random();

  // Picks a new random tip and triggers a screen refresh.
  void _showRandomTip() {
    setState(() {
      // setState tells Flutter "something changed — please redraw".
      _currentTip = _tips[_random.nextInt(_tips.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── App bar ─────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Bristle'),
        centerTitle: true,
      ),

      // ── Main content ────────────────────────────────────────────────────
      body: Center(
        // Column stacks widgets vertically, centred on screen.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot: a large toothbrush emoji stands in for Bristle in this POC.
            const Text(
              '🪥',
              style: TextStyle(fontSize: 80),
            ),

            const SizedBox(height: 16),

            Text(
              'Hi, I\'m Bristle!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 32),

            // Tip card — rounded card keeps the text readable.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _currentTip,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Button the user taps to get a new tip.
            FilledButton.icon(
              onPressed: _showRandomTip,
              icon: const Icon(Icons.refresh),
              label: const Text('Give me a tip!'),
            ),
          ],
        ),
      ),
    );
  }
}
