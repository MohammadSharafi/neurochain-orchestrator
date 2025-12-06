import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/repositories/marketplace_repository.dart';
import '../../../core/error/failures.dart';

part 'marketplace_event.dart';
part 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository repository;

  MarketplaceBloc(this.repository) : super(MarketplaceInitial()) {
    on<LoadMarketplaceItems>(_onLoadMarketplaceItems);
    on<FilterByCategory>(_onFilterByCategory);
    on<InstallItem>(_onInstallItem);
  }

  void _onLoadMarketplaceItems(
    LoadMarketplaceItems event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(MarketplaceLoading());
    final currentCategory = state is MarketplaceLoaded
        ? (state as MarketplaceLoaded).selectedCategory
        : null;
    
    final result = await repository.getMarketplaceItems(currentCategory);
    result.fold(
      (failure) => emit(MarketplaceError(_mapFailureToMessage(failure))),
      (items) => emit(MarketplaceLoaded(
        items: items.map((item) => MarketplaceItem(
          id: item.id,
          name: item.name,
          description: item.description,
          category: item.category,
          version: item.version,
          author: item.author,
          installed: item.installed,
        )).toList(),
        selectedCategory: currentCategory,
      )),
    );
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<MarketplaceState> emit,
  ) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      add(LoadMarketplaceItems());
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
    final result = await repository.installMarketplaceItem(event.itemId);
    result.fold(
      (failure) => emit(MarketplaceError(_mapFailureToMessage(failure))),
      (installResult) {
        if (installResult.success) {
          add(LoadMarketplaceItems());
        } else {
          emit(MarketplaceError(installResult.error ?? installResult.message));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else {
      return 'Unexpected error: ${failure.message}';
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

