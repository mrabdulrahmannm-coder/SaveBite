import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

// Layar form untuk menambahkan resep masakan baru ke dalam aplikasi.
class AddRecipeScreen extends StatefulWidget {
  final List<Ingredient> availableIngredients;

  const AddRecipeScreen({
    super.key,
    required this.availableIngredients,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _ingredientsTextController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedDifficulty = 'Mudah';
  final Set<String> _selectedRequiredIngredientIds = {};

  static const List<String> _difficulties = ['Mudah', 'Sedang', 'Sulit'];

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _ingredientsTextController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRequiredIngredientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih setidaknya 1 bahan utama yang dibutuhkan!'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Memecah teks bumbu/langkah berdasarkan baris baru
    final ingredientsList = _ingredientsTextController.text
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final instructionsList = _instructionsController.text
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final newRecipe = Recipe(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      cookingTime: int.parse(_timeController.text.trim()),
      difficulty: _selectedDifficulty,
      imageUrl:
          'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=500',
      requiredIngredientIds: _selectedRequiredIngredientIds.toList(),
      ingredientsText: ingredientsList.isNotEmpty
          ? ingredientsList
          : ['Bahan-bahan sesuai selera'],
      instructions: instructionsList.isNotEmpty
          ? instructionsList
          : ['Campurkan semua bahan dan masak hingga matang.'],
    );

    Navigator.pop(context, newRecipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Resep Baru',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Judul Resep
                const Text(
                  'Nama Resep Masakan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Nasi Goreng Spesial',
                    hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.restaurant_menu_rounded,
                        color: Color(0xFF2563EB), size: 22),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama resep tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Waktu & Tingkat Kesulitan
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Waktu Masak (Menit)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _timeController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              hintText: '15',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.timer_outlined,
                                  color: Color(0xFF2563EB), size: 20),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2563EB), width: 1.5),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Isi waktu';
                              }
                              if (int.tryParse(val) == null) {
                                return 'Harus angka';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kesulitan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2563EB), width: 1.5),
                              ),
                            ),
                            items: _difficulties.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d,
                                    style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedDifficulty = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pilih Bahan Kulkas yang Dibutuhkan untuk Resep Ini
                const Text(
                  'Bahan Kulkas yang Dibutuhkan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Centang bahan dari stok kulkas yang digunakan resep ini:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: widget.availableIngredients.map((ing) {
                      final isSelected =
                          _selectedRequiredIngredientIds.contains(ing.id);
                      return CheckboxListTile(
                        title: Text(
                          ing.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          ing.category,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        value: isSelected,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedRequiredIngredientIds.add(ing.id);
                            } else {
                              _selectedRequiredIngredientIds.remove(ing.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Rincian Bahan Teks
                const Text(
                  'Rincian Bahan & Takaran (Satu per baris)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ingredientsTextController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Contoh:\n2 butir Telur Ayam\n1 sdm Kecap Manis',
                    hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Langkah Memasak Teks
                const Text(
                  'Langkah Memasak (Satu per baris)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText:
                        'Contoh:\nKocok telur dalam mangkuk.\nGoreng telur hingga keemasan.',
                    hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Simpan Resep
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan Resep',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}