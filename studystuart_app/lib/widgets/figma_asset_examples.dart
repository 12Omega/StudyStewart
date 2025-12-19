import 'package:flutter/material.dart';
import '../constants/assets.dart';

/// Examples of using exact Figma assets for pixel-perfect design matching
/// Compare these implementations with the reference images in assets/screens/

class FigmaAssetExamples extends StatelessWidget {
  const FigmaAssetExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Figma Asset Examples'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              AppAssets.arrowLeft,
              width: 30,
              height: 29,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Navigation Icons'),
            _buildNavigationExample(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('UI Icons with Density Support'),
            _buildIconExamples(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Profile & Avatar Elements'),
            _buildProfileExamples(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Settings Screen Icons'),
            _buildSettingsExamples(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Progress Indicators'),
            _buildProgressExamples(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Background Elements'),
            _buildBackgroundExamples(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildNavigationExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Back Arrow (Exact Figma Asset)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // ❌ OLD: Material Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_back, size: 30),
                      const SizedBox(height: 4),
                      Text(
                        '❌ Material Icon',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // ✅ NEW: Exact Figma Asset
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        AppAssets.arrowLeft,
                        width: 30,
                        height: 29,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✅ Figma Asset',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Code: Image.asset(AppAssets.arrowLeft, width: 30, height: 29)',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Icons with Automatic Density Selection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildIconExample('Star', AppAssets.star, Icons.star),
                _buildIconExample('Notification', AppAssets.notification, Icons.notifications),
                _buildIconExample('Profile', AppAssets.profile, Icons.person),
                _buildIconExample('Settings', AppAssets.setting, Icons.settings),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Flutter automatically selects @2x or @3x variants based on device pixel ratio',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconExample(String name, String assetPath, IconData materialIcon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Material Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(materialIcon, size: 24),
            ),
            
            const SizedBox(width: 8),
            
            // Figma Asset
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                assetPath,
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildProfileExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile & Avatar Elements',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Profile Icon
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset(
                        AppAssets.profile,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Profile Icon', style: TextStyle(fontSize: 12)),
                  ],
                ),
                
                const SizedBox(width: 24),
                
                // Display Picture
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(AppAssets.displayPicture),
                    ),
                    const SizedBox(height: 8),
                    const Text('Display Picture', style: TextStyle(fontSize: 12)),
                  ],
                ),
                
                const SizedBox(width: 24),
                
                // Ellipse Element
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(AppAssets.ellipse7),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Ellipse Element', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings Screen Icons (Exact Figma Assets)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildSettingsItem('Dark Mode', AppAssets.darkMode),
            _buildSettingsItem('Notifications', AppAssets.notification),
            _buildSettingsItem('Privacy', AppAssets.privacy),
            _buildSettingsItem('Feedback', AppAssets.feedback),
            _buildSettingsItem('Share', AppAssets.share),
            _buildSettingsItem('Logout', AppAssets.logout),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, String iconAsset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
          Text(title),
          const Spacer(),
          if (title == 'Dark Mode')
            Image.asset(
              AppAssets.toggle,
              width: 51,
              height: 31,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Indicators (Exact Figma Assets)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  children: [
                    Image.asset(
                      AppAssets.progress76,
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    const Text('76% Progress', style: TextStyle(fontSize: 12)),
                  ],
                ),
                
                const SizedBox(width: 24),
                
                Column(
                  children: [
                    Image.asset(
                      AppAssets.progress76Alt,
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    const Text('76% Alt', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Use these exact progress indicators instead of creating custom circular progress bars',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Background Elements',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBackgroundExample('Rectangle 39', AppAssets.rectangle39),
                  const SizedBox(width: 16),
                  _buildBackgroundExample('Rectangle 40', AppAssets.rectangle40),
                  const SizedBox(width: 16),
                  _buildBackgroundExample('Background 1', AppAssets.background1),
                  const SizedBox(width: 16),
                  _buildBackgroundExample('Background 2', AppAssets.background2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundExample(String name, String assetPath) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(assetPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

/// Helper widget to compare Material Icons vs Figma Assets
class IconComparison extends StatelessWidget {
  final String title;
  final IconData materialIcon;
  final String figmaAsset;
  final double size;

  const IconComparison({
    super.key,
    required this.title,
    required this.materialIcon,
    required this.figmaAsset,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(materialIcon, size: size),
                ),
                const SizedBox(height: 4),
                const Text(
                  '❌ Material',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    figmaAsset,
                    width: size,
                    height: size,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '✅ Figma',
                  style: TextStyle(fontSize: 10, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}