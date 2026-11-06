class Recipe {
  final String id;
  final String title;
  final int cookingTime; // Durasi memasak dalam satuan menit
  final String difficulty; // 'Mudah', 'Sedang', 'Sulit'
  final String imageUrl;
  final List<String> requiredIngredientIds; // Daftar ID bahan dari ingredient.dart
  final List<String> ingredientsText; // Rincian bahan lengkap dengan takaran
  final List<String> instructions; // Langkah-langkah memasak berurutan

  Recipe({
    required this.id,
    required this.title,
    required this.cookingTime,
    required this.difficulty,
    required this.imageUrl,
    required this.requiredIngredientIds,
    required this.ingredientsText,
    required this.instructions,
  });

  /// Menghitung persentase bahan yang dimiliki di kulkas untuk resep ini.
  double getMatchPercentage(List<String> availableIngredientIds) {
    if (requiredIngredientIds.isEmpty) return 0.0;

    int matchCount = 0;
    for (final id in requiredIngredientIds) {
      if (availableIngredientIds.contains(id)) {
        matchCount++;
      }
    }

    return (matchCount / requiredIngredientIds.length) * 100;
  }
}

// Dummy Data Resep yang terhubung dengan ID di dummyIngredients ('1'=Telur, '2'=Tomat, '3'=Daging, '4'=Bawang)
final List<Recipe> dummyRecipes = [
  Recipe(
    id: 'r1',
    title: 'Telur Dadar Tomat',
    cookingTime: 15,
    difficulty: 'Mudah',
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500',
    requiredIngredientIds: ['1', '2', '4'], // Butuh: Telur Ayam, Tomat Segar, Bawang Putih
    ingredientsText: [
      '2 butir Telur Ayam',
      '1 buah Tomat Segar (cincang halus)',
      '2 siung Bawang Putih (cincang)',
      '1/2 sdt Garam & Merica',
      '1 sdm Minyak Goreng',
    ],
    instructions: [
      'Kocok telur ayam dalam wadah hingga berbuih halus.',
      'Masukkan potong tomat segar dan bawang putih cincang.',
      'Tambahkan garam serta merica, aduk hingga bumbu tercampur rata.',
      'Panaskan minyak goreng di wajan datar dengan api sedang.',
      'Tuangkan adonan telur dan masak hingga kedua sisi matang keemasan.',
    ],
  ),
  Recipe(
    id: 'r2',
    title: 'Tumis Daging Sapi Bawang',
    cookingTime: 30,
    difficulty: 'Sedang',
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
    requiredIngredientIds: ['3', '4'], // Butuh: Daging Sapi, Bawang Putih
    ingredientsText: [
      '250 gram Daging Sapi (iris tipis)',
      '4 siung Bawang Putih (geprek kasar)',
      '2 sdm Kecap Manis',
      '1 sdm Saus Tiram',
      '2 sdm Minyak Goreng',
    ],
    instructions: [
      'Marinasi irisan daging sapi dengan kecap manis dan saus tiram selama 10 menit.',
      'Panaskan minyak goreng pada wajan tumis.',
      'Masukkan bawang putih geprek, tumis hingga harum dan agak kecokelatan.',
      'Masukkan daging sapi marinasi, masak dengan api besar hingga berubah warna.',
      'Kecilkan api dan masak hingga daging empuk serta bumbu meresap sempurna.',
    ],
  ),
  Recipe(
    id: 'r3',
    title: 'Telur Ceplok Kecap Gurih',
    cookingTime: 10,
    difficulty: 'Mudah',
    imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500',
    requiredIngredientIds: ['1', '4'], // Butuh: Telur Ayam, Bawang Putih
    ingredientsText: [
      '2 butir Telur Ayam',
      '2 siung Bawang Putih (iris tipis)',
      '1.5 sdm Kecap Manis',
      '50 ml Air Matang',
    ],
    instructions: [
      'Goreng telur secara terpisah menjadi telur ceplok (mata sapi), sisihkan.',
      'Tumis irisan bawang putih hingga mengeluarkan aroma harum.',
      'Tuangkan air matang dan kecap manis, aduk hingga mendidih.',
      'Masukkan telur ceplok ke dalam kuah kecap, siram-siramkan kuah lalu angkat.',
    ],
  ),
];