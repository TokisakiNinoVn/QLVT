import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:txng/services/ticket_service.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTrain;
  Map<String, dynamic>? _selectedTrainData;
  String? _selectedTicketType;
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController(text: '0');
  final _emailController = TextEditingController();
  final _trainDisplayController = TextEditingController();
  final ticketService = TicketService();

  late List<Map<String, dynamic>> _listTicket = [];
  final List<String> _ticketTypes = const ['Hạng vé thường', 'Hạng ví VIP'];
  final List<int> _presetAges = [18, 25, 30, 45, 60];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _trainDisplayController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getListTicket();
  }

  Future<void> _getListTicket() async {
    final response = await ticketService.getListOfTicket();
    setState(() {
      _listTicket = (response['data'] as List).cast<Map<String, dynamic>>();
    });
  }

  void _createTicket() {
    if (_formKey.currentState!.validate()) {
      final ticketData = {
        "train": _selectedTrain!,
        "ticket": _selectedTrainData!,
        "ticketType": _selectedTicketType!,
        "fullName": _fullNameController.text,
        "phone": _phoneController.text.replaceAll(' ', ''),
        "age": _ageController.text,
        "email": _emailController.text,
      };
      context.push('/create-ticket/ticket-confirmation', extra: ticketData);
    }
  }

  void _showBottomSheet(
    BuildContext context,
    List items,
    String title,
    Function(String, [Map<String, dynamic>?]) onSelect, {
    bool isTrain = false,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    if (isTrain) {
                      final departureTime = DateTime.parse(
                        item['departure_time'],
                      );
                      final arrivalTime = DateTime.parse(item['arrival_time']);
                      final price = NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VNĐ',
                        decimalDigits: 0,
                      ).format(int.parse(item['price']));
                      final timeFormat = DateFormat('HH:mm');

                      return InkWell(
                        onTap: () {
                          onSelect(item['id'].toString(), item);
                          setState(() {
                            _trainDisplayController.text = item['route_name'];
                          });
                          Navigator.pop(context);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.train,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item['route_name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '⏰ ${timeFormat.format(departureTime)} → ${timeFormat.format(arrivalTime)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      price,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(item.toString()),
                      onTap: () {
                        onSelect(item.toString());
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _setAge(int age) {
    setState(() {
      _ageController.text = age.toString();
    });
  }

  void _appendGmailSuffix() {
    setState(() {
      String currentText = _emailController.text;
      if (!currentText.endsWith('@gmail.com')) {
        // Remove any existing domain if present
        currentText = currentText.split('@')[0];
        _emailController.text = '$currentText@gmail.com';
        _emailController.selection = TextSelection.fromPosition(
          TextPosition(offset: currentText.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tạo vé tàu'),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin đặt vé',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _trainDisplayController,
                  label: 'Loại vé tàu *',
                  icon: Icons.train,
                  readOnly: true,
                  onTap:
                      () => _showBottomSheet(
                        context,
                        _listTicket,
                        'Chọn loại vé tàu',
                        (value, [trainData]) => setState(() {
                          _selectedTrain = value;
                          _selectedTrainData = trainData;
                        }),
                        isTrain: true,
                      ),
                  validator:
                      (value) =>
                          _selectedTrain == null
                              ? 'Vui lòng chọn loại vé tàu'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: TextEditingController(text: _selectedTicketType),
                  label: 'Loại Vé *',
                  icon: Icons.confirmation_number,
                  readOnly: true,
                  onTap:
                      () => _showBottomSheet(
                        context,
                        _ticketTypes,
                        'Chọn loại vé',
                        (value, [extra]) =>
                            setState(() => _selectedTicketType = value),
                      ),
                  validator:
                      (value) =>
                          _selectedTicketType == null
                              ? 'Vui lòng chọn loại vé'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Họ Tên *',
                  icon: Icons.person,
                  validator:
                      (value) => value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration(
                    label: 'Số Điện Thoại *',
                    icon: Icons.phone,
                    suffixIcon: const Icon(
                      Icons.phone_iphone,
                      color: Colors.grey,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    _PhoneNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
                    if (!RegExp(r'^\d{4} \d{3} \d{3}$').hasMatch(value)) {
                      return 'Số điện thoại phải có 10 số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageController,
                  label: 'Độ Tuổi *',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập độ tuổi';
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 120) {
                      return 'Độ tuổi phải từ 0 đến 120';
                    }
                    return null;
                  },
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.blue.shade700),
                        onPressed: () {
                          int currentAge =
                              int.tryParse(_ageController.text) ?? 0;
                          if (currentAge > 0) {
                            setState(() {
                              _ageController.text = (currentAge - 1).toString();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue.shade700),
                        onPressed: () {
                          int currentAge =
                              int.tryParse(_ageController.text) ?? 0;
                          setState(() {
                            _ageController.text = (currentAge + 1).toString();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children:
                      _presetAges
                          .map(
                            (age) => ChoiceChip(
                              label: Text('$age'),
                              selected: _ageController.text == age.toString(),
                              onSelected: (selected) {
                                if (selected) _setAge(age);
                              },
                              selectedColor: Colors.blue.shade100,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color:
                                    _ageController.text == age.toString()
                                        ? Colors.blue.shade900
                                        : Colors.grey.shade700,
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(
                    label: 'Email *',
                    icon: Icons.email,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 10.0),
                      child: GestureDetector(
                        onTap: _appendGmailSuffix,
                        child: Text(
                          '@gmail.com',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập email';
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    // icon: Icon(Icons.arrow_right_sharp, color: Colors.white, size: 30,),
                    onPressed: _createTicket,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text(
                      'Tạo vé',
                      style: TextStyle(
                        fontSize: 18,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _buildInputDecoration(
        label: label,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(' ', '');
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 4 || i == 7) {
        formatted += ' ';
      }
      formatted += newText[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
