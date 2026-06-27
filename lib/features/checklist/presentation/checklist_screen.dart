import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/checklist/data/datasources/checklist_remote_data_source.dart';
import 'package:psm_mobile/features/checklist/data/repositories/checklist_repository_impl.dart';
import 'package:psm_mobile/features/checklist/presentation/bloc/checklist_list_bloc.dart';
import 'package:psm_mobile/features/checklist/presentation/bloc/checklist_list_event.dart';
import 'package:psm_mobile/features/checklist/presentation/bloc/checklist_list_state.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChecklistListBloc(
        repository: ChecklistRepositoryImpl(
          remoteDataSource: ChecklistRemoteDataSource(
            dio: DioClient().instance,
          ),
        ),
      )..add(const LoadChecklistList()),
      child: const _ChecklistScreenView(),
    );
  }
}

class _ChecklistScreenView extends StatefulWidget {
  const _ChecklistScreenView();

  @override
  State<_ChecklistScreenView> createState() => _ChecklistScreenViewState();
}

class _ChecklistScreenViewState extends State<_ChecklistScreenView> {
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
    context.read<ChecklistListBloc>().add(const LoadChecklistList());
  }

  IconData _tipeFormIcon(String code) {
    switch (code.toUpperCase()) {
      case 'KENDARAAN':
        return Icons.directions_bus;
      case 'PRAMUGARA':
        return Icons.person_outline;
      case 'BUS_DRIVER':
        return Icons.drive_eta;
      case 'KORLAP':
        return Icons.assignment_outlined;
      default:
        return Icons.checklist;
    }
  }

  Color _tipeFormColor(String code) {
    switch (code.toUpperCase()) {
      case 'KENDARAAN':
        return Colors.blue;
      case 'PRAMUGARA':
        return Colors.teal;
      case 'BUS_DRIVER':
        return Colors.deepPurple;
      case 'KORLAP':
        return Colors.indigo;
      default:
        return Colors.amber;
    }
  }

  Color _statusColor(String code) {
    switch (code.toUpperCase()) {
      case 'AKT':
      case 'ACTIVE':
        return Colors.green;
      case 'DFT':
      case 'DRAFT':
        return Colors.orange;
      case 'INACTIVE':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: 'Checklist Harian',
              subtitle: 'Daftar checklist harian',
              showBackButton: true,
              onBackPressed: () => context.pop(),
            ),
            Expanded(
              child: BlocConsumer<ChecklistListBloc, ChecklistListState>(
                listener: (context, state) {
                  if (state is ChecklistListError) {
                    showCoreErrorDialog(
                      context,
                      'Error',
                      'Gagal memuat data. Error: ${state.message}',
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChecklistListLoading ||
                      state is ChecklistListInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChecklistListLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async => _fetchData(),
                      child: state.items.isEmpty
                          ? _buildEmptyState(theme)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.all(16),
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return _buildCard(theme, item);
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
        onPressed: () async {
          final result = await context.push('/checklist/input');
          if (result == true && mounted) {
            _fetchData();
          }
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, dynamic item) {
    final isDark = theme.brightness == Brightness.dark;
    final formColor = _tipeFormColor(item.tipeFormCode);
    final formIcon = _tipeFormIcon(item.tipeFormCode);
    final sColor = _statusColor(item.statusCode);
    final createdDate = _formatDate(item.createdDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: navigasi ke detail
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.grey.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : Colors.grey.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon + Tipe Form + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: formColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(formIcon, color: formColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.tipeFormName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.code,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.statusName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: sColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Row 2: Koridor
              Row(
                children: [
                  const Icon(
                    Icons.route_outlined,
                    size: 16,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Koridor: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.koridorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 3: Bus
              Row(
                children: [
                  const Icon(
                    Icons.directions_bus_outlined,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bus: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'No. Lambung ${item.busNomorLambung} — ${item.busPlatNomor}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 4: Pramugara + Shift
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.pramugaraName}  •  ${item.shiftName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 5: Tanggal + Created date + chevron
              Row(
                children: [
                  // Icon(
                  //   Icons.calendar_today_outlined,
                  //   size: 14,
                  //   color: theme.textTheme.bodySmall?.color,
                  // ),
                  // const SizedBox(width: 6),
                  // Text(
                  //   item.tanggal,
                  //   style: TextStyle(
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.w600,
                  //     color: theme.primaryColor,
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      createdDate,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Icon(
                  //   Icons.chevron_right_rounded,
                  //   color: theme.colorScheme.primary,
                  // ),
                ],
              ),
            ],
          ),
        ),
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
                      Icons.checklist_outlined,
                      size: 56,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada data Checklist',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data checklist harian akan muncul di sini.',
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
