class Ingredient {
  final String id;
  final String name;
  final int daysLeft; // Sisa hari sebelum kadaluarsa
  final String category; // Sayur, Daging, Bumbu, dll.

  Ingredient({
    required this.id,
    required this.name,
    required this.daysLeft,
    required this.category,
  });
}

// Dummy data awal
List<Ingredient> dummyIngredients = [
  Ingredient(id: '1', name: 'Telur Ayam', daysLeft: 2, category: 'Protein'),
  Ingredient(id: '2', name: 'Tomat Segar', daysLeft: 1, category: 'Sayur'),
  Ingredient(id: '3', name: 'Daging Sapi', daysLeft: 5, category: 'Daging'),
  Ingredient(id: '4', name: 'Bawang Putih', daysLeft: 10, category: 'Bumbu'),
];