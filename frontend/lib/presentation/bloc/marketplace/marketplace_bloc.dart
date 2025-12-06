import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'marketplace_event.dart';
part 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc() : super(MarketplaceInitial()) {
    on<LoadMarketplaceItems>(_onLoadMarketplaceItems);
    on<FilterByCategory>(_onFilterByCategory);
    on<InstallItem>(_onInstallItem);
  }

  void _onLoadMarketplaceItems(
    LoadMarketplaceItems event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(MarketplaceLoading());
    try {
      // TODO: Load from GraphQL
      await Future.delayed(const Duration(seconds: 1));
      emit(MarketplaceLoaded(
        items: [],
        selectedCategory: null,
      ));
    } catch (e) {
      emit(MarketplaceError(e.toString()));
    }
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<MarketplaceState> emit,
  ) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      emit(MarketplaceLoaded(
        items: currentState.items,
        selectedCategory: event.category,
      ));
    }
  }

  void _onInstallItem(
    InstallItem event,
    Emitter<MarketplaceState> emit,
  ) async {
    try {
      // TODO: Install via GraphQL mutation
      add(LoadMarketplaceItems());
    } catch (e) {
      emit(MarketplaceError(e.toString()));
    }
  }
}

class MarketplaceItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String version;
  final String author;
  final bool installed;

  MarketplaceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.version,
    required this.author,
    required this.installed,
  });
}

