import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';

abstract class TimetableRepository {
  Future<Either<Failure, List<TimetableData>>> fetchListTimeTable(String keyword);

  Future<Either<Failure, double>> fetchNextRitase(int idKoridor, int idBus);
  Future<Either<Failure, String?>> checkinTimeTable(TimetableCheckin request);

  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(String keyword, int idKoridor);

}