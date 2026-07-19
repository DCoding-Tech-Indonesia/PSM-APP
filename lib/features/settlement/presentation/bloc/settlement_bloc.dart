import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/features/reference/domain/entities/document_preview.dart';
import 'package:travis/features/reference/domain/entities/reference_detail.dart';
import 'package:travis/features/settlement/domain/entities/settlement_create.dart';
import 'package:travis/features/settlement/domain/entities/settlement_detail.dart';
import 'package:travis/features/settlement/domain/entities/settlement_document.dart';
import 'package:travis/features/settlement/domain/repositories/settlement_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository settlementRepository;
  final SecureStorageService secureStorageService;

  SettlementBloc(this.settlementRepository, this.secureStorageService)
    : super(const SettlementState()) {
    on<PageInputLoad>((event, emit) async {
      emit(
        state.copyWith(
          status: SettlementStatus.loading,
          idShift: event.idShift,
          idKoridor: event.idKoridor,
          ritase: event.ritaseKe,
          auditTrailId: event.idAuditTrail,
          idBus: event.idBus,
          idKoridorShift: event.idKoridor,
          idBusShift: event.idBus,
        ),
      );

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
        double? ritaseKe = event.ritaseKe;
        bool? isLastRitase;
        bool? isNextRitase;
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
        } else {
          auditTrailId = null;
          idKoridor = event.idKoridor;
          idBus = event.idBus;

          if (idKoridor != null) {
            final resultBus = await settlementRepository.fetchReferenceBus(
              '',
              idKoridor,
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
        }

        // Fetch the latest ritase ke value from endpoint for new forms
        if (event.idAuditTrail == null && idKoridor != null && idBus != null) {
          final nextRitaseResult = await settlementRepository.fetchNextRitase(
            idKoridor!,
            idBus!,
          );

          nextRitaseResult.fold(
            (failure) {
              debugPrint("Failed to fetch next ritase: ${failure.message}");
            },
            (value) {
              ritaseKe = value.ritaseKe;
              isLastRitase = value.isLastRitase;
              isNextRitase = value.isNextRitase;
              debugPrint("Fetched latest ritaseKe from endpoint: $ritaseKe");
            },
          );
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

                    total: oldData?.total ?? 0,
                    value: oldData?.value ?? 0,
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

        final resultRefDocType = await settlementRepository
            .fetchReferenceDocType('');

        resultRefDocType.fold(
          (failure) {
            emit(
              state.copyWith(
                status: SettlementStatus.error,
                message: failure.message,
              ),
            );
          },
          (docTypes) {
            final docTypeId = docTypes
                .firstWhere((e) => e.code == 'BUKTISET')
                .id;

            emit(state.copyWith(idDocType: docTypeId));

            print(docTypeId);
          },
        );

        emit(
          state.copyWith(
            idShift: event.idShift,
            activeTabIndex: 0,
            activeTabId: activeTabId,
            activeTabLabel: activeTabLabel,
            auditTrailId: auditTrailId,
            ritase: ritaseKe,
            isLastRitase: isLastRitase,
            isNextRitase: isNextRitase,
            status: SettlementStatus.success,
            uploadingDoc: false,
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
      emit(
        state.copyWith(
          status: SettlementStatus.loading,
          page: 1,
          hasReachedMax: false,
        ),
      );

      final list = await settlementRepository.fetchTaskAuditTrailList(
        '',
        page: 1,
      );

      final userIdString = await secureStorageService.readUserId();
      final userId = int.tryParse(userIdString ?? '') ?? 0;

      final todaySchedule = await settlementRepository.fetchTodaySchedule(
        userId,
      );

      final todayScheduleData = todaySchedule.fold((failure) {
        emit(
          state.copyWith(
            status: SettlementStatus.error,
            message: failure.message,
            jadwalExist: false,
          ),
        );
        return null;
      }, (data) => data);

      if (todayScheduleData == null || todayScheduleData.isEmpty) {
        list.fold(
          (failure) {
            emit(
              state.copyWith(
                status: SettlementStatus.error,
                message: failure.message,
                jadwalExist: false,
              ),
            );
          },
          (data) {
            emit(
              state.copyWith(
                status: SettlementStatus.success,
                listTaskAuditTrail: data,
                jadwalExist: false,
                hasReachedMax: data.length < 10,
              ),
            );
          },
        );
        return;
      }

      final idKoridorShift = todayScheduleData[0].lokasi.koridor;
      final idShiftActive = todayScheduleData[0].shift.id;
      final idBusShift = todayScheduleData[0].bus.id;

      final nextRitaseResult = await settlementRepository.fetchNextRitase(
        idKoridorShift,
        idBusShift!,
      );

      final double ritaseValue = nextRitaseResult.fold(
        (_) => 0.0,
        (value) => value.ritaseKe!,
      );

      final bool isLastRitase = nextRitaseResult.fold(
        (_) => false,
        (value) => value.isLastRitase!,
      );

      final checkAllowInput = settlementRepository.checkAllowSettlement(
        idKoridorShift,
        idBusShift,
        ritaseValue,
      );

      final checkAllowInputResult = await checkAllowInput;

      final bool allowInputAccess = checkAllowInputResult.fold(
        (_) => false,
        (res) => res.isAllowed,
      );

      final String settlementMessage = checkAllowInputResult.fold(
        (_) => '',
        (res) => res.message,
      );

      list.fold(
        (failure) {
          emit(
            state.copyWith(
              isLastRitase: isLastRitase,
              ritase: ritaseValue,
              idShift: idShiftActive,
              idKoridorShift: idKoridorShift,
              idBusShift: idBusShift,
              status: SettlementStatus.error,
              message: failure.message,
              allowInput: !allowInputAccess,
              ctaValidationMessage: !allowInputAccess
                  ? null
                  : settlementMessage,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              isLastRitase: isLastRitase,
              ritase: ritaseValue,
              idShift: idShiftActive,
              idKoridorShift: idKoridorShift,
              idBusShift: idBusShift,
              listTaskAuditTrail: data,
              status: SettlementStatus.success,
              allowInput: !allowInputAccess,
              ctaValidationMessage: !allowInputAccess
                  ? null
                  : settlementMessage,
              hasReachedMax: data.length < 10,
            ),
          );
        },
      );
    });

    on<PageDashboardLoadNextPage>((event, emit) async {
      if (state.hasReachedMax || state.status == SettlementStatus.fetching) {
        return;
      }

      emit(state.copyWith(status: SettlementStatus.fetching));

      final nextPage = state.page + 1;
      final result = await settlementRepository.fetchTaskAuditTrailList(
        '',
        page: nextPage,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(status: SettlementStatus.success));
        },
        (data) {
          if (data.isEmpty) {
            emit(
              state.copyWith(
                hasReachedMax: true,
                status: SettlementStatus.success,
              ),
            );
          } else {
            emit(
              state.copyWith(
                listTaskAuditTrail: List.of(state.listTaskAuditTrail)
                  ..addAll(data),
                page: nextPage,
                hasReachedMax: data.length < 10,
                status: SettlementStatus.success,
              ),
            );
          }
        },
      );
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
            return detail.copyWith(
              idBus: event.id,
              ritaseKe: ritaseValue.ritaseKe,
            );
          }).toList();

          emit(
            state.copyWith(
              ritase: ritaseValue.ritaseKe,
              detail: updatedDetails,
            ),
          );
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
                idDocumentType: state.idDocType,
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

      debugPrint("========== SUBMIT SETTLEMENT ==========");
      debugPrint("state.ritase: ${state.ritase}");
      debugPrint("state.idShift: ${state.idShift}");
      debugPrint("state.idKoridor: ${state.idKoridor}");
      debugPrint("state.isLastRitase: ${state.isLastRitase}");

      final request = SettlementCreate(
        auditTrailId: state.auditTrailId == 0 ? null : state.auditTrailId,
        idKoridor: state.idKoridor,
        idShift: state.idShift!,
        ritaseKe: state.ritase,
        isSubmit: state.isLastRitase,
        detail: state.detail,
        document: state.document,
      );

      debugPrint("request.ritaseKe: ${request.ritaseKe}");
      debugPrint("request.detail count: ${request.detail.length}");

      for (int i = 0; i < request.detail.length; i++) {
        final detail = request.detail[i];
        debugPrint(
          "  Detail[$i] - ritaseKe: ${detail.ritaseKe}, idPayment: ${detail.idPayment}, idNasabah: ${detail.idNasabah}",
        );
      }

      debugPrint("=====================================");

      if (state.auditTrailId.toString() != '0') {
        final result = await settlementRepository.updateSettlement(request);

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
              status: data.status
                  ? SettlementStatus.successSubmitWorkflow
                  : SettlementStatus.failedSave,
              message: data.message,
            ),
          );
          },
        );
      } else {
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
      }
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
          emit(
            state.copyWith(
              status: data.status
                  ? SettlementStatus.successSave
                  : SettlementStatus.failedSave,
              message: data.message,
            ),
          );
        },
      );
    });

    on<CancelTaskDraft>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      final result = await settlementRepository.cancelTaskDraft(
        event.idAuditTrail,
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
              status: data.status
                  ? SettlementStatus.successSave
                  : SettlementStatus.failedSave,
              message: data.message,
            ),
          );
        },
      );
    });

    on<PageHistoryLoad>((event, emit) async {
      emit(state.copyWith(status: SettlementStatus.loading));

      try {
        final detailResult = await settlementRepository
            .fetchTaskAuditTrailDetail(event.idAuditTrail!);

        final detailData = detailResult.fold((failure) {
          throw Exception(failure.message);
        }, (data) => data);

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

        final noUnit = busList.firstWhere((e) => e.id == idBus).name;

        final documents = List<SettlementDocument>.from(detailData.document);

        final documentPreview = detailData.document
            .where((e) => (e.urlDoc ?? '').isNotEmpty)
            .map(
              (e) => DocumentPreview(idDocument: e.idDocument, url: e.urlDoc!),
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
          state.copyWith(status: SettlementStatus.error, message: e.toString()),
        );
      }
    });
  }
}
