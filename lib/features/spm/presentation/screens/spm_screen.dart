import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/presentations/widgets/core_blur_dialog.dart';
import 'package:travis/core/presentations/widgets/core_header.dart';
import 'package:travis/features/spm/data/datasources/spm_remote_data_source.dart';
import 'package:travis/features/spm/data/repositories/spm_repository_impl.dart';
import 'package:travis/features/spm/presentation/bloc/spm_list/spm_list_bloc.dart';
import 'package:travis/features/spm/presentation/bloc/spm_list/spm_list_event.dart';
import 'package:travis/features/spm/presentation/bloc/spm_list/spm_list_state.dart';

class SpmScreen extends StatelessWidget {
  const SpmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpmListBloc(
        repository: SpmRepositoryImpl(
          remoteDataSource: SpmRemoteDataSource(dio: DioClient().instance),
        ),
      )..add(const LoadSpmList()),
      child: const SpmScreenView(),
    );
  }
}

class SpmScreenView extends StatefulWidget {
  const SpmScreenView({super.key});

  @override
  State<SpmScreenView> createState() => _SpmScreenViewState();
}

class _SpmScreenViewState extends State<SpmScreenView> {
  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void _fetchData() {
    context.read<SpmListBloc>().add(const LoadSpmList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: 'Standar Pelayanan Minimal',
              subtitle: 'Kelola Standar Pelayanan Minimal',
              showBackButton: true,
              onBackPressed: () => context.pop(),
            ),
            Expanded(
              child: BlocConsumer<SpmListBloc, SpmListState>(
                listener: (context, state) {
                  if (state is SpmListError) {
                    showCoreErrorDialog(
                      context,
                      'Error',
                      'Gagal memuat data SPM. Error: ${state.message}',
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SpmListLoading || state is SpmListInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SpmListLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async => _fetchData(),
                      child: state.tasks.isEmpty
                          ? _buildEmptyState(theme)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.all(16),
                              itemCount: state.tasks.length,
                              itemBuilder: (context, index) {
                                final item = state.tasks[index];
                                final statusName = item.statusName;
                                final statusCode = item.statusCode;
                                final createdBy = item.createdBy;
                                final createdDate = _formatDate(
                                  item.createdDate,
                                );

                                final isDark =
                                    theme.brightness == Brightness.dark;
                                final modulName = item.moduleName;
                                final taskId = item.id.toString();
                                final statusStyle = _resolveStatusStyle(
                                  statusCode,
                                  statusName,
                                );

                                return Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () {
                                        context
                                            .push('/spm/detail', extra: item.id)
                                            .then((result) async {
                                              if (result == true) {
                                                await Future.delayed(
                                                  const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                );
                                                if (mounted) _fetchData();
                                              }
                                            });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              theme.cardTheme.color ??
                                              theme.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black26
                                                  : Colors.grey.withValues(
                                                      alpha: 0.12,
                                                    ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.transparent
                                                : Colors.grey.withValues(
                                                    alpha: 0.15,
                                                  ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusStyle.color
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    statusStyle.icon,
                                                    color: statusStyle.color,
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Task ID: $taskId',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Dibuat oleh: $createdBy',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: theme
                                                              .textTheme
                                                              .bodySmall
                                                              ?.color,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: statusStyle.color
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    border: Border.all(
                                                      color: statusStyle.color
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    statusStyle.label,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: statusStyle.color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 14),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.apps_outlined,
                                                  size: 16,
                                                  color: Colors.deepPurple,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Modul: ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.deepPurple,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    modulName,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Dibuat $createdDate',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color:
                                                      theme.colorScheme.primary,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/spm/input').then((_) async {
            // Beri sedikit jeda agar backend benar-benar selesai melakukan commit/transaksi database
            // sebelum kita melakukan GET list terbaru.
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              _fetchData();
            }
          });
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada data SPM',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data input SPM Anda akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpmStatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _SpmStatusStyle(this.label, this.color, this.icon);
}

_SpmStatusStyle _resolveStatusStyle(String statusCode, String statusName) {
  switch (statusCode.toUpperCase()) {
    case 'DFT':
      return _SpmStatusStyle(
        statusName.isEmpty ? 'DRAFT' : statusName,
        Colors.orange,
        Icons.edit_document,
      );
    case 'SUB':
    case 'PENDING':
      return _SpmStatusStyle(
        statusName.isEmpty ? 'SUBMITTED' : statusName,
        Colors.blue,
        Icons.hourglass_top_rounded,
      );
    case 'APR':
    case 'APPROVED':
      return _SpmStatusStyle(
        statusName.isEmpty ? 'APPROVED' : statusName,
        Colors.green,
        Icons.check_circle_outline_rounded,
      );
    case 'REJECTED':
      return _SpmStatusStyle(
        statusName.isEmpty ? 'REJECTED' : statusName,
        Colors.red,
        Icons.cancel_outlined,
      );
    default:
      return _SpmStatusStyle(
        statusName.isEmpty ? 'Unknown' : statusName,
        Colors.blueGrey,
        Icons.assignment_outlined,
      );
  }
}
