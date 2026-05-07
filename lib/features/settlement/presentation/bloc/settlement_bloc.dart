import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';
import 'package:psm_mobile/features/settlement/domain/repositories/settlement_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository settlementRepository;

  SettlementBloc(this.settlementRepository) : super(const SettlementState()) {
    on<PageDashboardLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final result = await settlementRepository.fetchTaskAuditTrailList('');

      result.fold((failure) {}, (data) {
        emit(state.copyWith(listTaskAuditTrail: data));
      });
      emit(state.copyWith(status: SettlementStatus.success));
    });

    on<PageInputLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final resultBus = await settlementRepository.fetchReferenceBus('');
      final resultKoridor = await settlementRepository.fetchReferenceKoridor(
        '',
      );
      final resultPayment = await settlementRepository.fetchReferencePayment(
        '',
      );
      final resultCustType = await settlementRepository.fetchReferenceCustType(
        '',
      );

      resultBus.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              status: SettlementStatus.success,
              referenceBus: data,
            ),
          );
        },
      );

      resultKoridor.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              status: SettlementStatus.success,
              referenceKoridor: data,
            ),
          );
        },
      );

      List<SettlementDetail> details = [];

      List paymentList = [];
      List custList = [];

      resultPayment.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
          return;
        },
        (data) {
          paymentList = data;
        },
      );

      resultCustType.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
          return;
        },
        (data) {
          custList = data;
        },
      );

      if (paymentList.isEmpty || custList.isEmpty) {
        emit(
          state.copyWith(
            status: SettlementStatus.error,
            message: 'Data reference tidak lengkap',
          ),
        );
        return;
      }

      List<String> labelPayment = [];
      List<String> labelCustomer = [];

      for (final payment in paymentList) {
        labelPayment.add(payment.name);
        for (final cust in custList) {
          labelCustomer.add(cust.name);
          details.add(
            SettlementDetail(
              idPayment: payment.id,
              idNasabah: cust.id,
              total: 0,
              value: 0,
            ),
          );
        }
      }

      emit(
        state.copyWith(
          totalSteps: paymentList.length + 2,
          status: SettlementStatus.success,
          detail: details,
          labelPayment: labelPayment,
          labelCustomer: labelCustomer,
        ),
      );
    });

    on<MoveStepWizard>((event, emit) {
      emit(state.copyWith(steps: event.value));
    });

    on<SelectBus>((event, emit) {
      emit(state.copyWith(idBus: event.id, noUnit: event.noUnit));
    });

    on<SelectKoridor>((event, emit) {
      emit(state.copyWith(idKoridor: event.id, namaKoridor: event.namaKoridor));
    });

    on<SettlementFieldChanged>((event, emit) {
      switch (event.field) {
        case 'processId':
          emit(state.copyWith(processId: event.value));
          break;
        case 'auditTrailId':
          emit(state.copyWith(auditTrailId: event.value));
          break;
        case 'idBus':
          emit(state.copyWith(idBus: event.value));
          break;
        case 'code':
          emit(state.copyWith(code: event.value));
          break;
        case 'idKoridor':
          emit(state.copyWith(idKoridor: event.value));
          break;
        case 'idShift':
          emit(state.copyWith(idShift: event.value));
          break;
      }
    });

    on<AddDetail>((event, emit) {
      final newList = List<SettlementDetail>.from(state.detail)
        ..add(event.detail);

      emit(state.copyWith(detail: newList));
    });

    on<UpdateDetail>((event, emit) {
      final updatedList = state.detail.map((d) {
        if (d.idPayment == event.idPayment && d.idNasabah == event.idNasabah) {
          return SettlementDetail(
            idPayment: d.idPayment,
            idNasabah: d.idNasabah,
            total: event.total ?? d.total,
            value: event.value ?? d.value,
          );
        }
        return d;
      }).toList();

      emit(state.copyWith(detail: updatedList));
    });

    on<RemoveDetail>((event, emit) {
      final newList = List<SettlementDetail>.from(state.detail)
        ..remove(event.detail);

      emit(state.copyWith(detail: newList));
    });

    on<AddDocument>((event, emit) {
      final newList = List<SettlementDocument>.from(state.document)
        ..add(event.document);

      emit(state.copyWith(document: newList));
    });

    on<RemoveDocument>((event, emit) {
      final newList = List<SettlementDocument>.from(state.document)
        ..remove(event.document);

      emit(state.copyWith(document: newList));
    });

    on<SubmitSettlement>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final request = SettlementCreate(
        idBus: state.idBus,
        code: "AMAIK NEW GEN LOS",
        idKoridor: state.idKoridor,
        idShift: state.idShift,
        detail: state.detail,
        document: state.document,
      );

      final result = await settlementRepository.createSettlement(request);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.failedSave,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              status: SettlementStatus.successSave,
              auditTrailId: int.parse(data),
            ),
          );
        },
      );
    });

    on<SubmitWorkflow>((event, emit) async {
      final result = await settlementRepository.submitWorkflow(
        state.auditTrailId,
        event.reason,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.failedSave,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              status: SettlementStatus.successSave,
            ),
          );
        },
      );
    });
  }
}
