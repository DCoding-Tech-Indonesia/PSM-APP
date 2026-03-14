import 'package:flutter_bloc/flutter_bloc.dart';

class SettlementStepCubit extends Cubit<int> {
  SettlementStepCubit() : super(0);
  void changeSettlementStep(val) => emit(val);
}