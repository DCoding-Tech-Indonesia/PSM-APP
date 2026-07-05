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
  successCheckIn,
  successCheckOut
}

class TimetableState extends Equatable {
  final String? disabledBerangkatMessage;
  final String? disabledDatangMessage;

  final int? idShift;
  final int? idKm;
  final double? ritaseKe;

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

  final double long;
  final double lat;

  const TimetableState({
    this.disabledBerangkatMessage,
    this.disabledDatangMessage,

    this.idShift,
    this.idKm,
    this.ritaseKe,

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

    this.long = 0,
    this.lat = 0,
  });

  TimetableState copyWith({
    String? disabledBerangkatMessage,
    String? disabledDatangMessage,

    int? idShift,
    int? idKm,
    double? ritaseKe,

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
      disabledBerangkatMessage: disabledBerangkatMessage ?? this.disabledBerangkatMessage,
      disabledDatangMessage: disabledDatangMessage ?? this.disabledDatangMessage,
      idShift: idShift ?? this.idShift,
      idKm: idKm ?? this.idKm,
      ritaseKe: ritaseKe ?? this.ritaseKe,
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
    disabledBerangkatMessage,
    disabledDatangMessage,
    idShift,
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
