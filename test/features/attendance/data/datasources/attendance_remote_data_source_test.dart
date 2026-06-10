import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late AttendanceRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.instance).thenReturn(mockDio);
    dataSource = AttendanceRemoteDataSourceImpl(mockDioClient);
  });

  final tRequest = AttendanceRequest(
    idUser: 6,
    lokasiLat: -6.228,
    lokasiLong: 106.833,
    idBus: 1,
    // idShift: 1,
  );

  test('should return true when the response status is true', () async {
    // arrange
    when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        data: {'status': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    // act
    final result = await dataSource.postAttendance(tRequest);

    // assert
    expect(result, true);
    verify(() => mockDio.post('/absensi', data: any(named: 'data')));
  });

  test('should return false when the response status is false', () async {
    // arrange
    when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        data: {'status': false},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    // act
    final result = await dataSource.postAttendance(tRequest);

    // assert
    expect(result, false);
  });
}
