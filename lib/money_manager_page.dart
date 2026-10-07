import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoneyManagerPage extends StatefulWidget {
  const MoneyManagerPage({
    super.key,
    required this.languageName,
    required this.currencyCode,
  });

  final String languageName;
  final String currencyCode;

  @override
  State<MoneyManagerPage> createState() => _MoneyManagerPageState();
}

class _MoneyManagerPageState extends State<MoneyManagerPage> {
  static const _storageKey = 'fim.money_manager.transactions.v1';
  List<MoneyTransaction> _transactions = [];
  bool _loading = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  MoneyCopy get _copy => MoneyCopy.forLanguage(widget.languageName);

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (!mounted) return;
    setState(() {
      _transactions = raw == null
          ? []
          : (jsonDecode(raw) as List<dynamic>)
              .map((item) => MoneyTransaction.fromJson(item as Map<String, dynamic>))
              .toList();
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(_transactions.map((item) => item.toJson()).toList()),
    );
  }

  List<MoneyTransaction> get _monthTransactions => _transactions
      .where((item) => item.date.year == _selectedMonth.year && item.date.month == _selectedMonth.month)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  int get _incomeCents => _monthTransactions
      .where((item) => item.type == MoneyType.income)
      .fold(0, (sum, item) => sum + item.amountCents);

  int get _expenseCents => _monthTransactions
      .where((item) => item.type == MoneyType.expense)
      .fold(0, (sum, item) => sum + item.amountCents);

  String _money(int cents) => '${widget.currencyCode} ${(cents / 100).toStringAsFixed(2)}';

  String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _addTransaction() async {
    final result = await showModalBottomSheet<MoneyTransaction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TransactionForm(copy: _copy, currencyCode: widget.currencyCode),
    );
    if (!mounted || result == null) return;
    setState(() => _transactions = [..._transactions, result]);
    await _persist();
  }

  Future<void> _delete(MoneyTransaction item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_copy.deleteTitle),
        content: Text(_copy.deleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_copy.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(_copy.delete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _transactions.removeWhere((entry) => entry.id == item.id));
    await _persist();
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final balance = _incomeCents - _expenseCents;
    return Scaffold(
      appBar: AppBar(
        title: Text(_copy.title),
        actions: [
          IconButton(onPressed: _addTransaction, icon: const Icon(Icons.add_rounded), tooltip: _copy.add),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add_rounded),
        label: Text(_copy.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
              children: [
                _BalanceCard(copy: _copy, balance: _money(balance), currencyCode: widget.currencyCode),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded)),
                    Expanded(child: Text('${_copy.months[_selectedMonth.month - 1]} ${_selectedMonth.year}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                    IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _SummaryTile(label: _copy.income, amount: _money(_incomeCents), color: Colors.green, icon: Icons.south_west_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: _SummaryTile(label: _copy.expenses, amount: _money(_expenseCents), color: scheme.error, icon: Icons.north_east_rounded)),
                  ],
                ),
                const SizedBox(height: 22),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_copy.recent, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), Text('${_monthTransactions.length} ${_copy.entries}', style: TextStyle(color: scheme.onSurface.withValues(alpha: .58), fontSize: 12))]),
                const SizedBox(height: 10),
                if (_monthTransactions.isEmpty)
                  _EmptyMoneyState(copy: _copy, onAdd: _addTransaction)
                else
                  for (final item in _monthTransactions) ...[
                    _TransactionTile(item: item, copy: _copy, amount: _money(item.amountCents), date: _date(item.date), onDelete: () => _delete(item)),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 10),
                Text(_copy.localOnly, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurface.withValues(alpha: .55), fontSize: 11, height: 1.4)),
              ],
            ),
    );
  }
}

class MoneyTransaction {
  const MoneyTransaction({required this.id, required this.title, required this.amountCents, required this.type, required this.category, required this.date, this.note = ''});
  final String id;
  final String title;
  final int amountCents;
  final MoneyType type;
  final String category;
  final DateTime date;
  final String note;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amountCents': amountCents, 'type': type.name, 'category': category, 'date': date.toIso8601String(), 'note': note};

  factory MoneyTransaction.fromJson(Map<String, dynamic> json) => MoneyTransaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amountCents: json['amountCents'] as int,
        type: MoneyType.values.byName(json['type'] as String),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        note: (json['note'] as String?) ?? '',
      );
}

enum MoneyType { income, expense }

class MoneyCopy {
  const MoneyCopy({required this.title, required this.add, required this.income, required this.expenses, required this.recent, required this.entries, required this.localOnly, required this.deleteTitle, required this.deleteBody, required this.cancel, required this.delete, required this.months, required this.newEntry, required this.expense, required this.incomeType, required this.amount, required this.category, required this.note, required this.save});

  final String title, add, income, expenses, recent, entries, localOnly, deleteTitle, deleteBody, cancel, delete, newEntry, expense, incomeType, amount, category, note, save;
  final List<String> months;

