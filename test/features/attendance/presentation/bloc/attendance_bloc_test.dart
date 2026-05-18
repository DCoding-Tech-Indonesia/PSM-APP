import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:psm_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:psm_mobile/core/helper/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}
class MockLocationService extends Mock implements LocationService {}
class FakeAttendanceRequest extends Fake implements AttendanceRequest {}

void main() {
  late AttendanceBloc bloc;
  late MockAttendanceRepository mockRepository;
  late MockLocationService mockLocationService;

  setUpAll(() {
    registerFallbackValue(FakeAttendanceRequest());
  });

  setUp(() {
    mockRepository = MockAttendanceRepository();
    mockLocationService = MockLocationService();
    bloc = AttendanceBloc(
      repository: mockRepository,
      locationService: mockLocationService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tUserId = '6';
  final tPosition = Position(
    longitude: 106.833,
    latitude: -6.228,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    isMocked: false,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );

  group('AttendanceBloc Tests', () {
    blocTest<AttendanceBloc, AttendanceState>(
      'should emit AttendanceLoaded with correct userId when LoadAttendanceData is added',
      build: () {
        when(() => mockLocationService.getCurrentLocation()).thenAnswer((_) async => tPosition);
        when(() => mockLocationService.calculateDistance(any(), any(), any(), any())).thenReturn(50.0);
        when(() => mockRepository.getHistory(any(), any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadAttendanceData(userId: tUserId)),
      expect: () => [
        isA<AttendanceLoaded>().having((s) => s.userId, 'userId', tUserId),
        isA<AttendanceLoaded>().having((s) => s.isLoading, 'isLoading', true),
        isA<AttendanceLoaded>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'should emit AttendanceLoaded with isCheckedIn true when CheckInRequested is successful',
      build: () {
        when(() => mockLocationService.getCurrentLocation()).thenAnswer((_) async => tPosition);
        when(() => mockLocationService.calculateDistance(any(), any(), any(), any())).thenReturn(50.0);
        when(() => mockRepository.submitAttendance(any())).thenAnswer((_) async => true);
        return bloc;
      },
      seed: () => AttendanceLoaded(
        userId: tUserId,
        currentDate: 'Today',
        currentTime: '10:00',
        isCheckedIn: false,
        checkInTime: '',
        checkOutTime: '',
        isLoading: false,
        canCheckIn: true,
        locationStatus: 'In Range',
        distanceFromOffice: '50m',
        stats: AttendanceStats(),
        history: [],
      ),
      act: (bloc) => bloc.add(CheckInRequested()),
      expect: () => [
        isA<AttendanceLoaded>().having((s) => s.isLoading, 'isLoading', true),
        isA<AttendanceLoaded>().having((s) => s.isCheckedIn, 'isCheckedIn', true),
      ],
      verify: (_) {
        verify(() => mockRepository.submitAttendance(any())).called(1);
      },
    );
  });
}
