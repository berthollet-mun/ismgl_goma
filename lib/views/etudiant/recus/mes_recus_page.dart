import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/views/shared/widgets/custom_app_bar.dart';
import 'package:ismgl/views/shared/widgets/empty_state.dart%20&%20error_widget.dart';
import 'package:ismgl/views/shared/widgets/loading_widget.dart';

class MesRecusPage extends StatefulWidget {
  const MesRecusPage({super.key});

  @override
  State<MesRecusPage> createState() => _MesRecusPageState();
}

class _MesRecusPageState extends State<MesRecusPage> {
  final ApiService _api = Get.find<ApiService>();

  List<dynamic> _recus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _api.get('/recus/me');
    if (result['success'] == true) {
      setState(() => _recus = (result['data'] as List?) ?? []);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _generer(int idRecu) async {
    final result = await _api.get('/recus/$idRecu/generate');
    if (result['success'] == true) {
      AppHelpers.showSuccess('Reçu généré avec succès');
    } else {
      AppHelpers.showError('Erreur génération reçu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes Reçus',
        showBack: true,
        showNotification: false,
        showProfile: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _recus.isEmpty
                  ? const EmptyState(message: 'Aucun reçu disponible', icon: Icons.receipt_long_outlined)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recus.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildCard(_recus[i]),
                    ),
            ),
    );
  }

  Widget _buildCard(Map<String, dynamic> r) {
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
                Text(r['numero_recu'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 15)),
                Text(
                  AppHelpers.formatMontant(double.tryParse(r['montant_total']?.toString() ?? '0') ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(r['nom_frais'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(AppHelpers.formatDate(r['date_emission']), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.payment, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(r['nom_mode'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _generer(r['id_recu']),
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Télécharger le reçu', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}