import 'package:flutter/material.dart';
import 'package:gestion_locative/ajoutMaison.dart';
import 'package:gestion_locative/app_background.dart';

// ─────────────────────────────────────────────
// MODÈLE
// ─────────────────────────────────────────────

class PropertyRecord {
  final String title;
  final String address;
  final String description;
  final String loyer;
  final String etat;
  final Color etatColor;
  final String type;
  final int chambres;
  final String imagePath;

  const PropertyRecord({
    required this.title,
    required this.address,
    required this.description,
    required this.loyer,
    required this.etat,
    required this.etatColor,
    required this.type,
    required this.chambres,
    required this.imagePath,
  });
}

const List<PropertyRecord> _sampleProperties = [
  PropertyRecord(
    title: 'Villa Les Cocotiers',
    address: 'Fidjrossè, Cotonou',
    description: 'Clôturée, eau courante, groupe électrogène, parking.',
    loyer: '250 000 FCFA',
    etat: 'Loué',
    etatColor: Color(0xFF1F6FEB),
    type: 'Villa',
    chambres: 5,
    imagePath: 'assets/images/image1 (2).jpg',
  ),
  PropertyRecord(
    title: 'Résidence Les Palmiers',
    address: 'Akpakpa Centre, Cotonou',
    description: 'Immeuble R+2, 8 chambres, gardien permanent.',
    loyer: '75 000 FCFA',
    etat: 'Disponible',
    etatColor: Color(0xFF149954),
    type: 'Appartement',
    chambres: 8,
    imagePath: 'assets/images/img (2).jpg',
  ),
  PropertyRecord(
    title: 'Maison Quartier Zogbo',
    address: 'Zogbo, Porto-Novo',
    description: 'Maison simple, puits, cuisine extérieure.',
    loyer: '60 000 FCFA',
    etat: 'En travaux',
    etatColor: Color(0xFFF59E0B),
    type: 'Maison',
    chambres: 3,
    imagePath: 'assets/images/img.jpeg',
  ),
  PropertyRecord(
    title: 'Studio Cadjehoun',
    address: 'Cadjehoun, Cotonou',
    description: 'Studio meublé, climatisé, accès internet.',
    loyer: '90 000 FCFA',
    etat: 'Loué',
    etatColor: Color(0xFF1F6FEB),
    type: 'Studio',
    chambres: 1,
    imagePath: 'assets/images/img (2).jpg',
  ),
  PropertyRecord(
    title: 'Bureau Ganhi',
    address: 'Ganhi, Cotonou',
    description: 'Local commercial, sécurisé, 2 salles de réunion.',
    loyer: '180 000 FCFA',
    etat: 'Disponible',
    etatColor: Color(0xFF149954),
    type: 'Bureau',
    chambres: 4,
    imagePath: 'assets/images/image1 (2).jpg',
  ),
];

// ─────────────────────────────────────────────
// PAGE PRINCIPALE
// ─────────────────────────────────────────────

class Propretaire extends StatefulWidget {
  const Propretaire({super.key});

  @override
  State<Propretaire> createState() => _PropretaireState();
}

class _PropretaireState extends State<Propretaire> {
  String _searchQuery = '';
  String _filterEtat = 'Tous';

  List<PropertyRecord> get _filtered {
    return _sampleProperties.where((p) {
      final matchSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFilter =
          _filterEtat == 'Tous' || p.etat == _filterEtat;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final loues = _sampleProperties.where((p) => p.etat == 'Loué').length;
    final disponibles =
        _sampleProperties.where((p) => p.etat == 'Disponible').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Propriétés',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF132238),
              ),
            ),
            Text(
              'Votre parc immobilier',
              style: TextStyle(fontSize: 13, color: Color(0xFF607086)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF132238),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF132238),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjoutMaison()),
          );
        },
        child: const Icon(Icons.add_home_outlined),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              // ── Hero banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF102A43),
                      Color(0xFF1F6FEB),
                      Color(0xFF63B3ED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parc immobilier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Consultez, filtrez et gérez tous vos biens immobiliers en un seul endroit.',
                      style: TextStyle(
                        color: Color(0xFFDDEAF8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── StatCards ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Biens total',
                      value: '${_sampleProperties.length}',
                      icon: Icons.home_work_outlined,
                      color: const Color(0xFF1F6FEB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Loués',
                      value: '$loues',
                      icon: Icons.people_outline_rounded,
                      color: const Color(0xFF1F6FEB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Disponibles',
                      value: '$disponibles',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF149954),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Barre de recherche ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF132238).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Color(0xFF132238)),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un bien…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7D8CA0),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF7D8CA0),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF7D8CA0), size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Filtres ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tous', 'Loué', 'Disponible', 'En travaux']
                      .map((f) => _filterChip(f))
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),

              // ── Compteur ──
              Text(
                '${filtered.length} bien${filtered.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Color(0xFF132238),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),

              // ── Liste des biens ──
              if (filtered.isEmpty)
                _EmptyState()
              else
                ...filtered.map((p) => _PropertyCard(property: p)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterEtat == label;
    return GestureDetector(
      onTap: () => setState(() => _filterEtat = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132238) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF132238)
                : const Color(0xFFDDEAF8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF132238),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132238).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF607086),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CARTE PROPRIÉTÉ
// ─────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final PropertyRecord property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132238).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Image.asset(
                  property.imagePath,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: const Color(0xFFDDEAF8),
                    child: const Icon(
                      Icons.home_work_outlined,
                      size: 48,
                      color: Color(0xFF7D8CA0),
                    ),
                  ),
                ),
                // Badge état sur l'image
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: property.etatColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.etat,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Badge type
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Infos ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          color: Color(0xFF132238),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      property.loyer,
                      style: const TextStyle(
                        color: Color(0xFF149954),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFF7D8CA0)),
                    const SizedBox(width: 4),
                    Text(
                      property.address,
                      style: const TextStyle(
                        color: Color(0xFF607086),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  property.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7D8CA0),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Chambres
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.meeting_room_outlined,
                              size: 14, color: Color(0xFF607086)),
                          const SizedBox(width: 4),
                          Text(
                            '${property.chambres} ch.',
                            style: const TextStyle(
                              color: Color(0xFF132238),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Bouton détails
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xFF132238),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Voir les détails',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white, size: 11),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ÉTAT VIDE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.home_work_outlined,
              size: 48, color: Color(0xFF7D8CA0)),
          SizedBox(height: 12),
          Text(
            'Aucun bien trouvé.',
            style: TextStyle(
              color: Color(0xFF607086),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
