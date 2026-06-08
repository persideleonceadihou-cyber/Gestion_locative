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
  XFile? _scannedImage;
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() {
        _scannedImage = image;
      });
    } catch (e) {
      setState(() {
        _scanError = 'Impossible de capturer l\'image: $e';
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
    if (_scannedImage == null) return;
    Navigator.pop(context, 'Document capturé: ${_scannedImage!.name}');
  }

  void _resetScan() {
    setState(() {
      _scannedImage = null;
      _scanError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasScan = _scannedImage != null;

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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  children: [
                    _ScanHero(isWeb: true),
                    const SizedBox(height: 18),
                    _ScanFrame(
                      animation: _scanController,
                      image: _scannedImage,
                      isScanning: _isScanning,
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
                      _StatusCard(
                        icon: Icons.error_outline,
                        title: 'Erreur',
                        message: _scanError!,
                        color: const Color(0xFFD64545),
                      )
                    else if (hasScan)
                      _StatusCard(
                        icon: Icons.check_circle_outline,
                        title: 'Document capturé',
                        message: 'Fichier: ${_scannedImage!.name}. Cliquez sur valider.',
                        color: const Color(0xFF149954),
                      )
                    else
                      const _StatusCard(
                        icon: Icons.info_outline,
                        title: 'Version Web',
                        message: 'Utilisez votre caméra ou importez un fichier pour simuler le scan.',
                        color: Color(0xFF2B7FFF),
                      ),
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
  final bool isWeb;
  const _ScanHero({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF1F6FEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture Web',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Prenez une photo ou importez un document.',
                  style: TextStyle(color: Color(0xFFDDEAF8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  final Animation<double> animation;
  final XFile? image;
  final bool isScanning;

  const _ScanFrame({
    required this.animation,
    required this.image,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF132238),
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (image != null)
              Positioned.fill(child: Image.network(image!.path, fit: BoxFit.cover))
            else
              const Center(
                child: Icon(Icons.camera_alt_outlined, color: Color(0xFFDDEAF8), size: 64),
              ),
            if (image == null)
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
                        boxShadow: [BoxShadow(color: const Color(0xFF63B3ED).withOpacity(0.5), blurRadius: 10)],
                      ),
                    ),
                  );
                },
              ),
            if (isScanning)
              const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          if (!hasScan) ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    onPressed: isScanning ? null : onPickCamera,
                    icon: Icons.camera_alt_outlined,
                    label: 'Caméra',
                    color: const Color(0xFF132238),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    onPressed: isScanning ? null : onPickGallery,
                    icon: Icons.photo_library_outlined,
                    label: 'Fichier',
                    color: const Color(0xFF1F6FEB),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    onPressed: onReset,
                    icon: Icons.refresh_rounded,
                    label: 'Refaire',
                    color: const Color(0xFF526072),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    onPressed: onValidate,
                    icon: Icons.check_rounded,
                    label: 'Valider',
                    color: const Color(0xFF149954),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({this.onPressed, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _StatusCard({required this.icon, required this.title, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                Text(message, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
