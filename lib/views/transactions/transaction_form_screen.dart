import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../../data/models/reminder.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/reminder_viewmodel.dart';
import '../../widgets/suggestion_chip.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'received';
  int? _categoryId;
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  double? _suggestedAmount;
  bool _isEditing = false;
  LixiTransaction? _existingTransaction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategories(
        context.read<AuthViewModel>().currentUser!.id!,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is LixiTransaction && !_isEditing) {
      _isEditing = true;
      _existingTransaction = args;
      _type = args.type;
      _amountController.text = NumberFormat.decimalPattern('vi_VN').format(args.amount);
      _personController.text = args.personName;
      _noteController.text = args.note ?? '';
      _categoryId = args.categoryId;
      _selectedDate = DateTime.tryParse(args.date) ?? DateTime.now();
      _imagePath = args.imagePath;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _personController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              const Text('Loại giao dịch', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _typeButton('Nhận lì xì', 'received', Icons.arrow_downward, AppConstants.receivedGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeButton('Cho lì xì', 'given', Icons.arrow_upward, AppConstants.givenOrange),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                  final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (double.tryParse(clean) == null || double.parse(clean) <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),

              // Suggestion chip
              if (_suggestedAmount != null && _suggestedAmount! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SuggestionChip(
                    amount: _suggestedAmount!,
                    onTap: () => _amountController.text = _suggestedAmount!.toStringAsFixed(0),
                  ),
                ),
              const SizedBox(height: 16),

              // Person name
              TextFormField(
                controller: _personController,
                decoration: InputDecoration(
                  labelText: 'Tên người',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên người' : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: InputDecoration(
                  labelText: 'Nhóm người thân',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Chưa phân loại')),
                  ...catVM.categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )),
                ],
                onChanged: (v) {
                  setState(() => _categoryId = v);
                  _loadSuggestion();
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Image
              const Text('Ảnh phong bao (tùy chọn)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_imagePath != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_imagePath!), width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                            onPressed: () => setState(() => _imagePath = null),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chọn ảnh'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEditing ? 'Cập nhật' : 'Lưu giao dịch',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String label, String type, IconData icon, Color color) {
    final isSelected = _type == type;
    return OutlinedButton.icon(
      onPressed: () => setState(() => _type = type),
      icon: Icon(icon, color: isSelected ? Colors.white : color),
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : color)),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color : null,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showReminderSuggestion(DateTime date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💡 Gợi ý nhắc nhở'),
        content: Text('Bạn vừa chọn ngày lì xì trong tương lai (${DateFormat('dd/MM/yyyy').format(date)}). Bạn có muốn thêm vào danh sách nhắc nhở không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Không')),
          ElevatedButton(
            onPressed: () async {
              final authVM = context.read<AuthViewModel>();
              final reminderVM = context.read<ReminderViewModel>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final userId = authVM.currentUser!.id!;
              final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final reminder = Reminder(
                userId: userId,
                personName: _personController.text.trim().isEmpty ? 'Người nhận' : _personController.text.trim(),
                amount: double.tryParse(amountStr),
                remindDate: date.toIso8601String().substring(0, 10),
                note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
              );

              await reminderVM.addReminder(reminder);

              if (mounted) {
                Navigator.pop(ctx); // Close dialog
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Đã thêm vào nhắc nhở!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryRed, foregroundColor: Colors.white),
            child: const Text('Thêm ngay'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final xFile = await picker.pickImage(source: source, maxWidth: 800);
    if (xFile != null) setState(() => _imagePath = xFile.path);
  }

  void _loadSuggestion() async {
    if (_categoryId == null) return;
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    final amount = await context.read<TransactionViewModel>().getSuggestedAmount(userId, _categoryId!);
    setState(() {
      _suggestedAmount = amount;
      // Also update controller if empty
      if (_amountController.text.isEmpty && amount > 0) {
        _amountController.text = NumberFormat.decimalPattern('vi_VN').format(amount);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthViewModel>().currentUser!.id!;
    final txnVM = context.read<TransactionViewModel>();

    final tetYear = _selectedDate.month <= 2 ? _selectedDate.year : _selectedDate.year;
    final cleanAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final transaction = LixiTransaction(
      id: _existingTransaction?.id,
      userId: userId,
      type: _type,
      amount: double.parse(cleanAmount),
      personName: _personController.text.trim(),
      categoryId: _categoryId,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      imagePath: _imagePath,
      date: _selectedDate.toIso8601String().substring(0, 10),
      year: tetYear,
      createdAt: _existingTransaction?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (_isEditing) {
      await txnVM.updateTransaction(transaction);
      if (mounted) Navigator.of(context).pop();
    } else {
      await txnVM.addTransaction(transaction);

      // Suggest reminder if future date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (_selectedDate.isAfter(today)) {
        if (mounted) _showReminderSuggestion(_selectedDate);
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }
}
