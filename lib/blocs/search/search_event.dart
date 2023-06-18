part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class OnActivateManualMarkerEvent extends SearchEvent {}

class OnDeactivateManualMarkerEvent extends SearchEvent {}

class OnNewUbicacionFoundEvent extends SearchEvent {
  final List<Ubicacion> ubicacion;
  const OnNewUbicacionFoundEvent(this.ubicacion);
}

class AddToHistoryEvent extends SearchEvent {
  final Ubicacion history;
  const AddToHistoryEvent(this.history);
}

class OnSelectUbicacionEvent extends SearchEvent {
  final Ubicacion selectedUbicacion;
  const OnSelectUbicacionEvent(this.selectedUbicacion);
}

class AddUbicacionByUserEvent extends SearchEvent {
  final String id;
  const AddUbicacionByUserEvent(this.id);
}
