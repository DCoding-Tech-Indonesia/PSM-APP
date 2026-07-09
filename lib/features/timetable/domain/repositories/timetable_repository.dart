import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_data_source_response.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/response/timetable_checkin_response.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkout.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';

abstract class TimetableRepository {
  Future<Either<Failure, List<CoreScheduleModel>>> fetchTodaySchedule(
      int userId,
      );
  Future<Either<Failure, CoreDataSourceResponse>> checkAllowCheckIn(
      int idKoridor,
      int idBus,
      double nextRit,
      );
  Future<Either<Failure, CoreDataSourceResponse>> checkAllowCheckOut(
      int idKoridor,
      int idBus,
      double nextRit,
      );

  Future<Either<Failure, List<KmbusData>>> fetchKmbusDataToday(String keyword);

  Future<Either<Failure, List<TimetableData>>> fetchListTimeTable(String keyword, {int page = 1});

  Future<Either<Failure, NextRitaseResponse>> fetchNextRitase(int idKoridor, int idBus);
  Future<Either<Failure, TimetableCheckinResponse?>> checkinTimeTable(TimetableCheckin request);
  Future<Either<Failure, TimetableCheckinResponse?>> checkoutTimeTable(TimetableCheckout request);

  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(String keyword, int idKoridor);

  Future<Either<Failure, CoreDataSourceResponse>> checkAllowTitikAwal(
      int idKoridor,
      int idBus,
      double nextRit,
      );

  Future<Either<Failure, bool?>> checkAbsenceExist(double long, double lat);
}