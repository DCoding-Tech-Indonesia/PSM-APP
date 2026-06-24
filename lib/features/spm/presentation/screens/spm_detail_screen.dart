import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/spm/data/datasources/spm_remote_data_source.dart';
import 'package:psm_mobile/features/spm/data/repositories/spm_repository_impl.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_detail/spm_detail_bloc.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_detail/spm_detail_event.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_detail/spm_detail_state.dart';

class SpmDetailScreen extends StatelessWidget {
  final int taskId;

  const SpmDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpmDetailBloc(
        repository: SpmRepositoryImpl(
          remoteDataSource: SpmRemoteDataSource(dio: DioClient().instance),
        ),
      )..add(LoadSpmDetail(taskId)),
      child: const SpmDetailScreenView(),
    );
  }
}

class SpmDetailScreenView extends StatefulWidget {
  const SpmDetailScreenView({super.key});

  @override
  State<SpmDetailScreenView> createState() => _SpmDetailScreenViewState();
}

class _SpmDetailScreenViewState extends State<SpmDetailScreenView> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    _checkIfAtBottom();
  }

  void _checkIfAtBottom() {
    if (_scrollController.hasClients) {
      final isBottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;
      if (isBottom != _isAtBottom) {
        setState(() {
          _isAtBottom = isBottom;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _showSubmitDialog(BuildContext context, int idAuditTrail) {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).cardTheme.color?.withValues(alpha: 0.9) ??
                    Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Konfirmasi Submit',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Apakah Anda yakin ingin melakukan submit data ini? Silakan isi alasan di bawah ini:',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alasan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alasan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(dialogContext);
                                context.read<SpmDetailBloc>().add(
                                  SubmitSpmData([
                                    idAuditTrail,
                                  ], reasonController.text),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<SpmDetailBloc, SpmDetailState>(
          listener: (context, state) {
            if (state is SpmSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(true); // signal list screen to refresh
            } else if (state is SpmSubmitError) {
              showCoreErrorDialog(context, 'Gagal', state.message);
            }
          },
          child: Column(
            children: [
              CoreHeader(
                title: 'Detail SPM',
                subtitle: 'Informasi Lengkap Tugas SPM',
                showBackButton: true,
                onBackPressed: () => context.pop(),
              ),
              Expanded(
                child: BlocBuilder<SpmDetailBloc, SpmDetailState>(
                  builder: (context, state) {
                    if (state is SpmDetailLoading ||
                        state is SpmDetailInitial ||
                        state is SpmSubmitLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SpmDetailError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat detail SPM:\n${state.message}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is SpmDetailLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _checkIfAtBottom();
                      });

                      final dataList = state.data;
                      if (dataList.isEmpty) {
                        return const Center(
                          child: Text('Data tidak ditemukan.'),
                        );
                      }

                      final data = dataList.first;

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<SpmDetailBloc>().add(
                            LoadSpmDetail(data.id),
                          );
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 16.0,
                            bottom: 80.0,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kartu Informasi Umum
                              _buildSectionCard(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.info_outline_rounded,
                                title: 'Informasi Umum',
                                color: Colors.blue,
                                children: [
                                  _buildInfoRow(
                                    Icons.view_module,
                                    'Modul',
                                    data.module.name,
                                    theme,
                                  ),
                                  _buildInfoRow(
                                    Icons.person_outline,
                                    'Dibuat Oleh',
                                    data.createdBy.userName,
                                    theme,
                                  ),
                                  _buildInfoRow(
                                    Icons.calendar_today_outlined,
                                    'Tanggal Dibuat',
                                    _formatDate(data.createdDate),
                                    theme,
                                  ),
                                  if (data.approvedBy != null)
                                    _buildInfoRow(
                                      Icons.check_circle,
                                      'Disetujui',
                                      data.approvedBy!.userName,
                                      theme,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Kartu Identitas
                              _buildSectionCard(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.location_on_outlined,
                                title: 'Identitas Pemeriksaan',
                                color: Colors.orange,
                                children: [
                                  _buildInfoRow(
                                    Icons.route_outlined,
                                    'ID Koridor',
                                    data.dataAfter.idKoridor?.toString() ?? '-',
                                    theme,
                                  ),
                                  _buildInfoRow(
                                    Icons.checklist_rtl_rounded,
                                    'ID Tipe',
                                    data.dataAfter.idTypePemeriksaan
                                            ?.toString() ??
                                        '-',
                                    theme,
                                  ),
                                  if (data.dataAfter.idBus != null)
                                    _buildInfoRow(
                                      Icons.directions_bus_outlined,
                                      'ID Bus',
                                      data.dataAfter.idBus.toString(),
                                      theme,
                                    ),
                                  if (data.dataAfter.idHalte != null)
                                    _buildInfoRow(
                                      Icons.storefront_outlined,
                                      'ID Halte',
                                      data.dataAfter.idHalte.toString(),
                                      theme,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Kartu Rincian Penilaian
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.analytics_outlined,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Rincian Penilaian',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (data.dataAfter.detail.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Tidak ada rincian penilaian.',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: data.dataAfter.detail.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final detail = data.dataAfter.detail[index];
                                    final isSuccess =
                                        detail.nilaiCapaian >=
                                        detail.nilaiStandar;

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.cardTheme.color ??
                                            theme.cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black26
                                                : Colors.grey.withValues(
                                                    alpha: 0.08,
                                                  ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.transparent
                                              : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color:
                                                  (isSuccess
                                                          ? Colors.green
                                                          : Colors.orange)
                                                      .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '#${detail.idIndikatorSpm}',
                                                style: TextStyle(
                                                  color: isSuccess
                                                      ? Colors.green.shade700
                                                      : Colors.orange.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Indikator SPM',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _buildScoreBadge(
                                                      'Target',
                                                      detail.nilaiStandar
                                                          .toString(),
                                                      Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _buildScoreBadge(
                                                      'Capaian',
                                                      detail.nilaiCapaian
                                                          .toString(),
                                                      isSuccess
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            isSuccess
                                                ? Icons.check_circle_rounded
                                                : Icons.warning_rounded,
                                            color: isSuccess
                                                ? Colors.green
                                                : Colors.orange,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<SpmDetailBloc, SpmDetailState>(
        builder: (context, state) {
          if (state is SpmDetailLoaded) {
            final data = state.data.isNotEmpty ? state.data.first : null;
            return Container(
              padding: data!.approvedBy == null
                  ? const EdgeInsets.all(16)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: data.approvedBy == null
                  ? ElevatedButton(
                      onPressed: _isAtBottom
                          ? () {
                              _showSubmitDialog(context, data.id);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        disabledBackgroundColor: theme.primaryColor.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isAtBottom
                            ? 'Submit'
                            : 'Harap scroll ke bawah untuk lanjut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(
                            alpha: _isAtBottom ? 1.0 : 0.7,
                          ),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : const SizedBox(),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
