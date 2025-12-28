

import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade700,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius:  20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child:  Icon(
                      Icons.eco,
                      size: 60,
                      color: Colors. green.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.welcomeToLocalizy,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homePage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors. white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height:  16),
                  
                  // Info Card
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    title: l10n. about,
                    description: l10n.welcomeToLocalizy,
                    color: Colors.blue,
                  ),
                  
                  const SizedBox(height:  16),
                  
                  // Map Card
                  _buildInfoCard(
                    icon: Icons.map_outlined,
                    title: l10n.map,
                    description: l10n.viewAndExploreMap,
                    color: Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Settings Card
                  _buildInfoCard(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    description: l10n.language,
                    color: Colors.orange,
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children:  [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color. withOpacity(0.1),
                borderRadius: BorderRadius. circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}