import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';
import 'package:psm_mobile/features/attendance/domain/repositories/approval_repository.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final ApprovalRepository repository;

  ApprovalBloc({required this.repository}) : super(ApprovalInitial()) {
    on<LoadApprovalData>(_onLoadData);
    on<LoadApprovalDetail>(_onLoadDetail);
    on<ApproveShift>(_onApproveShift);
  }

  Future<void> _onLoadData(
    LoadApprovalData event,
    Emitter<ApprovalState> emit,
  ) async {
    final initialState = ApprovalLoaded(isLoading: true, approvals: []);

    if (isClosed) return;
    emit(initialState);

    await _fetchAndEmit(initialState, emit, event);
  }

  Future<void> _fetchAndEmit(
    ApprovalLoaded state,
    Emitter<ApprovalState> emit,
    LoadApprovalData event,
  ) async {
    try {
      final results = await Future.wait([
        repository.getApprovalList(event.type),
      ]);

      final List<ApprovalModel> approvalList = results[0];

      emit(state.copyWith(isLoading: false, approvals: approvalList));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> _onLoadDetail(
    LoadApprovalDetail event,
    Emitter<ApprovalState> emit,
  ) async {
    final initialState = ApprovalDetailLoaded(detail: null, isLoading: true);

    if (isClosed) return;
    emit(initialState);

    try {
      final results = await repository.getApprovalDetail(event.id);

      if (results.isNotEmpty) {
        emit(initialState.copyWith(detail: results.first, isLoading: false));
      } else {
        emit(
          initialState.copyWith(
            isLoading: false,
            errorMessage: 'Data tidak ditemukan',
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          initialState.copyWith(isLoading: false, errorMessage: e.toString()),
        );
      }
    }
  }

  Future<void> _onApproveShift(
    ApproveShift event,
    Emitter<ApprovalState> emit,
  ) async {
    if (state is! ApprovalDetailLoaded) return;
    final currentState = state as ApprovalDetailLoaded;

    emit(currentState.copyWith(isLoading: true, clearError: true));

    try {
      final userIdStr = await SecureStorageService().readUserId();
      final userId = int.tryParse(userIdStr ?? '0') ?? 0;

      await repository.approveShift(
        pergantianShiftId: event.pergantianShiftId,
        userId: userId,
        approved: event.approved,
        rejectReason: event.rejectReason,
      );

      if (!isClosed) {
        emit(currentState.copyWith(isLoading: false, isActionSuccess: true));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          currentState.copyWith(isLoading: false, errorMessage: e.toString()),
        );
      }
    }
  }
}
