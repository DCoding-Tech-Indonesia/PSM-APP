import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
import 'package:psm_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';

class MockRemoteDataSource extends Mock implements AttendanceRemoteDataSource {}

class FakeAttendanceRequest extends Fake implements AttendanceRequest {}

void main() {
  late AttendanceRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeAttendanceRequest());
  });

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    repository = AttendanceRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tRequest = AttendanceRequest(
    idUser: 6,
    lokasiLat: -6.228,
    lokasiLong: 106.833,
    // idShift: 1,
  );

  test('should call remote data source and return its result', () async {
    // arrange
    when(
      () => mockRemoteDataSource.postAttendance(any()),
    ).thenAnswer((_) async => true);

    // act
    final result = await repository.submitAttendance(tRequest);

    // assert
    expect(result, true);
    verify(() => mockRemoteDataSource.postAttendance(tRequest));
  });
}
