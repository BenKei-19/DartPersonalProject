import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/voice_transaction_viewmodel.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../data/models/reminder.dart';
import '../../viewmodels/reminder_viewmodel.dart';

class VoiceTransactionScreen extends StatefulWidget {
  const VoiceTransactionScreen({super.key});

  @override
  State<VoiceTransactionScreen> createState() => _VoiceTransactionScreenState();
}

class _VoiceTransactionScreenState extends State<VoiceTransactionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Check locales on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceTransactionViewModel>().checkLocales();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceTransactionViewModel>(
      builder: (context, voiceVM, child) {
        // Listen for parsing errors and show SnackBar
        if (voiceVM.parseErrorMessage.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(voiceVM.parseErrorMessage),
                backgroundColor: Colors.orange[800],
                behavior: SnackBarBehavior.floating,
              ),
            );
            voiceVM.clearParseError();
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Voice AI Demo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.keyboard_outlined),
                tooltip: 'Nhập văn bản test',
                onPressed: () => _showTestInputDialog(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!voiceVM.isLocaleSupported && voiceVM.state == VoiceState.idle)
                  _buildLocaleWarning(voiceVM),

                // Status text
                Text(
                  _getStatusText(voiceVM.state),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getHintText(voiceVM.state),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Main content area
                Expanded(child: _buildContent(voiceVM)),

                // Bottom action
                _buildBottomAction(voiceVM),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(VoiceTransactionViewModel voiceVM) {
    switch (voiceVM.state) {
      case VoiceState.idle:
        return _buildIdleState();
      case VoiceState.listening:
        return _buildListeningState(voiceVM);
      case VoiceState.processing:
        return _buildProcessingState();
      case VoiceState.preview:
        return _buildPreviewState(voiceVM);
      case VoiceState.error:
        return _buildErrorState(voiceVM);
    }
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppConstants.primaryRed, AppConstants.primaryRed.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryRed.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                context.read<VoiceTransactionViewModel>().startListening();
                _pulseController.repeat(reverse: true);
              },
              icon: const Icon(Icons.mic, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nhấn micro để bắt đầu nói',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningState(VoiceTransactionViewModel voiceVM) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.primaryRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryRed.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      _pulseController.stop();
                      final categories = context.read<CategoryViewModel>().categories;
                      context.read<VoiceTransactionViewModel>().stopAndProcess(categories: categories);
                    },
                    icon: const Icon(Icons.stop, size: 50, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang lắng nghe...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
          ),
          const SizedBox(height: 16),
          if (voiceVM.recognizedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                voiceVM.recognizedText,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppConstants.primaryRed,
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'AI đang phân tích...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewState(VoiceTransactionViewModel voiceVM) {
    final data = voiceVM.parsedData!;
    final isReceived = data['type'] == 'received';
    final amount = (data['amount'] as num).toDouble();
    final person = data['personName'] as String;
    final dateStr = data['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10);
    final note = data['note'] as String?;
    final category = data['category'] as String?;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Recognized text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '"${voiceVM.recognizedText}"',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Preview card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isReceived ? AppConstants.receivedGreen : AppConstants.givenOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isReceived ? 'Nhận lì xì' : 'Cho lì xì',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  Text(
                    Formatters.formatCurrency(amount),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isReceived ? AppConstants.receivedGreen : AppConstants.givenOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details
                  _previewRow(Icons.person, 'Người', person),
                  if (category != null && category.isNotEmpty)
                    _previewRow(Icons.group, 'Nhóm', category),
                  _previewRow(Icons.calendar_today, 'Ngày', Formatters.formatDateString(dateStr)),
                  if (note != null && note.isNotEmpty)
                    _previewRow(Icons.note, 'Ghi chú', note),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VoiceTransactionViewModel voiceVM) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            voiceVM.errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(VoiceTransactionViewModel voiceVM) {
    switch (voiceVM.state) {
      case VoiceState.idle:
        return const SizedBox.shrink();
      case VoiceState.listening:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              _pulseController.stop();
              final categories = context.read<CategoryViewModel>().categories;
              voiceVM.stopAndProcess(categories: categories);
            },
            icon: const Icon(Icons.stop),
            label: const Text('Dừng & Phân tích'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      case VoiceState.processing:
        return const SizedBox.shrink();
      case VoiceState.preview:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => voiceVM.reset(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thử lại'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _confirmTransaction(voiceVM),
                icon: const Icon(Icons.check),
                label: const Text('Xác nhận lưu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );
      case VoiceState.error:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => voiceVM.reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
    }
  }

  Future<void> _confirmTransaction(VoiceTransactionViewModel voiceVM) async {
    final userId = context.read<AuthViewModel>().currentUser!.id!;
    final categories = context.read<CategoryViewModel>().categories;
    final transaction = voiceVM.buildTransaction(userId, categories: categories);
    if (transaction == null) return;

    final txnVM = context.read<TransactionViewModel>();
    await txnVM.addTransaction(transaction);

    // Check if it's a future date for reminder suggestion
    final transactionDate = DateTime.parse(transaction.date);
    final bool isFutureDate = transactionDate.isAfter(DateTime.now());
    
    if (isFutureDate && mounted) {
      final bool? addReminder = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ngày trong tương lai'),
          content: const Text('Bạn có muốn thêm giao dịch này vào danh sách nhắc nhở không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Thêm nhắc nhở'),
            ),
          ],
        ),
      );

      if (addReminder == true && mounted) {
        try {
          final reminderVM = context.read<ReminderViewModel>();
          
          // Create the actual Reminder object
          final newReminder = Reminder(
            userId: userId,
            personName: transaction.personName,
            amount: transaction.amount,
            remindDate: transaction.date,
            note: 'Tự động thêm từ Voice AI: ${transaction.note ?? ""}',
            isDone: false,
          );
          
          await reminderVM.addReminder(newReminder);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm giao dịch và nhắc nhở!')),
            );
          }
        } catch (e) {
          print('Error adding reminder: $e');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu giao dịch!')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu giao dịch bằng giọng nói!')),
      );
    }

    voiceVM.reset();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildLocaleWarning(VoiceTransactionViewModel voiceVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cảnh báo: Máy tính chưa bật tiếng Việt (vi_VN)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Để dùng giọng nói trên Windows, bạn cần:\n1. Vào Settings > Language > Cài đặt Tiếng Việt (có Speech).\n2. Bật "Online speech recognition" trong Privacy Settings.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Ngôn ngữ tìm thấy: ${voiceVM.availableLocales.take(5).join(', ')}...',
            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  void _showTestInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập câu lệnh test'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: Cho lì xì bà ngoại 200k',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                _simulateVoiceInput(text);
              }
            },
            child: const Text('Phân tích'),
          ),
        ],
      ),
    );
  }

  void _simulateVoiceInput(String text) {
    final voiceVM = context.read<VoiceTransactionViewModel>();
    voiceVM.setRecognizedTextForTest(text);
    final categories = context.read<CategoryViewModel>().categories;
    voiceVM.stopAndProcess(categories: categories);
  }

  String _getStatusText(VoiceState state) {
    switch (state) {
      case VoiceState.idle:
        return 'Thêm giao dịch bằng giọng nói';
      case VoiceState.listening:
        return 'Đang lắng nghe...';
      case VoiceState.processing:
        return 'Đang phân tích...';
      case VoiceState.preview:
        return 'Xem trước giao dịch';
      case VoiceState.error:
        return 'Có lỗi xảy ra';
    }
  }

  String _getHintText(VoiceState state) {
    switch (state) {
      case VoiceState.idle:
        return 'Ví dụ: "Cho lì xì bà ngoại 500 nghìn ngày mùng 1 Tết"';
      case VoiceState.listening:
        return 'Hãy nói rõ: ai, bao nhiêu tiền, ngày nào';
      case VoiceState.processing:
        return 'AI đang trích xuất thông tin giao dịch';
      case VoiceState.preview:
        return 'Kiểm tra và xác nhận giao dịch';
      case VoiceState.error:
        return 'Nhấn "Thử lại" để thử lần nữa';
    }
  }
}
