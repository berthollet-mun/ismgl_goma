import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/paiement_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart%20&%20error_widget.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/status_chip.dart%20&%20role_badge.dart';

class PaiementsPage extends StatefulWidget {
  const PaiementsPage({super.key});

  @override
  State<PaiementsPage> createState() => _PaiementsPageState();
}

class _PaiementsPageState extends State<PaiementsPage> {
  final ApiService _api = Get.find<ApiService>();

  List<PaiementModel> _paiements = [];
  bool   _isLoading   = true;
  int    _currentPage = 1;
  int    _totalPages  = 1;
  int    _total       = 0;
  String _search      = '';
  String? _dateDebut;
  String? _dateFin;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        if (_currentPage < _totalPages && !_isLoading) {
          _currentPage++;
          _load(append: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false, bool reset = false}) async {
    if (reset) { _currentPage = 1; _paiements = []; }
    setState(() => _isLoading = true);

    final result = await _api.get('/paiements', params: {
      'page': _currentPage, 'page_size': 20,
      if (_search.isNotEmpty) 'search':     _search,
      if (_dateDebut != null) 'date_debut': _dateDebut,
      if (_dateFin   != null) 'date_fin':   _dateFin,
    });

    if (result['success'] == true) {
      final data = result['data'];
      final items = (data['items'] as List).map((p) => PaiementModel.fromJson(p)).toList();
      setState(() {
        if (append) { _paiements.addAll(items); } else { _paiements = items; }
        _totalPages = data['pagination']['total_pages'];
        _total      = data['pagination']['total_items'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _annuler(PaiementModel p) async {
    final motifCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Annuler le paiement ${p.numeroPaiement} ?'),
            const SizedBox(height: 12),
            TextField(controller: motifCtrl, decoration: const InputDecoration(labelText: 'Motif d\'annulation'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Non')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Annuler paiement'),
          ),
        ],
      ),
    );

    if (confirm == true && motifCtrl.text.isNotEmpty) {
      final result = await _api.patch('/paiements/${p.idPaiement}/annuler', data: {'motif': motifCtrl.text});
      if (result['success'] == true) {
        AppHelpers.showSuccess('Paiement annulé');
        _load(reset: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Paiements ($_total)',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          IconButton(icon: const Icon(Icons.date_range_outlined), onPressed: _showDateFilter),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.caissierNouveauPaiement)?.then((_) => _load(reset: true)),
        label: const Text('Nouveau'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'Rechercher...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) { setState(() => _search = v); if (v.length >= 3 || v.isEmpty) _load(reset: true); },
            ),
          ),
          // Filtre date
          if (_dateDebut != null || _dateFin != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Du ${_dateDebut ?? '...'} au ${_dateFin ?? '...'}',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () { setState(() { _dateDebut = null; _dateFin = null; }); _load(reset: true); },
                    child: const Icon(Icons.close, size: 16, color: AppTheme.error),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading && _paiements.isEmpty
                ? const ShimmerList()
                : _paiements.isEmpty
                    ? EmptyState(message: 'Aucun paiement', icon: Icons.payments_outlined,
                        actionLabel: 'Nouveau paiement', onAction: () => Get.toNamed(AppRoutes.caissierNouveauPaiement))
                    : RefreshIndicator(
                        onRefresh: () => _load(reset: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _paiements.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            if (i >= _paiements.length) return const Center(child: CircularProgressIndicator());
                            return _buildCard(_paiements[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PaiementModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.numeroPaiement, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                StatusChip(status: p.statutPaiement, type: 'paiement'),
              ],
            ),
            const SizedBox(height: 6),
            Text(p.nomCompletEtudiant ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(p.nomFrais ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppHelpers.formatMontant(p.montant),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.success)),
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(p.modePaiement ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppHelpers.formatDate(p.datePaiement),
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    if (p.numeroRecu != null)
                      Row(
                        children: [
                          const Icon(Icons.receipt, size: 14, color: AppTheme.info),
                          const SizedBox(width: 4),
                          Text(p.numeroRecu!, style: const TextStyle(color: AppTheme.info, fontSize: 11)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            if (p.estValide) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.caissierRecus, arguments: p.idPaiement),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('Reçu', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () => _annuler(p),
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.error),
                    label: const Text('Annuler', style: TextStyle(fontSize: 12, color: AppTheme.error)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDateFilter() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _dateDebut = '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
        _dateFin   = '${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}';
      });
      _load(reset: true);
    }
  }
}