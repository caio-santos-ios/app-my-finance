import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:finance/core/services/util_service.dart';
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/operation.dart';
import 'package:finance/pages/operation/operation_details_page.dart';
import 'package:finance/repositories/category_repository.dart';
import 'package:finance/repositories/operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class OperationPage extends StatefulWidget {
  const OperationPage({super.key});

  @override
  State<OperationPage> createState() => _OperationPageState();
}

class _OperationPageState extends State<OperationPage> {
  final _operationRepository = OperationRepository();
  final _categoryRepository = CategoryRepository();

  bool _isInitLoading = true;
  List<Operation> _allOperations = [];
  List<Category> _categories = [];

  late DateTime _selectedDate;
  final List<String> _months = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro",
  ];

  String _selectedType = "all";
  String _selectedSort = "newest";
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initial();
  }

  Future<void> _initial() async {
    try {
      setState(() => _isInitLoading = true);
      await Future.wait([
        _getOperations(),
        _getCategories(),
      ]);
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  Future<void> _getOperations() async {
    try {
      final response = await _operationRepository.get();
      setState(() {
        _allOperations = response;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  Future<void> _getCategories() async {
    try {
      final response = await _categoryRepository.getSelect();
      setState(() {
        _categories = response;
      });
    } catch (_) {}
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  bool get _hasActiveFilters =>
      _selectedType != "all" || _selectedSort != "newest" || _selectedCategoryId != null;

  void _resetFilters() {
    setState(() {
      _selectedType = "all";
      _selectedSort = "newest";
      _selectedCategoryId = null;
    });
  }

  List<Operation> get _filteredOperations {
    List<Operation> list = _allOperations.where((op) {
      final matchMonth = op.createdAt.year == _selectedDate.year &&
          op.createdAt.month == _selectedDate.month;
      if (!matchMonth) return false;

      if (_selectedType != "all" && op.type != _selectedType) return false;

      if (_selectedCategoryId != null &&
          _selectedCategoryId!.isNotEmpty &&
          op.categoryId != _selectedCategoryId) {
        return false;
      }

      return true;
    }).toList();

    switch (_selectedSort) {
      case "oldest":
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case "highest":
        list.sort((a, b) => b.value.compareTo(a.value));
        break;
      case "lowest":
        list.sort((a, b) => a.value.compareTo(b.value));
        break;
      case "newest":
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }

  Map<String, List<Operation>> get _groupedOperations {
    final Map<String, List<Operation>> groups = {};
    final now = DateTime.now();

    for (final op in _filteredOperations) {
      final date = op.createdAt;
      String groupKey;

      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        groupKey = "Hoje";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        groupKey = "Ontem";
      } else {
        groupKey = DateFormat("dd 'de' MMMM", "pt_BR").format(date);
      }

      groups.putIfAbsent(groupKey, () => []).add(op);
    }

    return groups;
  }

  double get _totalIncome => _filteredOperations
      .where((o) => o.type == "income")
      .fold(0.0, (sum, o) => sum + o.value);

  double get _totalExpense => _filteredOperations
      .where((o) => o.type == "expense")
      .fold(0.0, (sum, o) => sum + o.value);

  String _normalizeValueCardOperation(double value, String type) {
    if (type == "income") return "+ ${UtilBrasilFields.obterReal(value)}";
    if (type == "expense") return "- ${UtilBrasilFields.obterReal(value)}";
    return UtilBrasilFields.obterReal(value);
  }

  void _showFilterModal() {
    String tempType = _selectedType;
    String tempSort = _selectedSort;
    String? tempCatId = _selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.light100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.light20,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtrar Transação",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark75,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempType = "all";
                            tempSort = "newest";
                            tempCatId = null;
                          });
                        },
                        child: const Text(
                          "Resetar",
                          style: TextStyle(
                            color: AppColors.violet100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Filtrar por",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark75,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip("Todos", "all", tempType, (val) {
                        setModalState(() => tempType = val);
                      }),
                      _buildChip("Receitas", "income", tempType, (val) {
                        setModalState(() => tempType = val);
                      }),
                      _buildChip("Despesas", "expense", tempType, (val) {
                        setModalState(() => tempType = val);
                      }),
                      _buildChip("Transferências", "transfer", tempType, (val) {
                        setModalState(() => tempType = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ordenar por",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark75,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip("Mais recente", "newest", tempSort, (val) {
                        setModalState(() => tempSort = val);
                      }),
                      _buildChip("Mais antigo", "oldest", tempSort, (val) {
                        setModalState(() => tempSort = val);
                      }),
                      _buildChip("Maior valor", "highest", tempSort, (val) {
                        setModalState(() => tempSort = val);
                      }),
                      _buildChip("Menor valor", "lowest", tempSort, (val) {
                        setModalState(() => tempSort = val);
                      }),
                    ],
                  ),
                  // if (_categories.isNotEmpty) ...[
                  //   const SizedBox(height: 20),
                  //   const Text(
                  //     "Categoria",
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w600,
                  //       color: AppColors.dark75,
                  //     ),
                  //   ),
                  //   const SizedBox(height: 10),
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 16),
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: AppColors.light20),
                  //       borderRadius: BorderRadius.circular(16),
                  //     ),
                  //     child: DropdownButtonHideUnderline(
                  //       child: DropdownButton<String?>(
                  //         isExpanded: true,
                  //         value: tempCatId,
                  //         hint: const Text("Todas as categorias"),
                  //         items: [
                  //           const DropdownMenuItem<String?>(
                  //             value: null,
                  //             child: Text("Todas as categorias"),
                  //           ),
                  //           ..._categories.map(
                  //             (c) => DropdownMenuItem<String?>(
                  //               value: c.id,
                  //               child: Text(c.name),
                  //             ),
                  //           ),
                  //         ],
                  //         onChanged: (val) {
                  //           setModalState(() => tempCatId = val);
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ],
                  const SizedBox(height: 28),
                  PrimaryButton(
                    isLoading: false,
                    text: "Aplicar",
                    onPressed: () {
                      setState(() {
                        _selectedType = tempType;
                        _selectedSort = tempSort;
                        _selectedCategoryId = tempCatId;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip(
    String label,
    String value,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isSelected = value == currentValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.violet100 : AppColors.dark50,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: AppColors.light40,
      selectedColor: AppColors.violet20,
      side: BorderSide(
        color: isSelected ? AppColors.violet100 : AppColors.light20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      onSelected: (_) => onSelected(value),
    );
  }

  void _showFinancialReportModal() {
    final balance = _totalIncome - _totalExpense;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.light100,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.light20,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Relatório de ${_months[_selectedDate.month - 1]}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark75,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.dark50),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.light40,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReportItem(
                      "Receitas",
                      _totalIncome,
                      AppColors.green100,
                      Icons.arrow_downward,
                    ),
                    Container(width: 1, height: 40, color: AppColors.light20),
                    _buildReportItem(
                      "Despesas",
                      _totalExpense,
                      AppColors.red100,
                      Icons.arrow_upward,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: balance >= 0 ? AppColors.green20 : AppColors.red20,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Saldo do Período",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: balance >= 0 ? AppColors.green100 : AppColors.red100,
                      ),
                    ),
                    Text(
                      UtilBrasilFields.obterReal(balance),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? AppColors.green100 : AppColors.red100,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportItem(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.dark25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          UtilBrasilFields.obterReal(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light80,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _getOperations,
          child: _isInitLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFinancialReportBanner(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _filteredOperations.isEmpty
                          ? _buildEmptyState()
                          : _buildGroupedList(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final monthName = _months[_selectedDate.month - 1];
    final year = _selectedDate.year;

    return AppBar(
      backgroundColor: AppColors.light80,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronLeft,
              color: AppColors.dark75,
              size: 14,
            ),
            onPressed: _previousMonth,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.light100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.light20),
            ),
            child: Text(
              "$monthName $year",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.dark75,
              ),
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppColors.dark75,
              size: 14,
            ),
            onPressed: _nextMonth,
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _hasActiveFilters ? AppColors.violet20 : AppColors.light100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasActiveFilters ? AppColors.violet100 : AppColors.light20,
                  ),
                ),
                child: FaIcon(
                  FontAwesomeIcons.sliders,
                  color: _hasActiveFilters ? AppColors.violet100 : AppColors.dark75,
                  size: 16,
                ),
              ),
              onPressed: _showFilterModal,
            ),
            if (_hasActiveFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.violet100,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFinancialReportBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.violet20,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _showFinancialReportModal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Veja seu relatório financeiro",
              style: TextStyle(
                color: AppColors.violet100,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppColors.violet100,
              size: 16,
            ),
          ],
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
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.violet20,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.receipt,
                    color: AppColors.violet100,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Nenhuma transação",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Não encontramos movimentações para este mês ou filtro selecionado.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.dark25,
                ),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text("Limpar filtros"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedList() {
    final groups = _groupedOperations;
    final keys = groups.keys.toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: keys.length,
      itemBuilder: (context, groupIndex) {
        final groupKey = keys[groupIndex];
        final operations = groups[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                groupKey,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark75,
                ),
              ),
            ),
            ...operations.map((op) => _buildCardOperation(op)),
          ],
        );
      },
    );
  }

  Widget _buildCardOperation(Operation operation) {
    final isTransfer = operation.type == "transfer";
    final isIncome = operation.type == "income";

    Color iconBgColor = AppColors.red20;
    Color iconColor = AppColors.red100;
    FaIconData icon = FontAwesomeIcons.bagShopping;

    if (isTransfer) {
      iconBgColor = AppColors.blue20;
      iconColor = AppColors.blue100;
      icon = FontAwesomeIcons.arrowRightArrowLeft;
    } else if (isIncome) {
      iconBgColor = AppColors.green20;
      iconColor = AppColors.green100;
      icon = FontAwesomeIcons.dollarSign;
    }

    final categoryTitle = isTransfer
        ? "Transferência"
        : (operation.categoryName.isNotEmpty ? operation.categoryName : "Sem categoria");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OperationDetailsPage(
                  type: operation.type,
                  operation: operation,
                ),
              ),
            );
            if (result == true) {
              _getOperations();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: FaIcon(
                            icon,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark75,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              operation.description.isNotEmpty
                                  ? operation.description
                                  : "Sem descrição",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.dark25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _normalizeValueCardOperation(
                        operation.value,
                        operation.type,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isIncome
                            ? AppColors.green100
                            : isTransfer
                                ? AppColors.blue100
                                : AppColors.red100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("HH:mm").format(operation.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.dark25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
