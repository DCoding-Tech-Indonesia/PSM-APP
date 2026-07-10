import 'package:flutter/material.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';

class WidgetDemoScreen extends StatefulWidget {
  const WidgetDemoScreen({super.key});

  @override
  State<WidgetDemoScreen> createState() => _WidgetDemoScreenState();
}

class _WidgetDemoScreenState extends State<WidgetDemoScreen> {
  // 0: Main Menu
  // 1: Button Showcase
  // 2: Card Showcase
  // 3: List Showcase
  // 4: Input Showcase
  int _selectedView = 0;

  // States for Button Demo
  bool _isButtonLoading = false;
  int _buttonCounter = 0;

  // States for Input Demo
  String _inputText = '';
  String _inputNumber = '';

  void _triggerLoadingDemo() async {
    setState(() {
      _isButtonLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isButtonLoading = false;
        _buttonCounter++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define different views
    switch (_selectedView) {
      case 1:
        return _buildButtonShowcase(theme, isDark);
      case 2:
        return _buildCardShowcase(theme, isDark);
      case 3:
        return _buildListShowcase(theme, isDark);
      case 4:
        return _buildInputShowcase(theme, isDark);
      default:
        return _buildMainMenu(theme, isDark);
    }
  }

  // --- 0. MAIN MENU VIEW ---
  Widget _buildMainMenu(ThemeData theme, bool isDark) {
    return Scaffold(
      appBar: AppBar(title: const Text("Core Widget Hub"), elevation: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1F3C72), const Color(0xFF2A5298)]
                      : [const Color(0xFF2376D9), const Color(0xFF1E5BB0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Global Component Hub",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pilih jenis komponen di bawah ini untuk melihat contoh penggunaan, variasi, dan cara implementasinya secara terpisah.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "Daftar Komponen Global",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // GRID OF MENUS (Using our CoreCard!)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard(
                  title: "Core Button",
                  subtitle: "Varian, ukuran, loading state, dll.",
                  icon: Icons.smart_button_rounded,
                  iconColor: Colors.blueAccent,
                  onTap: () => setState(() => _selectedView = 1),
                ),
                _buildMenuCard(
                  title: "Core Card",
                  subtitle: "Elevasi, inkwell, border, kustom.",
                  icon: Icons.dashboard_customize_outlined,
                  iconColor: Colors.orangeAccent,
                  onTap: () => setState(() => _selectedView = 2),
                ),
                _buildMenuCard(
                  title: "Core List Tile",
                  subtitle: "List item seragam dengan aksi.",
                  icon: Icons.list_alt_rounded,
                  iconColor: Colors.teal,
                  onTap: () => setState(() => _selectedView = 3),
                ),
                _buildMenuCard(
                  title: "Core Input",
                  subtitle: "Input text, angka, password.",
                  icon: Icons.text_fields_rounded,
                  iconColor: Colors.purpleAccent,
                  onTap: () => setState(() => _selectedView = 4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return CoreCard(
      onTap: onTap,
      elevation: 2.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. BUTTON SHOWCASE VIEW ---
  Widget _buildButtonShowcase(ThemeData theme, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core Button Showcase"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _selectedView = 0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("1. Button Types (Varian)"),
            _buildSubCard(
              child: Column(
                children: [
                  CoreButton(
                    text: "Primary Button",
                    width: double.infinity,
                    onPressed: () => _showSnackbar("Primary Button Pressed"),
                  ),
                  const SizedBox(height: 12),
                  CoreButton(
                    text: "Secondary Button",
                    type: CoreButtonType.secondary,
                    width: double.infinity,
                    onPressed: () => _showSnackbar("Secondary Button Pressed"),
                  ),
                  const SizedBox(height: 12),
                  CoreButton(
                    text: "Outline Button",
                    type: CoreButtonType.outline,
                    width: double.infinity,
                    onPressed: () => _showSnackbar("Outline Button Pressed"),
                  ),
                  const SizedBox(height: 12),
                  CoreButton(
                    text: "Text Button",
                    type: CoreButtonType.text,
                    width: double.infinity,
                    onPressed: () => _showSnackbar("Text Button Pressed"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader("2. Button Sizes (Ukuran)"),
            _buildSubCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Large (56px) - Aksi Utama:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  CoreButton(
                    text: "Large Button",
                    size: CoreButtonSize.large,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Medium (48px) - Standar/Default:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  CoreButton(
                    text: "Medium Button",
                    size: CoreButtonSize.medium,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Small (36px) - Aksi Ringkas:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CoreButton(
                        text: "Small Button",
                        size: CoreButtonSize.small,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      CoreButton(
                        text: "Small Outline",
                        type: CoreButtonType.outline,
                        size: CoreButtonSize.small,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader("3. Interactive & States"),
            _buildSubCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Simulasi loading 2 detik saat ditekan:",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  CoreButton(
                    text: "Klik Untuk Proses (Selesai: $_buttonCounter)",
                    width: double.infinity,
                    isLoading: _isButtonLoading,
                    onPressed: _triggerLoadingDemo,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Status Dinonaktifkan (Disabled State):",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CoreButton(
                          text: "Disabled Primary",
                          isDisabled: true,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CoreButton(
                          text: "Disabled Outline",
                          type: CoreButtonType.outline,
                          isDisabled: true,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader("4. Dengan Ikon"),
            _buildSubCard(
              child: Row(
                children: [
                  Expanded(
                    child: CoreButton(
                      text: "Simpan",
                      icon: const Icon(Icons.save_rounded, size: 20),
                      onPressed: () => _showSnackbar("Simpan Ditekan"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CoreButton(
                      text: "Lanjut",
                      type: CoreButtonType.outline,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      isIconTrailing: true,
                      onPressed: () => _showSnackbar("Lanjut Ditekan"),
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

  // --- 2. CARD SHOWCASE VIEW ---
  Widget _buildCardShowcase(ThemeData theme, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core Card Showcase"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _selectedView = 0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("1. Card Elevasi (Bayangan)"),
            _buildSectionDescription(
              "Elevasi menentukan kedalaman bayangan card di atas background.",
            ),
            const SizedBox(height: 10),

            CoreCard(
              elevation: 0,
              child: _buildCardDemoContent(
                "Flat Card (Elevation: 0)",
                "Card tanpa bayangan, cocok untuk tampilan minimalis bergaya flat.",
              ),
            ),
            const SizedBox(height: 12),
            CoreCard(
              elevation: 2.0,
              child: _buildCardDemoContent(
                "Default Card (Elevation: 2)",
                "Card dengan bayangan lembut standar.",
              ),
            ),
            const SizedBox(height: 12),
            CoreCard(
              elevation: 6.0,
              child: _buildCardDemoContent(
                "Elevated Card (Elevation: 6)",
                "Bayangan tebal untuk memberi fokus visual yang sangat kuat.",
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("2. Interactive Card (Dapat Diklik)"),
            _buildSectionDescription(
              "Ketika parameter onTap diberikan, card akan memicu animasi ripple air (InkWell).",
            ),
            const SizedBox(height: 10),

            CoreCard(
              onTap: () => _showSnackbar("Tapped on Interactive Card!"),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.touch_app_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sentuh Saya",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Card ini memiliki ripple effect yang rapi.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("3. Custom Styles"),
            _buildSectionDescription(
              "Card mendukung kustomisasi penuh warna latar, border, dan radius.",
            ),
            const SizedBox(height: 10),

            CoreCard(
              backgroundColor: Colors.teal.shade700,
              borderRadius: 20.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Custom Background & Radius",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Latar belakang teal gelap dengan radius sudut 20dp.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CoreCard(
              borderColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.05,
              ),
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dengan Outline/Border",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sempurna untuk membungkus konten informasi bertema info atau peringatan.",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDemoContent(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
        ),
      ],
    );
  }

  // --- 3. LIST SHOWCASE VIEW ---
  Widget _buildListShowcase(ThemeData theme, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core List Tile Showcase"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _selectedView = 0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("1. Standard List Tile"),
            _buildSectionDescription(
              "Daftar berulang dengan layout standar teratur.",
            ),
            const SizedBox(height: 10),

            CoreListTile(
              title: "Profil Pengguna",
              subtitle: "Kelola data diri, alamat, dan nomor telepon",
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => _showSnackbar("Tapped Profil"),
            ),
            const SizedBox(height: 10),
            CoreListTile(
              title: "Pengaturan Keamanan",
              subtitle: "Ubah kata sandi dan biometrik sidik jari",
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                child: const Icon(Icons.security_rounded, color: Colors.orange),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => _showSnackbar("Tapped Keamanan"),
            ),
            const SizedBox(height: 10),
            CoreListTile(
              title: "Notifikasi Sistem",
              subtitle: "Atur pemberitahuan push dan email",
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.purple,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => _showSnackbar("Tapped Notifikasi"),
            ),
            const SizedBox(height: 25),

            _buildSectionHeader("2. Kustomisasi & Widget Kompleks"),
            _buildSectionDescription(
              "Mendukung passing widget langsung di title, subtitle, atau trailing.",
            ),
            const SizedBox(height: 10),

            CoreListTile(
              title: Row(
                children: [
                  const Text(
                    "Fitur Premium",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "PRO",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: "Dapatkan akses tak terbatas ke semua fitur cloud",
              leading: const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 28,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            CoreListTile(
              title: "Status Sinkronisasi",
              subtitle: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Tersambung ke Cloud",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
              leading: const Icon(
                Icons.cloud_done_rounded,
                color: Colors.green,
                size: 28,
              ),
              trailing: CoreButton(
                text: "Refresh",
                size: CoreButtonSize.small,
                onPressed: () => _showSnackbar("Refreshing cloud..."),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. INPUT SHOWCASE VIEW ---
  Widget _buildInputShowcase(ThemeData theme, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core Input Showcase"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _selectedView = 0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Contoh Penggunaan Input Field"),
            _buildSectionDescription(
              "Mendemonstrasikan komponen CoreInputField dengan tipe rule berbeda.",
            ),
            const SizedBox(height: 15),

            CoreInputFieldNew(
              label: "Nama Lengkap",
              hintText: "Masukkan nama lengkap sesuai KTP",
              isRequired: true,
              onChanged: (val) {
                setState(() {
                  _inputText = val;
                });
              },
            ),
            const SizedBox(height: 20),

            CoreInputFieldNew(
              label: "Umur",
              hintText: "Masukkan umur dalam angka",
              rule: InputRuleSuffixNew.number,
              onChanged: (val) {
                setState(() {
                  _inputNumber = val;
                });
              },
            ),
            const SizedBox(height: 20),

            CoreInputFieldNew(
              label: "Password Keamanan",
              hintText: "Masukkan password minimal 8 karakter",
              isRequired: true,
              isSecured: true,
            ),
            const SizedBox(height: 25),
            CoreInputFieldNew(
              label: "Password Keamanan",
              hintText: "Masukkan password minimal 8 karakter",
              isRequired: true,
              widgetSuffix: Text("Lihat"),
            ),

            _buildSectionHeader("Output Realtime"),
            _buildSubCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama Lengkap: $_inputText",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Umur: $_inputNumber",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionDescription(String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        desc,
        style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
      ),
    );
  }

  Widget _buildSubCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
