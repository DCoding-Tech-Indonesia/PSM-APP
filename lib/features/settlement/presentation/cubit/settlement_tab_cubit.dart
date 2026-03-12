import 'package:flutter_bloc/flutter_bloc.dart';

class SettlementTabCubit extends Cubit<String> {
  SettlementTabCubit() : super("card");
  void changeSettlementTab(val) => emit(val);
}