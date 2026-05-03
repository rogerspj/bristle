import 'package:flutter/material.dart';

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

// ─── Cybersecurity tips by category ─────────────────────────────────────────

// Each key is a category name shown on the chip buttons.
// Each value is the ordered list of tips for that category.
// To add a new category, add a new key-value pair here.
const Map<String, List<String>> _tipsByCategory = {
  'Passwords': [
    'Use a unique password for every account. Reusing passwords means one breach exposes all of them.',
    'A password manager (such as Bitwarden or 1Password) remembers strong passwords so you don\'t have to.',
    'Make passwords long: 16+ characters is much harder to crack than 8, even with random characters.',
    'Never share your password over email, text, chat, or phone call. No legitimate service will ever ask for it.',
    'Turn on two-factor authentication (2FA) so a stolen password alone can\'t unlock your account.',
    'Avoid using personal info in passwords. Birthdays, pet names, and addresses are easy to guess.',
  ],
  'Phishing': [
    'Never click links in unexpected emails or texts. Go directly to the website by typing the address.',
    'Check the sender\'s full email address, not just their display name. Attackers can fake the display name easily.',
    'Urgency is often a red flag. "Act now or your account will be closed!" is a classic phishing tactic.',
    'On a computer, hovering over a link often shows the real destination URL before you click. This does not work on mobile, so be extra cautious there.',
    'When in doubt, call the company directly using a number from their official website, not from the email.',
    'Phishing attacks also arrive via text (smishing) and phone calls (vishing). Stay alert on all channels.',
  ],
  'Mobile': [
    'Lock your phone with a PIN, password, or biometrics. It is your first line of defense if it is lost.',
    'Only install apps from official stores (App Store / Google Play) and check reviews before installing.',
    'Review app permissions. A flashlight app has no reason to access your contacts or microphone.',
    'Keep your phone\'s operating system updated; updates often include critical security patches.',
    'Use a VPN on public Wi-Fi to keep your browsing private from others on the same network.',
    'Enable remote wipe so you can erase your phone\'s data if it is stolen.',
  ],
  'Physical': [
    'Lock your screen whenever you step away from your computer, even for just a minute.',
    'Be aware of shoulder surfers in public places; tilt your screen or use a privacy filter.',
    'Don\'t leave your laptop or phone unattended in public, even briefly.',
    'Shred documents containing personal information rather than putting them in the trash.',
    'Never plug in a USB drive you find or receive unexpectedly. They can carry malware and compromise your device.',
    'Use WPA3 if your router supports it, or WPA2 at minimum, and always change the default admin password.',
  ],
};

// The list of category names, derived from the map so it stays in sync automatically.
final List<String> _categories = _tipsByCategory.keys.toList();

// ─── Home screen ────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Which category chip is highlighted. Starts on the first category.
  String _selectedCategory = _categories.first;

  // Index of the tip currently on screen within the selected category.
  int _tipIndex = 0;

  // Whether the user has interacted yet. False = show the welcome prompt.
  // Becomes true the first time a chip or arrow is tapped.
  bool _started = false;

  // The text shown inside the tip card.
  // Before any interaction it shows a welcome message; after that, the real tip.
  String get _tipText => _started
      ? _tipsByCategory[_selectedCategory]![_tipIndex]
      : 'Pick a category above,\nthen tap an arrow to browse tips!';

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
    final tips = _tipsByCategory[_selectedCategory]!;
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
    final tips = _tipsByCategory[_selectedCategory]!;
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
    // Total tips in the currently selected category (used for the counter).
    final tipCount = _tipsByCategory[_selectedCategory]!.length;

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
            // ── Mascot ────────────────────────────────────────────────────
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

            // ── Category chips ─────────────────────────────────────────────
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

            // ── Tip card ───────────────────────────────────────────────────
            // The card uses a fixed height so the buttons below never move,
            // regardless of whether the tip text is short or long.
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
                      _tipText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Navigation: back arrow | counter | forward arrow ───────────
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
                // A fixed-width SizedBox prevents the counter from shifting
                // the arrows left or right as the number changes.
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
