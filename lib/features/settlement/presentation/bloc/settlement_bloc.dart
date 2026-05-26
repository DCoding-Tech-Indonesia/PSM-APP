import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';
import 'package:psm_mobile/features/settlement/domain/repositories/settlement_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository settlementRepository;

  SettlementBloc(this.settlementRepository) : super(const SettlementState()) {
    on<PageInputLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final resultKoridor = await settlementRepository.fetchReferenceKoridor(
        '',
      );
      final resultPayment = await settlementRepository.fetchReferencePayment(
        '',
      );
      final resultCustType = await settlementRepository.fetchReferenceCustType(
        '',
      );

      List paymentList = [];
      List custList = [];

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
          emit(state.copyWith(referenceKoridor: data));
        },
      );

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
          emit(state.copyWith(referencePayment: data));
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
          emit(state.copyWith(referenceCustomer: data));
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
      List<SettlementDocument> documents = [];
      List<DocumentPreview> documentsPreview = [];
      List<String> labelCustomer = [];

      for (final payment in paymentList) {
        for (final cust in custList) {
          labelCustomer.add(cust.name);

          final resultCustBill = await settlementRepository
              .fetchReferenceCustomerBilling(cust.id);

          resultCustBill.fold(
            (failure) {
              emit(
                state.copyWith(
                  status: SettlementStatus.error,
                  message: failure.message,
                ),
              );
            },
            (data) {
              details.add(
                SettlementDetail(
                  idBus: 0,
                  ritaseKe: 0,
                  idPayment: payment.id,
                  idNasabah: cust.id,
                  idCustomerBilling: data[0].id,
                  total: 0,
                  value: 0,
                  billingValue: int.parse(data[0].value),
                ),
              );
            },
          );
        }
      }

      emit(
        state.copyWith(
          status: SettlementStatus.success,
          // totalSteps: paymentList.length + 2,
          totalSteps: 3,
          detail: details,
          labelCustomer: labelCustomer,
          document: documents,
          documentPreview: documentsPreview,
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
          emit(state.copyWith(listTaskAuditTrail: data));
        },
      );
    });

    on<MoveStepWizard>((event, emit) {
      emit(state.copyWith(steps: event.value));
    });

    on<SelectBus>((event, emit) async {
      emit(
        state.copyWith(
          idBus: event.id,
          noUnit: event.noUnit,
        ),
      );

      final nextRitase = await settlementRepository.fetchNextRitase(
        state.idKoridor,
        event.id,
      );

      nextRitase.fold(
            (failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
        },
            (ritaseValue) {
          final updatedDetails = state.detail.map((detail) {
            return detail.copyWith(
              idBus: event.id,
              ritaseKe: ritaseValue,
            );
          }).toList();

          emit(
            state.copyWith(
              ritase: ritaseValue,
              detail: updatedDetails,
            ),
          );
        },
      );
    });

    on<SelectKoridor>((event, emit) async {
      emit(
        state.copyWith(
          ritase: 0,
          idKoridor: event.id,
          namaKoridor: event.namaKoridor,
          idBus: 0,
          referenceBus: null,
        ),
      );
      final resultBus = await settlementRepository.fetchReferenceBus(
        '',
        event.id,
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
          emit(state.copyWith(referenceBus: data));
        },
      );
    });

    on<AddDetail>((event, emit) {
      final details = List<SettlementDetail>.from(state.detail);

      final index = details.indexWhere(
            (e) =>
        e.idPayment == event.detail.idPayment &&
            e.idNasabah == event.detail.idNasabah,
      );

      if (index >= 0) {
        details[index] = event.detail;
      } else {
        details.add(event.detail);
      }

      emit(state.copyWith(detail: details));
    });

    on<UpdateDetail>((event, emit) {
      final updatedDetails = state.detail.map((detail) {
        if (detail.idPayment == event.idPayment &&
            detail.idNasabah == event.idNasabah) {
          return detail.copyWith(
            idBus: state.idBus,
            ritaseKe: state.ritase,
            total: event.total,
            value: event.value,
          );
        }

        return detail;
      }).toList();

      emit(
        state.copyWith(
          detail: updatedDetails,
        ),
      );
    });

    on<AddDocument>((event, emit) {
      final newList = List<SettlementDocument>.from(state.document)
        ..add(event.document);

      emit(state.copyWith(document: newList));
    });

    on<UploadDocument>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final uploadDoc = await settlementRepository.uploadDocument(event.file);

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
          final newDocuments = List<SettlementDocument>.from(state.document)
            ..add(
              SettlementDocument(
                idDocument: data.idDocument,
                idDocumentType: data.idDocument,
              ),
            );

          final newDocumentsPreview = List<DocumentPreview>.from(
            state.documentPreview,
          )..add(DocumentPreview(idDocument: data.idDocument, url: data.url));

          emit(
            state.copyWith(
              status: SettlementStatus.success,
              document: newDocuments,
              documentPreview: newDocumentsPreview,
            ),
          );
        },
      );
    });

    on<RemoveDocumentById>((event, emit) {
      final updatedDocuments = state.document
          .where((e) => e.idDocument != event.idDocument)
          .toList();

      final updatedPreviews = state.documentPreview
          .where((e) => e.idDocument != event.idDocument)
          .toList();

      emit(
        state.copyWith(
          document: updatedDocuments,
          documentPreview: updatedPreviews,
        ),
      );
    });

    on<SubmitSettlement>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final request = SettlementCreate(
        auditTrailId: state.auditTrailId == 0 ? null : state.auditTrailId,
        idKoridor: state.idKoridor,
        idShift: 1,
        detail: state.detail,
        document: state.document,
      );

      var result;

      if (state.auditTrailId.toString() != '0') {
        if (kDebugMode) {
          print("UPDATE SETTLEMENT");
        }
        result = await settlementRepository.updateSettlement(request);
      } else {
        if (kDebugMode) {
          print("CREATE SETTLEMENT");
        }
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
