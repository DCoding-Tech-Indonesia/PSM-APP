import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail_input.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';
import 'package:psm_mobile/features/settlement/domain/repositories/settlement_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository settlementRepository;

  SettlementBloc(this.settlementRepository) : super(const SettlementState()) {
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

      List busList = [];
      List koridorList = [];

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
          busList = data;
          emit(state.copyWith(referenceBus: data));
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
          koridorList = data;
          emit(state.copyWith(referenceKoridor: data));
        },
      );

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

      List<SettlementDetail> details = [];
      List<SettlementDetailInput> inputDetails = [];
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

          inputDetails.add(
            SettlementDetailInput(
              idPayment: payment.id,
              idNasabah: cust.id,
              value: 10000)
          );
        }
      }

      int? idBus;
      int? idKoridor;
      String noUnit = '';
      String namaKoridor = '';

      if (event.idAuditTrail != null) {
        emit(state.copyWith(auditTrailId: event.idAuditTrail));
        final resultAudit = await settlementRepository
            .fetchTaskAuditTrailDetail(event.idAuditTrail!);

        resultAudit.fold(
          (failure) {
            emit(
              state.copyWith(
                status: SettlementStatus.error,
                message: failure.message,
              ),
            );
          },
          (auditData) {
            idBus = auditData.idBus;
            idKoridor = auditData.idKoridor;

            final selectedBus = busList.cast<dynamic>().firstWhere(
              (e) => e?.id == idBus,
              orElse: () => null,
            );

            if (selectedBus != null) {
              noUnit = selectedBus.platNomor ?? '';
            }

            final selectedKoridor = koridorList.cast<dynamic>().firstWhere(
              (e) => e?.id == idKoridor,
              orElse: () => null,
            );

            if (selectedKoridor != null) {
              namaKoridor = selectedKoridor.name ?? '';
            }

            details = details.map((defaultDetail) {
              final matched = auditData.detail.firstWhere(
                (e) =>
                    e.idPayment == defaultDetail.idPayment &&
                    e.idNasabah == defaultDetail.idNasabah,
                orElse: () => defaultDetail,
              );

              return SettlementDetail(
                idPayment: defaultDetail.idPayment,
                idNasabah: defaultDetail.idNasabah,
                total: matched.total,
                value: matched.value,
              );
            }).toList();
          },
        );
      }

      emit(
        state.copyWith(
          status: SettlementStatus.success,
          totalSteps: paymentList.length + 2,
          detail: details,
          detailInput: inputDetails,
          labelPayment: labelPayment,
          labelCustomer: labelCustomer,
          idBus: idBus ?? state.idBus,
          idKoridor: idKoridor ?? state.idKoridor,
          noUnit: noUnit,
          namaKoridor: namaKoridor,
        ),
      );
    });

    on<PageDashboardLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final list = await settlementRepository.fetchTaskAuditTrailList('');

      list.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
        },
        (data) {
          // emit(state.copyWith(listTaskAuditTrail: data));
        },
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

    on<UploadDocument>((event, emit) async {
      final uploadDoc = await settlementRepository.uploadDocument(event.file);

      print("uploadDoc");
      print(uploadDoc);

      List<SettlementDocument> documents = [];

      uploadDoc.fold(
        (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.failedSave,
              message: failure.message,
            ),
          );
        },
        (data) {
          documents.add(
            SettlementDocument(idDocument: data, idDocumentType: data),
          );
        },
      );

      emit(state.copyWith(document: documents));
    });

    on<SubmitSettlement>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final request = SettlementCreate(
        auditTrailId: state.auditTrailId,
        idBus: state.idBus,
        code: "AMAIK NEW GEN LOS",
        idKoridor: state.idKoridor,
        idShift: state.idShift,
        detail: state.detail,
        document: state.document,
      );

      var result;

      if (state.auditTrailId.toString() != '') {
        result = await settlementRepository.updateSettlement(request);
      } else {
        result = await settlementRepository.createSettlement(request);
      }

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
          emit(state.copyWith(status: SettlementStatus.successSave));
          if (state.auditTrailId.toString() == '') {
            emit(state.copyWith(auditTrailId: int.parse(data)));
          }
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
          emit(state.copyWith(status: SettlementStatus.successSave));
        },
      );
    });
  }
}
