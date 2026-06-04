// Page publique de paiement pour les locataires.
// Aucun compte requis : le locataire saisit son nom, ses infos s'affichent
// automatiquement, puis il choisit ses mois et son mode de paiement.
//
// URL spécifique :  /pay?uid=UID&tenantId=ID&nom=NOM&chambre=CH&montant=M
// URL générale   :  /pay?uid=UID
//
// ⚠️  Règles Firestore requises (firestore.rules) :
//   match /users/{uid}/locataires/{id}  { allow read: if true; }
//   match /users/{uid}/paiements/{id}   { allow create: if true; }
//   match /users/{uid}/locataires/{id}  { allow update: if true; }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────
class TenantPaymentPage extends StatefulWidget {
  final String uid;
  final String tenantId;
  final String nom;
  final String chambre;
  final String montant;

  const TenantPaymentPage({
    super.key,
    required this.uid,
    required this.tenantId,
    required this.nom,
    required this.chambre,
    required this.montant,
  });

  @override
  State<TenantPaymentPage> createState() => _TenantPaymentPageState();
}

enum _Step { search, found, success }

class _TenantPaymentPageState extends State<TenantPaymentPage>
    with SingleTickerProviderStateMixin {
  _Step _step = _Step.search;

  // Champ de recherche
  final _nameCtrl = TextEditingController();
  bool _searching = false;
  bool _notFound = false;

  // Locataire trouvé
  Map<String, dynamic>? _tenant;
  String _foundId = '';
  String _foundName = '';
  String _foundStatus = '';
  int _foundMonthly = 0;

  // Formulaire paiement
  int _months = 1;
  String? _payMethod;
  bool _processing = false;

  int get _total => _foundMonthly * _months;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ─────────────────── Cycle de vie ──────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Lien spécifique : pré-remplir et chercher automatiquement
    if (widget.nom.isNotEmpty) {
      _nameCtrl.text = widget.nom;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────── Recherche locataire ──────────
  Future<void> _search() async {
    final query = _nameCtrl.text.trim();
    if (query.length < 2) {
      setState(() => _notFound = false);
      return;
    }

    setState(() {
      _searching = true;
      _notFound = false;
      _tenant = null;
    });

    try {
      QuerySnapshot snap;

      // Lien spécifique avec tenantId : requête directe
      if (widget.tenantId.isNotEmpty && widget.uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('locataires')
            .doc(widget.tenantId)
            .get();
        if (doc.exists) {
          _applyTenant(doc.id, doc.data() as Map<String, dynamic>);
          return;
        }
      }

      // Recherche par nom dans toute la collection
      if (widget.uid.isNotEmpty) {
        snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('locataires')
            .get();

        final queryLower = query.toLowerCase();
        final matches = snap.docs.where((doc) {
          final name =
              (doc.data() as Map<String, dynamic>)['name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return name == queryLower || name.contains(queryLower);
        }).toList();

        if (matches.isNotEmpty) {
          _applyTenant(
              matches.first.id,
              matches.first.data() as Map<String, dynamic>);
          return;
        }
      } else {
        // Pas de uid : utiliser les données de l'URL directement
        if (query.toLowerCase() == widget.nom.toLowerCase()) {
          _applyFromUrl();
          return;
        }
      }

      // Aucun résultat
      setState(() {
        _searching = false;
        _notFound = true;
      });
    } catch (_) {
      // Firestore inaccessible : fallback sur l'URL si nom correspond
      if (widget.nom.isNotEmpty &&
          query.toLowerCase() == widget.nom.toLowerCase()) {
        _applyFromUrl();
      } else {
        setState(() {
          _searching = false;
          _notFound = true;
        });
      }
    }
  }

  void _applyTenant(String id, Map<String, dynamic> data) {
    final amountRaw =
        data['rentAmount']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
        widget.montant;
    final monthly = int.tryParse(amountRaw) ??
        int.tryParse(widget.montant) ??
        0;

    setState(() {
      _searching = false;
      _notFound = false;
      _foundId = id;
      _foundName = data['name']?.toString() ?? widget.nom;
      _foundStatus = data['statusLabel']?.toString() ?? 'Paiement attendu';
      _foundMonthly = monthly;
      _tenant = {
        'id': id,
        'name': _foundName,
        'room': data['roomNumber']?.toString() ?? widget.chambre,
        'property': data['propertyName']?.toString() ?? '',
        'status': _foundStatus,
        'monthly': monthly,
      };
      _step = _Step.found;
    });
    _fadeCtrl.forward(from: 0);
  }

  void _applyFromUrl() {
    final monthly = int.tryParse(widget.montant) ?? 0;
    setState(() {
      _searching = false;
      _notFound = false;
      _foundId = widget.tenantId;
      _foundName = widget.nom;
      _foundStatus = 'Paiement attendu';
      _foundMonthly = monthly;
      _tenant = {
        'id': widget.tenantId,
        'name': widget.nom,
        'room': widget.chambre,
        'property': '',
        'status': 'Paiement attendu',
        'monthly': monthly,
      };
      _step = _Step.found;
    });
    _fadeCtrl.forward(from: 0);
  }

  // ─────────────────── Confirmer paiement ───────────
  Future<void> _pay() async {
    if (_payMethod == null) return;
    setState(() => _processing = true);

    try {
      if (widget.uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('paiements')
            .add({
          'tenantId': _foundId,
          'tenantName': _foundName,
          'amount': _total,
          'method': _payMethod,
          'status': 'paye',
          'monthsCount': _months,
          'source': 'lien_partage',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (_foundId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('locataires')
              .doc(_foundId)
              .set({
            'statusLabel': 'A jour',
            'statusColor': const Color(0xFF3B6D11).toARGB32(),
            'balanceLabel': 'Solde a jour',
            'paymentSummary':
                'Dernier paiement : ${_fmt(_total)} FCFA',
            'lastPaymentAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      setState(() {
        _processing = false;
        _step = _Step.success;
      });
    } catch (_) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Erreur lors de l\'enregistrement. Contactez votre propriétaire.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─────────────────── Format ────────────────────────
  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ─────────────────── Build ─────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_step == _Step.success) return _buildSuccess();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchSection(),
              if (_searching) _buildSearching(),
              if (_notFound) _buildNotFound(),
              if (_step == _Step.found && _tenant != null)
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildPaymentForm(),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // EN-TÊTE
  // ══════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF1F6FEB), Color(0xFF63B3ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.home_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Paiement de Loyer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Saisissez votre nom pour accéder à votre dossier',
            style: TextStyle(color: Color(0xFFDDEAF8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // CHAMP DE RECHERCHE
  // ══════════════════════════════════════════════════
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre nom complet',
            style: TextStyle(
              color: Color(0xFF132238),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Champ texte
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF132238).withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                        color: Color(0xFF132238), fontSize: 15),
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Ex : Kofi Mensah',
                      hintStyle: const TextStyle(
                          color: Color(0xFF9BAAB8), fontSize: 14),
                      prefixIcon: const Icon(Icons.person_search_rounded,
                          color: Color(0xFF1F6FEB), size: 22),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                    ),
                    onChanged: (_) {
                      // Réinitialiser si l'utilisateur modifie
                      if (_step == _Step.found) {
                        setState(() {
                          _step = _Step.search;
                          _tenant = null;
                          _notFound = false;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Bouton Rechercher
              GestureDetector(
                onTap: _search,
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F6FEB),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F6FEB).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Saisissez votre nom exactement comme enregistré par votre propriétaire.',
            style: TextStyle(color: Color(0xFF9BAAB8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // ÉTATS INTERMÉDIAIRES
  // ══════════════════════════════════════════════════
  Widget _buildSearching() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(
              color: Color(0xFF1F6FEB), strokeWidth: 2.5),
          SizedBox(height: 14),
          Text('Recherche en cours…',
              style: TextStyle(color: Color(0xFF607086), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBE5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF5B5A0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_off_rounded,
                color: Color(0xFF993C1D), size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Locataire introuvable',
                    style: TextStyle(
                      color: Color(0xFF993C1D),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Vérifiez l\'orthographe ou contactez votre propriétaire.',
                    style:
                        TextStyle(color: Color(0xFF993C1D), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // FORMULAIRE DE PAIEMENT (affiché après trouvé)
  // ══════════════════════════════════════════════════
  Widget _buildPaymentForm() {
    final isLate = _foundStatus == 'Retard';
    final t = _tenant!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte locataire trouvé ───────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF1F6FEB).withValues(alpha: 0.3),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F6FEB).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF132238),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _foundName.isNotEmpty
                              ? _foundName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _foundName,
                            style: const TextStyle(
                              color: Color(0xFF132238),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              if ((t['room'] as String).isNotEmpty)
                                'Chambre ${t['room']}',
                              if ((t['property'] as String).isNotEmpty)
                                t['property'] as String,
                            ].join(' · '),
                            style: const TextStyle(
                                color: Color(0xFF607086), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLate
                            ? const Color(0xFFFFEBE5)
                            : const Color(0xFFF0FAE4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLate
                              ? const Color(0xFFF5B5A0)
                              : const Color(0xFFC0DD97),
                        ),
                      ),
                      child: Text(
                        isLate ? 'En retard' : 'À jour',
                        style: TextStyle(
                          color: isLate
                              ? const Color(0xFF993C1D)
                              : const Color(0xFF3B6D11),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: Color(0xFFEEF3F8)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Loyer mensuel',
                      style:
                          TextStyle(color: Color(0xFF607086), fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF1F6FEB), size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${_fmt(_foundMonthly)} FCFA',
                          style: const TextStyle(
                            color: Color(0xFF132238),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Nombre de mois ───────────────────────────
          _sectionLabel('Nombre de mois à payer'),
          const SizedBox(height: 10),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundBtn(Icons.remove_rounded, () {
                  if (_months > 1) setState(() => _months--);
                }),
                Column(
                  children: [
                    Text(
                      '$_months',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF132238),
                      ),
                    ),
                    Text(
                      _months == 1 ? 'mois' : 'mois',
                      style: const TextStyle(
                          color: Color(0xFF607086), fontSize: 12),
                    ),
                  ],
                ),
                _roundBtn(Icons.add_rounded, () {
                  if (_months < 12) setState(() => _months++);
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Total ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF102A43), Color(0xFF1F6FEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total à payer',
                        style: TextStyle(
                            color: Color(0xFFDDEAF8), fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(
                      '${_fmt(_foundMonthly)} × $_months mois',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  '${_fmt(_total)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Modes de paiement ────────────────────────
          _sectionLabel('Mode de paiement'),
          const SizedBox(height: 10),

          _methodTile('MTN MoMo', Icons.phone_android_rounded,
              const Color(0xFFFFCC00), const Color(0xFF132238), 'MTN'),
          const SizedBox(height: 10),
          _methodTile('Moov Money', Icons.phone_android_rounded,
              const Color(0xFF1F6FEB), Colors.white, 'Moov'),
          const SizedBox(height: 10),
          _methodTile('Celtis Mobile', Icons.phone_android_rounded,
              const Color(0xFF00A86B), Colors.white, 'Celtis'),
          const SizedBox(height: 10),
          _methodTile('Virement bancaire',
              Icons.account_balance_outlined,
              const Color(0xFF132238), Colors.white, 'Banque'),

          const SizedBox(height: 28),

          // ── Bouton Payer Maintenant ──────────────────
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: (_payMethod == null || _processing) ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF149954),
                disabledBackgroundColor: const Color(0xFFB0BEC5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _processing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'PAYER MAINTENANT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Paiement sécurisé · Données chiffrées',
              style: TextStyle(color: Color(0xFF9BAAB8), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // SUCCESS
  // ══════════════════════════════════════════════════
  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B6D11).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF3B6D11), size: 68),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Paiement confirmé !',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF132238),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_fmt(_total)} FCFA',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F6FEB),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payé par $_foundName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF607086), fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'via $_payMethod · $_months mois',
                  style: const TextStyle(
                      color: Color(0xFF9BAAB8), fontSize: 13),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAE4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC0DD97)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF3B6D11), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Votre paiement a été enregistré. Votre propriétaire sera notifié automatiquement.',
                          style: TextStyle(
                              color: Color(0xFF3B6D11), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    final receipt = 'Reçu de paiement\n'
                        'Locataire : $_foundName\n'
                        'Montant : ${_fmt(_total)} FCFA\n'
                        'Mois payés : $_months\n'
                        'Mode : $_payMethod';
                    Clipboard.setData(ClipboardData(text: receipt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Reçu copié !'),
                        backgroundColor: const Color(0xFF3B6D11),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copier le reçu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F6FEB),
                    side: const BorderSide(color: Color(0xFF1F6FEB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────── Widgets helpers ──────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF132238),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F6FEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _methodTile(
    String label,
    IconData icon,
    Color bg,
    Color textColor,
    String method,
  ) {
    final selected = _payMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _payMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? bg : const Color(0xFFE0E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? textColor : const Color(0xFF607086),
                size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? textColor : const Color(0xFF132238),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: textColor, size: 22),
          ],
        ),
      ),
    );
  }
}
