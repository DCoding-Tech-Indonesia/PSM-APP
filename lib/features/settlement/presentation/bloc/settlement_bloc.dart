import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';
import 'package:psm_mobile/features/settlement/domain/repositories/settlement_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';
import 'dart:convert';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository settlementRepository;

  SettlementBloc(this.settlementRepository) : super(const SettlementState()) {
    on<PageInputLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      try {
        final resultKoridor = await settlementRepository.fetchReferenceKoridor(
          '',
        );

        final resultPayment = await settlementRepository.fetchReferencePayment(
          '',
        );

        final resultCustType = await settlementRepository
            .fetchReferenceCustType('');

        int? auditTrailId;
        int? idKoridor;
        int? idBus;
        double? ritaseKe;
        String? namaKoridor;
        String? noUnit;

        List<SettlementDetail> details = [];
        List<SettlementDetail> existingDetails = [];
        List<SettlementDocument> existingDocuments = [];

        List<SettlementDocument> documents = [];
        List<DocumentPreview> documentsPreview = [];
        List<String> labelCustomer = [];

        List<ReferenceDetail> paymentList = [];
        List<ReferenceDetail> custList = [];
        List<ReferenceDetail> busList = [];

        if (event.idAuditTrail != null) {
          final detailSettlement = await settlementRepository
              .fetchTaskAuditTrailDetail(event.idAuditTrail!);

          final isSuccess = detailSettlement.fold(
            (failure) {
              emit(
                state.copyWith(
                  status: SettlementStatus.error,
                  message: failure.message,
                ),
              );
              return false;
            },
            (data) {
              auditTrailId = event.idAuditTrail;
              idKoridor = data.idKoridor;
              idBus = data.detail.first.idBus;
              ritaseKe = data.detail.first.ritaseKe;

              existingDetails = data.detail;
              existingDocuments = data.document;

              debugPrint(
                const JsonEncoder.withIndent('  ').convert(data.toJson()),
              );

              return true;
            },
          );

          if (!isSuccess) return;

          final resultBus = await settlementRepository.fetchReferenceBus(
            '',
            idKoridor!,
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
              busList = data;
            },
          );

          if (emit.isDone) return;
        }

        final koridorList = resultKoridor.fold((failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (koridorList == null) return;

        paymentList = resultPayment.fold((failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
          return [];
        }, (data) => data);

        if (paymentList.isEmpty) return;

        custList = resultCustType.fold((failure) {
          emit(
            state.copyWith(
              status: SettlementStatus.error,
              message: failure.message,
            ),
          );
          return [];
        }, (data) => data);

        if (custList.isEmpty) return;

        if (idKoridor != null) {
          final koridor = koridorList.where((e) => e.id == idKoridor);

          if (koridor.isNotEmpty) {
            namaKoridor = koridor.first.name;
          }
        }

        if (idBus != null) {
          final bus = busList.where((e) => e.id == idBus);

          if (bus.isNotEmpty) {
            noUnit = bus.first.name;
          }
        }

        for (final payment in paymentList) {
          for (final cust in custList) {
            if (!labelCustomer.contains(cust.name)) {
              labelCustomer.add(cust.name);
            }

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
              (billingData) {
                if (billingData.isEmpty) return;

                final existing = existingDetails.where(
                  (e) => e.idPayment == payment.id && e.idNasabah == cust.id,
                );

                final oldData = existing.isNotEmpty ? existing.first : null;

                details.add(
                  SettlementDetail(
                    idBus: oldData?.idBus ?? idBus ?? 0,
                    ritaseKe: oldData?.ritaseKe ?? ritaseKe ?? 0,

                    idPayment: payment.id,
                    idNasabah: cust.id,

                    idCustomerBilling: billingData.first.id,

                    billingValue: int.tryParse(billingData.first.value) ?? 0,

                    total: oldData?.total,
                    value: oldData?.value,
                  ),
                );
              },
            );

            if (emit.isDone) return;
          }
        }

        documents = List<SettlementDocument>.from(existingDocuments);

        documentsPreview = existingDocuments
            .where((e) => (e.urlDoc ?? '').isNotEmpty)
            .map(
              (e) => DocumentPreview(idDocument: e.idDocument, url: e.urlDoc!),
            )
            .toList();

        final activeTabId = paymentList[0].id;

        final activeTabLabel = paymentList[0].name;

        emit(
          state.copyWith(
            activeTabIndex: 0,
            activeTabId: activeTabId,
            activeTabLabel: activeTabLabel,
            auditTrailId: auditTrailId,
            status: SettlementStatus.success,
            idKoridor: idKoridor,
            idBus: idBus,
            ritase: ritaseKe,
            namaKoridor: namaKoridor,
            noUnit: noUnit,
            referenceKoridor: koridorList,
            referenceBus: busList,
            referencePayment: paymentList,
            referenceCustomer: custList,
            totalSteps: 3,
            detail: details,
            labelCustomer: labelCustomer,
            document: documents,
            documentPreview: documentsPreview,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(
          state.copyWith(status: SettlementStatus.error, message: e.toString()),
        );
      }
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

      emit(state.copyWith(status: SettlementStatus.success));
    });

    on<MoveStepWizard>((event, emit) {
      emit(state.copyWith(steps: event.value));
    });

    on<ChangeTabDetail>((event, emit) {
      final newTabIndex = event.tabId;

      if (newTabIndex > state.activeTabIndex) {
        bool hasInvalidData;
        bool isLastPeymentMethod = newTabIndex == state.referencePayment.length;

        if (isLastPeymentMethod) {
          hasInvalidData = state.detail.any(
            (data) => data.total == null || data.value == null,
          );
        } else {
          emit(state.copyWith(detailValid: true));
          final currPayment = state.referencePayment[state.activeTabIndex];

          hasInvalidData = state.detail.any(
            (data) =>
                data.idPayment == currPayment.id &&
                (data.total == null || data.value == null),
          );
        }

        if (hasInvalidData) {
          emit(state.copyWith(detailValid: false));
          return;
        } else if (!hasInvalidData && isLastPeymentMethod) {
          emit(state.copyWith(allowLastStep: true));
        }
      }

      if (newTabIndex < state.referencePayment.length) {
        final nextPayment = state.referencePayment[newTabIndex];

        emit(
          state.copyWith(
            activeTabIndex: newTabIndex,
            activeTabId: nextPayment.id,
            activeTabLabel: nextPayment.name,
          ),
        );
      }
    });

    on<SelectBus>((event, emit) async {
      emit(state.copyWith(idBus: event.id, noUnit: event.noUnit));

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
            return detail.copyWith(idBus: event.id, ritaseKe: ritaseValue);
          }).toList();

          emit(state.copyWith(ritase: ritaseValue, detail: updatedDetails));
        },
      );
    });

    on<SelectKoridor>((event, emit) async {
      emit(
        state.copyWith(
          status: SettlementStatus.fetching,
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
          emit(
            state.copyWith(
              status: SettlementStatus.success,
              referenceBus: data,
            ),
          );
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

      emit(state.copyWith(detail: updatedDetails));
    });

    on<AddDocument>((event, emit) {
      final newList = List<SettlementDocument>.from(state.document)
        ..add(event.document);

      emit(state.copyWith(document: newList));
    });

    on<UploadDocument>((event, emit) async {
      emit(state.copyWith(uploadingDoc: true));

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

      emit(state.copyWith(uploadingDoc: false));
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

      final prettyDoc = const JsonEncoder.withIndent(
        '  ',
      ).convert(state.document);
      debugPrint("prettyDoc");
      debugPrint(prettyDoc);

      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(request.toJson());
      debugPrint(prettyJson);

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
          final newAuditTrailId = state.auditTrailId == 0
              ? int.parse(data)
              : state.auditTrailId;

          emit(
            state.copyWith(
              status: SettlementStatus.successSave,
              auditTrailId: newAuditTrailId,
            ),
          );
        },
      );
    });

    on<SubmitWorkflow>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final result = await settlementRepository.submitWorkflow(
        event.idAuditTrail,
        event.reason != '' ? event.reason : 'Done',
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

    on<CancelTaskDraft>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final result = await settlementRepository.cancelTaskDraft(event.idAuditTrail);

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

    on<PageHistoryLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      try {
        final detailResult = await settlementRepository
            .fetchTaskAuditTrailDetail(event.idAuditTrail!);

        final detailData = detailResult.fold(
              (failure) {
            throw Exception(failure.message);
          },
              (data) => data,
        );

        final idKoridor = detailData.idKoridor;
        final idBus = detailData.detail.first.idBus;
        final ritase = detailData.detail.first.ritaseKe;

        final results = await Future.wait([
          settlementRepository.fetchReferenceKoridor(''),
          settlementRepository.fetchReferencePayment(''),
          settlementRepository.fetchReferenceCustType(''),
          settlementRepository.fetchReferenceBus('', idKoridor),
        ]);

        final koridorList = results[0].fold(
              (f) => throw Exception(f.message),
              (d) => d,
        );

        final busList = results[3].fold(
              (f) => throw Exception(f.message),
              (d) => d,
        );

        final namaKoridor = koridorList
            .firstWhere((e) => e.id == idKoridor)
            .name;

        final noUnit = busList
            .firstWhere((e) => e.id == idBus)
            .name;

        final documents =
        List<SettlementDocument>.from(detailData.document);

        final documentPreview = detailData.document
            .where((e) => (e.urlDoc ?? '').isNotEmpty)
            .map(
              (e) => DocumentPreview(
            idDocument: e.idDocument,
            url: e.urlDoc!,
          ),
        )
            .toList();

        final paymentList = results[1].fold(
              (f) => throw Exception(f.message),
              (d) => d,
        );

        final customerList = results[2].fold(
              (f) => throw Exception(f.message),
              (d) => d,
        );

        emit(
          state.copyWith(
            status: SettlementStatus.success,
            auditTrailId: event.idAuditTrail,
            idKoridor: idKoridor,
            idBus: idBus,
            ritase: ritase,
            namaKoridor: namaKoridor,
            noUnit: noUnit,

            referenceKoridor: koridorList,
            referenceBus: busList,
            referencePayment: paymentList,
            referenceCustomer: customerList,

            detail: detailData.detail,

            document: documents,
            documentPreview: documentPreview,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: SettlementStatus.error,
            message: e.toString(),
          ),
        );
      }
    });

  }
}
