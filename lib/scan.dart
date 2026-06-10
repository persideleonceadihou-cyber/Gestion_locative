import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gestion_locative/app_background.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  Uint8List? _scannedBytes;
  String? _scannedName;
  bool _isScanning = false;
  String? _scanError;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isScanning = true;
      _scanError = null;
    });

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _scannedBytes = bytes;
        _scannedName = image.name;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _scanError = 'Impossible de capturer l\'image: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _validateScan() {
    if (_scannedBytes == null) return;
    Navigator.pop(context, 'Document scanne: ${_scannedName ?? 'fichier'}');
  }

  void _resetScan() {
    setState(() {
      _scannedBytes = null;
      _scannedName = null;
      _scanError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasScan = _scannedBytes != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Scanner un dossier',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ScanHero(),
                    const SizedBox(height: 18),
                    Center(
                      child: _ScanFrame(
                        animation: _scanController,
                        bytes: _scannedBytes,
                        isScanning: _isScanning,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ScanActionPanel(
                      hasScan: hasScan,
                      isScanning: _isScanning,
                      onPickCamera: () => _pickImage(ImageSource.camera),
                      onPickGallery: () => _pickImage(ImageSource.gallery),
                      onValidate: _validateScan,
                      onReset: _resetScan,
                    ),
                    const SizedBox(height: 16),
                    if (_scanError != null)
                      _ScanStatusCard(
                        icon: Icons.error_outline,
                        title: 'Scan interrompu',
                        message: _scanError!,
                        color: const Color(0xFFD64545),
                      )
                    else if (hasScan)
                      _ScanStatusCard(
                        icon: Icons.check_circle_outline,
                        title: 'Document capture',
                        message:
                            'Verifiez l\'apercu, puis validez pour l\'ajouter au dossier.',
                        color: const Color(0xFF149954),
                      )
                    else
                      const _ScanHelpBubble(),
                    const SizedBox(height: 16),
                    _ScanTips(hasScan: hasScan),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanHero extends StatelessWidget {
  const _ScanHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF1F6FEB), Color(0xFF63B3ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          _HeroIcon(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Numeriser un document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cadrez le contrat, l\'etat des lieux ou une piece du dossier locataire.',
                  style: TextStyle(color: Color(0xFFDDEAF8), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.document_scanner_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  final Animation<double> animation;
  final Uint8List? bytes;
  final bool isScanning;

  const _ScanFrame({
    required this.animation,
    required this.bytes,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF132238),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (bytes != null)
                Image.memory(bytes!, fit: BoxFit.cover)
              else
                const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFFDDEAF8),
                    size: 64,
                  ),
                ),
              if (bytes == null)
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Positioned(
                      left: 20,
                      right: 20,
                      top: 20 + (260 * animation.value),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF63B3ED),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF63B3ED,
                              ).withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (isScanning)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanActionPanel extends StatelessWidget {
  final bool hasScan;
  final bool isScanning;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onValidate;
  final VoidCallback onReset;

  const _ScanActionPanel({
    required this.hasScan,
    required this.isScanning,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onValidate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onPressed: isScanning ? null : onPickCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Galerie',
                onPressed: isScanning ? null : onPickGallery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasScan && !isScanning ? onValidate : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF149954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasScan && !isScanning ? onReset : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF132238),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFC9D3E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF132238),
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFC9D3E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _ScanStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _ScanStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF4B5A6A),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHelpBubble extends StatelessWidget {
  const _ScanHelpBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCFE0FF)),
      ),
      child: const Text(
        'Prenez une photo ou importez un fichier pour creer le dossier numerise.',
        style: TextStyle(color: Color(0xFF1B4C99), height: 1.35),
      ),
    );
  }
}

class _ScanTips extends StatelessWidget {
  final bool hasScan;

  const _ScanTips({required this.hasScan});

  @override
  Widget build(BuildContext context) {
    final tips = hasScan
        ? const [
            'Le fichier est pret a etre valide.',
            'Vous pouvez remplacer l\'image avant confirmation.',
          ]
        : const [
            'Utilisez la camera pour capturer un document propre.',
            'La galerie permet d\'importer un scan deja existant.',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conseils rapides',
          style: TextStyle(
            color: Color(0xFF132238),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.circle, size: 8, color: Color(0xFF1F6FEB)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: Color(0xFF4B5A6A),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
