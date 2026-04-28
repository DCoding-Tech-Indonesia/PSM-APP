import 'package:equatable/equatable.dart';

abstract class PortalEvent extends Equatable {
  const PortalEvent();

  @override
  List<Object> get props => [];
}

class FetchProfile extends PortalEvent {}

class PageLoad extends PortalEvent {}

class Logout extends PortalEvent {}


