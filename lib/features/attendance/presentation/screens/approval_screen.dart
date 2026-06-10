import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/notification/approval_refresh_notifier.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';
import 'package:psm_mobile/features/attendance/data/datasources/approval_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';
import 'package:psm_mobile/features/attendance/data/repositories/approval_repository_impl.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_state.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/widgets.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalBloc(
        repository: ApprovalRepositoryImpl(
          remoteDataSource: ApprovalRemoteDataSourceImpl(DioClient()),
        ),
      )..add(LoadApprovalData()),
      child: const ApprovalView(),
    );
  }
}

class ApprovalView extends StatefulWidget {
  const ApprovalView({super.key});

  @override
  State<ApprovalView> createState() => _ApprovalViewState();
}

class _ApprovalViewState extends State<ApprovalView> {
  StreamSubscription<void>? _approvalRefreshSubscription;

  @override
  void initState() {
    super.initState();
    _approvalRefreshSubscription = ApprovalRefreshNotifier.instance.stream
        .listen((_) {
          if (!mounted) return;
          context.read<ApprovalBloc>().add(LoadApprovalData());
        });
  }

  @override
  void dispose() {
    _approvalRefreshSubscription?.cancel();
    super.dispose();
  }

  int _countPending(List<dynamic> approvals) {
    return approvals.where((item) {
      if (item is! ApprovalModel) return false;
      final status = item.status.toLowerCase();
      return status.isEmpty ||
          status.contains('pending') ||
          status.contains('wait');
    }).length;
  }

  void _refreshApprovalList() {
    context.read<ApprovalBloc>().add(LoadApprovalData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<ApprovalBloc, ApprovalState>(
          listener: (context, state) {
            if (state is ApprovalLoaded && state.errorMessage != null) {
              showCoreErrorDialog(context, 'Kesalahan', state.errorMessage!);
            }
          },
          child: BlocBuilder<ApprovalBloc, ApprovalState>(
            builder: (context, state) {
              if (state is ApprovalInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              final s = state as ApprovalLoaded;

              return Column(
                children: [
                  const ApprovalHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<ApprovalBloc>();
                        _refreshApprovalList();
                        await bloc.stream.firstWhere(
                          (state) =>
                              state is ApprovalLoaded && !state.isLoading,
                        );
                      },
                      child: _buildBody(context, s, theme),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApprovalLoaded state,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 10),
                  const Text('Memuat data...'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (state.approvals.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const ApprovalEmptyState(),
          ),
        ],
      );
    }

    final pendingCount = _countPending(state.approvals);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: state.approvals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ApprovalSummaryBanner(
            totalCount: state.approvals.length,
            pendingCount: pendingCount,
          );
        }

        final approval = state.approvals[index - 1] as ApprovalModel;
        return ApprovalListCard(approval: approval);
      },
    );
  }
}