  static MoneyCopy forLanguage(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('বাংলা') || lower.contains('bengali') || lower.contains('bangla')) {
      return const MoneyCopy(title: 'মানি ম্যানেজার', add: 'লেনদেন যোগ করুন', income: 'আয়', expenses: 'খরচ', recent: 'সাম্প্রতিক লেনদেন', entries: 'টি', localOnly: 'আপনার অর্থের তথ্য শুধু এই device-এ থাকে।', deleteTitle: 'লেনদেন মুছে ফেলবেন?', deleteBody: 'এই কাজটি undo করা যাবে না।', cancel: 'বাতিল', delete: 'মুছুন', newEntry: 'নতুন লেনদেন', expense: 'খরচ', incomeType: 'আয়', amount: 'পরিমাণ', category: 'ক্যাটাগরি', note: 'নোট', save: 'সংরক্ষণ করুন', months: ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর']);
    }
    if (lower.contains('malay')) return _localized('Pengurus Wang', 'Tambah transaksi', 'Pendapatan', 'Perbelanjaan', 'Transaksi terkini', 'entri', 'Data wang disimpan hanya pada peranti ini.', ['Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun', 'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember']);
    if (lower.contains('hindi')) return _localized('मनी मैनेजर', 'लेन-देन जोड़ें', 'आय', 'खर्च', 'हाल के लेन-देन', 'प्रविष्टियां', 'आपका डेटा केवल इस डिवाइस पर रहता है।', ['जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर']);
    if (lower.contains('urdu')) return _localized('منی مینیجر', 'لین دین شامل کریں', 'آمدن', 'اخراجات', 'حالیہ لین دین', 'اندراجات', 'آپ کا ڈیٹا صرف اس ڈیوائس پر رہتا ہے۔', ['جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون', 'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر']);
    return _localized('Money Manager', 'Add transaction', 'Income', 'Expenses', 'Recent transactions', 'entries', 'Your money data stays only on this device.', ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
  }

  static MoneyCopy _localized(String title, String add, String income, String expenses, String recent, String entries, String localOnly, List<String> months) => MoneyCopy(title: title, add: add, income: income, expenses: expenses, recent: recent, entries: entries, localOnly: localOnly, deleteTitle: 'Delete transaction?', deleteBody: 'This action cannot be undone.', cancel: 'Cancel', delete: 'Delete', newEntry: 'New transaction', expense: 'Expense', incomeType: 'Income', amount: 'Amount', category: 'Category', note: 'Note', save: 'Save transaction', months: months);
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.copy, required this.balance, required this.currencyCode});
  final MoneyCopy copy;
  final String balance;
  final String currencyCode;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF010066), Color(0xFF124B9B)]), borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32), const SizedBox(height: 16), Text(copy.title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(balance, style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text('$currencyCode · ${copy.localOnly}', style: const TextStyle(color: Colors.white70, fontSize: 11))]),
      );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.amount, required this.color, required this.icon});
  final String label, amount;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [CircleAvatar(backgroundColor: color.withValues(alpha: .13), foregroundColor: color, child: Icon(icon, size: 19)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62), fontSize: 11)), const SizedBox(height: 3), Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))]))])));
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.copy, required this.amount, required this.date, required this.onDelete});
  final MoneyTransaction item;
  final MoneyCopy copy;
  final String amount, date;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final income = item.type == MoneyType.income;
    final color = income ? Colors.green : Theme.of(context).colorScheme.error;
    return Card(child: ListTile(leading: CircleAvatar(backgroundColor: color.withValues(alpha: .13), foregroundColor: color, child: Icon(income ? Icons.south_west_rounded : Icons.north_east_rounded, size: 19)), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${item.category} · $date'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('${income ? '+' : '-'}$amount', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)), PopupMenuButton<String>(onSelected: (_) => onDelete(), itemBuilder: (_) => [PopupMenuItem(value: 'delete', child: Text(copy.delete))])])));
  }
}

class _EmptyMoneyState extends StatelessWidget {
  const _EmptyMoneyState({required this.copy, required this.onAdd});
  final MoneyCopy copy;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(26), child: Column(children: [Icon(Icons.receipt_long_outlined, size: 46, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(copy.newEntry, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 6), Text(copy.localOnly, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62), fontSize: 12)), const SizedBox(height: 15), OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: Text(copy.add))])));
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({required this.copy, required this.currencyCode});
  final MoneyCopy copy;
  final String currencyCode;
  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  MoneyType _type = MoneyType.expense;
  String _category = 'Food';
  DateTime _date = DateTime.now();
  final _categories = const ['Food', 'Transport', 'Rent', 'Bills', 'Health', 'Salary', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', ''));
    if (title.isEmpty || amount == null || amount <= 0) return;
    Navigator.of(context).pop(MoneyTransaction(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, amountCents: (amount * 100).round(), type: _type, category: _category, date: _date, note: _noteController.text.trim()));
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20), child: ListView(shrinkWrap: true, children: [Text(widget.copy.newEntry, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 14), SegmentedButton<MoneyType>(segments: [ButtonSegment(value: MoneyType.expense, label: Text(widget.copy.expense), icon: const Icon(Icons.north_east_rounded)), ButtonSegment(value: MoneyType.income, label: Text(widget.copy.incomeType), icon: const Icon(Icons.south_west_rounded))], selected: {_type}, onSelectionChanged: (value) => setState(() => _type = value.first)), const SizedBox(height: 12), TextField(controller: _titleController, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: widget.copy.title, prefixIcon: const Icon(Icons.edit_outlined))), const SizedBox(height: 10), TextField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: '${widget.copy.amount} (${widget.currencyCode})', prefixIcon: const Icon(Icons.payments_outlined))), const SizedBox(height: 10), DropdownButtonFormField<String>(value: _category, decoration: InputDecoration(labelText: widget.copy.category, prefixIcon: const Icon(Icons.category_outlined)), items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _category = value ?? _category)), const SizedBox(height: 10), ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: Text('${_date.day}/${_date.month}/${_date.year}'), onTap: () async { final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: _date); if (picked != null) setState(() => _date = picked); }), TextField(controller: _noteController, maxLines: 2, decoration: InputDecoration(labelText: widget.copy.note, prefixIcon: const Icon(Icons.notes_outlined))), const SizedBox(height: 16), SizedBox(height: 52, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check_rounded), label: Text(widget.copy.save))) ]));
}
