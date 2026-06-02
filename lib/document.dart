import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_locative/locataire.dart';

class Document extends StatelessWidget {
  const Document({super.key});

  static const _navy = Color(0xFF1A2B5E);
  static const _cream = Color(0xFFF2C94C);
  static const _creamLight = Color(0xFFFDF6DC);
  static const _bgPage = Color(0xFFF5F0E8);
  static const _border = Color(0xFFECE6D6);
  static const _textMuted = Color(0xFF7A6F52);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _bgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: user == null
                ? _buildContent(context, const [])
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('locataires')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Impossible de charger les documents.'),
                        );
                      }

                      final tenants = snapshot.hasData
                          ? snapshot.data!.docs
                                .map(
                                  (doc) => TenantRecord.fromMap(
                                    doc.data() as Map<String, dynamic>,
                                  ).copyWith(id: doc.id),
                                )
                                .toList()
                          : <TenantRecord>[];

                      return _buildContent(context, tenants);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _navy,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Contrats, etats des lieux et dossiers scannes.',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0BAD0)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TenantRecord> tenants) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(tenants.length),
          const SizedBox(height: 18),
          _sectionTitle(
            'Documents par locataire',
            'Contrat et etat des lieux lies a chaque dossier',
          ),
          const SizedBox(height: 10),
          if (tenants.isEmpty)
            _emptyCard('Aucun document locataire enregistre')
          else
            ...tenants.map((tenant) => _tenantDocumentCard(context, tenant)),
          const SizedBox(height: 20),
          _scanButton(context),
        ],
      ),
    );
  }

  Widget _buildStats(int tenantCount) {
    return Row(
      children: [
        Expanded(
          child: _statCard('$tenantCount', 'Contrats', '$tenantCount actifs'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('$tenantCount', 'Etats des lieux', 'Dossiers lies'),
        ),
      ],
    );
  }

  Widget _statCard(String value, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _navy,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: _textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _navy,
          ),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 12, color: _textMuted)),
      ],
    );
  }

  Widget _tenantDocumentCard(BuildContext context, TenantRecord tenant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TenantDetailScreen(tenant: tenant),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: tenant.statusColor,
                    child: Text(
                      tenant.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.name,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Chambre ${tenant.roomNumber} - ${tenant.rentAmount}',
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _textMuted),
                ],
              ),
            ),
          ),
          _contractCard(tenant),
          _inventoryCard(tenant),
        ],
      ),
    );
  }

  Widget _contractCard(TenantRecord tenant) {
    final state = tenant.contract.state.isEmpty
        ? 'Nouveau'
        : tenant.contract.state;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: _cream),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.contract.title.isEmpty
                      ? 'Contrat ${tenant.roomNumber}'
                      : tenant.contract.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tenant.name} - ${tenant.propertyName}',
                  style: const TextStyle(
                    color: Color(0xFFD0D8F0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _badge(state),
        ],
      ),
    );
  }

  Widget _inventoryCard(TenantRecord tenant) {
    final state = tenant.inventory.state.isEmpty
        ? 'A faire'
        : tenant.inventory.state;
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_outlined, color: _navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.inventory.title.isEmpty
                      ? 'Etat des lieux ${tenant.roomNumber}'
                      : tenant.inventory.title,
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tenant.name,
                  style: const TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          _badge(state),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _creamLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _navy,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _emptyCard(String label) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Text(label, style: const TextStyle(color: _textMuted)),
    );
  }

  Widget _scanButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/scan'),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scanner'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _cream,
          foregroundColor: _navy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      selectedItemColor: _navy,
      unselectedItemColor: _textMuted,
      backgroundColor: Colors.white,
      onTap: (i) {
        final routes = [
          '/accueil',
          '/mesBiens',
          '/paiement',
          '/locataire',
          '/profil',
        ];
        Navigator.pushReplacementNamed(context, routes[i]);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_outlined),
          label: 'Biens',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments_outlined),
          label: 'Paiement',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Locataires',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
