import 'package:flutter_bloc/flutter_bloc.dart';

class CoreTabCubit extends Cubit<int> {
  CoreTabCubit() : super(0);

  void changeTab(val) => emit(val);
}