import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkout.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';

abstract class TimetableRepository {
  Future<Either<Failure, List<CoreScheduleModel>>> fetchTodaySchedule(
      int userId,
      );
  Future<Either<Failure, String>> checkAllowCheckIn(
      int idKoridor,
      int idBus,
      double nextRit,
      );
  Future<Either<Failure, String>> checkAllowCheckOut(
      int idKoridor,
      int idBus,
      double nextRit,
      );

  Future<Either<Failure, List<KmbusData>>> fetchKmbusDataToday(String keyword);

  Future<Either<Failure, List<TimetableData>>> fetchListTimeTable(String keyword);

  Future<Either<Failure, NextRitaseResponse>> fetchNextRitase(int idKoridor, int idBus);
  Future<Either<Failure, String?>> checkinTimeTable(TimetableCheckin request);
  Future<Either<Failure, String?>> checkoutTimeTable(TimetableCheckout request);

  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(String keyword, int idKoridor);

}