import 'package:flutter/material.dart';
import 'package:neu_pay/core/constants/app_constants.dart';

/// A responsive shell that adapts layout between mobile, tablet, and desktop.
///
/// - Mobile  (< 600dp): Bottom navigation bar, full-width content.
/// - Tablet  (600–1200dp): Navigation rail + expanded content.
/// - Desktop (≥ 1200dp): Fixed side drawer + centered constrained content.
///
/// Optimised for iPhone 8 (375pt logical width) and up.
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;

  const ResponsiveScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= AppConstants.desktopBreakpoint) {
          return _DesktopLayout(child: child);
        } else if (width >= AppConstants.mobileBreakpoint) {
          return _TabletLayout(child: child);
        } else {
          return _MobileLayout(child: child);
        }
      },
    );
  }
}

// ── Mobile ──────────────────────────────────────────────────────────────────
class _MobileLayout extends StatefulWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NEU-Pay')),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Tablet ──────────────────────────────────────────────────────────────────
class _TabletLayout extends StatefulWidget {
  final Widget child;
  const _TabletLayout({required this.child});

  @override
  State<_TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<_TabletLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(
                    icon: Icon(Icons.account_balance_wallet),
                    label: Text('Wallet')),
                NavigationRailDestination(
                    icon: Icon(Icons.person), label: Text('Profile')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

// ── Desktop ─────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatefulWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
                  child: Text('NEU-Pay',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(indent: 28, endIndent: 28),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: Text('Wallet'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
