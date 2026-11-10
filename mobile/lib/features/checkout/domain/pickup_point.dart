class PickupPoint {
  final String id;
  final String name;
  final String provider; // 'picPac' | 'Европочта' | 'Белпочта'
  final String address;
  final String workingHours;
  final String distance;
  final double latitude;
  final double longitude;
  final double mapX; // 0.0 - 1.0 (для fallback карты)
  final double mapY; // 0.0 - 1.0 (для fallback карты)

  const PickupPoint({
    required this.id,
    required this.name,
    required this.provider,
    required this.address,
    required this.workingHours,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.mapX,
    required this.mapY,
  });

  static const List<PickupPoint> defaultPoints = [
    PickupPoint(
      id: 'pp_1',
      name: 'picPac Hub • ТЦ Galleria Minsk',
      provider: 'picPac',
      address: 'г. Минск, пр. Победителей, 9 (этаж 2)',
      workingHours: 'Пн-Вс: 10:00 - 22:00',
      distance: '0.8 км',
      latitude: 53.9085,
      longitude: 27.5486,
      mapX: 0.48,
      mapY: 0.38,
    ),
    PickupPoint(
      id: 'pp_2',
      name: 'Европочта Отделение №124',
      provider: 'Европочта',
      address: 'г. Минск, ул. Притыцкого, 29 (ст.м. Спортивная)',
      workingHours: 'Пн-Вс: 09:00 - 21:00',
      distance: '1.4 км',
      latitude: 53.9083,
      longitude: 27.4984,
      mapX: 0.28,
      mapY: 0.44,
    ),
    PickupPoint(
      id: 'pp_3',
      name: 'picPac Point • Комаровка',
      provider: 'picPac',
      address: 'г. Минск, ул. Куйбышева, 40',
      workingHours: 'Пн-Сб: 10:00 - 20:00',
      distance: '1.9 км',
      latitude: 53.9189,
      longitude: 27.5794,
      mapX: 0.62,
      mapY: 0.32,
    ),
    PickupPoint(
      id: 'pp_4',
      name: 'Белпочта ОПС №100',
      provider: 'Белпочта',
      address: 'г. Минск, пр. Независимости, 134',
      workingHours: 'Пн-Пт: 09:00 - 20:00, Сб: 10:00 - 17:00',
      distance: '3.1 км',
      latitude: 53.9382,
      longitude: 27.6534,
      mapX: 0.74,
      mapY: 0.26,
    ),
    PickupPoint(
      id: 'pp_5',
      name: 'picPac Express • ТЦ Dana Mall',
      provider: 'picPac',
      address: 'г. Минск, ул. П. Мстиславца, 11 (ст.м. Восток)',
      workingHours: 'Пн-Вс: 10:00 - 22:00',
      distance: '4.2 км',
      latitude: 53.9333,
      longitude: 27.6521,
      mapX: 0.78,
      mapY: 0.20,
    ),
    PickupPoint(
      id: 'pp_6',
      name: 'Европочта Отделение №88',
      provider: 'Европочта',
      address: 'г. Минск, пр. Дзержинского, 104 (ТЦ Титан)',
      workingHours: 'Пн-Вс: 09:00 - 21:00',
      distance: '4.8 км',
      latitude: 53.8617,
      longitude: 27.4812,
      mapX: 0.34,
      mapY: 0.72,
    ),
  ];
}
