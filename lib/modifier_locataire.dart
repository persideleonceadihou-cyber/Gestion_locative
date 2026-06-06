import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_locative/app_background.dart';
import 'package:gestion_locative/locataire.dart';

class _C {
  static const navy = Color(0xFF1A2B5E);
  static const bgPage = Color(0xFFF5F0E8);
  static const success = Color(0xFF149954);
  static const danger = Color(0xFF993C1D);
}

class ModifierLocataire extends StatefulWidget {
  final TenantRecord tenant;

  const ModifierLocataire({super.key, required this.tenant});

  @override
  State<ModifierLocataire> createState() => _ModifierLocataireState();
}

class _ModifierLocataireState extends State<ModifierLocataire> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _roomController;
  late final TextEditingController _propertyController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _rentController;
  late final TextEditingController _contactController;
  late final TextEditingController _notesController;

  late String _selectedStatus;
  DateTime? _entryDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nameController = TextEditingController(text: t.name);
    _roomController = TextEditingController(text: t.roomNumber);
    _propertyController = TextEditingController(text: t.propertyName);
    _phoneController = TextEditingController(text: t.phone);
    _emailController = TextEditingController(text: t.email);
    _rentController = TextEditingController(
      text: t.rentAmount.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final rawContact = t.emergencyContact
        .replaceFirst('Contact urgence : ', '')
        .replaceFirst('Contact urgence non renseigné', '');
    _contactController = TextEditingController(text: rawContact);
    final rawNotes = t.notes == 'Aucune note ajoutée pour le moment.'
        ? ''
        : t.notes;
    _notesController = TextEditingController(text: rawNotes);
    _selectedStatus = t.statusLabel;
    _entryDate = t.entryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _propertyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rentController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.tenant.id;
    if (id == null) return;

    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final room = _roomController.text.trim().toUpperCase();
    final property = _propertyController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final rent = _rentController.text.trim();
    final emergencyContact = _contactController.text.trim();
    final notes = _notesController.text.trim();

    final data = <String, dynamic>{
      'name': name,
      'nom': name,
      'roomNumber': room,
      'chambre': room,
      'propertyName': property,
      'bien': property,
      'phone': phone,
      'email': email,
      'rentAmount': '$rent FCFA',
      'statusLabel': _selectedStatus,
      'balanceLabel': _statusMetaFor(_selectedStatus),
      'emergencyContact': emergencyContact.isEmpty
          ? 'Contact urgence non renseigné'
          : 'Contact urgence : $emergencyContact',
      'notes': notes.isEmpty ? 'Aucune note ajoutée pour le moment.' : notes,
    };
    if (_entryDate != null) data['entryDate'] = Timestamp.fromDate(_entryDate!);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('locataires')
            .doc(id)
            .update(data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name mis à jour !'),
          backgroundColor: _C.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      final updated = widget.tenant.copyWith(
        name: name,
        roomNumber: room,
        propertyName: property,
        phone: phone,
        email: email,
        rentAmount: '$rent FCFA',
        statusLabel: _selectedStatus,
        statusColor: _statusColorFor(_selectedStatus),
        balanceLabel: _statusMetaFor(_selectedStatus),
        emergencyContact: emergencyContact.isEmpty
            ? 'Contact urgence non renseigné'
            : 'Contact urgence : $emergencyContact',
        notes: notes.isEmpty ? 'Aucune note ajoutée pour le moment.' : notes,
        entryDate: _entryDate,
      );
      if (mounted) Navigator.of(context).pop(updated);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.message ?? "Impossible de mettre à jour"}'),
          backgroundColor: _C.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mise à jour impossible pour le moment.'),
          backgroundColor: _C.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgPage,
      appBar: AppBar(
        backgroundColor: _C.navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF132238),
              size: 18,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Modifier le locataire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Mettre à jour le dossier',
              style: TextStyle(fontSize: 12, color: Color(0xFFABC4E0)),
            ),
          ],
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section : Informations principales ──
                  _SectionCard(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF1F6FEB),
                    title: 'Informations principales',
                    child: Column(
                      children: [
                        _Field(
                          controller: _nameController,
                          label: 'Nom complet',
                          icon: Icons.badge_outlined,
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                controller: _roomController,
                                label: 'Chambre',
                                icon: Icons.meeting_room_outlined,
                                validator: _required,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Field(
                                controller: _rentController,
                                label: 'Loyer (FCFA)',
                                icon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                                validator: _required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _propertyController,
                          label: 'Bien loué',
                          icon: Icons.home_work_outlined,
                          validator: _required,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Section : Coordonnées ──
                  _SectionCard(
                    icon: Icons.contact_phone_outlined,
                    iconColor: const Color(0xFF149954),
                    title: 'Coordonnées',
                    child: Column(
                      children: [
                        _Field(
                          controller: _phoneController,
                          label: 'Téléphone',
                          icon: Icons.call_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _contactController,
                          label: 'Contact urgence',
                          icon: Icons.support_agent_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Section : Suivi ──
                  _SectionCard(
                    icon: Icons.track_changes_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Suivi du dossier',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(
                            color: Color(0xFF607086),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StatusSelector(
                          selected: _selectedStatus,
                          onChanged: (v) => setState(() => _selectedStatus = v),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Date d'entrée",
                          style: TextStyle(
                            color: Color(0xFF607086),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _entryDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              locale: const Locale('fr'),
                            );
                            if (picked != null) {
                              setState(() => _entryDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFDDEAF8),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFF7D8CA0),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _entryDate != null
                                      ? '${_entryDate!.day.toString().padLeft(2, '0')}/${_entryDate!.month.toString().padLeft(2, '0')}/${_entryDate!.year}'
                                      : "Sélectionner la date d'entrée",
                                  style: TextStyle(
                                    color: _entryDate != null
                                        ? const Color(0xFF132238)
                                        : const Color(0xFF7D8CA0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _notesController,
                          label: 'Notes',
                          icon: Icons.edit_note_outlined,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Bouton enregistrer ──
                  GestureDetector(
                    onTap: _saving ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF102A43), Color(0xFF1F6FEB)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F6FEB).withOpacity(0.30),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_saving)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Enregistrer les modifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est obligatoire' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ce champ est obligatoire';
    if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
    return null;
  }

  Color _statusColorFor(String s) {
    switch (s) {
      case 'Retard':
        return const Color(0xFFE53935);
      case 'Paiement attendu':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF149954);
    }
  }

  String _statusMetaFor(String s) {
    switch (s) {
      case 'Retard':
        return 'Relance à programmer';
      case 'Paiement attendu':
        return 'Première échéance en attente';
      default:
        return 'Dossier à jour';
    }
  }
}

// ── Widgets helpers (copiés du même style que ajout.dart) ──

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132238).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF132238),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF132238),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7D8CA0), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF7D8CA0), size: 20),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        alignLabelWithHint: maxLines > 1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDEAF8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1F6FEB), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.8),
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  static const _statuses = [
    _StatusOption('A jour', Color(0xFF149954), Icons.check_circle_outline_rounded),
    _StatusOption('Paiement attendu', Color(0xFFF59E0B), Icons.schedule_rounded),
    _StatusOption('Retard', Color(0xFFE53935), Icons.warning_amber_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _statuses.map((s) {
        final isSelected = selected == s.label;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s.label),
            child: Container(
              margin: EdgeInsets.only(right: s == _statuses.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? s.color.withOpacity(0.12)
                    : const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? s.color : const Color(0xFFDDEAF8),
                  width: isSelected ? 1.8 : 1.2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    s.icon,
                    color: isSelected ? s.color : const Color(0xFF7D8CA0),
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label == 'Paiement attendu' ? 'Attendu' : s.label,
                    style: TextStyle(
                      color: isSelected ? s.color : const Color(0xFF7D8CA0),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusOption {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusOption(this.label, this.color, this.icon);
}
