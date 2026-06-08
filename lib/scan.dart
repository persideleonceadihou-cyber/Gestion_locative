import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gestion_locative/app_background.dart';

enum _ScanResultType { success, alreadyUsed, failure }

class Scan extends StatefulWidget {
  final bool returnOnSuccess;
  const Scan({super.key, this.returnOnSuccess = false});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  _ScanResultType? _resultType;
  String? _scannedValue;
  String? _errorMessage;
  final List<Map<String, dynamic>> _localHistory = [];

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onQrCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || _resultType != null) return;

    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      // 🔁 Remplace par ton vrai appel API
      final result = await _validateQrCode(rawValue);

      final type = result == 'valide'
          ? _ScanResultType.success
          : result == 'deja_utilise'
              ? _ScanResultType.alreadyUsed
              : _ScanResultType.failure;

      _localHistory.insert(0, {
        'value': rawValue,
        'result': type,
        'time': DateTime.now(),
      });

      if (widget.returnOnSuccess && type == _ScanResultType.success && mounted) {
        Navigator.of(context).pop(rawValue);
        return;
      }

      setState(() {
        _resultType = type;
        _scannedValue = rawValue;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _resultType = _ScanResultType.failure;
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  // 🔁 Remplace le corps de cette méthode par ton vrai appel HTTP
  Future<String> _validateQrCode(String value) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'valide'; // ← temporaire
  }

  void _resetScanner() {
    setState(() {
      _resultType = null;
      _scannedValue = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showCamera = _resultType == null && !_isProcessing;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Scanner un QR Code',
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
                    // --- Cadre caméra ---
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: showCamera
                              ? MobileScanner(
                                  controller: _cameraController,
                                  onDetect: _onQrCodeDetected,
                                )
                              : _ResultDisplay(type: _resultType!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Carte état ---
                    if (_isProcessing)
                      const _StatusCard(
                        icon: Icons.hourglass_top_rounded,
                        title: 'Vérification...',
                        message: 'Interrogation du serveur en cours.',
                        color: Color(0xFF2B7FFF),
                      )
                    else if (_resultType == _ScanResultType.success)
                      _ResultCard(
                        icon: Icons.check_circle_outline,
                        title: 'Accès autorisé',
                        message: _scannedValue ?? '',
                        color: const Color(0xFF149954),
                        onReset: _resetScanner,
                      )
                    else if (_resultType == _ScanResultType.alreadyUsed)
                      _ResultCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'QR déjà utilisé',
                        message: 'Ce QR code a déjà été scanné.',
                        color: const Color(0xFFF39C12),
                        onReset: _resetScanner,
                      )
                    else if (_resultType == _ScanResultType.failure)
                      _ResultCard(
                        icon: Icons.cancel_outlined,
                        title: 'QR invalide',
                        message: _errorMessage ?? 'QR code non reconnu.',
                        color: const Color(0xFFD64545),
                        onReset: _resetScanner,
                      )
                    else
                      const _StatusCard(
                        icon: Icons.qr_code_scanner,
                        title: 'Prêt à scanner',
                        message: 'Pointez la caméra vers un QR code.',
                        color: Color(0xFF2B7FFF),
                      ),

                    // --- Historique ---
                    if (_localHistory.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _HistoryList(history: _localHistory),
                    ],
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

// ─── Widgets ────────────────────────────────────────────────

class _ResultDisplay extends StatelessWidget {
  final _ScanResultType type;
  const _ResultDisplay({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = type == _ScanResultType.success
        ? const Color(0xFF149954)
        : type == _ScanResultType.alreadyUsed
            ? const Color(0xFFF39C12)
            : const Color(0xFFD64545);
    final icon = type == _ScanResultType.success
        ? Icons.check_circle
        : type == _ScanResultType.alreadyUsed
            ? Icons.warning_amber_rounded
            : Icons.cancel;

    return Container(
      color: color.withOpacity(0.12),
      child: Center(child: Icon(icon, color: color, size: 80)),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _StatusCard({
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF132238))),
                const SizedBox(height: 5),
                Text(message,
                    style: const TextStyle(
                        color: Color(0xFF526072), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final VoidCallback onReset;

  const _ResultCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: Color(0xFF526072), height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132238),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Scanner à nouveau'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Historique',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF132238))),
          const SizedBox(height: 12),
          ...history.take(5).map((h) {
            final type = h['result'] as _ScanResultType;
            final color = type == _ScanResultType.success
                ? const Color(0xFF149954)
                : type == _ScanResultType.alreadyUsed
                    ? const Color(0xFFF39C12)
                    : const Color(0xFFD64545);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.qr_code, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(h['value'] ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF132238))),
                ),
                Text(
                  _formatTime(h['time'] as DateTime),
                  style: const TextStyle(
                      color: Color(0xFF526072), fontSize: 11),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}