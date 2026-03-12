import 'package:flutter_bloc/flutter_bloc.dart';

class SettlementCategoryCubit extends Cubit<String> {
  SettlementCategoryCubit() : super("pelajar");
  void changeSettlementCategory(val) => emit(val);
}