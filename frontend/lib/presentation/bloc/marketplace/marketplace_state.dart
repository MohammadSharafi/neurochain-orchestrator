part of 'marketplace_bloc.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class MarketplaceLoaded extends MarketplaceState {
  final List<MarketplaceItem> items;
  final String? selectedCategory;

  const MarketplaceLoaded({
    required this.items,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [items, selectedCategory];
}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError(this.message);

  @override
  List<Object> get props => [message];
}

