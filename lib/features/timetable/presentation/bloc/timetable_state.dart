import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';

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
  final int? idKm;

  final bool isLastRitase;
  final bool jadwalExist;
  final int? idCheckin;

  final TimetableStatus status;
  final String message;

  final bool isAllowCheckIn;
  final bool isAllowCheckOut;

  final List<TimetableData> listTimetable;
  final List<ReferenceDetail> referenceKoridor;
  final List<ReferenceDetail> referenceBus;

  final int idKoridor;
  final String namaKoridor;
  final int idBus;
  final String noUnit;

  final TimetableCheckin? checkinData;

  const TimetableState({
    this.idKm,

    this.isLastRitase = false,
    this.jadwalExist = true,
    this.idCheckin,

    this.status = TimetableStatus.initial,
    this.message = '',
    this.isAllowCheckIn = false,
    this.isAllowCheckOut = false,
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
    int? idKm,

    bool? isLastRitase,
    bool? jadwalExist,
    int? idCheckin,

    TimetableStatus? status,
    String? message,
    bool? isAllowCheckIn,
    bool? isAllowCheckOut,
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
      idKm: idKm ?? this.idKm,
      isLastRitase: isLastRitase ?? this.isLastRitase,
      jadwalExist: jadwalExist ?? this.jadwalExist,
      idCheckin: idCheckin ?? this.idCheckin,
      status: status ?? this.status,
      message: message ?? this.message,
      isAllowCheckIn: isAllowCheckIn ?? this.isAllowCheckIn,
      isAllowCheckOut: isAllowCheckOut ?? this.isAllowCheckOut,
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
    idKm,
    isLastRitase,
    jadwalExist,
    idCheckin,
    status,
    message,
    isAllowCheckIn,
    isAllowCheckOut,
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
