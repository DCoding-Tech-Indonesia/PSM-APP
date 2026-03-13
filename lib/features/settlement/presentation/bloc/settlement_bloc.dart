import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc() : super(const SettlementState()) {

    on<DebitKreditPictChanged>((event, emit) {
      emit(state.copyWith(debitKreditPict: event.value));
    });

    on<BrizziPictChanged>((event, emit) {
      emit(state.copyWith(brizziPict: event.value));
    });

    on<QrisPictChanged>((event, emit) {
      emit(state.copyWith(qrisPict: event.value));
    });

    on<PaymentCountChanged>((event, emit) {

      final newData = Map<String, Map<String, int>>.from(state.paymentData);

      newData[event.method] = Map<String, int>.from(newData[event.method]!)
        ..[event.category] = event.value;

      emit(state.copyWith(paymentData: newData));
    });
  }
}