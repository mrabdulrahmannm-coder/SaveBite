import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'add_ingredient_screen.dart';
import 'add_recipe_screen.dart';
import 'detail_recipe_screen.dart';

// Layar Utama / Dashboard SaveBite
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Local state untuk bahan dan resep
  late List<Ingredient> _ingredients;
  late List<Recipe> _recipes;

  // Set ID bahan yang dipilih pengguna untuk pencocokan resep (Ingredient Matcher)
  final Set<String> _selectedIngredientIds = {};

  String _searchQuery = '';
  int _activeTab = 0; // 0: Bahan Kulkas, 1: Rekomendasi Resep

  @override
  void initState() {
    super.initState();
    _ingredients = List<Ingredient>.from(dummyIngredients);
    _recipes = List<Recipe>.from(dummyRecipes);
  }

  // Menghitung jumlah bahan kritis (<= 2 hari kadaluarsa)
  int get _criticalItemsCount {
    return _ingredients.where((item) => item.daysLeft <= 2).length;
  }

  // Filter daftar bahan berdasarkan pencarian
  List<Ingredient> get _filteredIngredients {
    if (_searchQuery.trim().isEmpty) return _ingredients;
    return _ingredients.where((item) {
      return item.name.toLowerCase().contains(_searchQuery.trim().toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.trim().toLowerCase());
    }).toList();
  }

  // Buka Form Tambah Bahan & Tangkap Hasil Return
  Future<void> _navigateToAddIngredient() async {
    final newIngredient = await Navigator.push<Ingredient>(
      context,
      MaterialPageRoute(builder: (context) => const AddIngredientScreen()),
    );

    if (newIngredient != null) {
      setState(() {
        _ingredients.add(newIngredient);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bahan "${newIngredient.name}" berhasil ditambahkan!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Buka Form Tambah Resep Baru & Tangkap Hasil Return
  Future<void> _navigateToAddRecipe() async {
    final newRecipe = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(
          availableIngredients: _ingredients,
        ),
      ),
    );

    if (newRecipe != null) {
      setState(() {
        _recipes.add(newRecipe);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resep "${newRecipe.title}" berhasil ditambahkan!'),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Hapus Bahan dari Kulkas
  void _deleteIngredient(String id, String name) {
    setState(() {
      _ingredients.removeWhere((item) => item.id == id);
      _selectedIngredientIds.remove(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bahan "$name" berhasil dihapus'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Buka Halaman Detail Resep
  Future<void> _navigateToDetailRecipe(Recipe recipe) async {
    final updatedIngredientIds = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRecipeScreen(
          recipe: recipe,
          availableIngredients: _ingredients,
        ),
      ),
    );

    // Jika resep dimasak ("Selesai Memasak"), kurangi stok bahan yang terpakai
    if (updatedIngredientIds != null) {
      setState(() {
        _ingredients.removeWhere((item) => updatedIngredientIds.contains(item.id));
        _selectedIngredientIds.removeWhere((id) => updatedIngredientIds.contains(id));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat! Stok bahan telah diperbarui setelah memasak 🎉'),
          backgroundColor: Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                color: const Color(0xFF2563EB),
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildTabSwitcher(),
                    const SizedBox(height: 18),
                    _activeTab == 0
                        ? _buildIngredientsSection()
                        : _buildRecipeMatcherSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.kitchen_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SaveBite',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                'Kelola Kulkas & Bebas Waste',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF64748B), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Stok Bahan',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${_ingredients.length} Item',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white24,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hampir Kadaluarsa',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$_criticalItemsCount Item',
                    style: TextStyle(
                      color: _criticalItemsCount > 0
                          ? const Color(0xFFFECACA)
                          : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_criticalItemsCount > 0) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFECACA), size: 20),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(color: Color(0xFF1E293B)),
        decoration: const InputDecoration(
          hintText: 'Cari bahan kulkas atau resep...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _activeTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Bahan Kulkas (${_filteredIngredients.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          _activeTab == 0 ? FontWeight.bold : FontWeight.w600,
                      color: _activeTab == 0
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _activeTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 14, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 4),
                      Text(
                        'Resep Matcher',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              _activeTab == 1 ? FontWeight.bold : FontWeight.w600,
                          color: _activeTab == 1
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan Tab 1: Daftar Bahan Kulkas
  Widget _buildIngredientsSection() {
    final list = _filteredIngredients;

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.no_food_outlined, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'Tidak ada bahan makanan di kulkas',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: list.map(_buildIngredientCard).toList(),
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    final isSelectedForMatch = _selectedIngredientIds.contains(ingredient.id);

    Color badgeColor;
    String badgeText;

    if (ingredient.daysLeft <= 2) {
      badgeColor = const Color(0xFFEF4444); // Kritis (Merah)
      badgeText = ingredient.daysLeft <= 0
          ? 'Kadaluarsa!'
          : '${ingredient.daysLeft} Hari Lagi';
    } else if (ingredient.daysLeft <= 5) {
      badgeColor = const Color(0xFFF59E0B); // Peringatan (Kuning/Orange)
      badgeText = '${ingredient.daysLeft} Hari Lagi';
    } else {
      badgeColor = const Color(0xFF10B981); // Aman (Hijau)
      badgeText = '${ingredient.daysLeft} Hari Lagi';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelectedForMatch
              ? const Color(0xFF2563EB)
              : const Color(0xFFE2E8F0),
          width: isSelectedForMatch ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Checkbox(
          value: isSelectedForMatch,
          activeColor: const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedIngredientIds.add(ingredient.id);
              } else {
                _selectedIngredientIds.remove(ingredient.id);
              }
            });
          },
        ),
        title: Text(
          ingredient.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ingredient.category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFF94A3B8), size: 20),
          onPressed: () => _deleteIngredient(ingredient.id, ingredient.name),
        ),
      ),
    );
  }

  // Tampilan Tab 2: Matcher Resep Otomatis
  Widget _buildRecipeMatcherSection() {
    final activeIngredientIds = _selectedIngredientIds.isNotEmpty
        ? _selectedIngredientIds.toList()
        : _ingredients.map((e) => e.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rekomendasi Resep',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton.icon(
              onPressed: _navigateToAddRecipe,
              icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF7C3AED)),
              label: const Text(
                'Tambah Resep',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedIngredientIds.isNotEmpty
                      ? 'Mencocokkan resep berdasarkan ${_selectedIngredientIds.length} bahan yang kamu centang.'
                      : 'Menampilkan resep teratas dari seluruh stok kulkas kamu.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _recipes.map((recipe) {
            return _buildRecipeCard(recipe, activeIngredientIds);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe, List<String> availableIds) {
    final matchPercentage = recipe.getMatchPercentage(availableIds);

    Color matchColor = const Color(0xFF10B981);
    if (matchPercentage < 50) {
      matchColor = const Color(0xFFEF4444);
    } else if (matchPercentage < 100) {
      matchColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToDetailRecipe(recipe),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    recipe.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.restaurant_menu_rounded,
                            color: Color(0xFF94A3B8)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.cookingTime} mnt',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.bar_chart_rounded,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            recipe.difficulty,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: matchColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Cocok ${matchPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: matchColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FloatingActionButton adaptif sesuai tab yang aktif
  Widget _buildFab() {
    if (_activeTab == 1) {
      return FloatingActionButton.extended(
        onPressed: _navigateToAddRecipe,
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Resep',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return FloatingActionButton.extended(
      onPressed: _navigateToAddIngredient,
      backgroundColor: const Color(0xFF2563EB),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Tambah Bahan',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}