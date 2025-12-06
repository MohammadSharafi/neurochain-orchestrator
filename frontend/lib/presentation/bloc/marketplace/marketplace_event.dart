part of 'marketplace_bloc.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object> get props => [];
}

class LoadMarketplaceItems extends MarketplaceEvent {}

class FilterByCategory extends MarketplaceEvent {
  final String? category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class InstallItem extends MarketplaceEvent {
  final String itemId;

  const InstallItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

