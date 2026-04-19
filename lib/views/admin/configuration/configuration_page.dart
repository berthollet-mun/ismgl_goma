import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/button.dart';
import 'package:ismgl/views/shared/widgets/form_field.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> with SingleTickerProviderStateMixin {
  final ApiService _api = Get.find<ApiService>();
  late TabController _tabController;

  List<dynamic> _annees    = [];
  List<dynamic> _typesFrais = [];
  List<dynamic> _niveaux   = [];
  List<dynamic> _facultes  = [];
  List<dynamic> _departements = [];
  List<dynamic> _filieres  = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _api.get('/config/annees'),
      _api.get('/config/types-frais'),
      _api.get('/config/niveaux'),
      _api.get('/config/facultes'),
      _api.get('/filieres'),
    ]);
    setState(() {
      _annees      = (results[0]['data'] as List?) ?? [];
      _typesFrais  = (results[1]['data'] as List?) ?? [];
      _niveaux     = (results[2]['data'] as List?) ?? [];
      _facultes    = (results[3]['data'] as List?) ?? [];
      _filieres    = (results[4]['data'] as List?) ?? [];
      _isLoading   = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Configuration',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  tabs: const [
                    Tab(text: 'Années'),
                    Tab(text: 'Frais'),
                    Tab(text: 'Filières'),
                    Tab(text: 'Facultés'),
                    Tab(text: 'Niveaux'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAnneesTab(),
                      _buildTypesFraisTab(),
                      _buildFilieresTab(),
                      _buildFacultesTab(),
                      _buildNiveauxTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ===== ANNÉES ACADÉMIQUES =====
  Widget _buildAnneesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            label: 'Nouvelle Année Académique',
            onPressed: _showAnneeDialog,
            icon: Icons.add,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _annees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _buildAnneeCard(_annees[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnneeCard(Map<String, dynamic> annee) {
    final isCourante = annee['est_courante'] == true || annee['est_courante'] == 1;
    final isCloturee = annee['est_cloturee'] == true || annee['est_cloturee'] == 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isCourante ? Border.all(color: AppTheme.success, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(annee['code_annee'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (isCourante) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Courante', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                    if (isCloturee) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Clôturée', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                Text('Du ${AppHelpers.formatDate(annee['date_debut'])} au ${AppHelpers.formatDate(annee['date_fin'])}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (!isCourante && !isCloturee)
            TextButton(
              onPressed: () => _setAnneeCourante(annee['id_annee_academique']),
              child: const Text('Définir courante'),
            ),
          if (!isCloturee)
            IconButton(
              icon: const Icon(Icons.lock_outline, color: AppTheme.warning, size: 20),
              tooltip: 'Clôturer',
              onPressed: () => _cloturerAnnee(annee['id_annee_academique']),
            ),
        ],
      ),
    );
  }

  Future<void> _setAnneeCourante(int id) async {
    final result = await _api.patch('/config/annees/$id/courante');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Année définie comme courante');
      _loadAll();
    }
  }

  Future<void> _cloturerAnnee(int id) async {
    final confirm = await AppHelpers.showConfirmDialog(
      title: 'Clôturer l\'année', message: 'Cette action est irréversible. Confirmer ?',
      confirmText: 'Clôturer', confirmColor: AppTheme.warning,
    );
    if (!confirm) return;
    final result = await _api.patch('/config/annees/$id/cloturer');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Année clôturée');
      _loadAll();
    }
  }

  void _showAnneeDialog() {
    final codeCtrl  = TextEditingController();
    final debutCtrl = TextEditingController();
    final finCtrl   = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle Année Académique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (ex: 2024-2025)')),
            const SizedBox(height: 12),
            TextField(controller: debutCtrl, decoration: const InputDecoration(labelText: 'Date début (AAAA-MM-JJ)')),
            const SizedBox(height: 12),
            TextField(controller: finCtrl, decoration: const InputDecoration(labelText: 'Date fin (AAAA-MM-JJ)')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final parts = code.split('-');
              if (parts.length < 2) return;

              final result = await _api.post('/config/annees', data: {
                'code_annee':   code,
                'annee_debut':  parts[0],
                'annee_fin':    parts[1],
                'date_debut':   debutCtrl.text.trim(),
                'date_fin':     finCtrl.text.trim(),
                'est_courante': false,
              });
              Get.back();
              if (result['success'] == true) {
                AppHelpers.showSuccess('Année créée');
                _loadAll();
              } else {
                AppHelpers.showError(result['message'] ?? 'Erreur');
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  // ===== TYPES DE FRAIS =====
  Widget _buildTypesFraisTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(label: 'Nouveau Type de Frais', onPressed: _showTypeFraisDialog, icon: Icons.add),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _typesFrais.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final tf = _typesFrais[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.monetization_on_outlined, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tf['nom_frais'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(AppHelpers.formatMontant(double.tryParse(tf['montant_base']?.toString() ?? '0') ?? 0),
                              style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (tf['est_obligatoire'] == true ? AppTheme.error : Colors.grey).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tf['est_obligatoire'] == true ? 'Obligatoire' : 'Optionnel',
                            style: TextStyle(
                              fontSize: 10,
                              color: tf['est_obligatoire'] == true ? AppTheme.error : Colors.grey,
                            ),
                          ),
                        ),
                        Text(tf['code_frais'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTypeFraisDialog() {
    final nomCtrl     = TextEditingController();
    final codeCtrl    = TextEditingController();
    final montantCtrl = TextEditingController();
    bool estOblig = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          title: const Text('Nouveau Type de Frais'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (ex: SCOL)')),
              const SizedBox(height: 8),
              TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 8),
              TextField(controller: montantCtrl, decoration: const InputDecoration(labelText: 'Montant de base (FC)'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Obligatoire', style: TextStyle(fontSize: 14)),
                value: estOblig,
                onChanged: (v) => setStateDialog(() => estOblig = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final result = await _api.post('/config/types-frais', data: {
                  'code_frais':    codeCtrl.text.trim().toUpperCase(),
                  'nom_frais':     nomCtrl.text.trim(),
                  'montant_base':  double.tryParse(montantCtrl.text) ?? 0,
                  'est_obligatoire': estOblig,
                });
                Get.back();
                if (result['success'] == true) { AppHelpers.showSuccess('Type de frais créé'); _loadAll(); }
                else { AppHelpers.showError(result['message'] ?? 'Erreur'); }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  // ===== FILIÈRES =====
  Widget _buildFilieresTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(label: 'Nouvelle Filière', onPressed: _showFiliereDialog, icon: Icons.add),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _filieres.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final f = _filieres[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.school_outlined, color: AppTheme.success, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['nom_filiere'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(f['nom_departement'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          Text('${f['duree_etudes']} an(s) • ${f['diplome_delivre'] ?? ''}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(f['code_filiere'] ?? '', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFiliereDialog() {
    final nomCtrl    = TextEditingController();
    final codeCtrl   = TextEditingController();
    final dureeCtrl  = TextEditingController(text: '3');
    final diplomeCtrl = TextEditingController();
    int? selectedDept;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          title: const Text('Nouvelle Filière'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (ex: IG)')),
                const SizedBox(height: 8),
                TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom de la filière')),
                const SizedBox(height: 8),
                TextField(controller: diplomeCtrl, decoration: const InputDecoration(labelText: 'Diplôme délivré')),
                const SizedBox(height: 8),
                TextField(controller: dureeCtrl, decoration: const InputDecoration(labelText: 'Durée (années)'),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final result = await _api.post('/filieres', data: {
                  'code_filiere':    codeCtrl.text.trim().toUpperCase(),
                  'nom_filiere':     nomCtrl.text.trim(),
                  'id_departement':  1,
                  'diplome_delivre': diplomeCtrl.text.trim(),
                  'duree_etudes':    int.tryParse(dureeCtrl.text) ?? 3,
                });
                Get.back();
                if (result['success'] == true) { AppHelpers.showSuccess('Filière créée'); _loadAll(); }
                else { AppHelpers.showError(result['message'] ?? 'Erreur'); }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  // ===== FACULTÉS =====
  Widget _buildFacultesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(label: 'Nouvelle Faculté', onPressed: _showFaculteDialog, icon: Icons.add),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _facultes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final f = _facultes[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.account_balance_outlined, color: AppTheme.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['nom_faculte'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (f['doyen'] != null)
                            Text('Doyen: ${f['doyen']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(f['code_faculte'] ?? '', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFaculteDialog() {
    final nomCtrl   = TextEditingController();
    final codeCtrl  = TextEditingController();
    final doyenCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle Faculté'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (ex: FST)')),
            const SizedBox(height: 8),
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom de la faculté')),
            const SizedBox(height: 8),
            TextField(controller: doyenCtrl, decoration: const InputDecoration(labelText: 'Doyen (optionnel)')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final result = await _api.post('/config/facultes', data: {
                'code_faculte': codeCtrl.text.trim().toUpperCase(),
                'nom_faculte':  nomCtrl.text.trim(),
                'doyen':        doyenCtrl.text.trim().isEmpty ? null : doyenCtrl.text.trim(),
              });
              Get.back();
              if (result['success'] == true) { AppHelpers.showSuccess('Faculté créée'); _loadAll(); }
              else { AppHelpers.showError(result['message'] ?? 'Erreur'); }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  // ===== NIVEAUX =====
  Widget _buildNiveauxTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _niveaux.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final n = _niveaux[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.info.withValues(alpha: 0.1),
                child: Text('${n['ordre']}', style: const TextStyle(color: AppTheme.info, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(n['nom_niveau'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(n['code_niveau'] ?? '', style: const TextStyle(color: AppTheme.info, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}