import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/timetable/domain/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/timetable_data.dart';

enum TimetableStatus {
  initial,
  loading,
  success,
  error,
  successSave,
  failedSave,
  fetching,
  onSubmit,
  inValid,
}

class TimetableState extends Equatable {
  final TimetableStatus status;
  final String message;

  final List<TimetableData> listTimetable;
  final List<ReferenceDetail> referenceKoridor;
  final List<ReferenceDetail> referenceBus;

  final int idKoridor;
  final String namaKoridor;
  final int idBus;
  final String noUnit;

  final TimetableCheckin? checkinData;

  const TimetableState({
    this.status = TimetableStatus.initial,
    this.message = '',
    this.listTimetable = const [],
    this.referenceKoridor = const [],
    this.referenceBus = const [],
    this.idKoridor = 0,
    this.namaKoridor = '',
    this.idBus = 0,
    this.noUnit = '',
    this.checkinData,
  });

  TimetableState copyWith({
    TimetableStatus? status,
    String? message,
    List<TimetableData>? listTimetable,
    List<ReferenceDetail>? referenceKoridor,
    List<ReferenceDetail>? referenceBus,
    int? idKoridor,
    String? namaKoridor,
    int? idBus,
    String? noUnit,
    TimetableCheckin? checkinData,
  }) {
    return TimetableState(
      status: status ?? this.status,
      message: message ?? this.message,
      listTimetable: listTimetable ?? this.listTimetable,
      referenceKoridor: referenceKoridor ?? this.referenceKoridor,
      referenceBus: referenceBus ?? this.referenceBus,
      idKoridor: idKoridor ?? this.idKoridor,
      namaKoridor: namaKoridor ?? this.namaKoridor,
      idBus: idBus ?? this.idBus,
      noUnit: noUnit ?? this.noUnit,
      checkinData: checkinData ?? this.checkinData,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    listTimetable,
    referenceKoridor,
    referenceBus,
    idKoridor,
    namaKoridor,
    idBus,
    noUnit,
    checkinData,
  ];
}
