import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart%20&%20error_widget.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class RapportsPage extends StatefulWidget {
  const RapportsPage({super.key});

  @override
  State<RapportsPage> createState() => _RapportsPageState();
}

class _RapportsPageState extends State<RapportsPage> with SingleTickerProviderStateMixin {
  final ApiService _api = Get.find<ApiService>();
  late TabController _tabController;

  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _financier;
  List<dynamic> _impayes        = [];
  List<dynamic> _filieres       = [];
  List<dynamic> _rapportJour    = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      _api.get('/rapports/statistiques'),
      _api.get('/rapports/financier'),
      _api.get('/rapports/impayes'),
      _api.get('/rapports/filieres'),
      _api.get('/rapports/journalier'),
    ]);

    setState(() {
      _stats      = results[0]['data'];
      _financier  = results[1]['data'];
      _impayes    = (results[2]['data']?['etudiants'] as List?) ?? [];
      _filieres   = (results[3]['data'] as List?) ?? [];
      _rapportJour = (results[4]['data']?['details'] as List?) ?? [];
      _isLoading  = false;
    });
  }

  Future<void> _exportPDF(String type) async {
    setState(() => _isExporting = true);
    final result = await _api.get('/rapports/export/pdf', params: {'type': type});
    setState(() => _isExporting = false);

    if (result['success'] == true) {
      AppHelpers.showSuccess('Rapport généré: ${result['data']['pdf_url']}');
    } else {
      AppHelpers.showError('Erreur export');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rapports & Statistiques',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              onSelected: _exportPDF,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'general',  child: Text('Export Général')),
                const PopupMenuItem(value: 'paiements', child: Text('Export Paiements')),
                const PopupMenuItem(value: 'impayes',  child: Text('Export Impayés')),
                const PopupMenuItem(value: 'filieres', child: Text('Export Filières')),
              ],
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement des rapports...')
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  tabs: const [
                    Tab(text: 'Aperçu'),
                    Tab(text: 'Financier'),
                    Tab(text: 'Impayés'),
                    Tab(text: 'Filières'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildApercu(),
                      _buildFinancier(),
                      _buildImpayes(),
                      _buildFilieres(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildApercu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard('Étudiants', '${_stats?['total_etudiants_actifs'] ?? 0}', Icons.people_alt_rounded, AppTheme.primary),
              _StatCard('Inscriptions', '${_stats?['total_inscriptions'] ?? 0}', Icons.how_to_reg_rounded, AppTheme.success),
              _StatCard('Paiements Aujourd\'hui', '${_stats?['paiements_aujourdhui'] ?? 0}', Icons.payments_rounded, AppTheme.warning),
              _StatCard('Montant Aujourd\'hui',
                  AppHelpers.formatMontant(double.tryParse(_stats?['montant_aujourdhui']?.toString() ?? '0') ?? 0),
                  Icons.account_balance_wallet_rounded, AppTheme.info),
            ],
          ),
          const SizedBox(height: 20),
          // Rapport journalier
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rapport du Jour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ..._rapportJour.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r['nom_mode'] ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${r['nombre_transactions']} transaction(s)', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text(AppHelpers.formatMontant(double.tryParse(r['montant_total']?.toString() ?? '0') ?? 0),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _StatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancier() {
    final attendu   = double.tryParse(_financier?['montant_attendu']?.toString()  ?? '0') ?? 0;
    final percu     = double.tryParse(_financier?['montant_percu']?.toString()    ?? '0') ?? 0;
    final impaye    = double.tryParse(_financier?['montant_impaye']?.toString()   ?? '0') ?? 0;
    final taux      = double.tryParse(_financier?['taux_recouvrement']?.toString() ?? '0') ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Taux recouvrement
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Text('Taux de Recouvrement', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('${taux.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (taux / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Montants
          ...[ 
            ['Montant Attendu', attendu, AppTheme.textSecondary],
            ['Montant Perçu',   percu,   AppTheme.success],
            ['Montant Impayé',  impaye,  AppTheme.error],
          ].map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: item[2] as Color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(item[0] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                ]),
                Text(AppHelpers.formatMontant(item[1] as double),
                    style: TextStyle(fontWeight: FontWeight.bold, color: item[2] as Color)),
              ],
            ),
          )),
          const SizedBox(height: 8),
          // Graphique
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Répartition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: PieChart(PieChartData(
                    sections: [
                      PieChartSectionData(value: percu > 0 ? percu : 0.01, color: AppTheme.success, title: 'Perçu', radius: 65,
                          titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      PieChartSectionData(value: impaye > 0 ? impaye : 0.01, color: AppTheme.error, title: 'Impayé', radius: 65,
                          titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                    sectionsSpace: 3, centerSpaceRadius: 40,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpayes() {
    if (_impayes.isEmpty) return const EmptyState(message: 'Aucun impayé', icon: Icons.check_circle_outline);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _impayes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final imp = _impayes[i];
        final restant = double.tryParse(imp['montant_restant']?.toString() ?? '0') ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(imp['nom_complet'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                  Text(AppHelpers.formatMontant(restant), style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text(imp['numero_etudiant'] ?? '', style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
              Text('${imp['nom_filiere']} - ${imp['nom_niveau']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text('Depuis ${imp['jours_depuis_inscription']} jour(s)', style: const TextStyle(color: AppTheme.warning, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilieres() {
    if (_filieres.isEmpty) return const EmptyState(message: 'Aucune donnée', icon: Icons.school_outlined);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filieres.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final f = _filieres[i];
        final attendu = double.tryParse(f['montant_total_attendu']?.toString() ?? '0') ?? 0;
        final percu   = double.tryParse(f['montant_total_percu']?.toString()   ?? '0') ?? 0;
        final taux    = attendu > 0 ? (percu / attendu * 100) : 0.0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(f['nom_filiere'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                  Text('${taux.toStringAsFixed(1)}%', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: taux >= 80 ? AppTheme.success : taux >= 50 ? AppTheme.warning : AppTheme.error,
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${f['nombre_inscriptions'] ?? 0} inscriptions', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  Text(AppHelpers.formatMontant(percu), style: const TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (taux / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  taux >= 80 ? AppTheme.success : taux >= 50 ? AppTheme.warning : AppTheme.error,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }
}