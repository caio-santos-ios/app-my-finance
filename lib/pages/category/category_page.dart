import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/models/category.dart';
import 'package:finance/pages/category/category_details_page.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _categoryRepository = CategoryRepository();

  bool _isInitLoading = true;
  List<Category> _allCategories = [];
  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _initial();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      await _getCategories();
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _getCategories() async {
    try {
      final response = await _categoryRepository.getSelect();
      setState(() {
        _allCategories = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  List<Category> get _filteredCategories {
    if (_selectedFilter == "all") {
      return _allCategories;
    }
    return _allCategories
        .where((cat) => cat.type == _selectedFilter)
        .toList();
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryDetailsPage(),
      ),
    );

    if (result == true) {
      _initial();
    }
  }

  Future<void> _navigateToEdit(Category category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsPage(category: category),
      ),
    );

    if (result == true) {
      _initial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light80,
      appBar: AppBar(
        backgroundColor: AppColors.violet100,
        foregroundColor: AppColors.light100,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Categorias",
          style: TextStyle(
            color: AppColors.light100,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 18,
            color: AppColors.light100,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.violet100,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  _buildFilterTab("Todas", "all"),
                  const SizedBox(width: 8),
                  _buildFilterTab("Despesas", "expense"),
                  const SizedBox(width: 8),
                  _buildFilterTab("Receitas", "income"),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _initial,
                child: _isInitLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCategories.isEmpty
                        ? _buildEmptyState()
                        : _buildCategoryList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.light80,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: PrimaryButton(
              isLoading: false,
              text: "Nova Categoria",
              onPressed: _navigateToCreate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.light100 : AppColors.violet80,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.violet100 : AppColors.light100,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.violet20,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.tags,
                    color: AppColors.violet100,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Nenhuma categoria",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Você ainda não possui categorias cadastradas neste filtro. Clique abaixo para adicionar.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.dark25,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final list = _filteredCategories;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final category = list[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    final isExpense = category.type == "expense";
    final iconColor = isExpense ? AppColors.red100 : AppColors.green100;
    final bgColor = isExpense ? AppColors.red20 : AppColors.green20;
    final typeLabel = isExpense ? "Despesa" : "Receita";
    final icon = isExpense
        ? FontAwesomeIcons.arrowTrendDown
        : FontAwesomeIcons.arrowTrendUp;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToEdit(category),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: FaIcon(icon, color: iconColor, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark75,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: AppColors.dark25,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
