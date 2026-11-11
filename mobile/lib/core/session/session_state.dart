import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

class CartItem {
  final String id;
  final String title;
  final String format;
  final int spreadsCount;
  final String templateId;
  final String? coverImageUrl;
  final double price;
  final double? oldPrice;
  final int quantity;
  final bool isSelected;

  const CartItem({
    required this.id,
    required this.title,
    this.format = '20×20 см',
    this.spreadsCount = 10,
    this.templateId = 'school_drive',
    this.coverImageUrl,
    this.price = 72.90,
    this.oldPrice = 95.00,
    this.quantity = 1,
    this.isSelected = true,
  });

  CartItem copyWith({
    String? id,
    String? title,
    String? format,
    int? spreadsCount,
    String? templateId,
    String? coverImageUrl,
    double? price,
    double? oldPrice,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      format: format ?? this.format,
      spreadsCount: spreadsCount ?? this.spreadsCount,
      templateId: templateId ?? this.templateId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SessionState {
  final UserProfile? user;
  final AlbumData? currentAlbum;
  final List<CartItem> cartItems;

  const SessionState({
    this.user,
    this.currentAlbum,
    this.cartItems = const [],
  });

  SessionState copyWith({
    UserProfile? user,
    AlbumData? currentAlbum,
    List<CartItem>? cartItems,
  }) {
    return SessionState(
      user: user ?? this.user,
      currentAlbum: currentAlbum ?? this.currentAlbum,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    return const SessionState(
      cartItems: [
        CartItem(
          id: 'default_cart_album',
          title: 'Выпускной 11-Б • 2026',
          format: '20×20 см',
          spreadsCount: 10,
          templateId: 'school_drive',
          price: 72.90,
          oldPrice: 95.00,
          quantity: 1,
          isSelected: true,
        ),
      ],
    );
  }

  void setUser(UserProfile user) {
    state = state.copyWith(user: user);
  }

  void setAlbum(AlbumData album) {
    state = state.copyWith(currentAlbum: album);
  }

  void addOrUpdateCartItem(CartItem item) {
    final existingIndex = state.cartItems.indexWhere((e) => e.id == item.id);
    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state.cartItems);
      updatedList[existingIndex] = item;
      state = state.copyWith(cartItems: updatedList);
    } else {
      state = state.copyWith(cartItems: [...state.cartItems, item]);
    }
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeCartItem(id);
      return;
    }
    final updatedList = state.cartItems.map((e) {
      if (e.id == id) {
        return e.copyWith(quantity: quantity);
      }
      return e;
    }).toList();
    state = state.copyWith(cartItems: updatedList);
  }

  void toggleItemSelection(String id) {
    final updatedList = state.cartItems.map((e) {
      if (e.id == id) {
        return e.copyWith(isSelected: !e.isSelected);
      }
      return e;
    }).toList();
    state = state.copyWith(cartItems: updatedList);
  }

  void toggleSelectAll(bool selectAll) {
    final updatedList = state.cartItems.map((e) {
      return e.copyWith(isSelected: selectAll);
    }).toList();
    state = state.copyWith(cartItems: updatedList);
  }

  void removeCartItem(String id) {
    state = state.copyWith(
      cartItems: state.cartItems.where((e) => e.id != id).toList(),
    );
  }

  void reset() {
    state = const SessionState();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});

