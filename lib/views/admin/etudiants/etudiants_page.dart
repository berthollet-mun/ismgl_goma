import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/etudiant_model.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart%20&%20error_widget.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';
import 'package:ismgl/views/shared/widgets/status_chip.dart%20&%20role_badge.dart';

class EtudiantsPage extends StatefulWidget {
  const EtudiantsPage({super.key});

  @override
  State<EtudiantsPage> createState() => _EtudiantsPageState();
}

class _EtudiantsPageState extends State<EtudiantsPage> {
  final ApiService _api = Get.find<ApiService>();

  List<EtudiantModel> _etudiants = [];
  bool   _isLoading = true;
  int    _currentPage = 1;
  int    _totalPages  = 1;
  int    _total       = 0;
  String _search      = '';
  String? _filterStatut;
  String? _filterSexe;

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
    if (reset) { _currentPage = 1; _etudiants = []; }
    setState(() => _isLoading = true);

    final result = await _api.get('/etudiants', params: {
      'page': _currentPage,
      'page_size': 20,
      if (_search.isNotEmpty) 'search': _search,
      if (_filterStatut != null) 'statut': _filterStatut,
      if (_filterSexe   != null) 'sexe':   _filterSexe,
    });

    if (result['success'] == true) {
      final data = result['data'];
      final items = (data['items'] as List).map((e) => EtudiantModel.fromJson(e)).toList();
      setState(() {
        if (append) { _etudiants.addAll(items); } else { _etudiants = items; }
        _totalPages = data['pagination']['total_pages'];
        _total      = data['pagination']['total_items'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateStatut(EtudiantModel etudiant, String statut) async {
    final result = await _api.patch('/etudiants/${etudiant.idEtudiant}/statut', data: {'statut': statut});
    if (result['success'] == true) {
      AppHelpers.showSuccess('Statut mis à jour');
      _load(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Étudiants ($_total)',
        showBack: true,
        showNotification: false,
        showProfile: false,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: _showFilter),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading && _etudiants.isEmpty
                ? const ShimmerList()
                : _etudiants.isEmpty
                    ? const EmptyState(message: 'Aucun étudiant trouvé', icon: Icons.school_outlined)
                    : RefreshIndicator(
                        onRefresh: () => _load(reset: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _etudiants.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            if (i >= _etudiants.length) return const Center(child: CircularProgressIndicator());
                            return _buildCard(_etudiants[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Rechercher un étudiant...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _search = '');
                  _load(reset: true);
                })
              : null,
        ),
        onChanged: (v) {
          setState(() => _search = v);
          if (v.length >= 3 || v.isEmpty) _load(reset: true);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_filterStatut == null && _filterSexe == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          if (_filterStatut != null)
            Chip(
              label: Text(_filterStatut!),
              onDeleted: () { setState(() => _filterStatut = null); _load(reset: true); },
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            ),
          if (_filterSexe != null) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(_filterSexe == 'M' ? 'Masculin' : 'Féminin'),
              onDeleted: () { setState(() => _filterSexe = null); _load(reset: true); },
              backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(EtudiantModel e) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          radius: 26,
          child: Text(
            AppHelpers.getInitials(e.fullName),
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(e.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
            StatusChip(status: e.statut, type: 'etudiant'),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(e.numeroEtudiant, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500, fontSize: 12)),
            Text(e.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text(
              '${e.sexe == 'M' ? '♂ Masculin' : '♀ Féminin'} • ${AppHelpers.formatDate(e.dateNaissance)}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) => _updateStatut(e, v),
          itemBuilder: (_) => ['Actif', 'Suspendu', 'Diplômé', 'Abandonné']
              .where((s) => s != e.statut)
              .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
              .toList(),
        ),
      ),
    );
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Actif', 'Suspendu', 'Diplômé', 'Abandonné'].map((s) => FilterChip(
                label: Text(s),
                selected: _filterStatut == s,
                onSelected: (_) { setState(() => _filterStatut = _filterStatut == s ? null : s); Get.back(); _load(reset: true); },
              )).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Sexe', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('Masculin'), selected: _filterSexe == 'M',
                    onSelected: (_) { setState(() => _filterSexe = _filterSexe == 'M' ? null : 'M'); Get.back(); _load(reset: true); }),
                FilterChip(label: const Text('Féminin'), selected: _filterSexe == 'F',
                    onSelected: (_) { setState(() => _filterSexe = _filterSexe == 'F' ? null : 'F'); Get.back(); _load(reset: true); }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}